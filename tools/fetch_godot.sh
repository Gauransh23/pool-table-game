#!/usr/bin/env bash
set -euo pipefail

VERSION="4.7.2"
ARCHIVE_NAME="Godot_v${VERSION}-stable_macos.universal.zip"
DOWNLOAD_URL="https://github.com/godotengine/godot/releases/download/${VERSION}-stable/${ARCHIVE_NAME}"
EXPECTED_SHA256="c58a24e31d720be9d62f60cb5627c4e695fb72f21b0cfe1bc9ccaa9a3b3ba63e"
INSTALL_ROOT="${GODOT_INSTALL_ROOT:-${HOME}/Applications}"
APP_PATH="${INSTALL_ROOT}/Godot-${VERSION}.app"
GODOT_BIN="${APP_PATH}/Contents/MacOS/Godot"

if [[ "$(uname -s)" != "Darwin" ]]; then
	printf 'This bootstrap currently supports macOS only.\n' >&2
	exit 2
fi

if [[ -x "${GODOT_BIN}" ]]; then
	if "${GODOT_BIN}" --version | grep -q "^${VERSION}\.stable"; then
		printf '%s\n' "${GODOT_BIN}"
		exit 0
	fi
	printf 'Found a different Godot build at %s; refusing to overwrite it.\n' "${GODOT_BIN}" >&2
	exit 1
fi

mkdir -p "${INSTALL_ROOT}"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/long-rail-godot.XXXXXX")"
trap 'rm -rf "${TEMP_DIR}"' EXIT
ARCHIVE_PATH="${TEMP_DIR}/${ARCHIVE_NAME}"

if [[ -n "${GODOT_ARCHIVE:-}" ]]; then
	cp "${GODOT_ARCHIVE}" "${ARCHIVE_PATH}"
else
	curl --fail --location --retry 3 "${DOWNLOAD_URL}" --output "${ARCHIVE_PATH}"
fi

ACTUAL_SHA256="$(shasum -a 256 "${ARCHIVE_PATH}" | awk '{print $1}')"
if [[ "${ACTUAL_SHA256}" != "${EXPECTED_SHA256}" ]]; then
	printf 'Godot archive checksum mismatch. Expected %s, got %s.\n' "${EXPECTED_SHA256}" "${ACTUAL_SHA256}" >&2
	exit 1
fi

mkdir -p "${TEMP_DIR}/unpacked"
unzip -q "${ARCHIVE_PATH}" -d "${TEMP_DIR}/unpacked"
if [[ ! -d "${TEMP_DIR}/unpacked/Godot.app" ]]; then
	printf 'The verified archive did not contain Godot.app.\n' >&2
	exit 1
fi
ditto "${TEMP_DIR}/unpacked/Godot.app" "${APP_PATH}"
chmod +x "${GODOT_BIN}"
printf '%s\n' "${GODOT_BIN}"
