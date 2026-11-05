# Design audit

Source of truth: the 17 mockups in `design-inputs/epicyclic_mockups.zip`,
extracted without modifying the archive to `design-references/mockups/`.
Derived grids and material sheets are in `design-references/previews/`.
Individual product and banner art was extracted into `assets/images/`.

Every source mockup is a 1440 × 2560 PNG Android phone frame with a consistent
white/mist background, blue accent, Poppins-style headings, and rounded white
cards. The implementation follows that system rather than a generic storefront
template.

## Archive and asset inventory

- Archive: `design-inputs/epicyclic_mockups.zip` (36,341,121 bytes).
- Contents: 17 PNG screenshots only; no scripts, executables, fonts, nested
  archives, or other active content were present.
- Preservation: the original ZIP remains in `design-inputs/`; extracted copies
  are under `design-references/mockups/` with matching names and byte sizes.
- Review aids: 17 optimized previews plus layout grids and product/banner
  contact sheets are under `design-references/previews/`.
- Reusable extracted assets: 6 banner/onboarding images, 7 product images, and
  1 app icon under `assets/images/`.
- Fonts: Poppins Light, Regular, Medium, SemiBold, and Bold are under
  `assets/fonts/`. These were already present in the inspected workspace and
  are not entries in the mockup ZIP.

## Screen traceability

The status column reports what was found in the current workspace. It does not
constitute acceptance of later phases; those surfaces must be reviewed when the
corresponding phase is explicitly authorized.

| Mockup filename | Screen and purpose | Main UI elements | Expected interactions | Relevant assets | Current status |
|---|---|---|---|---|---|
| `epicyclic_splash_mockup.png` | Splash / brand introduction | Navy canvas, centered orbital mark, EPICYCLIC wordmark, tagline | Timed transition to onboarding or home | `assets/images/brand/app_icon.png` | Route and screen found |
| `epicyclic_onboarding_mockup.png` | First-run value proposition | Large setup photo, headline, supporting copy, page dots, Skip/Next controls | Swipe/next between pages; skip or finish into app | `hero_onboarding.png`, `onboarding_audio.png`, `onboarding_keys.png` | Three-page screen found; pages 2–3 inferred |
| `epicyclic_mobile_home_mockup.png` | Shopping discovery home | Logo, search/cart actions, headline, search field, hero banner, four categories, featured products, bottom nav | Search, open cart, swipe/tap hero, select category/product, toggle wishlist, change tab | `hero_home_clean.png`, product images | `/home` found |
| `epicyclic_catalog_mockup.png` | Browse and refine catalog | Header, title/subtitle, category chips, Filter and Sort controls, two-column product grid, bottom nav | Change category, filter/sort, open product, toggle wishlist | Keyboard, mouse, headset, microphone images | `/categories` and `/catalog` found |
| `epicyclic_search_mockup.png` | Product search | Search input, cancel/back action, recent searches, clear action, suggested products/results | Type query, submit suggestion, remove/clear history, open result | Product images | `/search` found |
| `epicyclic_product_details_mockup.png` | Evaluate and configure product | Header actions, image gallery/dots, name, rating, price/stock, description, feature pills, colour variants, quantity, sticky CTA | Swipe gallery, toggle wishlist, choose in-stock variant, adjust quantity, add to cart | `keyboard_white.png`, `keyboard_blue.png` | `/product/:id` found |
| `epicyclic_wishlist_mockup.png` | Review saved products | Header/cart, two-column saved-product grid, hearts, bottom nav | Open/remove item, add/open cart, navigate tabs; empty state inferred | Product images | `/wishlist` found |
| `epicyclic_cart_mockup.png` | Review provisional purchase | Cart lines, image/variant/price, quantity stepper, remove, promo field, subtotal/discount/delivery/total, checkout CTA | Change quantity, remove, apply supported promo, continue shopping, proceed to checkout | Product images | `/cart` found |
| `epicyclic_checkout_mockup.png` | Collect delivery choices and review order | Three-step rail, contact, address, delivery option, payment-method choices, order summary, CTA | Validate/edit contact/address, choose method, advance Delivery → Payment → Review, submit once | Product thumbnails | Three-step `/checkout` found |
| `epicyclic_login_mockup.png` | Existing-customer authentication | Email/password fields, visibility control, forgot-password link, sign-in CTA, Google option, sign-up link | Validate and submit, recover password, OAuth when configured, navigate to sign-up | Orbital logo | `/login` found |
| `epicyclic_signup_mockup.png` | Account creation | Name/email/password/confirm fields, terms acknowledgement, create-account CTA, Google option, login link | Validate, create account, OAuth when configured, navigate to login | Orbital logo | `/signup` found |
| `epicyclic_password_recovery_mockup.png` | Request password reset | Back action, explanatory copy, email field, send CTA | Validate email and request reset; show success/error | Orbital logo | `/forgot-password` found |
| `epicyclic_profile_mockup.png` | Account hub | Avatar/name/email, edit action, grouped order/address/payment/notification/settings/help rows, sign out, bottom nav | Open each account surface, edit profile, sign out, switch tabs | Initial/avatar treatment | `/profile` plus supporting routes found |
| `epicyclic_order_history_mockup.png` | Review prior orders | Header, active/completed tabs, order cards with reference/date/status/items/total | Switch tab, open order details/tracking, navigate tabs | Product thumbnails | `/orders` found |
| `epicyclic_order_tracking_mockup.png` | Inspect persisted order progress | Order reference/status, ETA copy, vertical status timeline, delivery address, item summary | Back, inspect timeline and order data; no fabricated live map/carrier tracking | Product thumbnail | `/orders/:id` found |
| `epicyclic_notifications_mockup.png` | Review app updates | Header, mark-all-read, grouped notification rows, unread indicators | Open linked order, mark all read, display empty/error states | Iconography only | `/notifications` found |
| `epicyclic_settings_mockup.png` | Configure app preferences | Grouped settings rows, notification toggles, appearance/theme, privacy/help, sign out | Toggle preferences, select theme, open support/legal pages, sign out | Iconography only | `/settings` found; dark theme is an extension |

