#!/usr/bin/env bash
# Builds device-specific release APKs (~36–44 MB each).
# Avoid `flutter build apk --release` alone — that produces a ~110 MB universal APK.
set -euo pipefail

cd "$(dirname "$0")/.."

flutter build apk \
  --release \
  --split-per-abi \
  --target-platform android-arm,android-arm64 \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

echo
echo "Release APKs:"
ls -lh build/app/outputs/flutter-apk/app-*-release.apk
