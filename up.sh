#!/bin/bash

# Path to the .env file
env_file=".env"

# Check if the .env file exists
if [ -f "$env_file" ]; then
    echo ".env file already exists. Skipping creation."
else
    # The .env file does not exist, seed it from .env.example so version
    # pins stay consistent regardless of which onboarding path is used
    echo "Creating .env file from .env.example..."
    cp .env.example "$env_file"

    read -n2048 -s -p 'Please enter your Tyk Pro License key: ' license_key
    echo

    sed -i.bak "s|^DASH_LICENSE=.*|DASH_LICENSE=$license_key|" "$env_file"
    rm -f "$env_file.bak"
    echo ".env file created and license key set."
fi

echo "Bringing your local Tyk environment up..."
docker compose up -d
if [ $? -ne 0 ]; then
    echo "docker compose up failed"
    exit 1
fi

# Resolve the actual published host ports for tyk-dashboard/tyk-gateway via
# `docker compose port` rather than hardcoding localhost:3000/8080 -- if
# docker-compose.yml's ports are ever remapped (e.g. a port is already in
# use on your machine), hardcoded ports here would silently bootstrap
# whatever else is listening on 3000/8080 instead of this stack.
dash_host=$(docker compose port tyk-dashboard 3000 2>/dev/null)
gw_host=$(docker compose port tyk-gateway 8080 2>/dev/null)
if [ -z "$dash_host" ] || [ -z "$gw_host" ]; then
    echo "Could not resolve published ports for tyk-dashboard/tyk-gateway via 'docker compose port' -- is the stack up?"
    exit 1
fi
DASH_URL="http://${dash_host}"
GW_URL="http://${gw_host}"

status=""
desired_status="200"
attempt_count=0
attempt_max=60

echo "Waiting for Tyk Dashboard to become ready (up to $((attempt_max * 2))s, first run may need to pull images)..."
while [ "$status" != "$desired_status" ] && [ $attempt_count -le $attempt_max ]
do
    status=$(curl -s -o /dev/null -I -w "%{http_code}" $DASH_URL/hello)

    if [ $attempt_count -eq $attempt_max ]; then
        echo "    Attempt $attempt_count of $attempt_max unsuccessful, received '$status'"
    fi
    attempt_count=$((attempt_count + 1))
    sleep 2
done

# Bootstrapping (org + user + sample API) is a one-time operation per Dashboard
# database. Running it again on a later `make up`/`make bootstrap` against the
# same, still-populated Postgres volume creates a *second* org with the same
# owner_name and a second `dev@tyk.io` user rather than updating the first —
# whichever org a browser session then resolves to may not be the one your
# tooling is actually using. Reuse the key already in .env if it still
# authenticates; only bootstrap from scratch if it doesn't (fresh volume).
existing_key=$(grep '^DASHBOARD_API_KEY=' "$env_file" | cut -d'=' -f2-)
if [ -n "$existing_key" ] && [ "$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: $existing_key" $DASH_URL/api/apis)" = "200" ]; then
    echo "Dashboard already bootstrapped and DASHBOARD_API_KEY in .env is still valid. Skipping org/user/sample-API creation."
    user_api_key="$existing_key"
