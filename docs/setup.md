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
