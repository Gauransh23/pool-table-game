#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${GODOT:-}" ]]; then
	GODOT_BIN="${GODOT}"
else
	GODOT_BIN="$(bash "${SCRIPT_DIR}/fetch_godot.sh")"
fi
exec "${GODOT_BIN}" "$@"
