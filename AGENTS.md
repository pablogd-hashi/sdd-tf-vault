# Agent instructions — Platform Engineering Copilot

This repository is a **software factory** for Vault service onboarding.

Prefer **skills** over raw `task` commands. Skills invoke scripts (`./scripts/factory-environment.sh`, `./evals/score.sh`, …). go-task is optional.

First-time local test: follow [docs/run-now.md](docs/run-now.md).

## Local demo vs Cloud Agent webhook

| Path | When | Grafana on localhost |
|------|------|----------------------|
| **Local agent / IDE** | Observability demo | Yes — start observability, then query Grafana/Prometheus MCP |
| **Cloud Agent** (Linear status `In Progress Cursor` / in progress, agents) | Unattended delivery | No — the VM cannot see laptop Grafana |

For a Cloud Agent run: follow autonomous delivery (`create-spec` → `implement-change` → `validate-change` until PASS → reviewer → bugbot → draft PR). Do not merge. Do not wait for "approved".

For a local operate demo: invoke `start-observability`, `show-dashboard`, then run a request and use Grafana MCP / Prometheus MCP.

## Factory DX skills (say these)

- `start-environment` — Vault `-dev` + kubernetes auth mount (no Kind)
- `start-observability` — OTel, Prometheus, Loki, Grafana, Jaeger, Vault
- `show-dashboard` — Factory Operations + Vault Onboarding URLs
- `factory-status` — health
- `stop-factory` — tear down compose + host Vault (does not delete Kind)
- `run-evals` — deterministic yield

## Autonomous delivery (Cloud or local)

1. Read the Linear/Jira ticket that triggered the run
2. `create-spec` → `implement-change` → `validate-change` until `04-validation/report.md` is PASS
3. Reviewer subagent → `bugbot-review` → `open-github-pr` (draft)
4. Comment on the ticket
5. Stop. Humans merge.

Never invent spec values. Never `terraform apply` outside `requests/<id>/03-terraform` or `terraform/platform`. Never merge the PR.

## Runtime

Factory default is **Vault as a binary/compose service**, not Kind. Kind (`platform:kind`) is optional proof that a pod can log in.

Vault: `http://127.0.0.1:8200` token `root`.
