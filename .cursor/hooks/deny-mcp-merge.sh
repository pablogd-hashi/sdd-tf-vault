#!/usr/bin/env bash
# beforeMCPExecution: deny GitHub merge tools.
set -euo pipefail
export ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export PAYLOAD
PAYLOAD="$(cat)"
python3 - <<'PY'
import json, os, subprocess
root = os.environ["ROOT"]
raw = os.environ.get("PAYLOAD", "")
try:
    data = json.loads(raw) if raw.strip() else {}
except json.JSONDecodeError:
    data = {}
name = (data.get("toolName") or data.get("tool_name") or data.get("name") or "").lower()
otel = os.path.join(root, "scripts", "factory-otel.sh")
blocked = ("merge_pull_request", "mergepullrequest", "merge_pr")
if any(b in name for b in blocked):
    if os.path.isfile(otel):
        subprocess.run([otel, "metric", "factory.hook.deny", "1", "reason=mcp_merge"], check=False)
    print(json.dumps({
        "permission": "deny",
        "user_message": "Do not merge pull requests. Humans merge after reviewing reviewer.md and bugbot.md.",
    }))
    raise SystemExit(0)
print(json.dumps({"permission": "allow"}))
PY
