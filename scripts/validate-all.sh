#!/usr/bin/env bash
# Validate all request directories (excluding _template).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=0

for dir in "${ROOT_DIR}"/requests/*/; do
  name="$(basename "${dir}")"
  [ "${name}" = "_template" ] && continue
  echo "=== Validating ${name} ==="
  if ! "${ROOT_DIR}/scripts/validate-request.sh" "${name}"; then
    FAILED=$((FAILED + 1))
  fi
done

if [ "${FAILED}" -gt 0 ]; then
  echo "${FAILED} request(s) failed validation"
  exit 1
fi

echo "All requests passed validation"
