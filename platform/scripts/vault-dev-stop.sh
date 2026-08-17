#!/usr/bin/env bash
# Stop host Vault -dev started by vault-dev.sh. Does not stop Docker Compose Vault
# (use observability/scripts/down.sh or task stop-factory).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PID_FILE="${ROOT_DIR}/.vault-dev.pid"
STATE_FILE="${ROOT_DIR}/.platform-state"

log() { echo "[vault-dev-stop] $*"; }

if [ -f "${PID_FILE}" ]; then
  PID="$(cat "${PID_FILE}")"
  if kill -0 "${PID}" 2>/dev/null; then
    log "Stopping host Vault (pid ${PID})..."
    kill "${PID}" 2>/dev/null || true
    sleep 1
    kill -9 "${PID}" 2>/dev/null || true
  fi
  rm -f "${PID_FILE}"
fi

if [ -f "${STATE_FILE}" ]; then
  rm -f "${STATE_FILE}"
fi

log "Host Vault -dev stopped."
