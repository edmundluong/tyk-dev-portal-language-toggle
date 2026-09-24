-- Creates the Spanish catalogue, product, and plan, and the PrimaryES nav
-- menu that points at it -- mirrors seed-french-catalogue.sql. The
-- product's path starts with "es-" (catalogue.tmpl uses this prefix to
-- show only Spanish products in the Spanish catalogue).
--
-- Run themes/seed-spanish-api.sh BEFORE this script -- it creates the two
-- policies ("Default Security Policy (ES)" and its Product policy) this
-- script looks up by name below. This catalogue shares the same backing
-- Httpbin API as every other language, since it's the same upstream
-- service (see themes/seed-spanish-api.sh).

SELECT api_id AS es_api_id FROM tyk_apis WHERE name = 'Httpbin' LIMIT 1 \gset
SELECT _id AS es_policy_id FROM tyk_policies WHERE name = 'Default Security Policy (ES)' LIMIT 1 \gset
SELECT _id AS es_product_policy_id FROM tyk_policies WHERE name = 'es-weather-sample-api' LIMIT 1 \gset

INSERT INTO catalogues (created_at, updated_at, cid, name, path, visibility_status)
VALUES (now(), now(), 'ESCATALOGUE0000000000001', 'Catálogo público - Español', 'public-catalogue-es', 'Public')
RETURNING id AS es_catalogue_id \gset

-- reference_id links this row to the Product policy above, connecting
-- this Catalogue Product to its Dashboard-managed access policy.
--
-- name/path match the Product policy's own name plus its provider
-- suffix, keeping the product's URL stable and predictable. display_name
-- (the customer-facing name shown throughout the Portal) is independent
-- of this and carries the translated name.
INSERT INTO products (created_at, updated_at, cid, name, display_name, path, description, content, auth_type, provider_id, is_documentation_only, feature, dcr_enabled, webhooks_enabled, cert_token_binding_enabled, reference_id)
VALUES (now(), now(), 'ESPRODUCT00000000000001', 'es-weather-sample-api', 'API Meteorológica de Ejemplo', 'es-weather-sample-api-1',
        'Un producto API de demostración de ejemplo para probar el flujo completo, desde la búsqueda hasta la emisión de credenciales. Las solicitudes se transmiten a httpbin.org a través de una API sandbox de demostración.',
        'Este producto API de demostración se creó para probar de extremo a extremo la navegación por el catálogo, las solicitudes de acceso y la emisión de credenciales. No es una API meteorológica real -- las solicitudes se transmiten a httpbin.org.',
        'authToken', 1, false, false, false, false, false, :'es_product_policy_id')
RETURNING id AS es_product_id \gset

INSERT INTO api_details (api_id, name, description, target_url, listen_path, api_type, product_id, status, auth_type)
VALUES (:'es_api_id', 'API Meteorológica de Ejemplo', 'Transmitida a httpbin.org con fines de demostración.', 'https://httpbin.org', '/httpbin', 'REST', :es_product_id, true, 'authToken');

-- A dedicated Plan row, not a reuse of the English, Arabic, or French
-- ones -- each language's plan carries its own translated name and
-- description.
INSERT INTO plans (created_at, updated_at, cid, name, display_name, reference_id, description, auth_type, rate, per, quota_max, quota_renewal_rate, auto_approve_access_requests, provider_id, unlimited_quota, unlimited_rate_limit)
VALUES (now(), now(), 'ESPLAN00000000000000001', 'Básico', 'Plan Básico', :'es_policy_id',
        'Acceso de demostración ilimitado -- aprobado automáticamente para que el flujo de demostración se complete sin un paso de aprobación manual.', 'authToken', 2, 10, -1, -1, true, 1, true, false)
RETURNING id AS es_plan_id \gset

INSERT INTO catalogue_products (catalogue_id, product_id) VALUES (:es_catalogue_id, :es_product_id);
INSERT INTO catalogue_plans (catalogue_id, plan_id) VALUES (:es_catalogue_id, :es_plan_id);

-- PrimaryES nav menu -- top_nav.tmpl picks this over Primary when $lang=es
-- (via the $menuSuffixes dict -> "Primary" + "ES").
INSERT INTO menus (created_at, updated_at, cid, name, path)
VALUES (now(), now(), 'ESMENU00000000000000001', 'PrimaryES', 'PrimaryES')
RETURNING id AS es_menu_id \gset

INSERT INTO menu_items (created_at, updated_at, cid, title, path, position, menu_id) VALUES
(now(), now(), 'ESMENUITEM0000000000001', 'Catálogos', '/portal/catalogue-products?catalogue=' || :es_catalogue_id, 1, :es_menu_id),
(now(), now(), 'ESMENUITEM0000000000002', 'Blog', '/blog', 2, :es_menu_id),
(now(), now(), 'ESMENUITEM0000000000003', 'Acerca de', '/es/about-us', 3, :es_menu_id);

SELECT :es_catalogue_id AS es_catalogue_id, :es_product_id AS es_product_id, :es_plan_id AS es_plan_id, :es_menu_id AS es_menu_id;
