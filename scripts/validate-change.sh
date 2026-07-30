#!/usr/bin/env bash
# Extended validation for autonomous delivery:
# fmt → validate → terraform test → terratest → conftest → trivy → tflint → plan
set -euo pipefail

REQUEST="${1:?Usage: validate-change.sh <request-id>}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REQ_DIR="${ROOT_DIR}/requests/${REQUEST}"
TF_DIR="${REQ_DIR}/03-terraform"
REPORT="${REQ_DIR}/04-validation/report.md"
VAL_DIR="${REQ_DIR}/04-validation"
TMP_PLAN="${VAL_DIR}/plan.out"

VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
VAULT_TOKEN="${VAULT_TOKEN:-root}"

log() { echo "[validate-change] $*"; }
die() { echo "[validate-change] ERROR: $*" >&2; exit 1; }

[ -d "${TF_DIR}" ] || die "Terraform directory not found: ${TF_DIR}"
[ -f "${TF_DIR}/main.tf" ] || die "main.tf not found in ${TF_DIR}"

mkdir -p "${VAL_DIR}"

if [ -f "${ROOT_DIR}/.platform-state" ]; then
  "${ROOT_DIR}/scripts/ensure-vault-ready.sh" >/dev/null 2>&1 || true
fi

"${ROOT_DIR}/scripts/check-phase-order.sh" "${REQUEST}" || true

FMT_RESULT="SKIP"
VALIDATE_RESULT="SKIP"
TFTEST_RESULT="SKIP"
TERRATEST_RESULT="SKIP"
CONFTEST_RESULT="SKIP"
TRIVY_RESULT="SKIP"
TFLINT_RESULT="SKIP"
PLAN_RESULT="SKIP"
PLAN_SUMMARY=""
VERDICT="FAIL"

cd "${TF_DIR}"

# 1. terraform fmt
log "Running terraform fmt -check..."
if terraform fmt -check -recursive . > "${VAL_DIR}/fmt.out" 2>&1; then
  FMT_RESULT="PASS"
else
  log "Auto-fixing formatting..."
  terraform fmt -recursive . > "${VAL_DIR}/fmt-fix.out" 2>&1
  if terraform fmt -check -recursive . > "${VAL_DIR}/fmt-recheck.out" 2>&1; then
    FMT_RESULT="PASS (auto-fixed)"
  else
    FMT_RESULT="FAIL"
  fi
fi

# 2. terraform validate
log "Running terraform init..."
terraform init -backend=false -input=false > "${VAL_DIR}/init.out" 2>&1

log "Running terraform validate..."
if terraform validate > "${VAL_DIR}/validate.out" 2>&1; then
  VALIDATE_RESULT="PASS"
else
  VALIDATE_RESULT="FAIL"
fi

# 3. terraform test
if compgen -G "${TF_DIR}/*.tftest.hcl" > /dev/null || compgen -G "${TF_DIR}/tests/*.tftest.hcl" > /dev/null; then
  log "Running terraform test..."
  if terraform test > "${VAL_DIR}/tftest.out" 2>&1; then
    TFTEST_RESULT="PASS"
  else
    TFTEST_RESULT="FAIL"
  fi
else
  TFTEST_RESULT="SKIP (no .tftest.hcl in request)"
  echo "No terraform test files in ${TF_DIR}" > "${VAL_DIR}/tftest.out"
fi

# Also run module-level terraform test if present
MODULE_DIR="${ROOT_DIR}/terraform/modules/vault-service-onboard"
if compgen -G "${MODULE_DIR}/*.tftest.hcl" > /dev/null; then
  log "Running module terraform test..."
  (
    cd "${MODULE_DIR}"
    terraform init -backend=false -input=false > "${VAL_DIR}/module-init.out" 2>&1
    if terraform test > "${VAL_DIR}/module-tftest.out" 2>&1; then
      if [[ "${TFTEST_RESULT}" == SKIP* ]]; then
        TFTEST_RESULT="PASS"
      fi
      echo "module-tftest: PASS" >> "${VAL_DIR}/tftest.out"
    else
      TFTEST_RESULT="FAIL"
      echo "module-tftest: FAIL" >> "${VAL_DIR}/tftest.out"
    fi
  )
