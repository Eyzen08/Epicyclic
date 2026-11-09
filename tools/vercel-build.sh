#!/usr/bin/env bash
# Builds the Flutter web release on Vercel's build image.
#
# Vercel does not ship the Flutter SDK, so this script downloads the pinned
# stable SDK, then runs the same build the local deploy script uses. The
# resulting bundle is published from build/web (see vercel.json).
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.8}"
SDK_ROOT="${HOME}/flutter-sdk"
ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${ARCHIVE}"

if [ ! -x "${SDK_ROOT}/bin/flutter" ]; then
  echo "==> Downloading Flutter ${FLUTTER_VERSION}"
  mkdir -p "${HOME}/flutter-download"
  curl -fsSL --retry 3 --retry-delay 2 "$URL" -o "/tmp/${ARCHIVE}"
  echo "==> Extracting"
  tar -xJf "/tmp/${ARCHIVE}" -C "${HOME}/flutter-download"
  rm -f "/tmp/${ARCHIVE}"
  mv "${HOME}/flutter-download/flutter" "${SDK_ROOT}"
fi

export PATH="${SDK_ROOT}/bin:${PATH}"
export PUB_CACHE="${HOME}/.pub-cache"

# The SDK tarball is a git checkout; running as a different user than the one
# that owns it makes git refuse to read it.
git config --global --add safe.directory "${SDK_ROOT}" || true

echo "==> Flutter version"
flutter --version
flutter config --no-analytics >/dev/null 2>&1 || true

echo "==> Resolving packages"
flutter pub get

echo "==> Building web release"
flutter build web --release --no-wasm-dry-run

echo "==> Built $(find build/web -type f | wc -l) files into build/web"