else
    echo "Tyk configured. Bootstrapping environment..."

    # Create default Org
    createOrgResponse=$(curl -s --location "$DASH_URL/admin/organisations/" \
                            --header 'admin-auth: 12345' \
                            --header 'Content-Type: application/json' \
                            --data '{
                                "owner_name": "Tyk",
                                "cname_enabled": true,
                                "event_options": {
                                    "hashed_key_event": {
                                        "redis": true
                                    },
                                    "key_event": {
                                        "redis": true
                                    }
                                },
                                "hybrid_enabled": true
                            }')

    orgId=$(echo "$createOrgResponse" | awk -F'"' '/"Meta":/{print $(NF-1)}')
    echo "Created org"


    # Create default user
    createUserResponse=$(curl -s --location "$DASH_URL/admin/users/" \
    --header 'Content-Type: application/json' \
    --header 'admin-auth: 12345' \
    --data-raw '{
      "org_id": "'$orgId'",
      "first_name": "Tyk",
      "last_name": "Admin",
      "email_address": "dev@tyk.io",
      "active": true,
      "user_permissions": { "IsAdmin": "admin" }
    }')
    user_id=$(echo "$createUserResponse" | awk -F'"id":"' '{split($2,a,"\""); print a[1]}')
    user_api_key=$(echo "$createUserResponse" | awk -F'"access_key":"' '{split($2,a,"\""); print a[1]}')
    echo "Created default user"

    # Persist the API key so other tooling (e.g. `make sync`/`make dump`) can
    # authenticate against the Dashboard API without it being pasted in by hand
    sed -i.bak "/^DASHBOARD_API_KEY=/d" "$env_file"
    echo "DASHBOARD_API_KEY=$user_api_key" >> "$env_file"
    rm -f "$env_file.bak"

    # Reset User Password
    curl -s -o /dev/null --location "$DASH_URL/api/users/$user_id/actions/reset" \
    --header 'Content-Type: application/json' \
    --header 'authorization: '$user_api_key \
    --data '{
      "new_password":"secret",
      "user_permissions": { "IsAdmin": "admin" }
    }'
    echo "Created user password"


    # Creates a Tyk OAS API Definition (an OpenAPI 3.x document plus the
    # x-tyk-api-gateway vendor extension for gateway configuration).
    # Authentication is declared using the standards-based
    # components.securitySchemes (bound through
    # x-tyk-api-gateway.server.authentication.securitySchemes) -- the
    # recommended approach for OAS APIs, since it keeps the API's
    # authentication method clearly represented wherever it's referenced,
    # including in the Developer Portal's product catalogue.
    createApiResponse=$(curl -s --location "$DASH_URL/api/apis/oas" \
    --header 'authorization: '$user_api_key'' \
    --header 'Content-Type: application/json' \
    --data '{
      "openapi": "3.0.3",
      "info": {
          "title": "Httpbin",
          "version": "1.0.0"
      },
      "paths": {},
      "components": {
          "securitySchemes": {
              "authorization": {
                  "type": "apiKey",
                  "name": "authorization",
                  "in": "header"
              }
          }
      },
      "security": [
          { "authorization": [] }
      ],
      "x-tyk-api-gateway": {
          "info": {
              "name": "Httpbin",
              "state": {
                  "active": true
              }
          },
          "upstream": {
              "url": "https://httpbin.org"
          },
          "server": {
              "listenPath": {
                  "value": "/httpbin",
                  "strip": true
              },
              "authentication": {
                  "enabled": true,
                  "securitySchemes": {
                      "authorization": {
                          "enabled": true,
                          "header": {
                              "enabled": true,
                              "name": "authorization"
                          }
                      }
                  }
              }
          }
      }
    }')
    apiId=$(echo "$createApiResponse" | awk -F'"' '/"ID":/{print $(NF-1)}')
    echo "Created Httpbin sample API (OAS)"

    # Two Dashboard Policies represent this API in the Developer Portal's
    # catalogue: a Product policy (API access/ACL) and a Plan policy
    # (quota and rate limit). This mirrors how Tyk's own reference
    # configurations model a catalogue product, and keeps access rights
    # and usage limits independently manageable.

    # Product policy: grants API access (ACL), used as the Catalogue
    # Product's reference_id below. Its name becomes the product's URL
    # path once synced into the Portal, so it's named deliberately here
    # to match the desired catalogue path from the start.
    createProductPolicyResponse=$(curl -s --location "$DASH_URL/api/portal/policies/" \
    --header 'Authorization: '$user_api_key'' \
    --header 'Content-Type: application/json' \
    --data '{
        "access_rights": {
            "'$apiId'": {
                "allowed_urls": [],
                "api_id": "'$apiId'",
                "api_name": "Httpbin",
                "limit": null,
                "versions": [
                    "Default"
                ]
            }
        },
        "active": true,
        "name": "weather-sample-api",
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
    echo "Created HttpBin Product Policy"

    # Plan policy: quota + rate limit, used as the Catalogue Plan's
    # reference_id -- same name as before ("Default Security Policyy"), so
    # anything already looking it up by that exact name keeps working.
    createPolicyResponse=$(curl -s --location "$DASH_URL/api/portal/policies/" \
    --header 'Authorization: '$user_api_key'' \
    --header 'Content-Type: application/json' \
    --data '{
        "access_rights": {
            "'$apiId'": {
                "allowed_urls": [],
                "api_id": "'$apiId'",
                "api_name": "Httpbin",
                "limit": null,
                "versions": [
                    "Default"
                ]
            }
        },
        "active": true,
        "name": "Default Security Policyy",
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
    echo "Created HttpBin Plan Policy"


    sleep 4

    # Create Httpbin API key -- applies both the Product and Plan policies
    # together, the same way a credential issued through the Developer
    # Portal's checkout flow combines a product's access policy with a
    # plan's quota/rate policy.
    keyName=my_custom_key
    curl -s -o /dev/null --location "$DASH_URL/api/keys/"$keyName \
    --header 'authorization: '$user_api_key'' \
    --header 'Content-Type: application/json' \
    --data-raw '{
         "apply_policies": [
             "'$productPolicyId'",
             "'$policyId'"
         ],
        "org_id": "'$orgId'",
        "allowance": -1,
        "per": -1,
        "quota_max": -1,
        "rate": -1
    }'
    echo "Created Httpbin API Key"

    # Send a setup ping
    curl -s -o /dev/null $GW_URL/httpbin/anything/hello -H "Authorization: my_custom_key"
fi

tput setaf 2;
echo "
---------------------------
Please sign in at $DASH_URL

user: dev@tyk.io
pw: secret

Your Tyk Gateway is found at $GW_URL

Press Enter to exit"

read
