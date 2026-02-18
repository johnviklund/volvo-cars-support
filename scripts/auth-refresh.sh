#!/usr/bin/env bash
# auth-refresh.sh — OAuth2 token refresh for Volvo Connected Vehicle API
#
# Refreshes the access token using the refresh_token grant type.
# Can be sourced (exposes do_token_refresh and update_env_var) or run standalone.
#
# Required environment variables (or in .env):
#   VOLVO_CLIENT_ID      - OAuth2 client ID from your Volvo developer app
#   VOLVO_CLIENT_SECRET   - OAuth2 client secret
#   VOLVO_REFRESH_TOKEN   - Refresh token from initial Authorization Code flow
#
# On success: updates .env with new VOLVO_ACCESS_TOKEN (and VOLVO_REFRESH_TOKEN
# if the server rotates it), and exports the values into the current shell.

set -euo pipefail

TOKEN_ENDPOINT="https://volvoid.eu.volvocars.com/as/token.oauth2"

# Resolve project root (works whether sourced or executed)
_AUTH_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
_ENV_FILE="${_AUTH_SCRIPT_DIR}/.env"

# --- update_env_var: atomically update or add a variable in .env ---
# Usage: update_env_var VAR_NAME "new_value"
update_env_var() {
  local var_name="$1"
  local var_value="$2"
  local env_file="${_ENV_FILE}"

  if [ ! -f "$env_file" ]; then
    echo "${var_name}=${var_value}" > "$env_file"
    chmod 600 "$env_file"
    return
  fi

  local tmp_file
  tmp_file="$(mktemp "${env_file}.XXXXXX")"

  if grep -q "^${var_name}=" "$env_file" 2>/dev/null; then
    sed "s|^${var_name}=.*|${var_name}=${var_value}|" "$env_file" > "$tmp_file"
  else
    cp "$env_file" "$tmp_file"
    echo "${var_name}=${var_value}" >> "$tmp_file"
  fi

  mv "$tmp_file" "$env_file"
  chmod 600 "$env_file"
}

# --- do_token_refresh: exchange refresh token for a new access token ---
# Returns 0 on success, 1 on failure.
# On success, VOLVO_ACCESS_TOKEN (and potentially VOLVO_REFRESH_TOKEN) are
# updated in .env and exported into the current shell.
do_token_refresh() {
  # Load .env if variables aren't already set
  if [ -z "${VOLVO_CLIENT_ID:-}" ] || [ -z "${VOLVO_CLIENT_SECRET:-}" ] || [ -z "${VOLVO_REFRESH_TOKEN:-}" ]; then
    if [ -f "$_ENV_FILE" ]; then
      set -a
      source "$_ENV_FILE"
      set +a
    fi
  fi

  if [ -z "${VOLVO_CLIENT_ID:-}" ]; then
    echo "Error: VOLVO_CLIENT_ID is not set." >&2
    echo "Run ./scripts/auth-init.sh to set up authentication." >&2
    return 1
  fi

  if [ -z "${VOLVO_CLIENT_SECRET:-}" ]; then
    echo "Error: VOLVO_CLIENT_SECRET is not set." >&2
    echo "Run ./scripts/auth-init.sh to set up authentication." >&2
    return 1
  fi

  if [ -z "${VOLVO_REFRESH_TOKEN:-}" ]; then
    echo "Error: VOLVO_REFRESH_TOKEN is not set." >&2
    echo "Run ./scripts/auth-init.sh to authenticate and obtain tokens." >&2
    return 1
  fi

  echo "Refreshing access token..." >&2

  local response
  response="$(curl -s -X POST "$TOKEN_ENDPOINT" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=refresh_token" \
    -d "client_id=${VOLVO_CLIENT_ID}" \
    -d "client_secret=${VOLVO_CLIENT_SECRET}" \
    -d "refresh_token=${VOLVO_REFRESH_TOKEN}")"

  local new_access_token
  new_access_token="$(echo "$response" | jq -r '.access_token // empty')"

  if [ -z "$new_access_token" ]; then
    local error_desc
    error_desc="$(echo "$response" | jq -r '.error_description // .error // "Unknown error"')"
    echo "Error: Token refresh failed — ${error_desc}" >&2
    echo "Run ./scripts/auth-init.sh to re-authenticate." >&2
    return 1
  fi

  # Update access token
  update_env_var "VOLVO_ACCESS_TOKEN" "$new_access_token"
  export VOLVO_ACCESS_TOKEN="$new_access_token"

  # Update refresh token if rotated
  local new_refresh_token
  new_refresh_token="$(echo "$response" | jq -r '.refresh_token // empty')"
  if [ -n "$new_refresh_token" ] && [ "$new_refresh_token" != "${VOLVO_REFRESH_TOKEN}" ]; then
    update_env_var "VOLVO_REFRESH_TOKEN" "$new_refresh_token"
    export VOLVO_REFRESH_TOKEN="$new_refresh_token"
    echo "Refresh token rotated and saved." >&2
  fi

  echo "Access token refreshed successfully." >&2
  return 0
}

# --- Run standalone if executed directly ---
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  do_token_refresh
fi
