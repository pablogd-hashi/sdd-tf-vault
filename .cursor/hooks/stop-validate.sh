#!/usr/bin/env bash
# stop: if an autonomous request is in flight without validation PASS, loop back.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
python3 - "${ROOT}" <<'PY'
import json, os, glob, re, sys
root = sys.argv[1]
markers = glob.glob(os.path.join(root, "requests", "*", "01-spec", "autonomous.json"))
needs = []
for marker in markers:
    req = os.path.basename(os.path.dirname(os.path.dirname(marker)))
    tf = os.path.join(root, "requests", req, "03-terraform", "main.tf")
    report = os.path.join(root, "requests", req, "04-validation", "report.md")
    if not os.path.isfile(tf):
        continue
    if not os.path.isfile(report):
        needs.append(req)
        continue
    text = open(report, encoding="utf-8").read()
    if not re.search(r"\*\*Status\*\*\s*\|\s*PASS", text):
        needs.append(req)
if needs:
    req = needs[0]
    print(json.dumps({
        "followup_message": (
            f"Validation is not PASS for {req}. "
            f"Run the validate-change skill (or scripts/validate-change.sh {req}), "
            "fix failures, and do not open a PR until 04-validation/report.md shows PASS."
        )
    }))
else:
    print(json.dumps({}))
PY
