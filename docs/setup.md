# Setup

This file records the toolchain discovered during Phase 0. Project setup and
build commands must be revalidated during Phase 1 before they are treated as
accepted.

## Discovered local toolchain

- Windows 11 (Flutter reports Windows version `10.0.26200.9711`)
- Flutter 3.47.8 / Dart 3.13.7: `C:\dev\flutter\flutter`
- Temurin JDK 17.0.20.1: `C:\dev\jdk17\jdk-17.0.20.1+1`
- Android SDK: `C:\Android\sdk`
- ADB 37.0.1: `C:\Android\sdk\platform-tools\adb.exe`
- Git 2.55.0: `C:\Program Files\Git\cmd\git.exe`
- Chrome and Edge are available for web rendering.
- Android Studio was not detected at its standard installation path.

Flutter, Dart, Java, and ADB are not on the default process `PATH`. A temporary
PowerShell setup for this machine is:

```powershell
$env:FLUTTER_HOME = 'C:\dev\flutter\flutter'
$env:JAVA_HOME = 'C:\dev\jdk17\jdk-17.0.20.1+1'
$env:ANDROID_HOME = 'C:\Android\sdk'
$env:Path = "$env:FLUTTER_HOME\bin;$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:Path"
```

Flutter is not persistently configured for the custom Android SDK. Phase 1
should either retain `ANDROID_HOME` or run:

```powershell
flutter config --android-sdk C:\Android\sdk
flutter doctor -v
```

## Project commands (to be validated in Phase 1)

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
flutter build apk --debug
```

## Application modes

Demo mode is the current default and needs no credentials. The candidate code
documents these demo values:

- Email: `alex.morgan@epicyclic.demo`
- Password: `Epicyclic123!`
- Promo: `EPIC10`

The demo is local-only and must not be described as live authentication,
payment, or fulfilment.

Supabase mode is intended to use compile-time defines:

```powershell
flutter run `
  --dart-define=APP_MODE=supabase `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

Only a public anon/publishable key may be supplied to the Flutter client.
Never place a service-role key, database password, or payment secret in source,
documentation, `.env.example`, or command history intended for sharing.

See `backend-setup.md` before attempting live mode. No live project was
configured or tested during Phase 0.

## Deploying the web build to Vercel

The storefront is published at <https://epicyclic-store.vercel.app>. The
`epicyclic.vercel.app` subdomain belongs to an unrelated project, so the Vercel
project is named `epicyclic-store` instead.

Vercel's build image does not include the Flutter SDK. Two paths publish the
same bundle:

**Automatic (pushes to `main`).** Pushes to `main` build on Vercel with
`tools/vercel-build.sh`, which downloads the pinned stable SDK (3.47.8), runs
`flutter pub get` and `flutter build web --release --no-wasm-dry-run`, and
publishes `build/web` (see `vercel.json`). The first build takes a few minutes
because the SDK download dominates; later builds reuse the build container and
are faster. `.vercelignore` keeps local artifacts (including a ~2 GB `build/`
tree) out of the upload.

Pushes are delivered by Vercel's GitHub App, so each push to `main` starts
exactly one production build. GitHub App webhooks do not appear in the
repository's webhook list, so an empty `/hooks` response is expected. If a push
produces no deployment, check that the app still has access to the repository
in Vercel's project settings. During setup, a temporary repository webhook and
deploy hook were used to unblock deploys; both were removed once the app
delivered pushes.

**Manual (prebuilt, no cloud build).**

```powershell
powershell -ExecutionPolicy Bypass -File tools\deploy-vercel.ps1
```

The script runs the same build locally, stages `build/web` into
`.vercel/output/static`, writes the cache config, and promotes the deployment to
production.

| Flag | Effect |
|---|---|
| `-SkipBuild` | Deploy the current `build/web` without rebuilding |
| `-Preview` | Create a preview deployment instead of production |
| `-BuildArg '--dart-define=...'` | Pass extra defines (for example a Supabase build) |

The deployed bundle runs in demo mode: no credentials are embedded, orders are
labelled non-live, and no payment is captured. Flutter serves hash URLs
(`/#/home`), so deep paths are not rewritten; the entry points
(`index.html`, `main.dart.js`, `flutter_bootstrap.js`,
`flutter_service_worker.js`) revalidate on every load so a new deployment is
picked up, while `/assets/*`, `/canvaskit/*`, and `/icons/*` are cached for an
hour.

## Brand assets and link previews

`tools/generate-brand-assets.ps1` redraws the icons and the Open Graph card from
code, so they can be regenerated instead of hand-exported:

| File | Use |
|---|---|
| `web/favicon.png` | Browser tab icon (48 px) |
| `web/icons/Icon-192.png`, `Icon-512.png` | PWA / install icons |
| `web/icons/Icon-maskable-*.png` | Android maskable variants |
| `web/icons/apple-touch-icon.png` | iOS home screen (180 px) |
| `web/social-preview.png` | 1200 x 630 Open Graph / X card |

`web/index.html` points the Open Graph and Twitter tags at
`https://epicyclic-store.vercel.app/social-preview.png` and the same origin's
icons, so link previews work without a separate asset host. If a custom domain
replaces the `vercel.app` one, update the absolute URLs in `web/index.html`,
`web/manifest.json`, and the generator's card text.
