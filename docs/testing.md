# Testing log

Results are separated by phase and by evidence. A command being requested is
not counted as a pass until its completion and outputs are verified.

## Phase 11 — verified product catalog (2026-11-05)

The catalog was rebuilt around verifiable products instead of illustrative data.
`docs/product-research.md` holds the per-product price, listing, and image
sources.

| Check | Result | Evidence / limitation |
|---|---|---|
| Catalog data validation | Passed | `assets/data/catalog.json` parses: 7 categories, 29 products, 29 variants, 29 image references, 51 product-category links, 29 unique ids |
| Seed consistency | Passed | `supabase/seed.sql` regenerated from the catalog: same 29 products, 29 variants, 29 images, 51 links, plus a delete for products no longer in the catalog |
| Asset audit | Passed | 29 files in `assets/images/products/` (~1.9 MB); every catalog image path resolves on disk; all `assets/...` references in `lib/` exist |
| Price storage | Passed | Exact centavo prices preserved as integers: `₱1,388.89 → 138889`, `₱2,833.33 → 283333`, `₱2,794.44 → 279444` |
| Review data honesty | Passed | Every product ships `rating: 0` / `reviewCount: 0`; star UI is suppressed when `reviewCount == 0` |
| `dart format lib test` | Passed | 79 files formatted |
| `flutter analyze` | Passed | No issues found |
| `flutter test` | Passed | **64 tests passed**, including the new catalog checks: one verified variant per product at a positive price, and every bundled image loads from the asset bundle |
| `flutter build apk --debug` | Passed | `build\app\outputs\flutter-apk\app-debug.apk`, 177,416,478 bytes, built with `ANDROID_HOME=C:\Android\sdk` and JDK 17 |
| Device install/run | Skipped | No Android device or emulator available |
| Live Supabase journey | Skipped | No hosted project or credentials; the new seed has not been applied |
| Photo redistribution rights | Unconfirmed | Provenance is documented, but permission to ship retailer photos publicly is not established |

**Phase 11 status:** The shipped catalog is 29 products, each with one verified
variant, a real peso price checked on 2026-11-05, and a local photo of that exact
model. Dashboard/rating data was not available, so it is left empty rather than
invented. Products that could not clear the verification bar are listed as
excluded in `docs/product-research.md`.

## Phase 10 — Philippine market build and responsive polish (2026-11-03)

| Check | Result | Evidence / limitation |
|---|---|---|
| Catalog data validation | Passed (superseded) | Phase 10 catalog: 7 categories, 39 products, 68 variants, 8 image references, 39 unique ids. Replaced on 2026-11-05 by the verified 29-product catalog — see Phase 11 |
| Seed consistency | Passed (superseded) | Phase 10 seed matched that catalog; regenerated for the verified catalog in Phase 11 |
| `flutter pub get` | Passed | Dependencies resolved |
| `dart format lib test` | Passed | 79 files formatted, 0 changes after the final pass |
| `flutter analyze` | Passed | No issues found |
| `flutter test` | Passed | **62 tests passed** |
| PHP formatter tests | Passed | `₱5,990.00`, `₱5,990`, `₱1,395.50`, zero, and no dollar signs |
| Responsive grid tests | Passed | 320/360/430 px render at 2 columns; 600→3, 768/1024→4, 1280/1920→5; no overflow exceptions |
| Title Case audit | Passed | Screen titles, headings, buttons, and field labels reviewed across auth, home, catalog, cart, checkout, orders, profile, settings, notifications, and support |
| Debug APK build | Passed | `build\app\outputs\flutter-apk\app-debug.apk` (208,342,567 bytes) produced with `ANDROID_HOME=C:\Android\sdk` and JDK 17 |
| Device install/run | Skipped | No Android device or emulator available |
| Live Supabase journey | Skipped | No hosted project or credentials |
| Payment-provider integration | Skipped | Payments remain demo labels only |
| Authentic product photography | Superseded | Phase 10 shipped 8 bundled images and 32 branded placeholders; replaced by real per-product photos in Phase 11 |

**Phase 10 status:** Catalog expansion, PHP formatting, Philippine address and
payment localization, responsive grids, and the Title Case pass are complete and
covered by automated checks. On-device visual QA, live backend execution, and
payment integration remain unverified.

## Phase 1 — environment, quality gates, and build (2026-10-30 → 2026-11-03)

| Check | Result | Evidence |
|---|---|---|
| `flutter pub get` | Passed | Dependencies resolved; 9 packages have newer versions but constraints accepted |
| `dart format lib test` | Passed | 76 files after Phase 4 test additions, 0 changes needed |
| `flutter analyze` | Passed | No issues found |
| `flutter test` | Passed | **51 tests passed** across catalog, auth, orders, cart, wishlist, widget, and navigation suites |
| Asset audit | Passed | All `assets/...` references used in `lib/` exist |
| `flutter build apk --debug` | Passed | First attempt failed on stale Gradle asset-cache cleanup; `build/` was removed and retry succeeded |

APK produced: `build\app\outputs\flutter-apk\app-debug.apk` (177,823,918 bytes).

## Phase 2 — design system and navigation hardening (2026-11-03)

