#!/usr/bin/env bash
# Emit OTLP HTTP traces/metrics/logs to the local collector (localhost:4318).
# Never fails the caller — telemetry is best-effort.
set -euo pipefail

OTLP_HTTP="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://127.0.0.1:4318}"
OTLP_HTTP="${OTLP_HTTP%/}"
SERVICE_NAME="${OTEL_SERVICE_NAME:-pe-factory}"

usage() {
  echo "Usage: $0 metric <name> <int> [key=value ...]"
  echo "       $0 span <name> [key=value ...]"
  echo "       $0 log <message> [key=value ...]"
  exit 2
}

[ "${#}" -lt 1 ] && usage
KIND="${1}"; shift

command -v python3 >/dev/null 2>&1 || exit 0
command -v curl >/dev/null 2>&1 || exit 0

NOW_NS="$(python3 -c 'import time; print(int(time.time()*1e9))')"

ATTRS=("service.name=${SERVICE_NAME}")
[ -n "${FACTORY_TICKET_ID:-}" ] && ATTRS+=("ticket_id=${FACTORY_TICKET_ID}")

attrs_json() {
  python3 - "$@" <<'PY'
import json, sys
out = []
for raw in sys.argv[1:]:
    if "=" not in raw:
        continue
    k, v = raw.split("=", 1)
    out.append({"key": k, "value": {"stringValue": str(v)}})
print(json.dumps(out))
PY
}

emit() {
  local path="$1" body="$2"
  curl -sS --max-time 2 -X POST "${OTLP_HTTP}${path}" \
    -H "Content-Type: application/json" \
    -d "${body}" >/dev/null 2>&1 || true
}

case "${KIND}" in
  metric)
    [ "${#}" -ge 2 ] || usage
    NAME="${1}"; VALUE="${2}"; shift 2
    AJ="$(attrs_json "${ATTRS[@]}" "$@")"
    BODY="$(NAME="${NAME}" VALUE="${VALUE}" NOW_NS="${NOW_NS}" AJ="${AJ}" SVC="${SERVICE_NAME}" python3 - <<'PY'
import json, os
attrs = json.loads(os.environ["AJ"])
body = {
  "resourceMetrics": [{
    "resource": {"attributes": [{"key": "service.name", "value": {"stringValue": os.environ["SVC"]}}]},
    "scopeMetrics": [{
      "scope": {"name": "pe-factory"},
      "metrics": [{
        "name": os.environ["NAME"],
        "unit": "1",
        "sum": {
          "aggregationTemporality": 2,
          "isMonotonic": True,
          "dataPoints": [{
            "asInt": str(os.environ["VALUE"]),
            "timeUnixNano": os.environ["NOW_NS"],
            "startTimeUnixNano": os.environ["NOW_NS"],
            "attributes": attrs,
          }],
        },
      }],
    }],
  }]
}
print(json.dumps(body))
PY
)"
    emit "/v1/metrics" "${BODY}"
    ;;
  span)
    [ "${#}" -ge 1 ] || usage
    NAME="${1}"; shift
    AJ="$(attrs_json "${ATTRS[@]}" "$@")"
    BODY="$(NAME="${NAME}" NOW_NS="${NOW_NS}" AJ="${AJ}" SVC="${SERVICE_NAME}" python3 - <<'PY'
import json, os
attrs = json.loads(os.environ["AJ"])
now_i = int(os.environ["NOW_NS"])
trace_id = os.environ.get("FACTORY_TRACE_ID") or os.urandom(16).hex()
span_id = os.urandom(8).hex()
body = {
  "resourceSpans": [{
    "resource": {"attributes": [{"key": "service.name", "value": {"stringValue": os.environ["SVC"]}}]},
    "scopeSpans": [{
      "scope": {"name": "pe-factory"},
      "spans": [{
        "traceId": trace_id,
        "spanId": span_id,
        "name": os.environ["NAME"],
        "kind": 1,
        "startTimeUnixNano": str(now_i - 1_000_000),
        "endTimeUnixNano": str(now_i),
        "attributes": attrs,
      }],
    }],
  }]
}
print(json.dumps(body))
PY
)"
    emit "/v1/traces" "${BODY}"
    ;;
  log)
    [ "${#}" -ge 1 ] || usage
    MSG="${1}"; shift
    AJ="$(attrs_json "${ATTRS[@]}" "$@")"
    BODY="$(MSG="${MSG}" NOW_NS="${NOW_NS}" AJ="${AJ}" SVC="${SERVICE_NAME}" python3 - <<'PY'
import json, os
attrs = json.loads(os.environ["AJ"])
body = {
  "resourceLogs": [{
    "resource": {"attributes": [{"key": "service.name", "value": {"stringValue": os.environ["SVC"]}}]},
    "scopeLogs": [{
      "scope": {"name": "pe-factory"},
      "logRecords": [{
        "timeUnixNano": os.environ["NOW_NS"],
        "severityText": "INFO",
        "body": {"stringValue": os.environ["MSG"]},
        "attributes": attrs,
      }],
    }],
  }]
}
print(json.dumps(body))
PY
)"
    emit "/v1/logs" "${BODY}"
    ;;
  *)
    usage
    ;;
esac
