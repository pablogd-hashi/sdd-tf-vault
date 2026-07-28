#!/usr/bin/env bash
# Ensure Vault port-forward is running (source from Makefile/scripts).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_FILE="${ROOT_DIR}/.platform-state"

if [ -f "${STATE_FILE}" ]; then
  # shellcheck disable=SC1090
  source "${STATE_FILE}"
fi

KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME:-pe-copilot}"
VAULT_NAMESPACE="${VAULT_NAMESPACE:-vault}"
VAULT_RELEASE="${VAULT_RELEASE:-vault}"
VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"

if curl -sf "${VAULT_ADDR}/v1/sys/health" >/dev/null 2>&1; then
  exit 0
fi

echo "[vault-ready] Starting port-forward to ${VAULT_ADDR}..."
nohup kubectl port-forward svc/"${VAULT_RELEASE}" 8200:8200 \
  -n "${VAULT_NAMESPACE}" \
  --context "kind-${KIND_CLUSTER_NAME}" \
  >> "${ROOT_DIR}/.vault-port-forward.log" 2>&1 &

for i in $(seq 1 15); do
  if curl -sf "${VAULT_ADDR}/v1/sys/health" >/dev/null 2>&1; then
    echo "[vault-ready] Vault reachable"
    exit 0
  fi
  sleep 1
done

echo "[vault-ready] ERROR: Vault not reachable at ${VAULT_ADDR}" >&2
exit 1
