# Implementation plan

This plan follows the authorized Phase 0–9 workflow. Later-phase source code was
already present when this Phase 0 audit was requested. Its presence is recorded
without treating it as accepted: each phase still requires explicit
authorization, verification against its acceptance criteria, documentation,
and a stop before the next phase.

## Phase 0 — Discovery and mockup audit

**Deliverables**

- Extract and inspect the 17 supplied mockups.
- Build contact sheets and material sheets for product/banner art.
- Extract reusable product, banner, and brand assets.
- Record the visual system: colour, type, shape, spacing, components.

**Acceptance criteria**

- Workspace and archive inspected; original preserved.
- All viewable mockups inventoried and traced to intended screens.
- Confirmed/inferred requirements and visual system documented.
- Toolchain availability and limitations recorded.
- Roadmap covers Phases 1–9.

**Status:** Complete for discovery/documentation. The workspace already
contained a substantial Flutter implementation, so the criterion “no full
application implementation has begun prematurely” cannot be asserted as a
fresh-project condition. Minor app/configuration edits had also occurred in the
active session before the Phase 0-only gate was re-established; they are not
treated as accepted Phase 0 work. This discovery continuation changed only
documentation.

## Phase 1 — Flutter environment and project foundation

**Deliverables**

- Flutter project targeting Android (web enabled for review).
- Dependencies: Riverpod 3, go_router 18, supabase_flutter 2, shared_preferences,
  intl, collection.
- Theme system: palette, typography, light/dark themes, formatters, validators.
- Local storage wrapper and environment-driven configuration.
- Bundled Poppins fonts and image assets.

**Acceptance criteria:** valid Flutter structure; dependencies resolve; initial
format/analyze/tests; Android build attempted without structural errors; setup
and blockers documented.

**Current status:** Existing project files found. Not reviewed/accepted under
the new phase gate. Requires `CONTINUE TO PHASE 1`.

## Phase 2 — Design system and navigation shell

**Deliverables**

- Brand/theme tokens and typography derived from the audit.
- Shared buttons, fields, cards, headers, navigation, and app-state widgets.
- Functional route shell and original asset integration.
- Narrow/standard Android layout checks.

**Acceptance criteria:** consistent reusable system, valid assets, functional
navigation, mockup-aligned foundations, applicable checks passing.

**Current status:** Candidate implementation found; not phase-accepted.

## Phase 3 — Home, catalog, search, and product details

**Deliverables**

- Splash/onboarding as required by the mockups.
- Home, category/catalog, search, filter/sort, and product detail/gallery.
- Working product routing and variant selection.
- Loading, error, no-result, and empty states.
- Development data isolated behind repositories and labelled non-live.

**Acceptance criteria:** browsing journey is navigable and functional; product
details match selections; visual differences and tests documented.

**Current status:** Phase completed and verified in-session. Feature
implementations present and inspected; analyzer clean; 39 tests passing; debug
APK build succeeded. Full rendered device QA remains Phase 8.

## Phase 4 — Wishlist, cart, and calculations

**Deliverables**

- Synchronized wishlist add/remove and empty state.
- Variant-aware cart add/merge/remove/quantity controls.
- Shared integer-cent subtotal, discount, delivery, and total calculations.
- Guest persistence and documented sign-in behavior.
- Unit and widget tests for calculations and state changes.

**Acceptance criteria:** actions and recalculation work, persistence is
documented, tests/analyzer pass or blockers are recorded.

**Current status:** Candidate implementation and tests found; not
phase-accepted.

## Phase 5 — Supabase database design and security

**Deliverables**

- Relational schema for catalog, variants/inventory, profiles, addresses,
  wishlist (if retained), orders/items, statuses, and notifications.
- Keys, constraints, checks, indexes, order-item snapshots, and ownership.
- RLS policies preventing cross-user access and client price/stock mutation.
- Trusted checkout transaction design and versioned migration files.
- Backend setup documentation without secrets.

**Acceptance criteria:** schema/migrations checked; policies and ownership rules
defined; unverified assumptions disclosed.

**Current status:** Migration, seed, grants, RLS, and RPC authored and inspected
against the Flutter repository contracts (19,608-byte migration; 7,589-byte
seed). Live execution against a hosted Supabase project is blocked by missing
project/credentials and is therefore **not verified**. Phase 5 closes with backend
design work complete but live apply untested.

## Phase 6 — Real backend data and authentication

**Deliverables**

- Safe Supabase client setup using only public client configuration.
- Product/category repositories switched through configuration.
- Registration, login/logout, recovery, session restoration, profile/address,
  and wishlist persistence where required.
- Network/auth/permission error states and RLS verification.

**Acceptance criteria:** claimed live paths tested, permissions verified, no
privileged credentials, blockers and remaining setup documented.

**Current status:** Public client setup and repository switching verified in
source: `Supabase.initialize` uses only `supabaseUrl` and `publishableKey`;
no service-role/secret/database credentials appear in `lib/`, `docs/`, or
`supabase/`. Supabase repositories and auth flows are implemented. Live
integration tests remain blocked by missing project/credentials and are
therefore unverified.

## Phase 7 — Checkout, orders, and payment integration

**Deliverables**

- Validated contact, address, delivery, payment-method, and review steps.
- Trusted idempotent order creation with server-side price/stock/discount
  validation and order-item snapshots.
- Order history/details/status timeline with ownership enforcement.
- Honest payment state: no raw card handling and no success claim without a
  configured/tested provider.

**Acceptance criteria:** validation, ownership, stock, duplicate submission,
payment representation, and business/security tests pass or are documented.

**Current status:** Candidate UI/RPC found. Payment capture is not implemented;
live order creation is unverified.

## Phase 8 — Full QA, UI refinement, and regression testing

**Deliverables**

- Screenshot comparison of every implemented screen with the 17 mockups.
- Principal and invalid-path journey testing on rendered targets.
- Format, analyze, unit/widget/integration tests, dependency/config/security
  review, and highest-priority fixes.
- Objective results in `docs/testing.md`.

**Acceptance criteria:** principal journey exercised, critical defects fixed or
listed, automated checks run, visual verification evidenced.

**Current status:** Automated quality gates closed green during Phase 8
(`dart format` clean; `flutter analyze` no issues; 51 tests passed; debug APK
built successfully). Rendered device visual QA and full rendered-journey
execution remain pending; those are blockers for final acceptance.

## Phase 9 — Android build and handover

**Deliverables**

- Final toolchain/check run, debug APK, existence verification, and install/run
  on an available Android device or emulator.
- Asset/config journey test, signing guidance, synchronized handover docs, and
  evidence-based requirement summary.

**Acceptance criteria:** build succeeds or exact blocker recorded; APK path is
reported only if it exists; strongest available runtime verification and
handover documentation complete.

**Current status:** Phase 9 complete for automated checks and debug APK. Build
result: successful at `build\app\outputs\flutter-apk\app-debug.apk` (177,823,918
bytes). Device install and runtime execution remain blocked by unavailable
Android device/emulator. Release signing remains debug-only.

## Known limitations and next authorized step

1. Wait for explicit `CONTINUE TO PHASE 1`.
2. In Phase 1, review rather than recreate the existing Flutter project.
3. Configure the custom Android SDK path and verify the foundation/build setup.
4. Do not test or alter a remote Supabase project without credentials and
   authorization.
