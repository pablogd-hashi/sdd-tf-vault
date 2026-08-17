#!/usr/bin/env bash
# Deterministic factory evals. Scores checked-in goldens; no API key required.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OTEL="${ROOT}/scripts/factory-otel.sh"
PASS=0
FAIL=0
RESULTS=()

ok() { PASS=$((PASS + 1)); RESULTS+=("PASS  $1"); echo "PASS  $1"; }
bad() { FAIL=$((FAIL + 1)); RESULTS+=("FAIL  $1 — $2"); echo "FAIL  $1 — $2"; }

extract_tf_attr() {
  local file="$1" key="$2"
  python3 - "$file" "$key" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
key = sys.argv[2]
# secret_paths = ["config", "db"]
if key == "secret_paths":
    m = re.search(r'secret_paths\s*=\s*\[([^\]]*)\]', text)
    if not m:
        print("")
        raise SystemExit(0)
    vals = re.findall(r'"([^"]+)"', m.group(1))
    print(",".join(vals))
    raise SystemExit(0)
m = re.search(rf'{re.escape(key)}\s*=\s*"([^"]+)"', text)
print(m.group(1) if m else "")
PY
}

spec_has() {
  local file="$1" needle="$2"
  grep -q "$needle" "$file"
}

# --- happy-payments-api ---
CASE="happy-payments-api"
SPEC="${ROOT}/requests/PE-001-payments-api/01-spec/spec.md"
TF="${ROOT}/requests/PE-001-payments-api/03-terraform/main.tf"
if spec_has "$SPEC" "payments-api" && spec_has "$SPEC" "**Ticket provider**" && spec_has "$SPEC" "R1" && spec_has "$SPEC" "R5"; then
  SVC="$(extract_tf_attr "$TF" "service_name")"
  TEAM="$(extract_tf_attr "$TF" "team")"
  NS="$(extract_tf_attr "$TF" "namespace")"
  SA="$(extract_tf_attr "$TF" "service_account")"
  PATHS="$(extract_tf_attr "$TF" "secret_paths")"
  if [ "$SVC" = "payments-api" ] && [ "$TEAM" = "payments" ] && [ "$NS" = "payments" ] && [ "$SA" = "payments-api" ] && [ "$PATHS" = "config,db" ]; then
    ok "$CASE (spec R1–R5 mapped verbatim into Terraform)"
  else
    bad "$CASE" "Terraform inputs mismatch spec (got service=$SVC paths=$PATHS)"
  fi
else
  bad "$CASE" "PE-001 spec missing required fields"
fi

# --- reject-missing-namespace ---
CASE="reject-missing-namespace"
REJECT_JSON="${ROOT}/evals/golden/reject-missing-namespace/case.json"
if python3 - "$REJECT_JSON" <<'PY'
import json, sys
c = json.load(open(sys.argv[1]))
ticket = c["ticket"]
ok = "namespace" not in ticket and c["expect"]["approved"] is False and c["expect"]["has_terraform"] is False
sys.exit(0 if ok else 1)
PY
then
  ok "$CASE (incomplete ticket fixture requires rejection, no Terraform)"
else
  bad "$CASE" "fixture does not encode a namespace rejection"
fi

# --- no-invented-paths ---
CASE="no-invented-paths"
TF1="${ROOT}/requests/PE-1-payments-api/03-terraform/main.tf"
PATHS1="$(extract_tf_attr "$TF1" "secret_paths")"
if [ "$PATHS1" = "config,db" ]; then
  ok "$CASE (PE-1 secret_paths exactly config,db — no extras)"
else
  bad "$CASE" "invented or missing paths: $PATHS1"
fi

# --- least-privilege ---
CASE="least-privilege"
POLICY="${ROOT}/terraform/modules/vault-service-onboard/main.tf"
if grep -q 'teams/\${var.team}/\${var.service_name}' "$POLICY" \
  && ! grep -q 'capabilities = \["create"' "$POLICY" \
  && ! grep -q 'capabilities = \["delete"' "$POLICY"; then
  ok "$CASE (module policy is read/list under teams/ only)"
else
  bad "$CASE" "module policy is not least-privilege"
fi

echo ""
echo "Yield: ${PASS} passed, ${FAIL} failed, $((PASS + FAIL)) total"

if [ -x "${OTEL}" ]; then
  FACTORY_TICKET_ID=evals "${OTEL}" metric factory.eval.pass "${PASS}" || true
  FACTORY_TICKET_ID=evals "${OTEL}" metric factory.eval.total "$((PASS + FAIL))" || true
fi

[ "${FAIL}" -eq 0 ]
