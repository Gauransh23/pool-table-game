#!/usr/bin/env bash
set -euo pipefail
VERSION=4.7.2
DEST="${HOME}/Library/Application Support/Godot/export_templates/${VERSION}.stable"
if [[ -f "${DEST}/macos.zip" ]]; then exit 0; fi
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/longrail-template.XXXXXX")"
trap 'rm -rf "${TEMP_DIR}"' EXIT
ARCHIVE="Godot_v${VERSION}-stable_export_templates.tpz"
curl --fail --location --retry 3 "https://github.com/godotengine/godot/releases/download/${VERSION}-stable/${ARCHIVE}" -o "${TEMP_DIR}/${ARCHIVE}"
EXPECTED=ca4d71c4d7b81dfc15d1a98baa07534aa95b03fdda78a0075b06672e1648d2e5f40980c9adc28d23e1b92e732ee7bf3461997aa804af74ec2fcd7a93ccb84079
ACTUAL="$(shasum -a 512 "${TEMP_DIR}/${ARCHIVE}" | awk '{print $1}')"
[[ "${ACTUAL}" == "${EXPECTED}" ]] || { echo 'Template checksum mismatch' >&2; exit 1; }
mkdir -p "${DEST}"
unzip -p "${TEMP_DIR}/${ARCHIVE}" templates/macos.zip > "${DEST}/macos.zip"
printf '%s\n' "${VERSION}.stable" > "${DEST}/version.txt"
