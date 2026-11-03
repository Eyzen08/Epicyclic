# Known issues and external dependencies

## Phase 0 blockers

1. **Android SDK discovery:** the SDK exists at `C:\Android\sdk`, but Flutter is
   not persistently configured to find it. `flutter doctor -v` reports the
   Android toolchain unavailable without environment/configuration changes.
2. **No Android runtime target:** no emulator or physical Android device was
   detected. Device installation and visual/runtime QA are blocked until one is
   available.
3. **Android Studio not detected:** it was not found at the standard install
   path. This is not necessarily a build blocker if the SDK/CLI tools are
   complete, but must be confirmed in Phase 1.
4. **Tool binaries not on default PATH:** Flutter, Dart, Java, and ADB require
   explicit paths or temporary environment variables on this machine.
5. **No repository metadata:** the workspace contains a `.gitignore` but no
   `.git` directory, so changes cannot currently be audited or restored through
   local Git history.

## Phase 10 limitations (Philippine market build)

1. **Product photography is partial.** Only 8 bundled product images are
   available. The other 32 catalog products render a branded category
   placeholder (icon + brand name) rather than a photo of a different item.
   Replace with licensed manufacturer or original photography before any
   public launch.
2. **Prices are illustrative.** Amounts are stored correctly as integer
   centavos, but they are demo Philippine peso values, not live retail prices.
3. **Payments remain non-live.** GCash, Maya, Cash On Delivery, Bank Transfer,
   and card are labels on the demo order only. No e-wallet, bank, or card
   integration exists.
4. **Address coverage is partial.** The form supports PH fields and `+63`
   mobile validation but does not include a PSGC/barangay picker, so users type
   names manually.
5. **Responsive checks are automated, not visual.** Grid breakpoints are tested
   at common widths, but no device or emulator was available for pixel-level
   review.
6. **Supabase mode was not exercised.** The regenerated seed mirrors the
   catalog, but it has not been applied to a hosted database.

## Existing implementation requiring later-phase verification

1. **APK result unknown:** a debug APK build was backgrounded. Do not report it
   as successful until the process completion and output file are verified.
2. **No live Supabase verification:** schema, RLS, seed, authentication,
   profiles, addresses, notifications, and `create_order` have not been tested
   against a hosted project.
3. **Payment not implemented:** checkout does not charge a card or PayPal
   account and must remain explicitly non-live.
4. **Duplicate order protection requires review:** trusted checkout must have a
   durable idempotency strategy before production use; this is not yet verified.
5. **Wishlist backend scope requires review:** the master roadmap names
   user-specific wishlist persistence, while the discovered candidate schema
   may rely on local persistence. Resolve during Phases 5–6.
6. **Release signing:** the discovered Android configuration uses debug signing
   for release builds; a private release key and secure CI/local configuration
   are still required for distributable releases.
7. **Visual QA incomplete:** the running app has not been compared across all
   17 mockups on narrow and standard Android devices.
8. **Deep-link/auth flows unverified:** OAuth and password-reset redirects need
   Supabase dashboard and installed-app testing.
9. **Product assets in Supabase seed:** candidate seed rows may use bundled
   asset paths rather than hosted URLs. This works only if the client ships the
   same assets and should be reviewed for a real catalog.
10. **No carrier tracking:** the order timeline is persisted status history,
    not live carrier location. It must not be represented as live tracking.
