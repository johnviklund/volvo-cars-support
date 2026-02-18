#!/bin/bash
# Usage: graphql-query.sh '<graphql-query-string>'
# Posts a GraphQL query to the Volvo Support Content Service and pretty-prints the response.
#
# Examples:
#   ./scripts/graphql-query.sh '{ markets { id caption } }'
#   ./scripts/graphql-query.sh '{ market(id: "se") { cars { displayName modelYear } } }'

set -euo pipefail

ENDPOINT="https://support-content-service.weu-prod.ecpaz.volvocars.biz/api/graphql"

if [ $# -eq 0 ]; then
  echo "Usage: graphql-query.sh '<graphql-query-string>'" >&2
  exit 1
fi

QUERY="$1"

curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$QUERY" '{query: $q}')" \
  | jq .
