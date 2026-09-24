-- Creates the Arabic catalogue, product, and plan, and the PrimaryAR nav
-- menu that points at it -- the same content model the Admin App's own
-- Catalogues/Products/Plans/Menus UI manages. The product's path starts
-- with "ar-" (catalogue.tmpl uses this prefix to show only Arabic
-- products in the Arabic catalogue).
--
-- Run themes/seed-arabic-api.sh BEFORE this script -- it creates the two
-- policies ("Default Security Policy (AR)" and its Product policy) this
-- script looks up by name below. The Arabic catalogue has its own
-- Policies, Product, Plan, and Catalogue, the same way each language's
-- catalogue is independently presented -- but shares the same backing
-- Httpbin API as every other language, since it's the same upstream
-- service (see themes/seed-arabic-api.sh).

SELECT api_id AS ar_api_id FROM tyk_apis WHERE name = 'Httpbin' LIMIT 1 \gset
SELECT _id AS ar_policy_id FROM tyk_policies WHERE name = 'Default Security Policy (AR)' LIMIT 1 \gset
SELECT _id AS ar_product_policy_id FROM tyk_policies WHERE name = 'ar-weather-sample-api' LIMIT 1 \gset

INSERT INTO catalogues (created_at, updated_at, cid, name, path, visibility_status)
VALUES (now(), now(), 'ARCATALOGUE0000000000001', 'الكتالوج العام - عربي', 'public-catalogue-ar', 'Public')
RETURNING id AS ar_catalogue_id \gset

-- reference_id links this row to the Product policy above, connecting
-- this Catalogue Product to its Dashboard-managed access policy.
--
-- name/path match the Product policy's own name plus its provider
-- suffix, keeping the product's URL stable and predictable. display_name
-- (the customer-facing name shown throughout the Portal) is independent
-- of this and carries the translated name.
INSERT INTO products (created_at, updated_at, cid, name, display_name, path, description, content, auth_type, provider_id, is_documentation_only, feature, dcr_enabled, webhooks_enabled, cert_token_binding_enabled, reference_id)
VALUES (now(), now(), 'ARPRODUCT00000000000001', 'ar-weather-sample-api', 'واجهة برمجة تطبيقات الطقس التجريبية', 'ar-weather-sample-api-1',
        'مثال تجريبي على منتج API لاختبار تدفق التصفح الكامل من البحث إلى إصدار بيانات الاعتماد. تُوجَّه الطلبات إلى httpbin.org عبر واجهة API الرملية التجريبية.',
        'أُنشئ هذا منتج API التجريبي لتجربة تصفح الكتالوج وطلبات الوصول وإصدار بيانات الاعتماد من البداية للنهاية. هذه ليست واجهة طقس حقيقية -- تُوجَّه الطلبات إلى httpbin.org.',
        'authToken', 1, false, false, false, false, false, :'ar_product_policy_id')
RETURNING id AS ar_product_id \gset

INSERT INTO api_details (api_id, name, description, target_url, listen_path, api_type, product_id, status, auth_type)
VALUES (:'ar_api_id', 'واجهة برمجة تطبيقات الطقس التجريبية', 'يُوجَّه إلى httpbin.org لأغراض العرض التجريبي.', 'https://httpbin.org', '/httpbin', 'REST', :ar_product_id, true, 'authToken');

-- A dedicated Plan row, not a reuse of the English "Basic Plan" -- each
-- language's plan carries its own translated name and description.
INSERT INTO plans (created_at, updated_at, cid, name, display_name, reference_id, description, auth_type, rate, per, quota_max, quota_renewal_rate, auto_approve_access_requests, provider_id, unlimited_quota, unlimited_rate_limit)
VALUES (now(), now(), 'ARPLAN00000000000000001', 'أساسية', 'الخطة الأساسية', :'ar_policy_id',
        'وصول تجريبي غير محدود -- يُعتمد تلقائيًا حتى يكتمل تدفق العرض التوضيحي دون خطوة موافقة يدوية.', 'authToken', 2, 10, -1, -1, true, 1, true, false)
RETURNING id AS ar_plan_id \gset

INSERT INTO catalogue_products (catalogue_id, product_id) VALUES (:ar_catalogue_id, :ar_product_id);
INSERT INTO catalogue_plans (catalogue_id, plan_id) VALUES (:ar_catalogue_id, :ar_plan_id);

-- PrimaryAR nav menu -- top_nav.tmpl picks this over Primary when $lang=ar.
INSERT INTO menus (created_at, updated_at, cid, name, path)
VALUES (now(), now(), 'ARMENU00000000000000001', 'PrimaryAR', 'PrimaryAR')
RETURNING id AS ar_menu_id \gset

INSERT INTO menu_items (created_at, updated_at, cid, title, path, position, menu_id) VALUES
(now(), now(), 'ARMENUITEM0000000000001', 'الكتالوجات', '/portal/catalogue-products?catalogue=' || :ar_catalogue_id, 1, :ar_menu_id),
(now(), now(), 'ARMENUITEM0000000000002', 'المدونة', '/blog', 2, :ar_menu_id),
(now(), now(), 'ARMENUITEM0000000000003', 'من نحن', '/ar/about-us', 3, :ar_menu_id);

SELECT :ar_catalogue_id AS ar_catalogue_id, :ar_product_id AS ar_product_id, :ar_plan_id AS ar_plan_id, :ar_menu_id AS ar_menu_id;
