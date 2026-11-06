#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"
bash tools/fetch_mac_templates.sh
mkdir -p build
touch build/.gdignore
VERSION="$(sed -n 's/^config\/version="\([^"]*\)"$/\1/p' project.godot)"
test -n "${VERSION}"
APP_BUNDLE="build/Long Rail-${VERSION}.app"
DMG_PATH="build/Long Rail-${VERSION}-mac.dmg"
bash tools/godot.sh --headless --path . --export-release macOS "${APP_BUNDLE}"
codesign --verify --deep --strict "${APP_BUNDLE}"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/longrail-dmg.XXXXXX")"
trap 'rm -rf "${STAGE}"' EXIT
ditto "${APP_BUNDLE}" "${STAGE}/Long Rail.app"
ln -s /Applications "${STAGE}/Applications"
hdiutil create -volname 'Long Rail' -srcfolder "${STAGE}" -format UDZO -ov "${DMG_PATH}"
shasum -a 256 "${DMG_PATH}" > 'build/SHA256SUMS.txt'
printf '\nReady: %s/%s\n' "${ROOT}" "${DMG_PATH}"
