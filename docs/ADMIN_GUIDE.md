# Admin guide: managing logins and adding translated content

This guide walks through administering the multi-language Developer
Portal from the Admin App — including how the different admin logins work
together, and how to add a new product or an entirely new language
through the UI. Read [`themes/README.md`](../themes/README.md) first for
an overview of the content model (Pages, Catalogues, Catalogue Products,
and Blog Posts, each maintained per language); this guide is the
practical, click-by-click companion to it.

## The three logins, and what each is for

| Login | URL | Who uses it | What they manage |
|---|---|---|---|
| **Dashboard admin** | http://localhost:3000 | API/Gateway owner | APIs, Policies, Certificates, Keys — the Gateway-facing configuration every Catalogue Product is backed by. |
| **Portal admin (Admin App)** | http://localhost:3001/admin | Content/portal owner | Providers, API Products, Plans, Catalogues, Pages, Menus, Blog — everything a customer sees, in every language. |
| **Portal developer** | http://localhost:3001 | Anyone testing the customer experience | Browse the catalogue, request access, hold credentials — the same experience a real external developer would have. |

These are three separate account systems, not three views onto one
login — a Dashboard admin has no automatic access to the Admin App and
vice versa, and neither has anything to do with a Portal developer
account (which is just a self-registered customer). In this demo all
three use `secret` as the password for convenience, but plan for them as
distinct roles in a real deployment:

- **Dashboard admin** owns the underlying API definitions and Policies
  that every language's catalogue is built on — the natural place to
  limit access to a small, trusted group.
- **Portal admin** is the login every content editor or translator needs.
  Since Admin App access isn't currently scoped by language or
  catalogue, a multi-language content team typically manages who has this
  login as part of their own review process (for example, requiring a
  second reviewer on translated content changes), the same way many
  organisations already handle multi-editor content workflows.
- **Portal developer** accounts are low-stakes and self-service — useful
  for testing the customer journey in each language, not for content
  administration.

## How translated content reaches the Portal

**Providers → Synchronize** is what brings API Products and Plans into
the Admin App from the Dashboard — this is the primary way Gateway-backed
products get created, rather than starting from a blank form.

Go to **Admin App → Providers**. You'll see a Provider row (for example
`Local Dashboard`, type `tyk-pro`) with **Products / Plans / APIs**
counts and a **Synchronize** button. This Provider represents a
connection to a Dashboard organisation. Each time it syncs — on its own
schedule, or on demand via the Synchronize button — it picks up every
Dashboard Policy configured as a Product or a Plan and creates or updates
a matching **API Product** / **Plan** in the Admin App. This is how
`Admin App → Developer Portal → API Products` comes to list each
language's sample product automatically, without anyone creating those
rows by hand.

**In practice: build the API and its Policies in the Dashboard first,
then let the Provider sync bring them into the Portal.** The Admin App's
own "Add new API Product" form is available for building a product
directly from an inline OAS specification, which is useful in its own
right but a different path from the Gateway-backed products this guide
focuses on.

## Walkthrough A: add another product to an existing language's catalogue

Use this when a language already has its content in place (Pages,
navigation menu, Catalogue) and you're adding a second product to it.

The Gateway API behind a Catalogue Product represents a real upstream
service, and is shared across every language that presents it — it isn't
duplicated per language. Which of the two steps below you need depends on
whether that service already has a Gateway API:

1. **If the service doesn't have a Gateway API yet: Dashboard (`:3000`) →
   APIs → Add API → OAS API.** Build or import the OAS document,
   declaring its authentication under `components.securitySchemes` (plus
   a `security` entry), bound through
   `x-tyk-api-gateway.server.authentication.securitySchemes`. This is the
   standards-based way to declare API authentication in an OAS document,
   and it's what lets a Policy built on top of this API resolve a clear
   authentication type once synced into the Portal. **If the service
   already has a Gateway API** (for example, you're adding French
   coverage for a product that already has an English catalogue entry),
   skip straight to step 2 and point the new Policies at that existing
   API — there's no need to create a second copy of it.
