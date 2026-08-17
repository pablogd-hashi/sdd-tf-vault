#!/usr/bin/env bash
# Print factory / observability health and dashboard URLs.
set -euo pipefail

check() {
  local name="$1" url="$2"
  if curl -sf --max-time 2 "${url}" >/dev/null 2>&1; then
    printf "  %-14s UP    %s\n" "${name}" "${url}"
  else
    printf "  %-14s DOWN  %s\n" "${name}" "${url}"
  fi
}

echo "Software factory status"
echo ""
check "Vault" "http://127.0.0.1:8200/v1/sys/health"
check "Prometheus" "http://127.0.0.1:9090/-/ready"
check "Grafana" "http://127.0.0.1:3000/api/health"
check "Jaeger" "http://127.0.0.1:16686"
check "Loki" "http://127.0.0.1:3100/ready"
check "OTLP HTTP" "http://127.0.0.1:4318/"

echo ""
echo "Dashboards"
echo "  Factory Operations: http://127.0.0.1:3000/d/factory-operations/factory-operations"
echo "  Vault Onboarding:   http://127.0.0.1:3000/d/vault-onboarding/vault-onboarding"
echo "  Grafana login:      admin / admin"

if command -v docker >/dev/null 2>&1; then
  echo ""
  echo "Compose services"
  docker compose -f "$(cd "$(dirname "$0")/../.." && pwd)/observability/docker-compose.yml" ps --format 'table {{.Name}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null || true
fi
