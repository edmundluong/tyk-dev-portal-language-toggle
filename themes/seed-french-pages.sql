-- Creates a parallel French homepage (/fr) as its own Page row + ContentBlocks,
-- mirroring the English home page (id=1) and seed-arabic-pages.sql, plus a
-- French twin of the default demo blog post. Same model the Admin App's own
-- Pages/Content Blocks/Posts UI manages -- no schema change, just data a
-- content editor would enter by hand in the Admin App.

INSERT INTO pages (created_at, updated_at, cid, page_type, title, path, status, page_type_id, allow_for_submission)
VALUES (now(), now(), 'FRHOME0000000000000000001', 'home', 'Construisez l''avenir avec les API Tyk', '/fr', 'Published', 0, false)
RETURNING id AS fr_page_id \gset

INSERT INTO content_blocks (created_at, updated_at, cid, name, content, page_id, markdown_enabled) VALUES
(now(), now(), 'FRHOME0000000000000000002', 'HeaderDescription', 'Bienvenue sur le portail développeur Tyk ! Nous accompagnons les développeurs indépendants, les start-up et les entreprises dans la création d''applications innovantes grâce à nos API et SDK Tyk. Propulsez votre modèle économique et rejoignez-nous dans l''innovation numérique autour de la gestion des API et au-delà.', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000003', 'HeaderButtonLabel', 'EXPLORER LES PRODUITS API', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000004', 'HeaderButtonLink', '/portal/catalogue-products', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000005', 'UseCasesTitle', 'Nos cas d''usage', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000006', 'UseCasesDescription', 'Découvrez nos cas d''usage pour déterminer si nos API conviennent à votre modèle économique', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000007', 'UseCase1Title', 'Concevoir pour les consommateurs', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000008', 'UseCase1Description', 'Utilisez nos API pour aider votre entreprise à écouter, agir et découvrir, afin de comprendre les besoins de vos clients.', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000009', 'UseCase2Title', 'Concevoir pour l''entreprise', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000010', 'UseCase2Description', 'Concevez pour les personnes de votre organisation afin d''intégrer ou d''améliorer leur expérience sur la plateforme.', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000011', 'UseCase3Title', 'Recherche', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000012', 'UseCase3Description', 'Utilisez nos API pour obtenir des données historiques et en temps réel pour votre prochain projet de recherche.', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000013', 'FlipFlopRightImageTitle1', 'Prise en main', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000014', 'FlipFlopRightImageSubTitle1', 'Voici un guide étape par étape pour accéder à nos produits API', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000015', 'FlipFlopRightImageInnerTitle1', 'S''inscrire / Se connecter', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000016', 'FlipFlopRightImageInnerDescription1', 'Pour accéder aux produits API et récupérer vos identifiants d''accès, veuillez vous inscrire sur le portail développeur.', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000017', 'FlipFlopRightImageInnerTitle2', 'Parcourir les produits API dans le catalogue', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000018', 'FlipFlopRightImageInnerDescription2', 'Dans le catalogue, vous pouvez parcourir différents produits API et filtrer entre les catalogues et catégories.', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000019', 'FlipFlopRightImageInnerTitle3', 'Ajouter un ou plusieurs produits API au panier', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000020', 'FlipFlopRightImageInnerDescription3', 'Un ou plusieurs produits API peuvent être ajoutés au panier tant qu''ils partagent le même type d''authentification.', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000021', 'FlipFlopRightImageInnerTitle4', 'Finaliser la commande et demander l''accès', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000022', 'FlipFlopRightImageInnerDescription4', 'Suivez le processus étape par étape dans le panier pour demander l''accès à un produit API.', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000023', 'FlipFlopRightImageInnerTitle5', 'Attendre l''approbation (vous recevrez un e-mail une fois approuvé)', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000024', 'FlipFlopRightImageInnerDescription5', 'Une fois la demande d''accès envoyée, il se peut que vous deviez attendre son approbation. Le statut de la demande est visible dans l''application, sous « Mes applications ».', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000025', 'FlipFlopRightImageInnerTitle6', 'Gérer votre application et vos identifiants d''accès', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000026', 'FlipFlopRightImageInnerDescription6', 'Une fois la demande approuvée, les identifiants sont émis et vous pouvez les consulter dans l''application concernée, sous « Mes applications ».', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000027', 'FlipFlopLeftImageTitle1', 'À propos de Tyk', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000028', 'FlipFlopLeftImageDescription1', 'Tyk est plébiscité aussi bien par les start-up que par les administrations et les entreprises soumises à une réglementation stricte. Notre passerelle API open source est rapide, évolutive et moderne. Nous proposons une plateforme de gestion d''API comprenant une passerelle API, des analyses d''API, un portail développeur et un tableau de bord.', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000029', 'FlipFlopLeftImageButtonLabel1', 'En savoir plus', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000030', 'FlipFlopLeftImageButtonLink1', '/fr/about-us', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000031', 'FeaturedProductsTitle', 'Découvrez nos produits API', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000032', 'FeaturedProductsDescription', 'Nos produits API vous permettent d''utiliser des données clients approuvées pour créer ou améliorer vos produits numériques.', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000033', 'FeaturedProductsLinkLabel', 'VOIR TOUS LES PRODUITS', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000034', 'FeaturedProductsLink', '/portal/catalogue-products', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000035', 'BlogsTitle', 'Articles de blog à la une', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000036', 'BlogsDescription', 'Découvrez notre marque et ce qui se cache derrière nos dernières innovations et ce qui nous fait avancer.', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000037', 'BlogsLink', '/blog', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000038', 'BlogsLinkLabel', 'VOIR TOUS LES ARTICLES', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000039', 'PartnersTitle', 'Nos partenaires', :fr_page_id, false),
(now(), now(), 'FRHOME0000000000000000040', 'PartnersDescription', 'Nous sommes partenaires de certaines des plus grandes marques mondiales', :fr_page_id, false);

SELECT id, path, title FROM pages WHERE path = '/fr';
INSERT INTO pages (created_at, updated_at, cid, page_type, title, path, status, page_type_id, allow_for_submission)
VALUES (now(), now(), 'FRABOUT000000000000000001', 'flip_flop', 'À propos du portail Tyk', '/fr/about-us', 'Published', 0, false)
RETURNING id AS fr_page_id \gset

INSERT INTO content_blocks (created_at, updated_at, cid, name, content, page_id, markdown_enabled) VALUES
(now(), now(), 'FRABOUT000000000000000002', 'HeaderDescription', 'Tyk est une entreprise de produits, dirigée par des ingénieurs. Nous ne faisons ni conseil, ni gestion du changement, ni services professionnels. En revanche, nous avons d''excellents partenaires qui le font !', :fr_page_id, false),
(now(), now(), 'FRABOUT000000000000000003', 'NoImageSectionTitle', 'Prononciation de Tyk : /taɪk/', :fr_page_id, false),
(now(), now(), 'FRABOUT000000000000000004', 'NoImageSectionDescription', '<p><strong>nom</strong></p><p>I.A. Petite créature intelligente, agile et tenace. Vit généralement en groupe. Une expérience de laboratoire un peu folle qui a bien tourné. Originaire de Grande-Bretagne, on la trouve aujourd''hui partout dans le monde. Se multiplie dans le Cloud. Farouchement protectrice, tenace et travailleuse, sa petite taille dissimule une force extraordinaire.</p><p><strong>pluriel</strong></p><p>une nuée de Tyk</p>', :fr_page_id, false),
(now(), now(), 'FRABOUT000000000000000005', 'FlipFlopRightImageTitle', 'Le résultat', :fr_page_id, false),
(now(), now(), 'FRABOUT000000000000000006', 'FlipFlopRightImageDescription', '<p>La passerelle API open source de Tyk a désormais été installée par des dizaines de milliers d''entreprises. Notre formidable équipe d''ingénieurs, en collaboration avec la communauté open source, opérant depuis nos bureaux de Londres, Atlanta et Singapour, fait que Tyk est aujourd''hui déployé dans certaines des plus grandes entreprises du monde et fait confiance pour des systèmes critiques dans des secteurs fortement réglementés.</p><p>Tyk ne fait pas dans les bureaux à la San Francisco ni les consultants du changement. Tyk fait de l''ingénierie. Une ingénierie puissante, performante et finement conçue, à laquelle vous pouvez faire confiance.</p>', :fr_page_id, false),
(now(), now(), 'FRABOUT000000000000000007', 'FlipFlopLeftImageTitle', 'Nous croyons en l''ingénierie', :fr_page_id, false),
(now(), now(), 'FRABOUT000000000000000008', 'FlipFlopLeftImageDescription', '<p>Tout serait meilleur une fois connecté, mais Internet est chaotique, imparfait et imprévisible.</p><p>Nos ingénieurs se consacrent à rendre simple, rapide et abordable la connexion de tous les systèmes du monde.</p><p>Nous veillons à ce que vous puissiez faire confiance à nos systèmes pour prendre soin des vôtres.</p>', :fr_page_id, false);

SELECT id, path, title FROM pages WHERE path = '/fr/about-us';

-- Blog posts are a different admin-authored content type from Pages (own
-- `posts` table, own blog_listing.tmpl/blog_detail.tmpl), with no locale
-- field either. Same fix shape as Catalogue Products: a twin post whose
-- `path` carries the "fr-" prefix, filtered at the template level (see
-- blog_listing.tmpl / blog_detail.tmpl) since GetPosts-equivalent data
-- aggregates every post regardless of language.
SELECT id AS blog_site_id FROM blog_sites LIMIT 1 \gset

INSERT INTO posts (created_at, updated_at, cid, title, lede, content, markdown_content, status, preview_content, path, header_image, markdown_enabled, product_doc, blog_site_id, product_id, author_id, position)
VALUES (now(), now(), 'FRBLOGPOST0000000000001', 'Comment rédiger un article de blog', '',
  '<p>Pour créer et gérer votre propre contenu, rendez-vous dans la section blog du tableau de bord d''administration. Vous pouvez y créer, modifier et supprimer des articles, et gérer les catégories. Si vous souhaitez mettre à jour les paramètres d''un article, vous pouvez le faire dans l''« onglet paramètres », où vous pouvez activer/désactiver le blog ainsi qu''activer/désactiver les commentaires.</p>
                        <p>Ajoutez des catégories à vos articles pour permettre aux utilisateurs de naviguer dans les pages de votre blog par sujet.</p>
                        <p>Une fois satisfait de votre article, publiez-le.</p>', '',
  'published',
  '<p>Pour créer et gérer votre propre contenu, rendez-vous dans la section blog du tableau de bord d''administration. Vous pouvez y créer, modifier et supprimer des articles, et gérer les catégories. Si vous souhaitez mettre à jour les paramètres d''un article, vous pouvez le faire dans l''« onglet paramètres », où vous pouvez activer/désactiver le blog ainsi qu''activer/désactiver les commentaires.</p>
                        <p>Ajoutez des catégories à vos articles pour permettre aux utilisateurs de naviguer dans les pages de votre blog par sujet.</p>
                        <p>Une fois satisfait de votre article, publiez-le.</p>',
  'fr-ten-tips-for-gaining-advantage', '{"FileName":"","Url":""}', 'f', false, :blog_site_id, 0, 0, 0);

SELECT id, path, title FROM posts WHERE path = 'fr-ten-tips-for-gaining-advantage';
