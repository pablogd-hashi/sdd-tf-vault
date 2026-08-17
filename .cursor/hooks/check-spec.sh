#!/usr/bin/env bash
# afterFileEdit: reject specs missing R1–R5 or ticket_provider.
set -euo pipefail
export ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export PAYLOAD
PAYLOAD="$(cat)"
python3 - <<'PY'
import json, os, re, subprocess
root = os.environ["ROOT"]
raw = os.environ.get("PAYLOAD", "")
try:
    data = json.loads(raw) if raw.strip() else {}
except json.JSONDecodeError:
    data = {}

def collect_paths(d):
    out = []
    for key in ("file_path", "path", "filePath"):
        if d.get(key):
            out.append(d[key])
    files = d.get("files") or d.get("edits") or []
    if isinstance(files, list):
        for f in files:
            if isinstance(f, str):
                out.append(f)
            elif isinstance(f, dict):
                out.append(f.get("path") or f.get("file_path") or "")
    return out

otel = os.path.join(root, "scripts", "factory-otel.sh")
for p in collect_paths(data):
    norm = str(p).replace("\\", "/")
    if "01-spec" not in norm or not norm.endswith("spec.md"):
        continue
    abs_p = p if os.path.isabs(p) else os.path.join(root, p)
    if not os.path.isfile(abs_p):
        continue
    text = open(abs_p, encoding="utf-8").read()
    missing = []
    if not re.search(r"Ticket provider", text, re.I):
        missing.append("ticket_provider")
    for req in ("R1", "R2", "R3", "R4", "R5"):
        if req not in text:
            missing.append(req)
    if missing:
        if os.path.isfile(otel):
            subprocess.run([otel, "metric", "factory.hook.deny", "1", "reason=incomplete_spec"], check=False)
        print(json.dumps({
            "permission": "deny",
            "user_message": "Spec is incomplete: missing " + ", ".join(missing) + ". Map ticket fields to R1–R5 and ticket_provider.",
        }))
        raise SystemExit(0)
print(json.dumps({"permission": "allow"}))
PY
