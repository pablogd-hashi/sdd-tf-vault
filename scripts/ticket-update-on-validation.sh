#!/usr/bin/env bash
# Post ticket comment after successful autonomous validation.
# Writes requests/<id>/07-ticket-update/comment.md; agent posts via provider MCP.
set -euo pipefail

REQUEST="${1:?Usage: ticket-update-on-validation.sh <request-id>}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REQ_DIR="${ROOT_DIR}/requests/${REQUEST}"
REPORT="${REQ_DIR}/04-validation/report.md"
COMMENT_FILE="${REQ_DIR}/07-ticket-update/comment.md"
AUTONOMOUS="${REQ_DIR}/01-spec/autonomous.json"
SPEC="${REQ_DIR}/01-spec/spec.md"
TF="${REQ_DIR}/03-terraform/main.tf"
META="${REQ_DIR}/06-pr/metadata.json"

log() { echo "[ticket-update] $*"; }
die() { echo "[ticket-update] ERROR: $*" >&2; exit 1; }

[ -f "${REPORT}" ] || die "Validation report not found: ${REPORT}"
grep -qE "PASS" "${REPORT}" || die "Validation verdict is not PASS — refusing ticket update"

TICKET_ID="$(echo "${REQUEST}" | grep -oE '^[A-Z]+-[0-9]+' || echo "${REQUEST%%-*}")"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Resolve provider: autonomous.json → spec header → TICKET_PROVIDER env → jira
PROVIDER=""
if [ -f "${AUTONOMOUS}" ]; then
  PROVIDER="$(grep -oE '"ticket_provider"[[:space:]]*:[[:space:]]*"[^"]+"' "${AUTONOMOUS}" | head -1 | sed -E 's/.*"([^"]+)"[[:space:]]*$/\1/' || true)"
fi
if [ -z "${PROVIDER}" ] && [ -f "${SPEC}" ]; then
  PROVIDER="$(grep -iE '\| \*\*Ticket provider\*\*' "${SPEC}" | head -1 | sed -E 's/.*\|[[:space:]]*([^|]+)[[:space:]]*\|[[:space:]]*$/\1/' | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]' || true)"
fi
if [ -z "${PROVIDER}" ]; then
  PROVIDER="${TICKET_PROVIDER:-jira}"
fi
case "${PROVIDER}" in
  jira|linear|pasted) ;;
  *) die "Unknown ticket_provider '${PROVIDER}' (expected jira|linear|pasted)" ;;
esac

# Idempotency: skip rewrite if comment already exists for same commit_sha
COMMIT_SHA=""
if [ -f "${META}" ]; then
  COMMIT_SHA="$(grep -oE '"commit_sha"[[:space:]]*:[[:space:]]*"[^"]+"' "${META}" | head -1 | sed -E 's/.*"([^"]+)"[[:space:]]*$/\1/' || true)"
fi
if [ -f "${COMMENT_FILE}" ] && [ -n "${COMMIT_SHA}" ]; then
  if grep -qE "(^|\\*\\*)commit_sha:\\*?\\*?[[:space:]]*\`?${COMMIT_SHA}\`?" "${COMMENT_FILE}" 2>/dev/null \
    || grep -qF "commit_sha: ${COMMIT_SHA}" "${COMMENT_FILE}" 2>/dev/null \
    || grep -qF "**commit_sha:** ${COMMIT_SHA}" "${COMMENT_FILE}" 2>/dev/null; then
    log "Comment already recorded for commit_sha ${COMMIT_SHA} — skipping rewrite (idempotent)"
    log "Provider: ${PROVIDER} | Ticket: ${TICKET_ID}"
    exit 0
  fi
fi

# Extract policy/role from terraform if possible
POLICY_NAME=""
ROLE_NAME=""
if [ -f "${TF}" ]; then
  POLICY_NAME="$(grep -E '[[:space:]]team[[:space:]]*=' "${TF}" | head -1 | sed -E 's/.*=[[:space:]]*"([^"]+)".*/\1/' || true)"
  SERVICE_NAME="$(grep -E '[[:space:]]service_name[[:space:]]*=' "${TF}" | head -1 | sed -E 's/.*=[[:space:]]*"([^"]+)".*/\1/' || true)"
  # Reject if sed failed to extract (still contains '=')
  if [[ "${POLICY_NAME}" == *"="* ]]; then POLICY_NAME=""; fi
  if [[ "${SERVICE_NAME}" == *"="* ]]; then SERVICE_NAME=""; fi
  if [ -n "${POLICY_NAME}" ] && [ -n "${SERVICE_NAME}" ]; then
    POLICY_NAME="${POLICY_NAME}-${SERVICE_NAME}"
    ROLE_NAME="${POLICY_NAME}"
  fi
fi

MCP_HINT="Atlassian MCP"
if [ "${PROVIDER}" = "linear" ]; then
  MCP_HINT="Linear MCP"
elif [ "${PROVIDER}" = "pasted" ]; then
  MCP_HINT="none (pasted request — do not post to Jira/Linear)"
fi

mkdir -p "${REQ_DIR}/07-ticket-update"

COMMIT_LINE=""
if [ -n "${COMMIT_SHA}" ]; then
  COMMIT_LINE="**commit_sha:** ${COMMIT_SHA}"
fi

cat > "${COMMENT_FILE}" <<EOF
# Ticket Update Comment

**Ticket:** ${TICKET_ID}
**Ticket provider:** ${PROVIDER}
**Posted at:** ${TIMESTAMP}
**Trigger:** Autonomous validation PASS
${COMMIT_LINE}

---

Infrastructure implementation for \`${REQUEST}\` completed and validated.

**Validation:** PASS — see \`requests/${REQUEST}/04-validation/report.md\`

**Artifacts:**
- Spec: \`requests/${REQUEST}/01-spec/spec.md\`
- Plan: \`requests/${REQUEST}/02-plan/plan.md\`
- Terraform: \`requests/${REQUEST}/03-terraform/main.tf\`

**Resources:**
- Policy: \`${POLICY_NAME:-see terraform outputs}\`
- Role: \`${ROLE_NAME:-see terraform outputs}\`

**Next steps:** Reviewer evaluation and PR creation pending human approval.
EOF

log "Draft comment written to ${COMMENT_FILE}"
log "Ticket: ${TICKET_ID} | Provider: ${PROVIDER}"
log "Agent should post comment via ${MCP_HINT} using content from ${COMMENT_FILE}"
log "Done."
