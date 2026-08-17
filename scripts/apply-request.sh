#!/usr/bin/env bash
# Apply a request's Terraform against local Vault. Used by apply-onboarding skill.
set -euo pipefail

REQUEST="${1:?Usage: apply-request.sh <request-id>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="${ROOT}/requests/${REQUEST}/03-terraform"

export VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
export VAULT_TOKEN="${VAULT_TOKEN:-root}"

[ -f "${TF_DIR}/main.tf" ] || { echo "ERROR: ${TF_DIR}/main.tf not found" >&2; exit 1; }

terraform -chdir="${TF_DIR}" init -input=false
terraform -chdir="${TF_DIR}" apply -auto-approve

echo ""
echo "Applied ${REQUEST} against ${VAULT_ADDR}"
echo "Confirm: vault policy read <team>-<service>"
