#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"
bash tools/fetch_mac_templates.sh
mkdir -p build
touch build/.gdignore
bash tools/godot.sh --headless --path . --export-release macOS 'build/Long Rail.app'
codesign --verify --deep --strict 'build/Long Rail.app'
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/longrail-dmg.XXXXXX")"
trap 'rm -rf "${STAGE}"' EXIT
ditto 'build/Long Rail.app' "${STAGE}/Long Rail.app"
ln -s /Applications "${STAGE}/Applications"
hdiutil create -volname 'Long Rail' -srcfolder "${STAGE}" -format UDZO -ov 'build/Long Rail-0.3.0-mac.dmg'
shasum -a 256 'build/Long Rail-0.3.0-mac.dmg' > 'build/SHA256SUMS.txt'
printf '\nReady: %s/build/Long Rail-0.3.0-mac.dmg\n' "${ROOT}"
