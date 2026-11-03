# Architecture

## Overview

Epicyclic is a Flutter client with feature-first modules and two interchangeable
data backends:

1. **Demo (default):** all data lives in `SharedPreferences`. Auth, orders, and
   notifications are explicitly local and non-live.
2. **Supabase:** Postgres + Auth via the public anon key. Catalog is read-only
   for clients; orders are created through a security-definer RPC.

```
lib/
  main.dart                 bootstrap, config gate, Supabase init
  app.dart                  MaterialApp.router, themes, scroll behavior
  core/
    config/                 AppConfig (APP_MODE, URL, anon key)
    router/                 all go_router routes and shell
    storage/                typed SharedPreferences wrapper
    theme/                  palette, typography, ThemeData
    utils/                  money/date formatters, validators
  features/
    auth/                   repository + login/signup/reset screens
    cart/                   cart models, controller, cart screen
    catalog/                models, repositories, catalog/product screens
    checkout/               checkout and confirmation screens
    home/ onboarding/ shell/ splash/ search/ wishlist/
    orders/                 models, repositories, history/tracking screens
    notifications/          notification list
    profile/                profile, addresses, settings, support screens
    settings/               theme and notification preferences
  shared/
    providers/              app-wide providers and repository wiring
    widgets/                reusable visual components
supabase/
  migrations/               schema, RLS, create_order RPC
  seed.sql                  catalog seed matching assets/data/catalog.json
```

## State management

Riverpod 3 owns state. Repositories are plain Dart classes and do not import
widgets.

- `appConfigProvider`, `localStoreProvider`, `supabaseClientProvider` are
  overridden in `main.dart`.
- `authRepositoryProvider` and the other repository providers choose demo or
  Supabase implementations from `AppConfig`.
- `authStateProvider` streams the signed-in `AppUser`; account-scoped providers
  watch it so they refresh on sign-in/out.
- `catalogProvider`, `profileProvider`, `addressesProvider`, `ordersProvider`,
  `orderByIdProvider`, and `notificationsProvider` are `FutureProvider`s and
  render loading/error/data through `AsyncValue.when`.
- `CartController` and `WishlistController` are `AsyncNotifier`s persisted to
  `LocalStore`. The cart survives sign-out.
- `SettingsController` holds theme mode and notification preferences.

Derived providers (`cartCountProvider`, `wishlistIdsProvider`,
`unreadNotificationCountProvider`) keep widgets free of calculation logic.

## Routing

`go_router` defines:

- Unauthenticated: `/splash`, `/onboarding`, `/login`, `/signup`,
  `/forgot-password`.
- Shopping shell: `/home`, `/categories`, `/wishlist`, `/profile`, plus pushed
  `/search`, `/catalog`, `/product/:id`, `/cart`, `/checkout`,
  `/order-confirmation/:id`.
- Account surfaces: `/orders`, `/orders/:id`, `/notifications`, `/settings`,
  `/edit-profile`, `/addresses`, `/addresses/edit`, `/help`, `/privacy`,
  `/payment-methods`.

The shell uses `StatefulShellRoute.indexedStack`, so each tab keeps its own
navigation stack. Account/checkout screens redirect unauthenticated users to
`/login?next=...` (see the screens for the exact guard).

## Data contracts

### Demo repositories

- `DemoCatalogRepository` loads and caches `assets/data/catalog.json` from the
  asset bundle.
- `DemoAuthRepository` accepts only the documented demo credentials, stores a
  demo user JSON, and never sends email.
- `DemoOrderRepository` seeds two orders (`EP-20481`, `EP-20396`), resolves
  prices from the catalog, validates stock and `EPIC10`, and writes orders plus
  a notification locally.
- `DemoProfileRepository` seeds Alex Morgan, his address, and profile edits.

### Supabase repositories

- Catalog: reads `categories`, `products` (`is_active`), `product_variants`,
  `product_images`, and `product_categories`, then maps rows to the same domain
  models.
- Auth: `signInWithPassword`, `signUp` with `full_name` metadata, password reset
  and Google OAuth using custom-scheme redirects, profile metadata updates.
- Profile: `profiles` upsert and `addresses` CRUD, scoped to `auth.uid()`.
- Orders: selects `orders` with nested `order_items` and `order_status_events`;
  creation calls `create_order` with:

```json
{
  "p_items": [{"product_id": "...", "variant_id": "...", "quantity": 2}],
  "p_address": {"full_name": "...", "line1": "...", "city": "...", "...": "..."},
  "p_payment_method": "Credit or debit card",
  "p_contact_email": "buyer@example.com",
  "p_promo_code": "EPIC10"
}
```

Prices, totals, discounts, stock checks, and order numbers are decided by the
database, not the client. Demo mode mirrors those rules locally.

## Database and security

Tables: `categories`, `products`, `product_variants`, `product_images`,
`product_categories`, `profiles`, `addresses`, `orders`, `order_items`,
`order_status_events`, `notifications`.

Security model:

- Catalog tables are publicly readable (active products only).
- Profiles and addresses are limited to the owning `auth.uid()`.
- Orders, items, and events are readable only by their owner. Clients have no
  write policies for these tables.
- Notifications are owner-readable and owner-updatable (read flag); creation is
  server-side.
- `create_order` is `security definer`, uses `auth.uid()`, locks variants,
  recalculates totals, decrements stock atomically, and inserts the initial
  status events and notification.
- Only the public anon key reaches the app. Service-role keys and database
  passwords never appear in the client or repository.

The migration is `supabase/migrations/20260101000000_init.sql`. It has not been
run against a hosted project in this environment; see `testing.md`.

## Money and dates

All money is stored as integer centavos (1 peso = 100 centavos). `formatMoney` in
`lib/core/utils/formatters.dart` renders Philippine pesos (`en_PH`, `₱`); the demo
and SQL order paths both compute discounts with round-half-up semantics. Dates
are stored ISO-8601 and displayed with `intl`.

## Error and offline behavior

Repositories translate backend failures into user-safe exceptions
(`AuthFailure`, `OrderException`). Providers expose errors to `AppErrorState`
with retry. Local storage failures fall back to safe empty state. The app does
not silently treat a failed network call as success. There is no background
sync or offline order queue; a network failure during Supabase checkout shows an
error and leaves the cart intact.

## Payments

Payment is intentionally not implemented. Checkout records a label
("Credit or debit card" or "PayPal") and creates an order. The UI states that no
card details are collected and no payment is captured. Adding a provider
requires server-side payment intents and webhook-driven status updates, not a
client-only success screen.