Additional surfaces required by the brief but not drawn as a standalone mockup:
order confirmation, edit profile, address list/form, help, privacy, and
payment-method information. These reuse the same card, type, and button system.

## Visual system extracted from the mockups

### Colour

| Token | Light value | Use |
|-------|-------------|-----|
| Background | `#F4F8FC` | App canvas |
| Surface | `#FFFFFF` | Cards, fields, sheets |
| Surface alt | `#F8FAFD` | Image plates, subtle fills |
| Primary | `#2F8BF7` | CTAs, links, active states |
| Primary soft | `#DCEDFF` | Selected chips, promo panels |
| Text primary | `#0B1220` | Headings and body |
| Text secondary | `#667085` | Supporting copy |
| Border | `#E6EDF6` | 1 px card and field outlines |
| Navy | `#0A1733` | Splash, snackbars, dark text on light chips |
| Success | `#12A150` | In-stock, delivered |
| Warning | `#F59E0B` | Ratings, processing emphasis |
| Danger | `#EF4444` | Errors, saved-heart accent |

A dark palette was added for Settings. Light remains the default because every
mockup is light.

### Typography

Poppins is bundled locally (Light 300 through Bold 700), so the app does not
depend on runtime font downloads. Headings use tight tracking and 700 weight;
body copy uses 400; buttons and labels use 500–600. Screen titles are 24–28 px,
section titles 21 px, and body copy 14 px.

### Shape and spacing

- Cards: 16–20 px radius, 1 px `#E6EDF6` border, no heavy elevation.
- Buttons: stadium/pill shape, 54–56 px height; primary is solid blue with white
  text.
- Inputs: 16 px radius, white fill, border that turns blue on focus.
- Screen gutters: 20 px on phones, 32 px from 768 px up; content is capped at
  600–1180 px depending on the screen.
- Common vertical rhythm: 8 / 12 / 14 / 18 / 24 / 28 px.
- Product grids: responsive at 2 / 3 / 4 / 5 columns with 12–18 px gaps. Image
  area is capped at 210 px and the text block reserves 124 px, so cards keep a
  consistent height from 320 px phones to 1920 px desktops.

### Components observed and reused

- Circular orbital logo mark plus wordmark.
- Pill search field with leading magnifier.
- Full-bleed rounded hero carousel with dot indicators and an "Explore" pill.
- Four square category tiles with line icons and labels.
- Product card: image plate, heart button, rating, name, tagline, price.
- Sticky product action bar with price, stock state, and "Add to cart".
- Colour swatches with a blue selection ring; quantity stepper with outlined
  square buttons.
