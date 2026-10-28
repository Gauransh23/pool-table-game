#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CXX="${CXX:-c++}"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/long-rail-native.XXXXXX")"
trap 'rm -rf "${TEMP_DIR}"' EXIT
OUTPUT="${TEMP_DIR}/physics_core_tests"

"${CXX}" \
	-std=c++17 \
	-O3 \
	-ffp-contract=off \
	-fno-fast-math \
	-Wall -Wextra -Werror \
	-I "${ROOT}/native/include" \
	"${ROOT}/native/src/physics_core.cpp" \
	"${ROOT}/native/tests/physics_core_tests.cpp" \
	-o "${OUTPUT}"

"${OUTPUT}" "$@"
