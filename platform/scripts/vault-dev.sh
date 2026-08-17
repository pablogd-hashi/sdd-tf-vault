#!/usr/bin/env bash
# Start Vault in -dev mode for the software factory (no Kind).
# Prefers Docker Compose service "vault"; falls back to the vault binary on PATH.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STATE_FILE="${ROOT_DIR}/.platform-state"
PID_FILE="${ROOT_DIR}/.vault-dev.pid"
LOG_FILE="${ROOT_DIR}/.vault-dev.log"
VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
VAULT_TOKEN="${VAULT_TOKEN:-root}"
COMPOSE_FILE="${ROOT_DIR}/observability/docker-compose.yml"

log() { echo "[vault-dev] $*"; }
die() { echo "[vault-dev] ERROR: $*" >&2; exit 1; }

write_state() {
  cat > "${STATE_FILE}" <<EOF
VAULT_ADDR=${VAULT_ADDR}
VAULT_TOKEN=${VAULT_TOKEN}
FACTORY_RUNTIME=vault-dev
EOF
}

if curl -sf "${VAULT_ADDR}/v1/sys/health" >/dev/null 2>&1; then
  log "Vault already reachable at ${VAULT_ADDR}"
  write_state
  exit 0
fi

start_compose_vault() {
  command -v docker >/dev/null 2>&1 || return 1
  docker info >/dev/null 2>&1 || return 1
  [ -f "${COMPOSE_FILE}" ] || return 1
  log "Starting Vault via Docker Compose..."
  docker compose -f "${COMPOSE_FILE}" up -d vault
  local i
  for i in $(seq 1 30); do
    if curl -sf "${VAULT_ADDR}/v1/sys/health" >/dev/null 2>&1; then
      log "Vault reachable at ${VAULT_ADDR} (compose)"
      write_state
      return 0
    fi
    sleep 1
  done
  return 1
}

start_host_vault() {
  command -v vault >/dev/null 2>&1 || return 1
  log "Starting Vault binary in -dev mode..."
  nohup vault server \
    -dev \
    -dev-root-token-id="${VAULT_TOKEN}" \
    -dev-listen-address=127.0.0.1:8200 \
    -config="${ROOT_DIR}/platform/vault-dev.hcl" \
    >> "${LOG_FILE}" 2>&1 &
  echo $! > "${PID_FILE}"
  local i
  for i in $(seq 1 20); do
    if curl -sf "${VAULT_ADDR}/v1/sys/health" >/dev/null 2>&1; then
      log "Vault reachable at ${VAULT_ADDR} (host pid $(cat "${PID_FILE}"))"
      write_state
      echo "VAULT_DEV_PID=$(cat "${PID_FILE}")" >> "${STATE_FILE}"
      return 0
    fi
    sleep 1
  done
  return 1
}

if start_compose_vault; then
  exit 0
fi

if start_host_vault; then
  exit 0
fi

die "Could not start Vault. Install Docker (preferred) or the Vault binary, then retry."
