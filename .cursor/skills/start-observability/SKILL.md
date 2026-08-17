---
name: start-observability
description: Start the factory observability stack (OTel Collector, Prometheus, Loki, Grafana, Jaeger, Vault). Use when the user says start observability, start grafana, start prometheus, or bring up dashboards.
---

# Start Observability

Start the Causa-shaped local compose stack so Grafana and Prometheus are on localhost for the **local agent** demo.

## Steps

1. Docker must be running (`docker info`). If not, stop and tell the user to start Docker Desktop, then say **start observability** again.
2. If a host Vault `-dev` is holding `:8200`, stop it so compose can bind Grafana + Vault:

```bash
./platform/scripts/vault-dev-stop.sh || true
./observability/scripts/up.sh
./scripts/factory-environment.sh
```

`factory-environment.sh` is a no-op Vault start when compose is already healthy; it applies the kubernetes auth mount.

3. If `.cursor/mcp.json` is missing, copy `.cursor/mcp.json.example` and tell the user to reload MCP.
4. Tell the user:
   - Grafana: http://127.0.0.1:3000 (admin/admin)
   - Factory Operations: http://127.0.0.1:3000/d/factory-operations/factory-operations
   - Vault Onboarding: http://127.0.0.1:3000/d/vault-onboarding/vault-onboarding
   - Prometheus: http://127.0.0.1:9090
   - Jaeger: http://127.0.0.1:16686

This stack includes Vault. For the full evals + golden apply path, prefer **run the local demo**.

Cloud Agents cannot reach this laptop Grafana. Local IDE / local runtime only.
