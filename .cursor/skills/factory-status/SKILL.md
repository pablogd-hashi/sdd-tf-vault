---
name: factory-status
description: Check whether Vault and the observability stack are up. Use when the user says is it up, factory status, health check, or what's running.
---

# Factory Status

Report Vault, Prometheus, Grafana, Jaeger, Loki, and OTLP health plus dashboard URLs.

## Steps

1. Run:

```bash
./observability/scripts/status.sh
# or: task factory:status
```

2. Summarize which components are UP vs DOWN in a short list.
3. If everything is down, suggest **start observability** (full stack) or **start the environment** (Vault only).
