# Epicyclic

**Find Your Next Upgrade.**

Epicyclic is a portfolio-quality Flutter e-commerce app for gaming and desk
gear, built to match 17 supplied product mockups. It ships with a fully offline
demo mode and an optional Supabase/PostgreSQL backend, and it is honest about
what is and isn't real: no card data is collected, no payment is captured, and
demo orders are clearly labelled as non-live.

<p>
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white">
  <img alt="Platform" src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white">
  <img alt="Backend" src="https://img.shields.io/badge/Backend-Supabase%20(optional)-3ECF8E?logo=supabase&logoColor=white">
</p>

---

## Highlights

- **17 mockups, faithfully implemented** — onboarding, auth, home, catalog,
  search, product detail, wishlist, cart, checkout, order history, order
  tracking, notifications, profile, and settings.
- **Offline demo mode by default** — a complete, explorable shopping journey
  with no backend, no account, and no network.
- **Optional real backend** — Supabase auth, catalog, profiles, addresses,
  orders, and notifications behind a single configuration switch.
- **Server-trusted pricing** — order totals are recalculated server-side; the
  client never dictates prices, stock, or discounts.
- **Explicit states everywhere** — loading, empty, error, offline, and success
  states are part of the design, not an afterthought.
- **No secrets in the client** — only the public Supabase URL and anon key are
  ever used.

## Features

| Area | What works |
|---|---|
| Discovery | Hero banner, curated collections, featured and recommended products |
| Catalog | Category browse, filtering by category, price sorting |
| Search | Query matching across names, taglines, and categories, with empty state |
| Product detail | Image gallery, variants (color/switch), stock-aware quantity, wishlist toggle |
| Wishlist | Add/remove products, persisted locally, synced to the wishlist screen |
| Cart | Add/merge lines, quantity steppers, remove, promo codes, live totals |
| Checkout | Contact, address, delivery, payment-method label, review, and confirmation |
| Orders | Order history and status timeline / tracking view |
| Auth | Sign in, sign up, password recovery, session restoration |
| Profile | Account details, saved addresses, support, notifications, settings |
| Settings | Theme (light/dark/system), notification preferences, sign out |

## Tech stack

- **Flutter 3.47 / Dart 3.13** — single codebase, Android-first.
- **Riverpod 3** — app state and dependency injection.
- **go_router 18** — declarative routing with deep links.
- **Supabase Flutter 2** — optional Postgres, Auth, and RPC backend.
- **SharedPreferences** — local persistence for demo mode.
- **intl** — currency and date formatting; money is stored in integer cents.

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

- Feature-first layout with a strict `data → domain → presentation` split.
- Repositories are dumb; Riverpod controllers own state transitions.
- Routes live in `lib/core/router/app_router.dart`.
- Cross-feature providers live in `lib/shared/providers/app_providers.dart`.
- Design tokens come from `AppPalette` / `AppTheme`; screens never hard-code
  colors.

See [docs/architecture.md](docs/architecture.md) for the deeper contract.

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

Current status: **51 tests passing**, analyzer clean, debug APK builds.

The suite covers cart math and persistence, wishlist toggling, demo auth,
catalog data, order creation (including stock and promo validation), shared
widgets, and navigation.

## Database and security

- Schema, RLS policies, and the `create_order` RPC live in
  `supabase/migrations/20260101000000_init.sql`.
- Orders are **write-protected from the client**; the `create_order`
  security-definer function re-checks prices, discounts, stock, and ownership.
- Per-user RLS prevents cross-account reads; catalog tables are public-read.
- Seed data in `supabase/seed.sql` mirrors `assets/data/catalog.json`.

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

This project is intentionally transparent about scope:

- **No real payment processing.** Only a payment-method label is recorded; no
  card data is collected, transmitted, or stored, and no charge is captured.
- **Live Supabase paths are unverified.** No hosted project or credentials were
  available during development, so migrations, RLS, and the order RPC are
  authored but not exercised against a live database.
- **Runtime device QA is pending.** The debug APK builds successfully, but no
  physical Android device or emulator was available for on-device testing.
- **Release signing** currently uses debug keys.
- The raw design mockups (`design-inputs/`, `design-references/`) are not
  committed to keep the repository lean.

## License

This is a personal portfolio project. The bundled product and banner imagery is
for demonstration purposes only.