- Three-step checkout progress rail (Delivery → Payment → Review).
- Order cards with status chips and a chevron; vertical tracking timeline.
- Toggle rows, grouped setting cards, and a sign-out action.
- Bottom navigation: Home / Categories / Wishlist / Profile.

## Fidelity decisions

### Implemented directly

- Home hierarchy: logo/header, headline, search, hero, categories, featured
  products, service strip.
- Product detail gallery, rating, price, stock, feature chips, colour and
  quantity controls, sticky add-to-cart bar.
- Cart line items, promo field, summary card, free delivery.
- Checkout contact/address/delivery/payment/summary cards.
- Order list tabs and detailed status timeline.
- Wishlist grid with saved items and empty state.
- Profile header, menu rows, settings groups, notification preferences.

### Deliberate extensions

- **Onboarding pages 2–3** were added because the mockup shows one page while
  the dot indicator implies three. Copy stays in the supplied voice.
- **Audio category** was added so headphones and microphones in the mockups have
  a destination. The mockup category row shows four tiles: Gaming, Keyboards,
  Mice, Audio.
- **Notifications entry** is available from Profile and the header bell, because
  no bottom-nav slot was drawn for it.
- **Contextual orders navigation**: the order screens use Home / Orders /
  Wishlist / Profile so Orders remains reachable without losing the mockup's
  4-item bottom bar.
- **Dark theme** and **reduced-motion-friendly** transitions are settings
  additions, not mockup content.
- **Guest cart and wishlist** persist locally before sign-in, so the demo is
  explorable without an account.

### Mockup inconsistencies resolved

- The mockups use different people and addresses (`Alex Morgan` in profile,
  another name in checkout). The app consistently uses Alex Morgan and a
  Philippine demo address: Unit 12, 123 Sample Street, Barangay San Lorenzo,
  Makati City, Metro Manila 1223.
- The mockups show dollar prices; the shipped app displays Philippine pesos
  through a single formatter and keeps the underlying values as integer
  centavos.
- The headset is shown at `$149` in one sheet and `$129` elsewhere; the catalog
  replaces this with real product pricing rather than copying inconsistent
  mockup values.
- Bottom navigation differs between shopping and order screens; the app uses
  the contextual variants described above rather than forcing one global bar.
- Checkout says "Your information is secure and encrypted." Because this build
  does not capture payment data, the app instead states that no card details are
  collected and no payment is taken. This avoids a false security claim.

## Honest content and states

- A compact `DEMO` chip appears in demo mode on commerce surfaces.
- Checkout explicitly labels the demo order action, and the success screen
  states that no payment was taken.
- The Supabase branch states that order creation is live but payment capture and
  fulfilment are not implemented.
- Loading, empty, error, and retry states exist for catalog, search, cart,
  wishlist, orders, notifications, addresses, and checkout dependencies.
- Disabled and sold-out variants are rendered but cannot be added to the cart.

## Visual QA status

Static analysis and widget tests pass. The app has not yet been compared
pixel-by-pixel on a physical Android device; see `docs/testing.md` for the
verification log and remaining visual checks. Responsive rules are covered by
widget tests at 320, 360, 430, 768, 1024, and 1440 px widths.

## Verified product catalog (2026-11-05)

### Products

The catalog now ships 29 verified products across 7 categories. Each row is a
real manufacturer model that was matched to a live Philippine retailer listing
with a stated peso price; the full source manifest is in
`docs/product-research.md`.

| Category | Products |
|---|---|
| Keyboards (5) | Keychron K8, AULA F75, Redragon K617 Fizz, SteelSeries Apex Pro TKL, Royal Kludge RK-M75 |
| Mice (6) | Logitech G102 Lightsync, Razer DeathAdder V3, Logitech G502 X Plus, Logitech G Pro X Superlight 2, Razer Viper V3 Pro, Logitech G304 X |
| Audio (5) | Razer BlackShark V2 X, HyperX Cloud III, HyperX Cloud III S Wireless, SteelSeries Arctis Nova Pro Wireless, Razer Kraken V4 X |
| Mousepads (4) | Razer Goliathus Chroma, Razer Strider Large, Fantech ATO MP905 Luffy, Keychron Desk Mat NINEGO |
| Accessories (5) | Razer Base Station V2 Chroma, UGREEN Uno 6-in-1 Hub, InPlay KMT-3, Keychron Silicone Palm Rest, Arctic Z1 Basic |
| Streaming (4) | HyperX QuadCast 2, Razer Seiren V3 Mini, Razer Seiren V3 Chroma, Logitech C922 |

