# Multi-language Developer Portal — implementation guide

This theme implements a portal-wide **English / Arabic (RTL) / French /
Spanish** language switcher for the Tyk Enterprise Developer Portal,
through standard theme customization only — no changes to Tyk product
code, and no server-side functionality beyond what the Portal's own
template engine already provides. All four languages are live end to
end: navigation and UI chrome, translated content pages, a translated
catalogue product per language, and a complete browse → request access →
credential-issued flow, including full right-to-left rendering in
Arabic.

`themes/default/` is a customized copy of the Enterprise Developer
Portal's "default" theme, bind-mounted into the running Portal container
via `docker-compose.yml` (`./themes/default:/opt/portal/themes/default`)
— the same mechanism used to deploy a theme customization in a real
environment. Compatible with Portal versions `v1.16.0` through `v1.18.0`.

For a click-by-click guide to managing this as an administrator —
including adding a new product or catalogue for a language through the
Admin App — see [`docs/ADMIN_GUIDE.md`](../docs/ADMIN_GUIDE.md).

## How the language switcher works

1. **Switcher UI** — `partials/top_nav.tmpl` renders a language dropdown
   from a simple list of `{code, label, flag}` entries. Selecting a
   language sets a cookie and calls `tykSwitchLang()` (in
   `partials/footer.tmpl`), which also redirects translated content pages
   to their equivalent in the new language. Adding a language to the
   switcher is a one-line addition to that list — no new markup or logic.
2. **Language detection** — every layout and template that needs to know
   the active language reads a small, consistently-named list of
   supported language codes and checks the request cookie against it,
   falling back to English for anything unrecognised. This keeps the
   detection logic identical everywhere it's used, so adding a language
   is a matter of adding its code to that list wherever it appears,
   rather than writing new branching logic per file.
3. **Right-to-left layout** — `assets/stylesheets/rtl.css` is linked
   automatically whenever the active language is configured as
   right-to-left (currently Arabic). It supplies the RTL-specific
   overrides — spacing, alignment, dropdown positioning — needed on top
   of the browser's native `dir="rtl"` handling, giving Arabic a fully
   mirrored, natively-feeling layout rather than just reversed text.

```
curl http://localhost:3001/                             # <html lang="en">
curl -H "Cookie: tdp_locale=ar" http://localhost:3001/   # <html lang="ar" dir="rtl">
```

### What adding another language involves

The switching mechanism is config-driven and inexpensive to extend:

- **Mechanism** — add the new language code to the supported-languages
  list used throughout the theme, to the switcher's language list (with
  its label and flag), and to the RTL list if applicable. This is a
  small, mechanical change with no new logic required.
