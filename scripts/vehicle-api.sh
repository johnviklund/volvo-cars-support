#!/bin/bash
# Usage: vehicle-api.sh <GET|POST> <path> [body]
# Wrapper for the Volvo Connected Vehicle API v2.
#
# Requires environment variables:
#   VCC_API_KEY          - Your primary Volvo Cars API key (from developer.volvocars.com)
#
# For token refresh (recommended):
#   VOLVO_CLIENT_ID      - OAuth2 client ID
#   VOLVO_CLIENT_SECRET  - OAuth2 client secret
#   VOLVO_REFRESH_TOKEN  - Refresh token from initial auth flow
#
# Optional environment variables:
#   VOLVO_ACCESS_TOKEN     - OAuth2 Bearer token (auto-refreshed if refresh credentials are set)
#   VOLVO_VIN              - Default VIN; auto-substituted into {vin} path segments
#   VCC_API_KEY_SECONDARY  - Secondary API key; used as fallback on 429
#
# Examples:
#   ./scripts/vehicle-api.sh GET /vehicles
#   ./scripts/vehicle-api.sh GET /vehicles/{vin}/doors
#   ./scripts/vehicle-api.sh POST /vehicles/{vin}/commands/lock

set -euo pipefail

# Load .env if present (auto-export so vars are available without export prefixes)
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
  set -a
  source "$SCRIPT_DIR/.env"
  set +a
fi

# Source auth-refresh.sh to make do_token_refresh() available
source "$(dirname "$0")/auth-refresh.sh"

BASE_URL="https://api.volvocars.com/connected-vehicle/v2"

if [ -z "${VCC_API_KEY:-}" ]; then
  echo "Error: VCC_API_KEY environment variable is not set." >&2
  echo "Get your API key at https://developer.volvocars.com" >&2
  exit 1
fi

# If no access token, attempt a refresh before failing
if [ -z "${VOLVO_ACCESS_TOKEN:-}" ]; then
  if ! do_token_refresh; then
    echo "Error: VOLVO_ACCESS_TOKEN is not set and token refresh failed." >&2
    echo "Run ./scripts/auth-init.sh to authenticate." >&2
    exit 1
  fi
fi

if [ $# -lt 2 ]; then
  echo "Usage: vehicle-api.sh <GET|POST> <path> [body]" >&2
  exit 1
fi

METHOD="$1"
PATH_SEGMENT="$2"
BODY="${3:-}"

# --- VIN substitution ---
if [[ "$PATH_SEGMENT" == *"{vin}"* ]]; then
  if [ -z "${VOLVO_VIN:-}" ]; then
    echo "Error: Path contains {vin} but VOLVO_VIN is not set." >&2
    echo "Set VOLVO_VIN or replace {vin} with an actual VIN." >&2
    exit 1
  fi
  PATH_SEGMENT="${PATH_SEGMENT//\{vin\}/$VOLVO_VIN}"
fi

# --- Helper: make a curl request with a given API key ---
do_request() {
  local api_key="$1"

  local curl_args=(
    -s
    -w "\n%{http_code}"
    -X "$METHOD"
    -H "vcc-api-key: $api_key"
    -H "Authorization: Bearer $VOLVO_ACCESS_TOKEN"
    -H "Content-Type: application/json"
    -H "Accept: application/json"
  )

  if [ -n "$BODY" ]; then
    curl_args+=(-d "$BODY")
  fi

  curl "${curl_args[@]}" "${BASE_URL}${PATH_SEGMENT}"
}

# --- Primary request ---
RESPONSE="$(do_request "$VCC_API_KEY")"
HTTP_CODE="${RESPONSE##*$'\n'}"
RESPONSE_BODY="${RESPONSE%$'\n'"$HTTP_CODE"}"

# --- On 401: attempt token refresh and retry ---
if [[ "$HTTP_CODE" == "401" ]]; then
  echo "HTTP 401 — attempting token refresh..." >&2
  if do_token_refresh; then
    RESPONSE="$(do_request "$VCC_API_KEY")"
    HTTP_CODE="${RESPONSE##*$'\n'}"
    RESPONSE_BODY="${RESPONSE%$'\n'"$HTTP_CODE"}"
  fi
fi

# --- Failover to secondary key on 429 ---
if [[ "$HTTP_CODE" == "429" ]] && [ -n "${VCC_API_KEY_SECONDARY:-}" ]; then
  echo "Primary key returned HTTP 429 — retrying with secondary key..." >&2
  RESPONSE="$(do_request "$VCC_API_KEY_SECONDARY")"
  HTTP_CODE="${RESPONSE##*$'\n'}"
  RESPONSE_BODY="${RESPONSE%$'\n'"$HTTP_CODE"}"
fi

echo "$RESPONSE_BODY" | jq .
