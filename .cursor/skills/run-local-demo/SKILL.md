---
name: run-local-demo
description: Run the full local software-factory demo with skills — start Grafana/Vault, run evals, validate and apply PE-001, show dashboards. Use when the user says run the local demo, run everything with skills, green light, test the factory, or try it from the IDE.
---

# Run Local Demo

This is the **Cursor IDE** path. Do not ask the user to paste shell commands. Run the script, then summarize.

## Prerequisites the user must already have done

- This repo checked out (branch with the factory operate layer)
- **Docker Desktop running** (`docker info` works)
- `terraform` on PATH

If Docker is not running, stop. Tell them to start Docker Desktop, wait until it is idle, and say **run the local demo** again. Do not fall back to Vault-only; they asked for Grafana too.

## Steps

1. Run:

```bash
./scripts/run-local-demo.sh
```

Optional request id: `./scripts/run-local-demo.sh PE-001-payments-api`

2. Report PASS/FAIL for evals and validate-change, then Grafana + Vault URLs.
3. If Grafana MCP is connected, `list_dashboards` and confirm `factory-operations` and `vault-onboarding`.
4. Tell the user they can next say **show the dashboard**, **factory status**, or **stop the factory**.

Do **not** merge a PR. Do **not** start Kind.

Cloud Agents cannot fill laptop Grafana. This skill is **local IDE only**.
