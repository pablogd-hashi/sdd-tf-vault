#!/usr/bin/env bash
# Tear down local Kind cluster and stop port-forward.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME:-pe-copilot}"
STATE_FILE="${ROOT_DIR}/.platform-state"

log() { echo "[teardown] $*"; }

if [ -f "${STATE_FILE}" ]; then
  # shellcheck disable=SC1090
  source "${STATE_FILE}" 2>/dev/null || true
  if [ -n "${PF_PID:-}" ] && kill -0 "${PF_PID}" 2>/dev/null; then
    log "Stopping Vault port-forward (pid ${PF_PID})..."
    kill "${PF_PID}" 2>/dev/null || true
  fi
  rm -f "${STATE_FILE}"
fi

if kind get clusters 2>/dev/null | grep -qx "${KIND_CLUSTER_NAME}"; then
  log "Deleting Kind cluster '${KIND_CLUSTER_NAME}'..."
  kind delete cluster --name "${KIND_CLUSTER_NAME}"
else
  log "Kind cluster '${KIND_CLUSTER_NAME}' not found; nothing to delete"
fi

log "Teardown complete."