| Check | Result | Evidence |
|---|---|---|
| Shared widget inventory | Passed | app states, bottom bar, logo, product card, product image, stepper, section header, UI helpers present |
| Theme configuration | Passed | Reusable Material button/input/switch/chip/theme configuration present in `AppTheme` |
| Asset audit | Passed | No new missing assets |
| Navigation tests | Passed | Initial route `/splash`; home shell render |

**Phase 2 status:** Design foundations, reusable components, and navigation smoke tests verified. Runtime visual QA remains with Phase 8.

## Phase 3 — home, catalog, search, and product details (2026-11-03)

| Check | Result | Evidence / limitation |
|---|---|---|
| Feature coverage review | Passed | Home, catalog, search, and product-detail implementations reviewed for Phase 3 scope |
| Analyzer | Passed | No issues found |
| Tests | Passed | Existing suites continued to pass in the full run |
| Runtime QA | Pending | Rendered device comparison remains Phase 8 |

**Phase 3 status:** Feature implementations present and inspected; analyzer clean; full suite passing.

## Phase 4 — wishlist, cart, and calculations (2026-11-03)

| Check | Result | Evidence |
|---|---|---|
| Cart math tests | Passed | Subtotal, discount, and total calculations verified in cents |
| Cart action tests | Passed | Add, merge, quantity, remove, clear, promo apply/remove |
| Cart persistence assertions | Passed | Local JSON persistence after add and clear |
| Wishlist controller tests | Passed | Toggle add/remove and persistence |
| Full suite | Passed | **51 tests passed** |

Phase 4 closed with `dart format` clean, `flutter analyze` clean, and all
tests passing.

## Phase 9 — Android build and handover (2026-11-03)

| Check | Result | Evidence / limitation |
|---|---|---|
| Final quality gates | Passed | `dart format` clean; `flutter analyze` no issues; **51 tests passed** |
| Debug APK build | Passed | `build\app\outputs\flutter-apk\app-debug.apk`, 177,823,918 bytes |
| APK existence | Passed | File verified present after successful build |
| Device install/run | Skipped | No Android device/emulator available |
| Release signing | Blocked | Release build currently uses debug signing; private release key not configured |

**Phase 9 status:** Debug build completed and APK artifact verified. Handover documentation updated.

## Phase 8 — full QA, UI refinement, and regression testing (2026-11-03)

| Check | Result | Evidence / limitation |
|---|---|---|
| `dart format lib test` | Passed | 76 files, 0 changes needed |
| `flutter analyze` | Passed | No issues found |
| `flutter test` | Passed | **51 tests passed** |
| Debug APK | Passed | `build\app\outputs\flutter-apk\app-debug.apk`, 177,823,918 bytes |
| Source-level security scan | Passed | No service-role/secret/database credentials in client code/docs/SQL |
| Rendered UI comparison | Skipped | No Android device/emulator available |
| Live backend journey | Skipped | No Supabase project/credentials available |

**Phase 8 status:** Automated quality gates passed and closed. Rendered device
visual QA, live backend execution, and payment-provider integration testing
remain unverified and are deferred to later phases.

## Phase 0 — discovery (2026-10-30)

| Check | Result | Evidence / limitation |
|---|---|---|
| Workspace inventory | Passed | Flutter project, docs, archive, extracted references, assets, tests, and candidate Supabase files found |
| ZIP safety/inventory | Passed | One archive containing exactly 17 PNG files; no executable or script entries |
| Extraction preservation | Passed | Original ZIP retained; 17 same-name extracted PNG files found |
| Image readability | Passed | All source files report 1440 × 2560; mockups/contact sheets were visually inspected using the image reader |
| `flutter --version` | Passed via explicit path | Flutter 3.47.8, Dart 3.13.7 |
| `flutter doctor -v` | Partial | Flutter works, but SDK binaries are not on `PATH`; custom Android SDK not discovered; no Android target detected |
| Java | Passed via explicit path | Temurin OpenJDK 17.0.20.1 |
| Git | Passed | Git 2.55.0 |
| ADB | Passed via explicit path | ADB 37.0.1; no connected Android device was reported by Flutter doctor |
| Android Studio | Not detected | Standard install path absent |

No format, analyzer, test, build, installation, or runtime checks were initiated
as part of the new Phase 0 authorization.

## Existing evidence discovered in the workspace/session

Before the current phase-gated roadmap was supplied, the project had already
been developed substantially. The most recent recorded automated run reported:

- `dart format lib test`: completed.
- `flutter analyze`: one unused test import remained at that run and was then
  removed, but a clean analyzer rerun still needs to be accepted in the
  appropriate phase.
- `flutter test`: **37 tests passed** in the recorded run; later phases added
  navigation, cart, and wishlist suites to bring the final total to **51 tests
  passed**.
- `flutter build apk --debug`: was moved to a background process; the retry
  after cleaning `build/` **succeeded**, producing
  `build\app\outputs\flutter-apk\app-debug.apk` (177,823,918 bytes).

## Unverified areas

- No physical Android phone or emulator runtime inspection.
- No screenshot-by-screenshot comparison of the running app with all 17
  mockups.
- No live Supabase project, migrations, auth, RLS, CRUD, or order-RPC test.
- No real payment provider, capture, webhook, refund, or fulfilment flow.
- No release-signing verification.
- No end-to-end integration test of the principal shopping journey.
- No verification that the bundled product photos may be redistributed in a
  public build. The files match the models, but licensing is unconfirmed.
- No runtime check that prices still match the retailers after 2026-11-05.
