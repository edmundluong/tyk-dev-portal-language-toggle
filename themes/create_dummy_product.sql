-- Seeds a sample Catalogue Product ("Weather Sample API") backed by the
-- Httpbin API and the two policies (Product/ACL + Plan/quota-rate-limit)
-- that `make bootstrap` already creates in the Dashboard, plus the
-- Provider record connecting the Portal to that Dashboard. Everything
-- below is looked up dynamically (organisation, API, policies, and
-- Dashboard API key) rather than hardcoded, so this runs correctly
-- against any fresh `make bootstrap`.
--
-- The Provider's `type` ("tyk-pro") and its `provider_configs.meta_data`
-- shape (URL/Secret/OrgID/Gateway/PoliciesTags/InsecureSkipVerify) match
-- what the Admin App's own "Add Provider" form
-- (/admin/providers/new) produces.

SELECT _id AS org_id FROM tyk_organisations LIMIT 1 \gset
SELECT api_id AS httpbin_api_id FROM tyk_apis WHERE name = 'Httpbin' LIMIT 1 \gset
-- up.sh creates two policies for Httpbin -- a Product (ACL) policy and a
-- Plan (quota/rate limit) policy -- matched here by exact name.
SELECT _id AS httpbin_policy_id FROM tyk_policies WHERE org_id = :'org_id' AND name = 'Default Security Policyy' LIMIT 1 \gset
SELECT _id AS httpbin_product_policy_id FROM tyk_policies WHERE org_id = :'org_id' AND name = 'weather-sample-api' LIMIT 1 \gset
SELECT accesskey AS dashboard_api_key FROM tyk_analytics_users WHERE emailaddress = 'dev@tyk.io' LIMIT 1 \gset

INSERT INTO providers (created_at, updated_at, cid, name, type, status)
VALUES (now(), now(), 'MOCKPROVIDER00000000001', 'Local Dashboard', 'tyk-pro', 'active')
RETURNING id AS provider_id \gset

INSERT INTO provider_configs (created_at, updated_at, meta_data, provider_id)
VALUES (now(), now(), json_build_object(
    'URL', 'http://tyk-dashboard:3000',
    'Secret', :'dashboard_api_key',
    'OrgID', :'org_id',
    'Gateway', '',
    'PoliciesTags', '[]'::json,
    'InsecureSkipVerify', false
  )::text, :provider_id);

-- reference_id links this row to the Product policy above, connecting
-- this Catalogue Product to its Dashboard-managed access policy.
--
-- name/path match the Product policy's own name plus its provider
-- suffix, keeping the product's URL stable and predictable. display_name
-- (the customer-facing name shown throughout the Portal) is independent
-- of this and carries the human-readable name.
INSERT INTO products (created_at, updated_at, cid, name, display_name, path, description, content, auth_type, provider_id, is_documentation_only, feature, dcr_enabled, webhooks_enabled, cert_token_binding_enabled, reference_id)
VALUES (now(), now(), 'MOCKPRODUCT00000000001', 'weather-sample-api', 'Weather Sample API', 'weather-sample-api-1',
        'A sample API product for trying the full browse-to-credential flow. Backed by httpbin.org via the demo Httpbin API/policy created at bootstrap.',
        'This is a sample API product for exercising catalogue browsing, access requests, and credential issuance end to end. It is not a real weather API -- calls are proxied to httpbin.org.',
        'authToken', :provider_id, false, false, false, false, false, :'httpbin_product_policy_id')
RETURNING id AS product_id \gset

INSERT INTO api_details (api_id, name, description, target_url, listen_path, api_type, product_id, status, auth_type)
VALUES (:'httpbin_api_id', 'Weather Sample API', 'Proxies to httpbin.org for demo purposes.', 'https://httpbin.org', '/httpbin', 'REST', :product_id, true, 'authToken');

INSERT INTO plans (created_at, updated_at, cid, name, display_name, reference_id, description, auth_type, rate, per, quota_max, quota_renewal_rate, auto_approve_access_requests, provider_id, unlimited_quota, unlimited_rate_limit)
VALUES (now(), now(), 'MOCKPLAN00000000000001', 'Basic', 'Basic Plan', :'httpbin_policy_id',
        'Unlimited demo access -- auto-approved so the demo flow completes without a manual approval step.', 'authToken', 2, 10, -1, -1, true, :provider_id, true, false)
RETURNING id AS plan_id \gset

INSERT INTO catalogue_products (catalogue_id, product_id) VALUES (1, :product_id);
INSERT INTO catalogue_plans (catalogue_id, plan_id) VALUES (1, :plan_id);

SELECT :product_id AS product_id, :plan_id AS plan_id, :provider_id AS provider_id;