2. **Dashboard → Policies → Add Policy**, twice, both scoped to the API
   from step 1:
   - A **Product policy** — access rights to the API, with no quota or
     rate limit configured. Give it a clear, stable name (for example
     `ar-invoices-sample-api`) — this name becomes the product's URL
     path once synced, so choosing it deliberately up front keeps
     catalogue links predictable.
   - A **Plan policy** — quota and/or rate limit configured on the same
     API. Any descriptive name works well here.
3. **Admin App → Providers → Synchronize.** Once the sync completes, the
   Plans/Products counts on the Provider row will each increase by one
   (the APIs count only increases if step 1 created a new API).
4. **Admin App → Developer Portal → API Products**, open the newly
   synced product. On the **Details** tab, set:
   - **Catalogue display name** — the translated, customer-facing name
     shown throughout the Portal.
   - The two description fields (catalogue page and product details
     page) with translated copy.
   - Scroll to **Publish API product to catalogue** and select the
     language's Catalogue.
5. **Admin App → Developer Portal → Plans**, open the matching Plan, set
   its display name and description the same way, and confirm it's
   published to the same Catalogue.
6. Check the live portal in that language — the new product appears in
   the catalogue immediately, with no restart required.

## Walkthrough B: add an entirely new language

This builds on Walkthrough A, plus the content-tree setup a new language
needs from scratch, plus a small set of theme-side additions a developer
makes alongside it. In order:

1. **Follow steps 1–2 of Walkthrough A** for the new language's sample
   product — its own two Policies, with the Product policy named using
   the new language's prefix (for example `de-weather-sample-api`),
   pointed at the same existing Gateway API every other language's
   sample product already uses (no new API needed, unless you're also
   introducing a genuinely new service alongside the new language).
2. **Admin App → Providers → Synchronize.**
3. **Admin App → Developer Portal → Catalogues → Add new Catalogue.**
   Give it a translated **Name** and a **Path** ending in the language
   code (for example `public-catalogue-de`). Set **Visibility** to
   Public, then select the new Product and Plan from step 1 to publish
   them into it.
4. **Complete steps 4–5 of Walkthrough A** (translated display name and
   description on the Product and Plan, published to the new Catalogue).
5. **Admin App → Customise → Pages → Add new Page**, once for Home and
   once for About Us, each with a **Path** starting with the new language
   code (`/de`, `/de/about-us`) and translated Content Blocks — the same
   Pages and Content Blocks model used to author any page in the Admin
   App.
6. **Admin App → Customise → Menus → Add new Menu.** Name it
   `Primary<CODE>` (for example `PrimaryDE`), with translated Menu Items
   pointing to the new Catalogue, the blog, and the new About Us page.
7. **A small set of theme-side additions**, made by a developer alongside
   the content setup above (see `themes/README.md`'s ["What adding
   another language
   involves"](../themes/README.md#what-adding-another-language-involves)):
   - Add the language code to the theme's supported-languages list, and
     to the switcher's language list (with its label and flag).
   - Add the new language to the small set of page-path mappings used by
     the navigation and error pages.
   - Add the new language's translations to the theme's string
     dictionaries, using `themes/i18n-sync.py` (`extract` → translate →
     `apply`) to manage this centrally rather than editing each template
     by hand.

## A tip on keeping catalogue paths stable

A Catalogue Product's technical name (visible as **Product Name** in the
Admin App, set from its backing Dashboard Policy) determines its URL
path, and stays aligned with that Policy's name through every sync. The
most reliable approach is to name the Policy deliberately when you first
create it — using the language-prefixed, URL-friendly name you want the
product to keep — rather than renaming it later. A **Catalogue's** own
path, by contrast, is a straightforward field you set directly when
creating the Catalogue and can rely on staying exactly as entered.
