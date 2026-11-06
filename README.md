# Epicyclic

**Find Your Next Upgrade.**

Epicyclic is a Flutter-based e-commerce mobile application for gaming
accessories and desk equipment. I am building it as a **personal learning
project** — a place to practice mobile application development, explore how
real shopping apps work, and keep improving my skills one feature at a time.

<p>
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white">
  <img alt="Platform" src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white">
  <img alt="Backend" src="https://img.shields.io/badge/Backend-Supabase%20(optional)-3ECF8E?logo=supabase&logoColor=white">
</p>

**Live web build:** <https://epicyclic-store.vercel.app> (demo mode, no account
needed). The shorter `epicyclic.vercel.app` name belongs to an unrelated
project, so this one is published under `epicyclic-store`.

---

## About this project

I am an aspiring software developer using Epicyclic to learn by building a
complete application from start to finish. Rather than following a single
tutorial, I wanted a project large enough to cover planning, UI design,
application structure, state management, backend integration, testing, and
debugging — and an e-commerce app touches all of those areas.

This is an **ongoing learning project**, not a finished commercial product.
Some parts are well tested, others are still being explored, and a few
integrations are intentionally left unverified because I do not have the
required infrastructure (a live Supabase project, a payment provider, or a
physical Android device). I document those gaps honestly instead of hiding
them.

## Why I am building Epicyclic

The project serves two purposes:

1. **Application development practice** — building practical skills in mobile
   application development, Flutter and Dart, application architecture, state
   management, and backend integration.
2. **E-commerce application learning** — understanding how shopping
   applications work, including product browsing, search, product details,
   wishlist, shopping cart, checkout workflows, order management, and user
   accounts.

Everything I implement is something I want to understand well enough to explain
and improve later. When a feature is incomplete or untested, I say so.

## Learning Goals and Development Journey

These are the areas I am practicing and gradually improving. I do not claim
mastery of every technology listed — they are the subjects I am actively
studying through this project.

- **Mobile application development** — building, running, and iterating on an
  Android-first application.
- **Flutter and Dart programming** — widgets, layouts, navigation, async work,
  and idiomatic Dart.
- **E-commerce application development** — how catalogs, carts, checkout, and
  orders fit together in a real shopping flow.
- **UI/UX design and implementation** — turning supplied mockups into working
  screens with consistent spacing, typography, and color.
- **Application architecture and project organization** — keeping a growing
  codebase readable with a feature-first structure.
- **State management using Riverpod** — separating UI from business logic and
  handling loading, empty, error, and success states.
- **Backend integration using Supabase** — connecting a Flutter client to
  PostgreSQL, authentication, and server-side functions.
- **Database management and data handling** — designing tables, relationships,
  and constraints, and keeping client and server contracts in sync.
- **Authentication and user management** — sign in, sign up, session
  restoration, profiles, and per-user data.
- **Application testing and debugging** — writing unit and widget tests,
  reading failures, and fixing regressions.
- **Problem-solving and software development practices** — planning work in
  phases, documenting decisions, and reviewing my own code.

## What the app does

The application currently includes:

| Area | What works |
|---|---|
| Discovery | Hero banner, curated collections, featured and recommended products |
| Catalog | 39 real products across 7 categories, category browse, price filtering, sorting |
| Search | Query matching across names, brands, taglines, and categories, with an empty state |
| Product detail | Image gallery or branded placeholder, variants (color/switch), stock-aware quantity, wishlist toggle |
| Wishlist | Add/remove products, persisted locally, synced to the wishlist screen |
| Cart | Add/merge lines, quantity steppers, remove, promo codes, live totals |
| Checkout | Contact, Philippine address, delivery, payment-method label, review, and confirmation |
| Orders | Order history and a status timeline / tracking view |
| Auth | Sign in, sign up, password recovery, session restoration |
| Profile | Account details, saved addresses, support, notifications, settings |
| Settings | Theme (light/dark/system), notification preferences, sign out |

The 17 screens follow the supplied mockups: onboarding, login, sign up,
password recovery, home, catalog, search, product detail, wishlist, cart,
checkout, order confirmation, order history, order tracking, notifications,
profile, and settings.

### Philippine market build

The storefront is set up for a Philippine audience:

- **Prices** are shown in Philippine pesos (`₱`) through one formatter,
  `lib/core/utils/formatters.dart`. Amounts are still stored and calculated as
  integer centavos, so the database contract is unchanged.
- **Addresses** use Philippine fields: full name, mobile number, house/street,
  barangay, city/municipality, postal code, province, and country (fixed to
  Philippines). Mobile numbers are validated in local `+63`/`09XX` form.
- **Payment methods** at checkout are GCash, Maya, Cash On Delivery, Bank
  Transfer, and Credit Or Debit Card. These are **labels only** — the app never
  collects card data, charges an e-wallet, or captures a payment.
- **Catalog** contains 39 commercially available products from Keychron,
  Logitech, Razer, SteelSeries, HyperX, Corsair, Elgato, Audio-Technica,
  Fantech, Ugreen, and Epicyclic's own demo peripherals.

## Two ways to run it

Epicyclic has two deliberately separate modes, and the difference matters:

- **Demo mode (default)** — everything runs offline and is stored locally on
  the device with SharedPreferences. This is the easiest way to explore the app
  and the mode I use most while learning.
- **Supabase mode (optional)** — the same features run against a real
  PostgreSQL database, Supabase Auth, and a server-side order function. It
  requires a hosted project and public client credentials.

