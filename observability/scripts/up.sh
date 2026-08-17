#!/usr/bin/env bash
# Bring up the observability stack (OTel, Prometheus, Loki, Grafana, Jaeger, Vault).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
COMPOSE_FILE="${ROOT_DIR}/observability/docker-compose.yml"

log() { echo "[observability] $*"; }
die() { echo "[observability] ERROR: $*" >&2; exit 1; }

command -v docker >/dev/null 2>&1 || die "Docker is required to start observability"
docker info >/dev/null 2>&1 || die "Docker is not running"

log "Starting compose stack..."
docker compose -f "${COMPOSE_FILE}" up -d

wait_http() {
  local url="$1" name="$2"
  local i
  for i in $(seq 1 45); do
    if curl -sf "${url}" >/dev/null 2>&1; then
      log "${name} ready (${url})"
      return 0
    fi
    sleep 1
  done
  die "${name} did not become ready at ${url}"
}

wait_http "http://127.0.0.1:8200/v1/sys/health" "Vault"
wait_http "http://127.0.0.1:9090/-/ready" "Prometheus"
wait_http "http://127.0.0.1:3000/api/health" "Grafana"

log "Jaeger UI:     http://127.0.0.1:16686"
log "Prometheus:    http://127.0.0.1:9090"
log "Grafana:       http://127.0.0.1:3000  (admin/admin)"
log "  Factory:     http://127.0.0.1:3000/d/factory-operations/factory-operations"
log "  Vault:       http://127.0.0.1:3000/d/vault-onboarding/vault-onboarding"
log "OTLP HTTP:     http://127.0.0.1:4318"
