#!/usr/bin/env bash
# One-shot factory environment: Vault -dev + kubernetes auth mount.
# Used by the start-environment skill. Does not require go-task.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
chmod +x "${ROOT}/platform/scripts/vault-dev.sh" "${ROOT}/scripts/ensure-vault-ready.sh"

"${ROOT}/platform/scripts/vault-dev.sh"
terraform -chdir="${ROOT}/terraform/platform" init -input=false
terraform -chdir="${ROOT}/terraform/platform" apply -auto-approve

ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
echo ""
echo "Vault: ${ADDR}  (token root)"
echo "Next: ./evals/score.sh"
echo "      terraform -chdir=requests/PE-001-payments-api/03-terraform apply -auto-approve"
echo "Grafana (needs Docker): ./observability/scripts/up.sh"