There is no silent fallback between them. If Supabase mode is selected without
credentials, the app shows a blocking setup screen instead of pretending to be
connected.

## Tech stack

- **Flutter 3.47 / Dart 3.13** — single codebase, Android-first.
- **Riverpod 3** — app state and dependency injection.
- **go_router 18** — declarative routing with deep links.
- **Supabase Flutter 2** — optional Postgres, Auth, and RPC backend.
- **SharedPreferences** — local persistence for demo mode.
- **intl** — Philippine peso (`en_PH`) and date formatting; money is stored in
  integer centavos.

## Architecture

```
lib/
  core/            # config, routing, theme, formatting, validation, storage
  features/
    <feature>/
      data/        # repositories (demo + Supabase)
      domain/      # models and contracts
      presentation/# screens, controllers, widgets
  shared/          # cross-feature widgets and providers
```

A few rules I try to keep as the project grows:

- Feature-first layout with a `data → domain → presentation` split.
- Repositories stay simple; Riverpod controllers own state transitions.
- Routes live in `lib/core/router/app_router.dart`.
- Cross-feature providers live in `lib/shared/providers/app_providers.dart`.
- Design tokens come from `AppPalette` / `AppTheme`; screens never hard-code
  colors.

This structure is something I am still learning to apply consistently. See
[docs/architecture.md](docs/architecture.md) for the deeper contract.

## Getting started

### Prerequisites

- Flutter 3.47+ (Dart 3.13+)
- Android SDK for the Android target (optional: web/desktop for quick checks)

### Run the demo

```bash
flutter pub get
flutter run
```

Demo mode is the default. Sign in with:

| Field | Value |
|---|---|
| Email | `alex.morgan@epicyclic.demo` |
| Password | `Epicyclic123!` |
| Promo code | `EPIC10` (10% off) |
| Demo address | Makati City, Metro Manila |
| Demo mobile | `+63 917 555 0147` |

Everything is stored locally on the device. Orders placed in demo mode are
explicitly marked **non-live**.

### Run against Supabase

1. Create a Supabase project.
2. Apply `supabase/migrations/20260101000000_init.sql`, then `supabase/seed.sql`.
3. Launch with public credentials only:

```bash
flutter run \
  --dart-define=APP_MODE=supabase \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

Missing credentials produce a blocking setup screen — there is no silent
fallback to demo mode.

**Never** ship a service-role key, database password, or payment secret in the
client. See [docs/setup.md](docs/setup.md) and
[docs/backend-setup.md](docs/backend-setup.md).

## Testing and quality

```bash
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

Current status: **66 tests passing**, analyzer clean, and a debug APK builds.

The suite covers cart math and persistence, wishlist toggling, demo auth,
catalog data (29 verified products, 7 categories, one variant and one bundled
photo each), order creation (including stock and promo validation), PHP money
formatting, responsive grid breakpoints from 320 px to 1920 px, shared widgets,
and navigation. Writing these tests has
been one of the most useful parts of the project — they catch mistakes I would
otherwise miss when changing code.

## Database and security

- Schema, RLS policies, and the `create_order` RPC live in
  `supabase/migrations/20260101000000_init.sql`.
- Orders are **write-protected from the client**; the `create_order`
  security-definer function re-checks prices, discounts, stock, and ownership.
- Per-user RLS prevents cross-account reads; catalog tables are public-read.
- Seed data in `supabase/seed.sql` mirrors `assets/data/catalog.json`.
- Only the public Supabase URL and anon key are ever used by the client.

## Documentation

- [docs/design-audit.md](docs/design-audit.md) — mockup inventory and decisions
- [docs/architecture.md](docs/architecture.md) — layers, state, routing, contracts
- [docs/implementation-plan.md](docs/implementation-plan.md) — phase tracker
- [docs/setup.md](docs/setup.md) — run, backend, and build instructions
- [docs/backend-setup.md](docs/backend-setup.md) — Supabase setup
- [docs/testing.md](docs/testing.md) — what is verified and what is not
- [docs/known-issues.md](docs/known-issues.md) — blockers and limitations
- [AGENTS.md](AGENTS.md) — conventions for contributors and agents

## Honest limitations

I would rather be clear about what is not finished than overstate what the
project can do:

- **No real payment processing.** Only a payment-method label is recorded; no
  card data is collected, transmitted, or stored, and no charge is captured.
  GCash, Maya, Cash On Delivery, Bank Transfer, and card options are demo
  selections, not integrations.
- **Product photography is incomplete.** Eight bundled product images cover a
  few items; the remaining products render a branded category placeholder with
  the real brand name instead of a borrowed or misleading photo.
- **Live Supabase paths are unverified.** No hosted project or credentials were
  available during development, so the migrations, RLS policies, and order RPC
  are written but have not been exercised against a live database.
- **Runtime device QA is pending.** The debug APK builds successfully, but I
  have not yet tested it on a physical Android device or emulator.
- **Release signing** currently uses debug keys.
- **The raw design mockups** (`design-inputs/`, `design-references/`) are not
  committed, to keep the repository lean.

## What I plan to learn next

- Run the full Supabase flow against a real project and verify RLS and the
  order function end to end.
- Test the app on an Android device and compare every screen with the mockups.
- Improve the architecture and refactor parts that have grown messy.
- Study testing more deeply, especially integration and widget tests for
  multi-step flows.
- Learn the basics of release signing and app distribution.

## License

This is a personal learning project. The bundled product and banner imagery is
for demonstration purposes only.
