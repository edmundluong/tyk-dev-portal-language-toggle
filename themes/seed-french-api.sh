#!/bin/bash
# Creates the two Policies ("Default Security Policy (FR)" Plan +
# Product policy) the French catalogue product points at. These share the
# same backing Httpbin API that up.sh already creates for the English
# sample product -- a Gateway API represents a real upstream service, so
# it's shared across every language's catalogue product for that service;
# only the Portal-side Policy/Product/Plan/Catalogue layer is duplicated
# per language, since that's what carries the translated name,
# description, and independent access/quota control per language.
#
# Uses the Dashboard's REST API (as up.sh does), so each Policy is
# properly recorded and available to the Portal's catalogue sync.
# seed-french-catalogue.sql looks up this script's output by name
# ("Default Security Policy (FR)" / its Product policy) -- run this
# script BEFORE seed-french-catalogue.sql.
#
# Idempotent: skips creation if a policy named "fr-weather-sample-api"
# already exists.

set -e

dash_host=$(docker compose port tyk-dashboard 3000 2>/dev/null)
if [ -z "$dash_host" ]; then
  echo "Could not resolve the published port for tyk-dashboard -- is the stack up?"
  exit 1
fi
DASH_URL="http://${dash_host}"

user_api_key=$(grep '^DASHBOARD_API_KEY=' .env | cut -d'=' -f2-)
if [ -z "$user_api_key" ]; then
  echo "DASHBOARD_API_KEY not found in .env -- run 'make bootstrap' first."
  exit 1
fi

existing=$(docker compose exec -T tyk-postgres psql -U postgres -d tyk_analytics -t -A -c "SELECT 1 FROM tyk_policies WHERE name = 'fr-weather-sample-api' LIMIT 1;" 2>/dev/null)
if [ "$existing" = "1" ]; then
  echo "fr-weather-sample-api policy already exists. Skipping creation."
  exit 0
fi

orgId=$(docker compose exec -T tyk-postgres psql -U postgres -d tyk_analytics -t -A -c "SELECT _id FROM tyk_organisations LIMIT 1;" 2>/dev/null)
if [ -z "$orgId" ]; then
  echo "Could not resolve org_id."
  exit 1
fi

apiId=$(docker compose exec -T tyk-postgres psql -U postgres -d tyk_analytics -t -A -c "SELECT api_id FROM tyk_apis WHERE name = 'Httpbin' LIMIT 1;" 2>/dev/null)
if [ -z "$apiId" ]; then
  echo "Could not find the Httpbin API -- run 'make bootstrap' first."
  exit 1
fi

# Product policy: grants API access (ACL), used as the Catalogue
# Product's reference_id in seed-french-catalogue.sql. Named to match the
# desired product path from the start, the same approach up.sh uses.
createProductPolicyResponse=$(curl -s --location "$DASH_URL/api/portal/policies/" \
  --header "Authorization: $user_api_key" \
  --header 'Content-Type: application/json' \
  --data '{
      "access_rights": {
          "'$apiId'": {
              "allowed_urls": [],
              "api_id": "'$apiId'",
              "api_name": "Httpbin",
              "limit": null,
              "versions": ["Default"]
          }
      },
      "active": true,
      "name": "fr-weather-sample-api",
      "org_id": "'$orgId'",
      "per": 10,
      "rate": 2,
      "quota_max": -1,
      "quota_remaining": -1,
      "quota_renewal_rate": -1,
      "quota_renews": -1,
      "throttle_interval": -1,
      "throttle_retry_limit": -1,
      "tags": [],
      "allowance": 0,
      "auth_type": "authToken",
      "expires": 0,
      "key_expires_in": 0,
      "last_check": 0,
      "partitions": {
          "acl": true,
          "quota": false,
          "rate_limit": false,
          "complexity": false,
          "per_api": false
      }
  }')
productPolicyId=$(echo "$createProductPolicyResponse" | grep -o '"Message":"[^"]*"' | cut -d":" -f2 | tr -d '"')
if [ -z "$productPolicyId" ]; then
  echo "Failed to create fr-weather-sample-api policy: $createProductPolicyResponse"
  exit 1
fi
echo "Created fr-weather-sample-api Product policy ($productPolicyId)"

# Plan policy: quota + rate limit, used as the Catalogue Plan's
# reference_id.
createPolicyResponse=$(curl -s --location "$DASH_URL/api/portal/policies/" \
  --header "Authorization: $user_api_key" \
  --header 'Content-Type: application/json' \
  --data '{
      "access_rights": {
          "'$apiId'": {
              "allowed_urls": [],
              "api_id": "'$apiId'",
              "api_name": "Httpbin",
              "limit": null,
              "versions": ["Default"]
          }
      },
      "active": true,
      "name": "Default Security Policy (FR)",
      "org_id": "'$orgId'",
      "per": 10,
      "rate": 2,
      "quota_max": -1,
      "quota_remaining": -1,
      "quota_renewal_rate": -1,
      "quota_renews": -1,
      "throttle_interval": -1,
      "throttle_retry_limit": -1,
      "tags": [],
      "allowance": 0,
      "auth_type": "authToken",
      "expires": 0,
      "key_expires_in": 0,
      "last_check": 0,
      "partitions": {
          "acl": false,
          "quota": true,
          "rate_limit": true,
          "complexity": false,
          "per_api": false
      }
  }')
policyId=$(echo "$createPolicyResponse" | grep -o '"Message":"[^"]*"' | cut -d":" -f2 | tr -d '"')
if [ -z "$policyId" ]; then
  echo "Failed to create Default Security Policy (FR): $createPolicyResponse"
  exit 1
fi
echo "Created Default Security Policy (FR) ($policyId)"
