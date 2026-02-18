#!/usr/bin/env bash
# auth-refresh.sh — OAuth token refresh guidance for Volvo Connected Vehicle API
#
# The Volvo ID OAuth2 flow requires a browser-based login and cannot be fully
# automated without a client_secret (which is tied to your registered app).
# This script prints the steps needed to obtain a fresh access token.

set -euo pipefail

cat <<'EOF'
=== Volvo Connected Vehicle API — Token Refresh ===

Your VOLVO_ACCESS_TOKEN has expired or is missing. Follow these steps to
obtain a new one:

1. Go to the Volvo Developer Portal:
   https://developer.volvocars.com

2. Log in and open your application settings.

3. Use the OAuth2 Authorization Code flow to get a new access token.
   The portal documents the required endpoints:
     - Authorization: https://volvoid.eu.volvocars.com/as/authorization.oauth2
     - Token:         https://volvoid.eu.volvocars.com/as/token.oauth2

4. Request the scopes your application needs. Common scopes:
     conve:vehicle_relation        — list vehicles, get details
     conve:diagnostics_engine_status — engine status
     conve:diagnostics_workshop    — diagnostics, brakes
     conve:fuel_status             — fuel level
     conve:odometer_status         — odometer
     conve:tyre_status             — tyre pressure
     conve:environment             — statistics
     conve:windows_status          — windows
     conve:door_and_lock_status    — doors and locks
     conve:warnings                — warnings
     conve:commands                — remote commands
     conve:lock                    — lock/unlock
     conve:engine_status           — engine start/stop
     conve:climate_status          — climatisation

5. Copy the new access token and update your .env file:
     VOLVO_ACCESS_TOKEN=<your-new-token>

Note: Automated refresh is not possible without a client_secret stored
server-side. This is a manual step by design.
EOF

exit 0
