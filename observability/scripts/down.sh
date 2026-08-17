#!/usr/bin/env bash
# Stop the observability compose stack (includes compose Vault).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
COMPOSE_FILE="${ROOT_DIR}/observability/docker-compose.yml"

echo "[observability] Stopping compose stack..."
docker compose -f "${COMPOSE_FILE}" down
echo "[observability] Stopped."