fi

# 4. Terratest (go test)
log "Running Terratest..."
if [ "${SKIP_VAULT_TESTS:-}" = "true" ]; then
  TERRATEST_RESULT="SKIP (SKIP_VAULT_TESTS=true)"
  echo "Skipped via SKIP_VAULT_TESTS" > "${VAL_DIR}/terratest.out"
elif curl -sf "${VAULT_ADDR}/v1/sys/health" >/dev/null 2>&1; then
  export VAULT_ADDR VAULT_TOKEN
  if (cd "${ROOT_DIR}/tests" && go test -v -count=1 -timeout 10m ./... > "${VAL_DIR}/terratest.out" 2>&1); then
    TERRATEST_RESULT="PASS"
  else
    TERRATEST_RESULT="FAIL"
  fi
else
  TERRATEST_RESULT="SKIP (Vault unreachable at ${VAULT_ADDR})"
  echo "Vault unreachable — run 'make bootstrap && make platform-apply'" > "${VAL_DIR}/terratest.out"
fi

# 5. conftest (plan JSON policy)
CONFTEST_INPUT="${VAL_DIR}/plan.json"
if command -v conftest >/dev/null 2>&1; then
  log "Running conftest..."
  if curl -sf "${VAULT_ADDR}/v1/sys/health" >/dev/null 2>&1; then
    export VAULT_ADDR VAULT_TOKEN
    terraform plan -input=false -no-color -out="${TMP_PLAN}.tfplan" > "${TMP_PLAN}" 2>&1 || true
    if [ -f "${TMP_PLAN}.tfplan" ]; then
      terraform show -json "${TMP_PLAN}.tfplan" > "${CONFTEST_INPUT}" 2>/dev/null || echo '{}' > "${CONFTEST_INPUT}"
    else
      echo '{}' > "${CONFTEST_INPUT}"
    fi
  else
    # Fall back to scanning HCL when Vault unavailable
    terraform show -json > "${CONFTEST_INPUT}" 2>/dev/null || echo '{}' > "${CONFTEST_INPUT}"
  fi

  POLICY_DIR="${ROOT_DIR}/policies/conftest"
  if [ -d "${POLICY_DIR}" ] && [ -s "${CONFTEST_INPUT}" ] && grep -q "planned_values" "${CONFTEST_INPUT}" 2>/dev/null; then
    if conftest test "${CONFTEST_INPUT}" -p "${POLICY_DIR}" > "${VAL_DIR}/conftest.out" 2>&1; then
      CONFTEST_RESULT="PASS"
    else
      CONFTEST_RESULT="FAIL"
    fi
  elif [ ! -d "${POLICY_DIR}" ]; then
    CONFTEST_RESULT="SKIP (no policies in policies/conftest/)"
    echo "No policy directory" > "${VAL_DIR}/conftest.out"
  else
    CONFTEST_RESULT="SKIP (no plan JSON — Vault unreachable)"
    echo "Plan JSON unavailable" > "${VAL_DIR}/conftest.out"
  fi
else
  CONFTEST_RESULT="SKIP (conftest not installed)"
  echo "Install: https://www.conftest.dev/" > "${VAL_DIR}/conftest.out"
fi

# 6. trivy config scan
if command -v trivy >/dev/null 2>&1; then
  log "Running trivy config..."
  if trivy config --severity HIGH,CRITICAL "${TF_DIR}" > "${VAL_DIR}/trivy.out" 2>&1; then
    TRIVY_RESULT="PASS"
  else
    TRIVY_RESULT="FAIL"
  fi
else
  TRIVY_RESULT="SKIP (trivy not installed)"
  echo "Install: https://aquasecurity.github.io/trivy/" > "${VAL_DIR}/trivy.out"
fi

# 7. tflint (legacy check preserved)
if command -v tflint >/dev/null 2>&1; then
  log "Running tflint..."
  if tflint --init > "${VAL_DIR}/tflint-init.out" 2>&1 && tflint > "${VAL_DIR}/tflint.out" 2>&1; then
    TFLINT_RESULT="PASS"
  else
    TFLINT_RESULT="FAIL"
  fi
