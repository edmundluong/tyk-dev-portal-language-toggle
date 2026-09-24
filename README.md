# Tyk Enterprise Developer Portal — Multi-Language Reference Implementation

This project demonstrates how the Tyk Enterprise Developer Portal can be
localized for a global audience using standard theme customization only —
no changes to Tyk product code. It runs a complete local Tyk stack
(Dashboard, Gateway, Pump, Enterprise Developer Portal) with **four
languages live end to end**: English, Arabic (with full right-to-left
layout), French, and Spanish. Every language has its own home and About
Us page and its own catalogue with its own API product, and supports the
complete browse → request access → receive credential journey.

See [`themes/README.md`](themes/README.md) for how the localization is
implemented — the language-switching mechanism, the content model, and
guidance for extending it further. See
[`docs/ADMIN_GUIDE.md`](docs/ADMIN_GUIDE.md) for a step-by-step guide to
managing this portal as an administrator, including how to add a product
or catalogue for a new language through the Admin App.

| English | Arabic (RTL) |
|---|---|
| ![English home page](docs/screenshots/home-en.png) | ![Arabic home page, right-to-left layout](docs/screenshots/home-ar.png) |

| French | Spanish |
|---|---|
| ![French home page](docs/screenshots/home-fr.png) | ![Spanish home page](docs/screenshots/home-es.png) |

Each language has its own catalogue, showing only that language's
products:

| English | Arabic (RTL) | French | Spanish |
|---|---|---|---|
| ![English catalogue](docs/screenshots/catalogue-en.png) | ![Arabic catalogue](docs/screenshots/catalogue-ar.png) | ![French catalogue](docs/screenshots/catalogue-fr.png) | ![Spanish catalogue](docs/screenshots/catalogue-es.png) |

The product detail page and the developer's own account settings page are
fully translated too:

| English | Arabic (RTL) | French | Spanish |
|---|---|---|---|
| ![English product detail](docs/screenshots/product-detail-en.png) | ![Arabic product detail](docs/screenshots/product-detail-ar.png) | ![French product detail](docs/screenshots/product-detail-fr.png) | ![Spanish product detail](docs/screenshots/product-detail-es.png) |

| English | Arabic (RTL) | French | Spanish |
|---|---|---|---|
| ![English settings](docs/screenshots/settings-en.png) | ![Arabic settings](docs/screenshots/settings-ar.png) | ![French settings](docs/screenshots/settings-fr.png) | ![Spanish settings](docs/screenshots/settings-es.png) |

## What this demonstrates

- **A portal-wide language switcher, built entirely in the theme layer.**
  Adding a language to the switcher is a configuration change, not new
  code — detection, right-to-left support, and translation lookups are
  all written generically for any number of languages.
- **Genuine right-to-left support for Arabic**, not just mirrored text —
  layout, navigation, forms, and the checkout flow all render correctly
  in RTL.
- **A complete content model for localized catalogues** that scales with
  the number of services, not the number of languages times the number of
  services. Each language has its own Catalogue, API Product, and Plan
  for translated presentation and independent access control, while the
  Gateway API behind a product is shared across every language that
  presents it — one API definition per real service, regardless of how
  many languages it's offered in.
- **A real, working credential-issuance flow** in every language —
  registering, browsing the catalogue, requesting access, and receiving a
  live API credential all work identically regardless of language.
- **A maintainable translation workflow** — every UI string in the theme
  is kept in a single source-of-truth file (`themes/i18n-strings.json`),
  with a small tool (`themes/i18n-sync.py`) to keep it in sync with the
  templates as the theme evolves.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- A valid Tyk Dashboard licence

## Quick start

```
chmod +x up.sh themes/seed-*-api.sh   # first time only
make bootstrap
```

This starts the stack and bootstraps a Dashboard organisation, user, and
sample `Httpbin` API with its Policies. First run pulls Docker images and
can take a few minutes. The language switcher itself needs nothing
further — it's built into the theme and is live as soon as the Portal is
up.

The **sample catalogue products** (one per language, each with its own
Policies, all sharing the same backing Httpbin API `make bootstrap`
already created) and the translated page and navigation content are a
one-time seed, run once after the stack is up, in this order:

```
docker exec -i $(docker compose ps -q tyk-postgres) psql -U postgres -d tyk_analytics < themes/create_dummy_product.sql

docker exec -i $(docker compose ps -q tyk-postgres) psql -U postgres -d tyk_analytics < themes/seed-arabic-pages.sql
./themes/seed-arabic-api.sh
docker exec -i $(docker compose ps -q tyk-postgres) psql -U postgres -d tyk_analytics < themes/seed-arabic-catalogue.sql

docker exec -i $(docker compose ps -q tyk-postgres) psql -U postgres -d tyk_analytics < themes/seed-french-pages.sql
./themes/seed-french-api.sh
docker exec -i $(docker compose ps -q tyk-postgres) psql -U postgres -d tyk_analytics < themes/seed-french-catalogue.sql

docker exec -i $(docker compose ps -q tyk-postgres) psql -U postgres -d tyk_analytics < themes/seed-spanish-pages.sql
./themes/seed-spanish-api.sh
docker exec -i $(docker compose ps -q tyk-postgres) psql -U postgres -d tyk_analytics < themes/seed-spanish-catalogue.sql
```

