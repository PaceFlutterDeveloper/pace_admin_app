#!/bin/sh
# Flutter 3.41.x may embed a simulator-built package:objective_c dylib into device
# builds (shared native_assets cache), causing install failure 0xe8008014 and/or
# dlopen "incompatible platform". Fixed upstream for Flutter 3.43+ (flutter/flutter#181507).
# Workaround: drop the cached framework when Mach-O platform ≠ current PLATFORM_NAME.
# Ref: https://github.com/flutter/flutter/issues/185667
set -eu

FWK_DIR="${SRCROOT}/../build/native_assets/ios/objective_c.framework"
FWK_BIN="${FWK_DIR}/objective_c"

[ -f "${FWK_BIN}" ] || exit 0

case "${PLATFORM_NAME:-}" in
iphoneos) want=2 ;;           # PLATFORM_IOS
iphonesimulator) want=7 ;;    # PLATFORM_IOSSIMULATOR
*) exit 0 ;;
esac

got=$(otool -l "${FWK_BIN}" 2>/dev/null | awk '/LC_BUILD_VERSION/{p=1; next} p && /platform /{print int($2); exit}')
[ -n "${got}" ] || exit 0

if [ "${got}" -ne "${want}" ]; then
  echo "warning: Removing stale objective_c.framework (Mach-O platform ${got}, expected ${want} for ${PLATFORM_NAME}). See flutter/flutter#185667."
  rm -rf "${FWK_DIR}"
fi
