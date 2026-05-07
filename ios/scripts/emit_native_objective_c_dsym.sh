#!/bin/sh
# Flutter rsync embeds Dart native_assets (e.g. package:objective_c) into the app.
# Xcode does not run dsymutil for those binaries, so App Store uploads report
# missing objective_c.framework dSYMs unless we emit one here.
#
# Requires DWARF in the dylib (-g/-gline-tables-only); see dart-lang/native#3290.
set -eu

case "${PLATFORM_NAME:-}" in
iphoneos | iphonesimulator) ;;
*)
  exit 0
  ;;
esac

FRAMEWORK_REL="objective_c.framework/objective_c"
SEARCH_ROOT="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

bin=""
if [ -f "${SEARCH_ROOT}/${FRAMEWORK_REL}" ]; then
  bin="${SEARCH_ROOT}/${FRAMEWORK_REL}"
else
  # Thin Binary copies from FLUTTER_BUILD_DIR relative to the app repo (Runner ios/ SRCROOT → parent).
  fb="${FLUTTER_BUILD_DIR:-build}"
  alt="${SRCROOT}/../${fb}/native_assets/ios/${FRAMEWORK_REL}"
  if [ -f "${alt}" ]; then
    bin="${alt}"
  fi
fi

if [ -z "${bin}" ]; then
  exit 0
fi

dest="${DWARF_DSYM_FOLDER_PATH:-}"
if [ -z "${dest}" ]; then
  echo "warning: DWARF_DSYM_FOLDER_PATH is empty; skipping objective_c.framework.dSYM emission."
  exit 0
fi

mkdir -p "${dest}"
out="${dest}/objective_c.framework.dSYM"
rm -rf "${out}"
dsymutil "${bin}" -o "${out}"

# Some Xcode versions also collect archive dSYM dirs during Organizer upload.
archive_dir="${ARCHIVE_DSYMS_PATH:-${ARCHIVE_DSYMS_FOLDER_PATH:-}}"
if [ -n "${archive_dir}" ] && [ "${archive_dir}" != "${dest}" ]; then
  mkdir -p "${archive_dir}"
  rm -rf "${archive_dir}/objective_c.framework.dSYM"
  cp -R "${out}" "${archive_dir}/"
fi
