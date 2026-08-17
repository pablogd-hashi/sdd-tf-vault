---
name: start-observability
description: Start the factory observability stack (OTel Collector, Prometheus, Loki, Grafana, Jaeger, Vault). Use when the user says start observability, start grafana, start prometheus, or bring up dashboards.
---

# Start Observability

Start the Causa-shaped local compose stack so Grafana and Prometheus are on localhost for the **local agent** demo.

## Steps

1. Docker must be running.
2. Run:

```bash
task factory:observability
```

3. Wait until the script prints Grafana and Prometheus URLs.
4. Tell the user:
   - Grafana: http://127.0.0.1:3000 (admin/admin)
   - Factory Operations: http://127.0.0.1:3000/d/factory-operations/factory-operations
   - Vault Onboarding: http://127.0.0.1:3000/d/vault-onboarding/vault-onboarding
   - Prometheus: http://127.0.0.1:9090
   - Jaeger: http://127.0.0.1:16686

This stack includes Vault. You do not also need `start-environment` unless you are running host Vault without compose.

Cloud Agents cannot reach this laptop Grafana. Local IDE / local runtime only.