- **UI strings** — every translated string in the theme is defined as a
  small per-language dictionary next to where it's used. Adding a
  language means adding one entry per string — see [Translation
  management](#translation-management) below for the tooling that keeps
  this manageable at scale.
- **Content** — Pages, the navigation menu, the product catalogue, and
  blog posts are each authored per language (see [Content
  model](#content-model-for-localized-portals) below). This is the one
  part of adding a language that scales with content volume rather than
  becoming cheaper over time — budget it as a content-authoring exercise
  for each new language, done through the Admin App the same way any
  other portal content is managed.

**In short:** the switching mechanism scales to any number of languages
with minimal engineering effort. The content itself — translated pages,
translated catalogue entries — scales with how much of the portal you
choose to localize, independent of how the mechanism is built.

## Content model for localized portals

Home, About Us, Catalogues, Catalogue Products, and Blog Posts are all
authored through the Admin App, the same interface used to manage any
Tyk Developer Portal's content. To present each of them in multiple
languages, this implementation gives each language its own copy — the
same underlying content model the Admin App already provides for
building a Page, Catalogue, or Product, simply used once per language:

- **Pages** — `/ar`, `/fr`, `/es` (and their `/about-us` equivalents) are
  full Page records with their own translated content blocks, created the
  same way any Page is created in the Admin App's Pages editor. This
  reference project seeds them via SQL for convenience; in day-to-day
  use, a content editor creates and maintains them directly in the Admin
  App.
- **Navigation menus** — each language has its own menu
  (`PrimaryAR`/`PrimaryFR`/`PrimaryES`) with translated labels pointing
  at that language's pages and catalogue, so the navigation itself feels
  native, not just the pages it links to.
- **Catalogue Products** — each language has its own Catalogue, Product,
  and Plan, giving every language a fully independent, natively-presented
  product listing with its own translated name, description, and access
  control — see [`docs/ADMIN_GUIDE.md`](../docs/ADMIN_GUIDE.md) for how
  to set this up for a new product or language through the Admin App UI.
- **Blog Posts** — the same per-language pattern as Catalogue Products,
  filtered by a simple path convention so each language's blog listing
  only shows its own posts.

Maintaining parity across languages — keeping each translated page,
product, and post up to date as the English original changes — is a
content-operations process best owned by whoever manages translations,
the same as it would be for any multilingual content strategy.

### One backing API per service, not one per language

The Gateway API behind a Catalogue Product represents a real upstream
service — in this reference project, the sample Httpbin API. That API is
shared across every language's version of the product: all four
languages' catalogue products (`weather-sample-api`,
`ar-weather-sample-api`, `fr-weather-sample-api`,
`es-weather-sample-api`) point at the same single Httpbin API definition
in the Dashboard, each through its own Policy.

This is the layer that matters for scale. A catalogue of 50 real APIs
localized into four languages needs 50 Gateway API definitions — the same
number it would need for a single language — plus 4 Policies per API (one
Product/ACL policy and one Plan/quota policy per language) and 4
Catalogue Products per API for the translated listings. The API surface
doesn't multiply with language count; only the Portal-side content layer
that presents it does, which is exactly the layer built to scale per
language.

When adding a language for a service that already has a Gateway API,
create that language's Policies against the *existing* API rather than
creating a new one — see [`docs/ADMIN_GUIDE.md`](../docs/ADMIN_GUIDE.md).
A new Gateway API is only needed when onboarding a genuinely new service,
independent of how many languages will present it.

## Translation management

Every UI string in the theme lives inline in the relevant template, next
to where it's used — this is how the Portal's template engine expects
translated content to be authored. To keep that manageable across 40+
files and four languages, `themes/i18n-sync.py` maintains a single
source-of-truth file, `themes/i18n-strings.json` (keyed by the English
string), in sync with every template:

- `check` — verifies every string in the templates matches the JSON file
  (safe to run in CI or a pre-commit hook).
- `apply` — rewrites the templates to match the JSON file, after a
  translator updates it.
- `extract` — rebuilds the JSON file from the current templates, useful
  for bootstrapping or recovering it.

This means a translator works from one JSON file instead of searching
through the theme's templates directly. Adding a new language is a matter
of adding its code to the `LANGS` list at the top of the script, adding a
placeholder entry for it wherever an existing string is defined, then
using `extract` → translate → `apply` to populate it everywhere at once.

A handful of specialised dictionaries (enum-style labels, date/number
formatting, page-path mappings) live outside this system, each documented
in place where they're defined — see [Best
practices](#best-practices-for-extending-this-theme) below for guidance
on keeping those in sync as the theme grows.

## What's translated

This implementation covers every page a developer or administrator would
see, logged in or logged out:

- **Navigation and chrome** — top navigation, language switcher, footer,
  and the logged-in sidebar (Dashboard, My apps, Users, Profile settings).
- **Authentication** — login, registration, password reset, and invite
  acceptance.
- **Account management** — the analytics dashboard, app creation and
  credential management (including rotation, revocation, plan changes,
  webhooks, and mTLS certificates), profile settings, and user
  administration.
- **Catalogue browsing** — the product catalogue, product detail pages,
  and the complete cart and checkout flow.
- **Blog** — listing and detail pages.
- **System pages** — 404, error, and portal-disabled pages.

A small number of elements are intentionally outside the scope of this
pass: third-party embedded documentation viewers (Redoc, GraphiQL, and
similar), transactional emails, and a handful of system-generated
messages (such as the confirmation banner shown immediately after
submitting a credential request) that are rendered directly by the
platform rather than by the theme.

## Best practices for extending this theme

A few patterns worth keeping in mind when adding new translated content
or a new language:

- **Reuse the existing per-language dictionary pattern.** Every
  translated string follows the same `{ "en": "...", "ar": "...",
  "fr": "...", "es": "..." }` shape next to where it's used — matching
  this consistently is what lets `i18n-sync.py` manage it centrally.
- **Give catalogue products a clear, stable name from the start.** A
  Catalogue Product's name (set via its backing Dashboard Policy) is used
  to derive its URL, so choosing a descriptive, stable name up front — for
  example, prefixing it with the language code — keeps catalogue links
  predictable as you add more products and languages.
- **Share one Gateway API per service across every language it's offered
  in.** Point each language's Policies at the same API instead of
  creating a duplicate — see [One backing API per
  service](#one-backing-api-per-service-not-one-per-language) above.
- **Check translated labels in context, not just in isolation.** A
  longer translation can occasionally need more room than a shorter
  English label did — worth a quick visual check across languages when
  adding new UI text, the same way you'd check any responsive layout.
- **Verify link targets when adding new content blocks.** When authoring
  a translated Page or Catalogue Product, double-check that any links
  within its content point to that language's version of the target page,
  not the English default.
- **Client-side text needs its own translation step.** Any UI text set
  directly by JavaScript (loading states, button label changes, and
  similar) isn't reached by the template-level translation system and
  needs a small parallel lookup of its own, keyed off the same language
  cookie the templates use.
- **Keep classification logic and display text separate.** Where a
  template derives a value used both for logic (a data attribute, a
  comparison) and for display, translate a dedicated display copy of the
  value rather than overwriting the original — this keeps any downstream
  logic that depends on the original value working correctly.

## Reproducing this setup

Runs on the stack's default ports (3000 Dashboard, 3001 Portal, 8080
Gateway):

```
make bootstrap
docker compose up -d tyk-ent-portal   # picks up themes/default/ via the bind mount
curl http://localhost:3001/
curl -H "Cookie: tdp_locale=ar" http://localhost:3001/
curl -H "Cookie: tdp_locale=ar" http://localhost:3001/ar/about-us
```

Seed data, in order (one `create_dummy_product.sql`, then three files per
language):

```
docker exec -i <postgres container> psql -U postgres -d tyk_analytics < themes/create_dummy_product.sql

docker exec -i <postgres container> psql -U postgres -d tyk_analytics < themes/seed-arabic-pages.sql
bash themes/seed-arabic-api.sh
docker exec -i <postgres container> psql -U postgres -d tyk_analytics < themes/seed-arabic-catalogue.sql

docker exec -i <postgres container> psql -U postgres -d tyk_analytics < themes/seed-french-pages.sql
bash themes/seed-french-api.sh
docker exec -i <postgres container> psql -U postgres -d tyk_analytics < themes/seed-french-catalogue.sql

docker exec -i <postgres container> psql -U postgres -d tyk_analytics < themes/seed-spanish-pages.sql
bash themes/seed-spanish-api.sh
docker exec -i <postgres container> psql -U postgres -d tyk_analytics < themes/seed-spanish-catalogue.sql
```

`seed-*-api.sh` (run from the project root, not inside the container — it
needs `docker compose` and the `.env` file) creates each language's two
Policies through the Dashboard's REST API, pointed at the same sample
Httpbin API `up.sh` already created for English — ensuring each Policy is
properly recorded and available to the Portal's catalogue sync, without
duplicating the underlying Gateway API per language (see [One backing API
per service](#one-backing-api-per-service-not-one-per-language)).

`create_dummy_product.sql` creates the Provider record connecting the
Portal to the Dashboard, and the English Catalogue Product backed by the
sample API and Policies `make bootstrap` already creates. Every reference
it needs (organisation, API, policy, Dashboard API key) is looked up
dynamically, so it runs correctly against any fresh `make bootstrap`.

French and Spanish follow the same shape as Arabic:
`themes/seed-french-pages.sql`/`seed-french-api.sh`/
`seed-french-catalogue.sql`, then the `seed-spanish-*` equivalents, run in
the same order.

For a production rollout, author translated pages and catalogues through
the Admin App directly, the same way any other portal content is
maintained — see [`docs/ADMIN_GUIDE.md`](../docs/ADMIN_GUIDE.md) for that
walkthrough.
