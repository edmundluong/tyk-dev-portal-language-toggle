-- Creates a parallel Arabic homepage (/ar) as its own Page row + ContentBlocks,
-- mirroring the English home page (id=1), plus an Arabic twin of the default
-- demo blog post. This is the exact model the Admin App's own Pages/Content
-- Blocks/Posts UI manages -- no schema change, just data a content editor
-- would enter by hand in the Admin App.

INSERT INTO pages (created_at, updated_at, cid, page_type, title, path, status, page_type_id, allow_for_submission)
VALUES (now(), now(), 'ARHOME0000000000000000001', 'home', 'ابنِ المستقبل مع واجهات برمجة تطبيقات Tyk', '/ar', 'Published', 0, false)
RETURNING id AS ar_page_id \gset

INSERT INTO content_blocks (created_at, updated_at, cid, name, content, page_id, markdown_enabled) VALUES
(now(), now(), 'ARHOME0000000000000000002', 'HeaderDescription', 'مرحبًا بك في بوابة مطوري Tyk! ندعم المطورين المستقلين والشركات الناشئة والمؤسسات الكبرى في بناء تطبيقات مبتكرة باستخدام واجهات برمجة التطبيقات وحزم SDK من Tyk.', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000003', 'HeaderButtonLabel', 'استكشف منتجات API', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000004', 'HeaderButtonLink', '/portal/catalogue-products', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000005', 'UseCasesTitle', 'حالات استخدامنا', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000006', 'UseCasesDescription', 'تعرّف على حالات استخدامنا لتحديد ما إذا كانت واجهات برمجة التطبيقات لدينا تناسب نموذج عملك', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000007', 'UseCase1Title', 'البناء للمستهلكين', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000008', 'UseCase1Description', 'استخدم واجهات برمجة التطبيقات لمساعدة عملك على الاستماع والتصرف والاكتشاف لفهم احتياجات عملائك.', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000009', 'UseCase2Title', 'البناء للأعمال', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000010', 'UseCase2Description', 'ابنِ لأشخاص داخل مؤسستك لتحسين تجربتهم على المنصة.', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000011', 'UseCase3Title', 'البحث', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000012', 'UseCase3Description', 'استخدم واجهات برمجة التطبيقات للحصول على بيانات تاريخية وفورية لمشروع بحثك القادم.', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000013', 'FlipFlopRightImageTitle1', 'كيف تبدأ', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000014', 'FlipFlopRightImageSubTitle1', 'دليل خطوة بخطوة للوصول إلى منتجات API لدينا', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000015', 'FlipFlopRightImageInnerTitle1', 'التسجيل / تسجيل الدخول', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000016', 'FlipFlopRightImageInnerDescription1', 'للوصول إلى منتجات API واسترداد بيانات الاعتماد، يرجى التسجيل في بوابة المطورين.', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000017', 'FlipFlopRightImageInnerTitle2', 'تصفح منتجات API في الكتالوج', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000018', 'FlipFlopRightImageInnerDescription2', 'في الكتالوج يمكنك تصفح منتجات API المختلفة والتصفية بين الكتالوجات والفئات.', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000019', 'FlipFlopRightImageInnerTitle3', 'أضف منتج API واحد أو أكثر إلى السلة', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000020', 'FlipFlopRightImageInnerDescription3', 'يمكن إضافة منتج API واحد أو أكثر إلى السلة طالما أنها من نفس نوع المصادقة.', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000021', 'FlipFlopRightImageInnerTitle4', 'أكمل الدفع وطلب الوصول', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000022', 'FlipFlopRightImageInnerDescription4', 'اتبع عملية الخطوة بخطوة في السلة لطلب الوصول إلى منتج API.', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000023', 'FlipFlopRightImageInnerTitle5', 'انتظر الموافقة (ستتلقى بريدًا إلكترونيًا عند الموافقة)', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000024', 'FlipFlopRightImageInnerDescription5', 'بعد إرسال طلب الوصول، قد تحتاج إلى انتظار الموافقة. يمكن رؤية حالة الطلب في التطبيق تحت "تطبيقاتي".', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000025', 'FlipFlopRightImageInnerTitle6', 'إدارة تطبيقك وبيانات الاعتماد', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000026', 'FlipFlopRightImageInnerDescription6', 'عند الموافقة على الطلب، تُصدر بيانات الاعتماد ويمكنك عرضها في التطبيق المحدد تحت "تطبيقاتي".', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000027', 'FlipFlopLeftImageTitle1', 'عن Tyk', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000028', 'FlipFlopLeftImageDescription1', 'تحظى Tyk بثقة الشركات الناشئة والحكومات والمؤسسات الخاضعة لتنظيم صارم على حدٍ سواء. توفر منصتنا لإدارة واجهات برمجة التطبيقات بوابة API وتحليلات وبوابة مطورين ولوحة تحكم.', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000029', 'FlipFlopLeftImageButtonLabel1', 'اقرأ المزيد', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000030', 'FlipFlopLeftImageButtonLink1', '/ar/about-us', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000031', 'FeaturedProductsTitle', 'اكتشف منتجات API لدينا', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000032', 'FeaturedProductsDescription', 'تتيح لك منتجات API لدينا استخدام بيانات العملاء المعتمدة لإنشاء أو تحسين منتجاتك الرقمية.', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000033', 'FeaturedProductsLinkLabel', 'عرض جميع المنتجات', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000034', 'FeaturedProductsLink', '/portal/catalogue-products', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000035', 'BlogsTitle', 'أحدث تدويناتنا', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000036', 'BlogsDescription', 'تعرّف على قصتنا واقرأ عن أحدث ابتكاراتنا وما يحفزنا على الاستمرار.', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000037', 'BlogsLink', '/blog', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000038', 'BlogsLinkLabel', 'عرض جميع التدوينات', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000039', 'PartnersTitle', 'شركاؤنا', :ar_page_id, false),
(now(), now(), 'ARHOME0000000000000000040', 'PartnersDescription', 'نحن نتشارك مع بعض أكبر العلامات التجارية في العالم', :ar_page_id, false);

SELECT id, path, title FROM pages WHERE path = '/ar';
INSERT INTO pages (created_at, updated_at, cid, page_type, title, path, status, page_type_id, allow_for_submission)
VALUES (now(), now(), 'ARABOUT000000000000000001', 'flip_flop', 'عن بوابة Tyk', '/ar/about-us', 'Published', 0, false)
RETURNING id AS ar_page_id \gset

INSERT INTO content_blocks (created_at, updated_at, cid, name, content, page_id, markdown_enabled) VALUES
(now(), now(), 'ARABOUT000000000000000002', 'HeaderDescription', 'Tyk هي شركة منتجات يقودها مهندسون. لا نقدّم خدمات استشارية أو إدارة تغيير أو خدمات مهنية. لكن لدينا شركاء رائعون يقدمون ذلك!', :ar_page_id, false),
(now(), now(), 'ARABOUT000000000000000003', 'NoImageSectionTitle', 'طريقة نطق Tyk: /taɪk/', :ar_page_id, false),
(now(), now(), 'ARABOUT000000000000000004', 'NoImageSectionDescription', '<p><strong>اسم</strong></p><p>مخلوق ذكي صغير ونحيل وعنيد. يعيش عادةً كجزء من مجموعة. تجربة معملية جامحة نجحت. موطنه الأصلي بريطانيا، ويوجد الآن في كل العالم. يتضاعف في السحابة. شديد الحماية، عنيد وكادّ، حجمه الصغير لا يعكس قوته الاستثنائية.</p><p><strong>الجمع</strong></p><p>مجموعة من Tyk</p>', :ar_page_id, false),
(now(), now(), 'ARABOUT000000000000000005', 'FlipFlopRightImageTitle', 'النتيجة', :ar_page_id, false),
(now(), now(), 'ARABOUT000000000000000006', 'FlipFlopRightImageDescription', '<p>تم تثبيت بوابة Tyk مفتوحة المصدر الآن من قبل عشرات الآلاف من الشركات. فريقنا الرائع من المهندسين، بالتعاون مع مجتمع المصادر المفتوحة، ومن مكاتبنا في لندن وأتلانتا وسنغافورة، يعني أن Tyk تُستخدم الآن في بعض أكبر المؤسسات في العالم وتحظى بالثقة في الأنظمة الحيوية بالصناعات الخاضعة لتنظيم صارم.</p><p>لا تتعامل Tyk بأسلوب مكاتب سان فرانسيسكو أو مستشاري التغيير. Tyk تفعل الهندسة. هندسة قوية وعالية الأداء ودقيقة يمكنك الوثوق بها.</p>', :ar_page_id, false),
(now(), now(), 'ARABOUT000000000000000007', 'FlipFlopLeftImageTitle', 'نحن نؤمن بالهندسة', :ar_page_id, false),
(now(), now(), 'ARABOUT000000000000000008', 'FlipFlopLeftImageDescription', '<p>كل شيء سيكون أفضل عند ربطه، لكن الإنترنت فوضوي وغير كامل وغير متوقع.</p><p>مهندسونا مكرَّسون لجعل ربط كل نظام في العالم أمرًا بسيطًا وسريعًا وبأسعار معقولة.</p><p>نضمن لك أن تثق في أنظمتنا لرعاية أنظمتك.</p>', :ar_page_id, false);

SELECT id, path, title FROM pages WHERE path = '/ar/about-us';

-- Blog posts are a different admin-authored content type from Pages (own
-- `posts` table, own blog_listing.tmpl/blog_detail.tmpl), with no locale
-- field either. Same fix shape as Catalogue Products: a twin post whose
-- `path` carries the "ar-" prefix, filtered at the template level (see
-- blog_listing.tmpl / blog_detail.tmpl) since GetPosts-equivalent data
-- aggregates every post regardless of language.
SELECT id AS blog_site_id FROM blog_sites LIMIT 1 \gset

INSERT INTO posts (created_at, updated_at, cid, title, lede, content, markdown_content, status, preview_content, path, header_image, markdown_enabled, product_doc, blog_site_id, product_id, author_id, position)
VALUES (now(), now(), 'ARBLOGPOST0000000000001', 'كيفية كتابة منشور مدونة', '',
  '<p>لإنشاء المحتوى الخاص بك وإدارته، انتقل إلى قسم المدونة داخل لوحة تحكم الإدارة. من هنا يمكنك إنشاء المنشورات وتعديلها وحذفها وإدارة الفئات. إذا كنت ترغب في تحديث إعدادات المنشور، يمكنك القيام بذلك ضمن "علامة تبويب الإعدادات" حيث يمكنك تفعيل/إلغاء تفعيل المدونة وكذلك تشغيل/إيقاف التعليقات.</p>
                        <p>أضف فئات إلى منشوراتك حتى يتمكن المستخدمون من التنقل بين صفحات مدونتك حسب الموضوع.</p>
                        <p>بمجرد أن تكون راضيًا عن منشورك، انشره مباشرة.</p>', '',
  'published',
  '<p>لإنشاء المحتوى الخاص بك وإدارته، انتقل إلى قسم المدونة داخل لوحة تحكم الإدارة. من هنا يمكنك إنشاء المنشورات وتعديلها وحذفها وإدارة الفئات. إذا كنت ترغب في تحديث إعدادات المنشور، يمكنك القيام بذلك ضمن "علامة تبويب الإعدادات" حيث يمكنك تفعيل/إلغاء تفعيل المدونة وكذلك تشغيل/إيقاف التعليقات.</p>
                        <p>أضف فئات إلى منشوراتك حتى يتمكن المستخدمون من التنقل بين صفحات مدونتك حسب الموضوع.</p>
                        <p>بمجرد أن تكون راضيًا عن منشورك، انشره مباشرة.</p>',
  'ar-ten-tips-for-gaining-advantage', '{"FileName":"","Url":""}', 'f', false, :blog_site_id, 0, 0, 0);

SELECT id, path, title FROM posts WHERE path = 'ar-ten-tips-for-gaining-advantage';
