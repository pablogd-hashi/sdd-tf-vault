#!/usr/bin/env bash
# Validate phase order gates for a request directory.
set -euo pipefail

REQUEST="${1:?Usage: check-phase-order.sh <request-id>}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REQ_DIR="${ROOT_DIR}/requests/${REQUEST}"

die() { echo "[check-phase] ERROR: $*" >&2; exit 1; }
warn() { echo "[check-phase] WARN: $*" >&2; }

[ -d "${REQ_DIR}" ] || die "Request directory not found: ${REQ_DIR}"

has_approval() {
  local file="$1"
  [ -f "${file}" ] && grep -qE '\|.*\|.*\|.*☑|\|.*\|.*\|.*✓|\|.*\|.*\|.*yes' "${file}"
}

# Phase 02 requires approved spec
if [ -f "${REQ_DIR}/02-plan/plan.md" ]; then
  [ -f "${REQ_DIR}/01-spec/spec.md" ] || die "02-plan exists but 01-spec/spec.md missing"
  has_approval "${REQ_DIR}/01-spec/spec.md" || warn "02-plan exists but spec sign-off not marked approved"
fi

# Phase 03 requires approved plan
if [ -d "${REQ_DIR}/03-terraform" ] && [ -n "$(ls -A "${REQ_DIR}/03-terraform" 2>/dev/null)" ]; then
  [ -f "${REQ_DIR}/02-plan/plan.md" ] || die "03-terraform exists but 02-plan/plan.md missing"
  has_approval "${REQ_DIR}/02-plan/plan.md" || warn "03-terraform exists but plan sign-off not marked approved"
fi

# Phase 04 requires terraform
if [ -f "${REQ_DIR}/04-validation/report.md" ]; then
  [ -f "${REQ_DIR}/03-terraform/main.tf" ] || die "04-validation exists but 03-terraform/main.tf missing"
fi

# Phase 05 requires validation pass
if [ -f "${REQ_DIR}/05-review/bugbot.md" ]; then
  [ -f "${REQ_DIR}/04-validation/report.md" ] || die "05-review exists but 04-validation/report.md missing"
  grep -qE "PASS" "${REQ_DIR}/04-validation/report.md" || warn "05-review exists but validation verdict not PASS"
fi

# Phase 06 requires bugbot pass
if [ -f "${REQ_DIR}/06-pr/metadata.json" ]; then
  [ -f "${REQ_DIR}/05-review/bugbot.md" ] || die "06-pr exists but 05-review/bugbot.md missing"
fi

echo "[check-phase] Phase order OK for ${REQUEST}"