Brands represented: Keychron, AULA, Redragon, SteelSeries, Royal Kludge,
Logitech G, Razer, HyperX, Fantech, UGREEN, InPlay, and Arctic. Every product has
exactly one verified variant, so the catalog holds 29 variants and 51
product-category links.

Prices are the retailer's peso prices stored as integer centavos
(`₱4,400.00 → 440000`, `₱1,388.89 → 138889`). Products sold at a discount keep
the discounted price in `priceCents`; the regular price is recorded in
`docs/product-research.md`. `stock` is a demo placeholder of `10` per variant,
not live retailer inventory.

The earlier 39-product expansion (2026-11-03) was superseded: most of those rows
had illustrative prices and multiple invented colour variants. It is kept only
as history, not as shipped data.

### Imagery

All 29 products now ship with one real photo of the exact model and variant,
downloaded into `assets/images/products/` (~1.9 MB total). There are no remote
image URLs and no placeholder-rendered products in the catalog.

Photos were taken from the manufacturer or the same retailer listing. Where a
photo carried an `EASYPC` watermark, a clean shot of the identical model was
used instead; the swap is documented per product. `ProductImage` renders with
`BoxFit.contain`, so isolated product shots are letterboxed rather than cropped.

No review data was available from these retailers, so every product uses
`rating: 0` and `reviewCount: 0`. The product card, product detail screen, and
search result tile hide stars when `reviewCount == 0`.

### Currency and localization

- One formatter (`formatMoney`) renders `en_PH` pesos with `₱`.
- Whole-peso catalog prices drop the `.00`; cart, checkout, and order totals keep
  two decimals.
- Address forms use Barangay, City/Municipality, Province, Postal Code, and a
  fixed Philippines country field.
- Mobile validation accepts `+63 9XX XXX XXXX`, `09XX XXX XXXX`, and 10-digit
  local numbers.
- Checkout offers GCash, Maya, Cash On Delivery, Bank Transfer, and Credit Or
  Debit Card as demo-only labels.
- Demo seeds use a Makati address, `+63` phone numbers, and PHP totals.

### Responsive and copy pass

- `ProductGridMetrics` centralizes 2 / 3 / 4 / 5 column breakpoints and card
  height, so Home, Catalog, Wishlist, and related products stay aligned.
- Home and Catalog cap content at 1180 px; Cart, Checkout, Search, and address
  forms use narrower 600–760 px columns for readable line lengths.
- Home category tiles scroll horizontally on phones instead of squeezing seven
  categories into one row.
- Product detail gallery, sticky action bar, checkout payment rows, and cart
  line items were adjusted to avoid overflow on narrow screens.
- Screen titles, section headings, buttons, and field labels use Title Case;
  brand names keep their official capitalization.

### Known content limitations

- Product photos are real retailer/manufacturer shots of the exact model, but
  they are used here as a learning/demo catalog. Confirm redistribution rights
  and re-host them before any public launch.
- Prices were captured from EasyPC and DataBlitz on 2026-11-05 and can change.
  Re-verify before presenting them as live pricing.
- `stock` is a placeholder, not live retailer inventory.
- No device or emulator was available for on-device visual QA.


## Environment discovery (Phase 0)

Checked on Windows 11 on 2026-10-30:

- Flutter 3.47.8 and Dart 3.13.7 exist at `C:\dev\flutter\flutter`, but neither
  binary is on the default `PATH`.
- Temurin OpenJDK 17.0.20.1 exists at
  `C:\dev\jdk17\jdk-17.0.20.1+1`, but `java` is not on the default `PATH`.
- Android SDK/platform tools exist at `C:\Android\sdk`; ADB 37.0.1 runs via its
  explicit path. Flutter is not configured to discover that custom SDK, so
  `flutter doctor -v` reports the Android toolchain as unavailable unless
  `ANDROID_HOME` is set or `flutter config --android-sdk C:\Android\sdk` is run.
- Git 2.55.0 is installed and available.
- Android Studio was not found at the standard
  `C:\Program Files\Android\Android Studio` location.
- Chrome, Edge, and Windows desktop targets are detected. No Android emulator or
  physical Android device was detected by `flutter doctor -v`.
- Visual Studio is present but lacks optional C++ desktop components. This does
  not block the Android-first scope.
