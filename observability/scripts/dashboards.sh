#!/usr/bin/env bash
# Print Grafana dashboard URLs (and open them when possible).
set -euo pipefail

FACTORY="http://127.0.0.1:3000/d/factory-operations/factory-operations"
VAULT="http://127.0.0.1:3000/d/vault-onboarding/vault-onboarding"

echo "Factory Operations: ${FACTORY}"
echo "Vault Onboarding:   ${VAULT}"
echo "Grafana (admin/admin): http://127.0.0.1:3000"

if curl -sf --max-time 2 "http://127.0.0.1:3000/api/health" >/dev/null 2>&1; then
  echo "Grafana is up."
else
  echo "Grafana is down. Say \"start observability\" first." >&2
  exit 1
fi

open_url() {
  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$1" >/dev/null 2>&1 || true
  elif command -v open >/dev/null 2>&1; then
    open "$1" >/dev/null 2>&1 || true
  fi
}

open_url "${FACTORY}"
open_url "${VAULT}"
