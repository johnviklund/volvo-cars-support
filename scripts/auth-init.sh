#!/usr/bin/env bash
# auth-init.sh — One-time OAuth2 Authorization Code flow for Volvo Connected Vehicle API
#
# Walks you through the full OAuth2 flow:
#   1. Validates VOLVO_CLIENT_ID and VOLVO_CLIENT_SECRET in .env
#   2. Opens the authorization URL in your browser
#   3. Prompts you to paste the authorization code
#   4. Exchanges the code for access_token + refresh_token
#   5. Saves tokens to .env
#
# After running this once, use auth-refresh.sh to renew tokens automatically.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

AUTH_ENDPOINT="https://volvoid.eu.volvocars.com/as/authorization.oauth2"
TOKEN_ENDPOINT="https://volvoid.eu.volvocars.com/as/token.oauth2"
REDIRECT_URI="https://localhost:8080/callback"

ALL_SCOPES="openid conve:vehicle_relation conve:diagnostics_engine_status conve:diagnostics_workshop conve:fuel_status conve:odometer_status conve:tyre_status conve:environment conve:windows_status conve:door_and_lock_status conve:warnings conve:commands conve:lock conve:engine_status conve:climate_status"

# Source auth-refresh.sh for update_env_var()
source "$(dirname "$0")/auth-refresh.sh"

# --- Load .env ---
if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
fi

# --- Validate client credentials ---
if [ -z "${VOLVO_CLIENT_ID:-}" ]; then
  echo "Error: VOLVO_CLIENT_ID is not set." >&2
  echo "" >&2
  echo "Add your OAuth2 client credentials to ${ENV_FILE}:" >&2
  echo "  VOLVO_CLIENT_ID=your-client-id" >&2
  echo "  VOLVO_CLIENT_SECRET=your-client-secret" >&2
  echo "" >&2
  echo "Get these from your app at https://developer.volvocars.com" >&2
  exit 1
fi

if [ -z "${VOLVO_CLIENT_SECRET:-}" ]; then
  echo "Error: VOLVO_CLIENT_SECRET is not set." >&2
  echo "" >&2
  echo "Add your client secret to ${ENV_FILE}:" >&2
  echo "  VOLVO_CLIENT_SECRET=your-client-secret" >&2
  exit 1
fi

# --- Build authorization URL ---
ENCODED_SCOPES="${ALL_SCOPES// /+}"
AUTH_URL="${AUTH_ENDPOINT}?response_type=code&client_id=${VOLVO_CLIENT_ID}&redirect_uri=${REDIRECT_URI}&scope=${ENCODED_SCOPES}"

echo "=== Volvo Connected Vehicle API — Authorization Setup ==="
echo ""
echo "Opening your browser to authorize the application..."
echo ""
echo "If the browser doesn't open, visit this URL manually:"
echo "  ${AUTH_URL}"
echo ""

# Open browser (macOS: open, Linux: xdg-open)
if command -v open &>/dev/null; then
  open "$AUTH_URL"
elif command -v xdg-open &>/dev/null; then
  xdg-open "$AUTH_URL"
fi

echo "After authorizing, you'll be redirected to a URL like:"
echo "  ${REDIRECT_URI}?code=AUTHORIZATION_CODE"
echo ""
echo "Paste the authorization code (or the full callback URL) below."
echo ""
read -rp "Authorization code: " USER_INPUT

if [ -z "$USER_INPUT" ]; then
  echo "Error: No authorization code provided." >&2
  exit 1
fi

# Extract code from full URL or use as-is
AUTH_CODE="$USER_INPUT"
if [[ "$USER_INPUT" == *"code="* ]]; then
  # Extract code parameter from URL
  AUTH_CODE="$(echo "$USER_INPUT" | sed -n 's/.*[?&]code=\([^&]*\).*/\1/p')"
  if [ -z "$AUTH_CODE" ]; then
    echo "Error: Could not extract authorization code from URL." >&2
    exit 1
  fi
fi

echo ""
echo "Exchanging authorization code for tokens..."

# --- Exchange code for tokens ---
RESPONSE="$(curl -s -X POST "$TOKEN_ENDPOINT" \
  -u "${VOLVO_CLIENT_ID}:${VOLVO_CLIENT_SECRET}" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code" \
  -d "code=${AUTH_CODE}" \
  -d "redirect_uri=${REDIRECT_URI}")"

ACCESS_TOKEN="$(echo "$RESPONSE" | jq -r '.access_token // empty')"
REFRESH_TOKEN="$(echo "$RESPONSE" | jq -r '.refresh_token // empty')"

if [ -z "$ACCESS_TOKEN" ]; then
  ERROR_DESC="$(echo "$RESPONSE" | jq -r '.error_description // .error // empty')"
  echo "Error: Token exchange failed." >&2
  if [ -n "$ERROR_DESC" ]; then
    echo "  ${ERROR_DESC}" >&2
  else
    echo "  Response: ${RESPONSE}" >&2
  fi
  exit 1
fi

# --- Save tokens to .env ---
update_env_var "VOLVO_ACCESS_TOKEN" "$ACCESS_TOKEN"
export VOLVO_ACCESS_TOKEN="$ACCESS_TOKEN"

if [ -n "$REFRESH_TOKEN" ]; then
  update_env_var "VOLVO_REFRESH_TOKEN" "$REFRESH_TOKEN"
  export VOLVO_REFRESH_TOKEN="$REFRESH_TOKEN"
fi

chmod 600 "$ENV_FILE"

echo ""
echo "Authentication successful!"
echo "  Access token saved to .env"
if [ -n "$REFRESH_TOKEN" ]; then
  echo "  Refresh token saved to .env"
  echo ""
  echo "Tokens will be refreshed automatically when they expire."
else
  echo ""
  echo "Warning: No refresh token received. You may need to re-run this script when the token expires."
fi
echo ""
echo "You're ready to use the Connected Vehicle API."
