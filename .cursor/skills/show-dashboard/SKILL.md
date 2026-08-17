---
name: show-dashboard
description: Show the Grafana Factory Operations and Vault Onboarding dashboard URLs. Use when the user says show the dashboard, open grafana, show factory metrics, or where is the dashboard.
---

# Show Dashboard

Print (and open, when a browser opener exists) the two Grafana dashboards in one Grafana.

## Steps

1. Run:

```bash
task factory:dashboards
```

2. If Grafana is down, tell the user to say **start observability** first.
3. Optionally, if Grafana MCP is connected, call `list_dashboards` and confirm `factory-operations` and `vault-onboarding` exist.

## URLs

- Factory Operations: http://127.0.0.1:3000/d/factory-operations/factory-operations
- Vault Onboarding: http://127.0.0.1:3000/d/vault-onboarding/vault-onboarding
- Login: admin / admin
