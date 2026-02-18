#!/bin/bash
# Usage: graphql-introspect.sh
# Runs a full introspection query against the Volvo Support Content Service GraphQL API.
# Outputs all types, their fields, arguments, and enum values.

set -euo pipefail

ENDPOINT="https://support-content-service.weu-prod.ecpaz.volvocars.biz/api/graphql"

QUERY='{ __schema { queryType { name fields { name args { name type { name kind ofType { name kind ofType { name kind } } } } type { name kind ofType { name kind ofType { name kind } } } } } types { name kind description fields { name description args { name description type { name kind ofType { name kind ofType { name kind } } } } type { name kind ofType { name kind ofType { name kind } } } } enumValues { name description } } } }'

curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$QUERY" '{query: $q}')" \
  | jq .