(`make reset` wipes this along with everything else — re-run all ten
commands above after the next `make bootstrap`.)

Once it's up:

- **Developer Portal:** http://localhost:3001
- **Dashboard:** http://localhost:3000
- **Gateway:** http://localhost:8080

## Credentials

| Role | URL | Email | Password |
|---|---|---|---|
| Dashboard admin | http://localhost:3000 | `dev@tyk.io` | `secret` |
| Portal admin (Admin App — content, products, providers) | http://localhost:3001/admin | `admin@tyk.io` | `secret` |
| Portal developer (customer-facing — browse, checkout) | http://localhost:3001 | `dev@tyk.io` | `secret` |

The Dashboard admin and Portal admin accounts are created automatically by
`make bootstrap`. The **Portal developer account is not** — it's an
ordinary customer sign-up, so register it once yourself at
http://localhost:3001/auth/password/register (email `dev@tyk.io`,
password `secret`) after the stack is up. This is the same
self-registration flow any real developer would use, with a fixed
email/password for convenience in this demo.

See [`docs/ADMIN_GUIDE.md`](docs/ADMIN_GUIDE.md) for what each of these
three logins is for, and how they work together when managing localized
content.

## Trying the language switcher

Click the flag/language dropdown in the top navigation on any page — EN,
AR, FR, ES. Navigation, buttons, forms, and labels switch instantly
everywhere. Home and About Us have genuine translated content authored as
separate pages per language, reachable directly at `/`, `/ar`, `/fr`,
`/es` (and their `/about-us` twins), or via the switcher from any page.
Each language's sample catalogue product is a full twin too — its own
name and description — reachable by switching language while browsing
the catalogue.

## End-to-end walkthrough: browse → checkout → credential

This is the full path a developer follows to get a working API
credential, and it works identically in every language, including in
Arabic with full RTL rendering.

1. **Log in** at http://localhost:3001/auth/password/login as the portal
   developer (`dev@tyk.io` / `secret`).
2. **Browse the catalogue** at `/portal/catalogue-products` (switch
   language first if you like — the catalogue, product, and checkout
   pages all fully translate, including the product's own translated name
   and description).
3. Open the sample product's card (click "More info" or its translated
   equivalent).
4. Click **Access this product**, which jumps to the plans section, then
   **Access with this plan** on the Basic Plan card. This adds the
   product to your cart — a confirmation banner appears with a link to
   the cart.
5. Click **Go to cart** to land on the checkout page. It walks through,
   in order: the product(s) you've selected, the plan that will apply,
   creating (or choosing) an App to hold your credentials, and
   confirmation that a credential will be generated automatically.
6. Give the app a name, then **Submit request**.
7. You're redirected straight to the new app's overview page, with a live
   credential already listed under **Approved access** — no manual
   approval step required, since the demo plan is configured to
   auto-approve.

From here the issued credential authenticates real requests through the
Gateway at `http://localhost:8080/httpbin/...`, proxied to `httpbin.org`.

## Day to day

```
make up            # start/resume the stack
make down           # stop
make reset          # stop and wipe all data (start completely fresh)
make ps / make logs [SERVICE=tyk-ent-portal]
```

## Project layout

- `docker-compose.yml`, `confs/` — the local Tyk stack (Dashboard, Gateway,
  Pump, Portal, Postgres, Redis).
- `themes/default/` — the customized Enterprise Developer Portal theme:
  every template involved in the localization. See
  [`themes/README.md`](themes/README.md) for the full breakdown.
- `themes/*.sql`, `themes/seed-*-api.sh` — the seed data behind this demo
  (translated pages, each language's sample catalogue product and
  Policies, each language's navigation menu) — see `themes/README.md`'s
  Reproducing section to re-run them against a fresh stack.
- `themes/i18n-strings.json`, `themes/i18n-sync.py` — the single source of
  truth for every translated UI string in the theme, and the tool that
  keeps it in sync with the templates.
- `up.sh` — first-boot bootstrap (organisation, user, sample API and
  Policies).
- `docs/screenshots/` — current screenshots for all four languages.
- `docs/ADMIN_GUIDE.md` — step-by-step guide to the admin logins and to
  adding a product or catalogue for a language through the Admin App.
