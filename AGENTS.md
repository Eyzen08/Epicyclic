# AGENTS.md

Guidance for anyone (human or agent) changing Epicyclic.

## What this project is

Epicyclic is a Flutter e-commerce app for gaming and desk gear, built from 17
supplied mockups. Android is the primary target; the web build is useful for
quick visual checks. The app ships with an offline demo mode by default and an
optional Supabase backend.

Read these before significant changes:

- `docs/design-audit.md` — mockup inventory and design decisions
- `docs/architecture.md` — layers, state, routing, data contracts
- `docs/setup.md` — run, backend, and build instructions
- `docs/testing.md` — what is verified and what is not

## Commands

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
flutter build apk --debug
```

The local toolchain on this machine:

- Flutter 3.47.8 / Dart 3.13.7 at `C:\dev\flutter\flutter`
- JDK 17 at `C:\dev\jdk17\jdk-17.0.20.1+1`
- Android SDK at `C:\Android\sdk` (platform 36, build-tools 36)

## Architecture rules

- Feature-first layout under `lib/features/<feature>/{data,domain,presentation}`.
- Shared widgets live in `lib/shared/widgets`; cross-feature providers in
  `lib/shared/providers/app_providers.dart`.
- Riverpod owns app state. Widgets read providers; repositories stay dumb.
- `go_router` owns navigation. Add routes in `lib/core/router/app_router.dart`.
- Theme values come from `AppPalette` / `AppTheme`; do not hard-code colors in
  screens. Money is stored and calculated in integer cents.
- Every remote or local read should render loading, empty, error, and data
  states. Use `AppLoading`, `AppEmptyState`, and `AppErrorState`.
- Checkout totals are recalculated from the catalog. Never trust prices sent by
  the client.

## Demo mode vs Supabase mode

- Demo mode is the default (`APP_MODE` unset). `DemoAuthRepository`,
  `DemoCatalogRepository`, `DemoOrderRepository`, and `DemoProfileRepository`
  keep data in `SharedPreferences`.
- Supabase mode requires both `SUPABASE_URL` and `SUPABASE_ANON_KEY`. Missing
  credentials show a blocking setup screen; do not add a silent fallback.
- Never ship a service-role key, database password, or payment secret.
- Demo order placement is explicitly labelled non-live. Do not describe it as a
  real purchase, and do not add fake payment-success screens.
- The app records only a payment-method label. No card data is collected,
  transmitted, or stored, and no payment is captured.

## Database rules

- Schema, RLS policies, and `create_order` live in
  `supabase/migrations/20260101000000_init.sql`. Change them together.
- Order writes are server-side only. Do not add client insert/update policies
  for `orders`, `order_items`, `order_status_events`, or `notifications`.
- The `create_order` RPC recalculates prices and discounts and checks stock.
  Keep the Flutter `CreateOrderRequest` contract and the SQL signature in sync.
- Seed data in `supabase/seed.sql` mirrors `assets/data/catalog.json`. Update
  both when changing the catalog.

## Style and quality

- Keep the Poppins typography, blue-on-mist palette, 16–20 px cards, and pill
  buttons. Match the mockups before inventing new patterns.
- Prefer small reusable widgets over one-off layout code.
- Run `dart format`, `flutter analyze`, and `flutter test` before claiming work
  is complete. Add tests for new business rules.
- Document unverified paths honestly in `docs/testing.md` (for example, live
  Supabase and payment flows that cannot be exercised without credentials).
