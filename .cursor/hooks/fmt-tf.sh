#!/usr/bin/env bash
# afterFileEdit: terraform fmt any edited .tf files. Always allow.
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
paths = []
for key in ("file_path", "path", "filePath"):
    if data.get(key):
        paths.append(data[key])
files = data.get("files") or data.get("edits") or []
if isinstance(files, list):
    for f in files:
        if isinstance(f, str):
            paths.append(f)
        elif isinstance(f, dict):
            paths.append(f.get("path") or f.get("file_path") or "")
for p in paths:
    if str(p).endswith(".tf"):
        abs_p = p if os.path.isabs(p) else os.path.join(root, p)
        if os.path.isfile(abs_p):
            subprocess.run(["terraform", "fmt", abs_p], check=False, cwd=root)
print(json.dumps({"permission": "allow"}))
PY
