-- Creates a parallel Spanish homepage (/es) as its own Page row + ContentBlocks,
-- mirroring the English home page (id=1) and seed-french-pages.sql, plus a
-- Spanish twin of the default demo blog post. Same model the Admin App's own
-- Pages/Content Blocks/Posts UI manages -- no schema change, just data a
-- content editor would enter by hand in the Admin App.

INSERT INTO pages (created_at, updated_at, cid, page_type, title, path, status, page_type_id, allow_for_submission)
VALUES (now(), now(), 'ESHOME0000000000000000001', 'home', 'Construya el futuro con las API de Tyk', '/es', 'Published', 0, false)
RETURNING id AS es_page_id \gset

INSERT INTO content_blocks (created_at, updated_at, cid, name, content, page_id, markdown_enabled) VALUES
(now(), now(), 'ESHOME0000000000000000002', 'HeaderDescription', '¡Bienvenido al portal del desarrollador de Tyk! Apoyamos a desarrolladores independientes, startups y empresas en la creación de aplicaciones innovadoras con nuestras API y SDK de Tyk. Impulse su modelo de negocio y únase a nosotros en la innovación digital en torno a la gestión de API y más allá.', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000003', 'HeaderButtonLabel', 'EXPLORAR PRODUCTOS API', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000004', 'HeaderButtonLink', '/portal/catalogue-products', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000005', 'UseCasesTitle', 'Nuestros casos de uso', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000006', 'UseCasesDescription', 'Conozca nuestros casos de uso para determinar si nuestras API se adaptan a su modelo de negocio', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000007', 'UseCase1Title', 'Diseñado para consumidores', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000008', 'UseCase1Description', 'Utilice nuestras API para ayudar a su empresa a escuchar, actuar y descubrir, con el fin de comprender las necesidades de sus clientes.', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000009', 'UseCase2Title', 'Diseñado para empresas', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000010', 'UseCase2Description', 'Diseñe para las personas de su organización con el fin de integrar o mejorar su experiencia en la plataforma.', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000011', 'UseCase3Title', 'Investigación', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000012', 'UseCase3Description', 'Utilice nuestras API para obtener datos históricos y en tiempo real para su próximo proyecto de investigación.', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000013', 'FlipFlopRightImageTitle1', 'Primeros pasos', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000014', 'FlipFlopRightImageSubTitle1', 'Aquí tiene una guía paso a paso para acceder a nuestros productos API', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000015', 'FlipFlopRightImageInnerTitle1', 'Regístrese / Inicie sesión', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000016', 'FlipFlopRightImageInnerDescription1', 'Para acceder a los productos API y obtener sus credenciales de acceso, regístrese en el portal del desarrollador.', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000017', 'FlipFlopRightImageInnerTitle2', 'Explore los productos API en el catálogo', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000018', 'FlipFlopRightImageInnerDescription2', 'En el catálogo puede explorar distintos productos API y filtrar entre diferentes catálogos y categorías.', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000019', 'FlipFlopRightImageInnerTitle3', 'Añada uno o más productos API al carrito', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000020', 'FlipFlopRightImageInnerDescription3', 'Puede añadir uno o más productos API al carrito siempre que compartan el mismo tipo de autenticación.', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000021', 'FlipFlopRightImageInnerTitle4', 'Complete la compra y solicite acceso', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000022', 'FlipFlopRightImageInnerDescription4', 'Siga el proceso paso a paso en el carrito para solicitar acceso a un producto API.', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000023', 'FlipFlopRightImageInnerTitle5', 'Espere la aprobación (recibirá un correo una vez aprobada)', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000024', 'FlipFlopRightImageInnerDescription5', 'Una vez enviada la solicitud de acceso, es posible que deba esperar su aprobación. El estado de la solicitud puede consultarse en la aplicación, en «Mis aplicaciones».', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000025', 'FlipFlopRightImageInnerTitle6', 'Gestione su aplicación y sus credenciales de acceso', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000026', 'FlipFlopRightImageInnerDescription6', 'Cuando se aprueba la solicitud, se emiten las credenciales y puede consultarlas en la aplicación correspondiente, en «Mis aplicaciones».', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000027', 'FlipFlopLeftImageTitle1', 'Acerca de Tyk', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000028', 'FlipFlopLeftImageDescription1', 'Tyk cuenta con la confianza tanto de startups como de administraciones públicas y empresas sujetas a una regulación estricta. Nuestra puerta de enlace API de código abierto es rápida, escalable y moderna. Ofrecemos una plataforma de gestión de API que incluye una puerta de enlace API, análisis de API, un portal del desarrollador y un panel de control.', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000029', 'FlipFlopLeftImageButtonLabel1', 'Leer más', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000030', 'FlipFlopLeftImageButtonLink1', '/es/about-us', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000031', 'FeaturedProductsTitle', 'Descubra nuestros productos API', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000032', 'FeaturedProductsDescription', 'Nuestros productos API le permiten utilizar datos de clientes aprobados para crear o mejorar sus productos digitales.', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000033', 'FeaturedProductsLinkLabel', 'VER TODOS LOS PRODUCTOS', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000034', 'FeaturedProductsLink', '/portal/catalogue-products', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000035', 'BlogsTitle', 'Artículos de blog destacados', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000036', 'BlogsDescription', 'Conozca nuestra marca y descubra qué hay detrás de nuestra última innovación y qué nos impulsa a seguir adelante.', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000037', 'BlogsLink', '/blog', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000038', 'BlogsLinkLabel', 'VER TODOS LOS ARTÍCULOS', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000039', 'PartnersTitle', 'Nuestros socios', :es_page_id, false),
(now(), now(), 'ESHOME0000000000000000040', 'PartnersDescription', 'Colaboramos con algunas de las marcas más importantes del mundo', :es_page_id, false);

SELECT id, path, title FROM pages WHERE path = '/es';
INSERT INTO pages (created_at, updated_at, cid, page_type, title, path, status, page_type_id, allow_for_submission)
VALUES (now(), now(), 'ESABOUT000000000000000001', 'flip_flop', 'Acerca del portal Tyk', '/es/about-us', 'Published', 0, false)
RETURNING id AS es_page_id \gset

INSERT INTO content_blocks (created_at, updated_at, cid, name, content, page_id, markdown_enabled) VALUES
(now(), now(), 'ESABOUT000000000000000002', 'HeaderDescription', 'Tyk es una empresa de producto, liderada por ingenieros. No ofrecemos consultoría, gestión del cambio ni servicios profesionales. Sin embargo, ¡contamos con excelentes socios que sí lo hacen!', :es_page_id, false),
(now(), now(), 'ESABOUT000000000000000003', 'NoImageSectionTitle', 'Pronunciación de Tyk: /taɪk/', :es_page_id, false),
(now(), now(), 'ESABOUT000000000000000004', 'NoImageSectionDescription', '<p><strong>sustantivo</strong></p><p>I.A. Criatura pequeña, ágil y tenaz. Suele vivir en grupo. Un experimento de laboratorio algo disparatado que salió bien. Originaria de Gran Bretaña, hoy se encuentra en todo el mundo. Se multiplica en la nube. Ferozmente protectora, tenaz y trabajadora; su tamaño diminuto oculta una fuerza extraordinaria.</p><p><strong>plural</strong></p><p>una nube de Tyk</p>', :es_page_id, false),
(now(), now(), 'ESABOUT000000000000000005', 'FlipFlopRightImageTitle', 'El resultado', :es_page_id, false),
(now(), now(), 'ESABOUT000000000000000006', 'FlipFlopRightImageDescription', '<p>La puerta de enlace API de código abierto de Tyk ha sido instalada por decenas de miles de empresas. Nuestro fantástico equipo de ingenieros, en colaboración con la comunidad de código abierto, trabajando desde nuestras oficinas en Londres, Atlanta y Singapur, hace que Tyk esté hoy desplegado en algunas de las empresas más grandes del mundo y sea de confianza para sistemas críticos en sectores altamente regulados.</p><p>Tyk no se dedica a las oficinas al estilo de San Francisco ni a los consultores de cambio. Tyk se dedica a la ingeniería. Una ingeniería potente, eficiente y minuciosamente diseñada en la que puede confiar.</p>', :es_page_id, false),
(now(), now(), 'ESABOUT000000000000000007', 'FlipFlopLeftImageTitle', 'Creemos en la ingeniería', :es_page_id, false),
(now(), now(), 'ESABOUT000000000000000008', 'FlipFlopLeftImageDescription', '<p>Todo sería mejor si estuviera conectado, pero internet es caótico, imperfecto e impredecible.</p><p>Nuestros ingenieros se dedican a hacer que conectar todos los sistemas del mundo sea sencillo, rápido y asequible.</p><p>Nos aseguramos de que pueda confiar en nuestros sistemas para cuidar de los suyos.</p>', :es_page_id, false);

SELECT id, path, title FROM pages WHERE path = '/es/about-us';

-- Blog posts are a different admin-authored content type from Pages (own
-- `posts` table, own blog_listing.tmpl/blog_detail.tmpl), with no locale
-- field either. Same fix shape as Catalogue Products: a twin post whose
-- `path` carries the "es-" prefix, filtered at the template level (see
-- blog_listing.tmpl / blog_detail.tmpl) since GetPosts-equivalent data
-- aggregates every post regardless of language.
SELECT id AS blog_site_id FROM blog_sites LIMIT 1 \gset

INSERT INTO posts (created_at, updated_at, cid, title, lede, content, markdown_content, status, preview_content, path, header_image, markdown_enabled, product_doc, blog_site_id, product_id, author_id, position)
VALUES (now(), now(), 'ESBLOGPOST0000000000001', 'Cómo escribir un artículo de blog', '',
  '<p>Para crear y gestionar su propio contenido, vaya a la sección de blog dentro del panel de administración. Aquí puede crear, editar y eliminar artículos, y gestionar categorías. Si desea actualizar la configuración de un artículo, puede hacerlo en la «pestaña de configuración», donde puede activar/desactivar el blog, así como activar/desactivar los comentarios.</p>
                        <p>Añada categorías a sus artículos para que los usuarios puedan navegar por las páginas de su blog según el tema.</p>
                        <p>Cuando esté satisfecho con su artículo, publíquelo.</p>', '',
  'published',
  '<p>Para crear y gestionar su propio contenido, vaya a la sección de blog dentro del panel de administración. Aquí puede crear, editar y eliminar artículos, y gestionar categorías. Si desea actualizar la configuración de un artículo, puede hacerlo en la «pestaña de configuración», donde puede activar/desactivar el blog, así como activar/desactivar los comentarios.</p>
                        <p>Añada categorías a sus artículos para que los usuarios puedan navegar por las páginas de su blog según el tema.</p>
                        <p>Cuando esté satisfecho con su artículo, publíquelo.</p>',
  'es-ten-tips-for-gaining-advantage', '{"FileName":"","Url":""}', 'f', false, :blog_site_id, 0, 0, 0);

SELECT id, path, title FROM posts WHERE path = 'es-ten-tips-for-gaining-advantage';
