-- Creates the French catalogue, product, and plan, and the PrimaryFR nav
-- menu that points at it -- mirrors seed-arabic-catalogue.sql. The
-- product's path starts with "fr-" (catalogue.tmpl uses this prefix to
-- show only French products in the French catalogue).
--
-- Run themes/seed-french-api.sh BEFORE this script -- it creates the two
-- policies ("Default Security Policy (FR)" and its Product policy) this
-- script looks up by name below. This catalogue shares the same backing
-- Httpbin API as every other language, since it's the same upstream
-- service (see themes/seed-french-api.sh).

SELECT api_id AS fr_api_id FROM tyk_apis WHERE name = 'Httpbin' LIMIT 1 \gset
SELECT _id AS fr_policy_id FROM tyk_policies WHERE name = 'Default Security Policy (FR)' LIMIT 1 \gset
SELECT _id AS fr_product_policy_id FROM tyk_policies WHERE name = 'fr-weather-sample-api' LIMIT 1 \gset

INSERT INTO catalogues (created_at, updated_at, cid, name, path, visibility_status)
VALUES (now(), now(), 'FRCATALOGUE0000000000001', 'Catalogue public - Français', 'public-catalogue-fr', 'Public')
RETURNING id AS fr_catalogue_id \gset

-- reference_id links this row to the Product policy above, connecting
-- this Catalogue Product to its Dashboard-managed access policy.
--
-- name/path match the Product policy's own name plus its provider
-- suffix, keeping the product's URL stable and predictable. display_name
-- (the customer-facing name shown throughout the Portal) is independent
-- of this and carries the translated name.
INSERT INTO products (created_at, updated_at, cid, name, display_name, path, description, content, auth_type, provider_id, is_documentation_only, feature, dcr_enabled, webhooks_enabled, cert_token_binding_enabled, reference_id)
VALUES (now(), now(), 'FRPRODUCT00000000000001', 'fr-weather-sample-api', 'API Météo exemple', 'fr-weather-sample-api-1',
        'Un exemple de produit API de démonstration pour tester le parcours complet, de la recherche à l''émission des identifiants. Les requêtes sont transmises à httpbin.org via une API sandbox de démonstration.',
        'Ce produit API de démonstration a été créé pour tester de bout en bout la navigation dans le catalogue, les demandes d''accès et l''émission des identifiants. Il ne s''agit pas d''une véritable API météo -- les requêtes sont transmises à httpbin.org.',
        'authToken', 1, false, false, false, false, false, :'fr_product_policy_id')
RETURNING id AS fr_product_id \gset

INSERT INTO api_details (api_id, name, description, target_url, listen_path, api_type, product_id, status, auth_type)
VALUES (:'fr_api_id', 'API Météo exemple', 'Transmise à httpbin.org à des fins de démonstration.', 'https://httpbin.org', '/httpbin', 'REST', :fr_product_id, true, 'authToken');

-- A dedicated Plan row, not a reuse of the English or Arabic ones -- each
-- language's plan carries its own translated name and description.
INSERT INTO plans (created_at, updated_at, cid, name, display_name, reference_id, description, auth_type, rate, per, quota_max, quota_renewal_rate, auto_approve_access_requests, provider_id, unlimited_quota, unlimited_rate_limit)
VALUES (now(), now(), 'FRPLAN00000000000000001', 'Basique', 'Plan Basique', :'fr_policy_id',
        'Accès de démonstration illimité -- approuvé automatiquement afin que le parcours de démonstration se termine sans étape d''approbation manuelle.', 'authToken', 2, 10, -1, -1, true, 1, true, false)
RETURNING id AS fr_plan_id \gset

INSERT INTO catalogue_products (catalogue_id, product_id) VALUES (:fr_catalogue_id, :fr_product_id);
INSERT INTO catalogue_plans (catalogue_id, plan_id) VALUES (:fr_catalogue_id, :fr_plan_id);

-- PrimaryFR nav menu -- top_nav.tmpl picks this over Primary when $lang=fr
-- (via the $menuSuffixes dict -> "Primary" + "FR").
INSERT INTO menus (created_at, updated_at, cid, name, path)
VALUES (now(), now(), 'FRMENU00000000000000001', 'PrimaryFR', 'PrimaryFR')
RETURNING id AS fr_menu_id \gset

INSERT INTO menu_items (created_at, updated_at, cid, title, path, position, menu_id) VALUES
(now(), now(), 'FRMENUITEM0000000000001', 'Catalogues', '/portal/catalogue-products?catalogue=' || :fr_catalogue_id, 1, :fr_menu_id),
(now(), now(), 'FRMENUITEM0000000000002', 'Blog', '/blog', 2, :fr_menu_id),
(now(), now(), 'FRMENUITEM0000000000003', 'À propos', '/fr/about-us', 3, :fr_menu_id);

SELECT :fr_catalogue_id AS fr_catalogue_id, :fr_product_id AS fr_product_id, :fr_plan_id AS fr_plan_id, :fr_menu_id AS fr_menu_id;
