#!/usr/bin/env bash
# beforeShellExecution: deny merge and out-of-scope terraform apply.
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
cmd = data.get("command") or data.get("cmd") or ""
otel = os.path.join(root, "scripts", "factory-otel.sh")

def deny(reason, msg):
    if os.path.isfile(otel):
        subprocess.run([otel, "metric", "factory.hook.deny", "1", f"reason={reason}"], check=False)
    print(json.dumps({"permission": "deny", "user_message": msg}))
    raise SystemExit(0)

lower = cmd.lower()
if re.search(r"\bgh\s+pr\s+merge\b", lower) or re.search(r"\bgit\s+push\s+.*\bmain\b", lower):
    deny("merge", "Factory agents must not merge or push to main. Open a draft PR and stop.")
if re.search(r"\bterraform\s+apply\b", lower):
    allowed = ("requests/" in cmd and "03-terraform" in cmd) or "terraform/platform" in cmd or "-chdir=requests/" in cmd
    if not allowed:
        deny("apply", "terraform apply is only allowed under requests/<id>/03-terraform or terraform/platform.")
print(json.dumps({"permission": "allow"}))
PY
