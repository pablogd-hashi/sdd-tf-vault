# Observability stack

Docker Compose for the factory operate layer. No Kubernetes.

Say **start observability** in Cursor (or `task factory:observability`).

| URL | What |
|-----|------|
| http://127.0.0.1:3000 | Grafana (admin/admin) |
| http://127.0.0.1:3000/d/factory-operations/factory-operations | Factory Operations |
| http://127.0.0.1:3000/d/vault-onboarding/vault-onboarding | Vault Onboarding |
| http://127.0.0.1:9090 | Prometheus |
| http://127.0.0.1:16686 | Jaeger |
| http://127.0.0.1:8200 | Vault `-dev` (token `root`) |
| http://127.0.0.1:4318 | OTLP HTTP |

See [ADR-007](../docs/engineering-decisions/007-factory-operate-layer.md).