else
  TFLINT_RESULT="SKIP (not installed)"
  echo "Optional — install tflint for lint coverage" > "${VAL_DIR}/tflint.out"
fi

# 8. terraform plan (legacy check preserved)
if curl -sf "${VAULT_ADDR}/v1/sys/health" >/dev/null 2>&1; then
  log "Running terraform plan against ${VAULT_ADDR}..."
  export VAULT_ADDR VAULT_TOKEN
  if terraform plan -input=false -no-color -out="${TMP_PLAN}.tfplan" > "${TMP_PLAN}" 2>&1; then
    PLAN_RESULT="PASS"
    PLAN_SUMMARY="$(tail -20 "${TMP_PLAN}")"
  else
    PLAN_RESULT="FAIL"
    PLAN_SUMMARY="$(cat "${TMP_PLAN}")"
  fi
else
  PLAN_RESULT="SKIP (Vault unreachable at ${VAULT_ADDR})"
  PLAN_SUMMARY="Run 'make bootstrap && make platform-apply' to enable plan validation."
fi

# Verdict: fmt + validate must pass; any installed check that ran and failed blocks PASS
passes_core() {
  [[ "${FMT_RESULT}" == PASS* ]] && [[ "${VALIDATE_RESULT}" == "PASS" ]]
}

no_failures() {
  local result
  for result in "${TFTEST_RESULT}" "${TERRATEST_RESULT}" "${CONFTEST_RESULT}" "${TRIVY_RESULT}" "${TFLINT_RESULT}" "${PLAN_RESULT}"; do
    if [[ "${result}" == "FAIL" ]]; then
      return 1
    fi
  done
  return 0
}

if passes_core && no_failures; then
  if [[ "${PLAN_RESULT}" == "PASS" ]]; then
    VERDICT="PASS"
  elif [[ "${PLAN_RESULT}" == SKIP* ]]; then
    VERDICT="PASS (plan skipped — Vault unavailable)"
  fi
fi

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
TICKET_ID="$(echo "${REQUEST}" | grep -oE '^[A-Z]+-[0-9]+' || echo "${REQUEST%%-*}")"

cat > "${REPORT}" <<EOF
# Validation Report

| Field | Value |
|-------|-------|
| **Ticket** | ${TICKET_ID} |
| **Request** | ${REQUEST} |
| **Generated by** | \`scripts/validate-change.sh\` |
| **Pipeline** | autonomous (fmt → validate → test → conftest → trivy) |
| **Timestamp** | ${TIMESTAMP} |
| **Status** | ${VERDICT} |

## Results

| Check | Result | Output |
|-------|--------|--------|
| \`terraform fmt -check\` | ${FMT_RESULT} | [fmt.out](fmt.out) |
| \`terraform validate\` | ${VALIDATE_RESULT} | [validate.out](validate.out) |
| \`terraform test\` | ${TFTEST_RESULT} | [tftest.out](tftest.out) |
| Terratest | ${TERRATEST_RESULT} | [terratest.out](terratest.out) |
| \`conftest test\` | ${CONFTEST_RESULT} | [conftest.out](conftest.out) |
| \`trivy config\` | ${TRIVY_RESULT} | [trivy.out](trivy.out) |
| \`tflint\` | ${TFLINT_RESULT} | [tflint.out](tflint.out) |
| \`terraform plan\` | ${PLAN_RESULT} | [plan.out](plan.out) |

## Plan summary

\`\`\`
${PLAN_SUMMARY}
\`\`\`

## Verdict

- $([[ "${VERDICT}" == PASS* ]] && echo "[x]" || echo "[ ]") PASS — proceed to reviewer and ticket update
- $([[ "${VERDICT}" != PASS* ]] && echo "[x]" || echo "[ ]") FAIL — fix issues and re-run \`make validate-change REQUEST=${REQUEST}\`
EOF

log "Report written to ${REPORT}"
log "Verdict: ${VERDICT}"

[[ "${VERDICT}" == PASS* ]] || exit 1
