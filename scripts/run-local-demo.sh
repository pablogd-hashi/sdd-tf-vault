#!/usr/bin/env bash
# Skill-driven local IDE demo: Grafana stack + evals + golden onboard.
# Requires Docker Desktop (or a running dockerd). Does not require go-task.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REQUEST="${1:-PE-001-payments-api}"

log() { echo "[local-demo] $*"; }
die() { echo "[local-demo] ERROR: $*" >&2; exit 1; }

chmod +x "${ROOT}/observability/scripts/"*.sh \
  "${ROOT}/platform/scripts/"*.sh \
  "${ROOT}/scripts/"*.sh \
  "${ROOT}/evals/score.sh"

command -v docker >/dev/null 2>&1 || die "Docker CLI not found. Install Docker Desktop, then retry."
if ! docker info >/dev/null 2>&1; then
  die "Docker is not running. Start Docker Desktop, wait until it is idle, then say \"run the local demo\" again."
fi
command -v terraform >/dev/null 2>&1 || die "terraform is required on PATH."

log "Freeing :8200 if a host Vault -dev is holding it..."
"${ROOT}/platform/scripts/vault-dev-stop.sh" || true

log "Starting observability (Grafana, Prometheus, Loki, Jaeger, OTel, Vault)..."
"${ROOT}/observability/scripts/up.sh"

log "Applying platform kubernetes auth mount..."
"${ROOT}/scripts/factory-environment.sh"

if [ ! -f "${ROOT}/.cursor/mcp.json" ] && [ -f "${ROOT}/.cursor/mcp.json.example" ]; then
  cp "${ROOT}/.cursor/mcp.json.example" "${ROOT}/.cursor/mcp.json"
  log "Wrote .cursor/mcp.json from example. Reload MCP in Cursor (Grafana + Prometheus on localhost)."
fi

log "Running evals..."
"${ROOT}/evals/score.sh"

log "Validating ${REQUEST}..."
"${ROOT}/scripts/validate-change.sh" "${REQUEST}"

log "Applying ${REQUEST}..."
"${ROOT}/scripts/apply-request.sh" "${REQUEST}"

log "Dashboards + status..."
"${ROOT}/observability/scripts/dashboards.sh"
"${ROOT}/observability/scripts/status.sh"

echo ""
echo "Local demo complete."
echo "  Grafana: http://127.0.0.1:3000  (admin / admin)"
echo "  Vault:   http://127.0.0.1:8200  (token root)"
echo "In Cursor, next: show the dashboard · factory status · list Grafana dashboards"
echo "Tear down: stop the factory"
