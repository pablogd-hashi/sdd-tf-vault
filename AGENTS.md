# Agent instructions — Platform Engineering Copilot

This repository is a **software factory** for Vault service onboarding.

Prefer **skills** over raw `task` or shell. Skills invoke scripts. go-task is optional.

First-time local IDE test: user says **run the local demo** ([docs/run-now.md](docs/run-now.md)). Requires Docker Desktop.

## Intake (pick one)

| Path | Plan / trigger | Grafana |
|------|----------------|---------|
| **Paste** (default on Cursor Ultra) | User pastes the request → `onboard-from-paste` | Only if they also say **run the local demo** / **start observability** |
| **Local demo** | **run the local demo** (golden PE-001) | Yes |
| **Jira webhook** | Cursor **Teams** automations + Atlassian MCP on the PE site | No |
| **Linear webhook** | **In Progress Cursor** | No |

Jira-triggered Cloud Agents need Cursor Teams (and Atlassian OAuth on the site that hosts project PE). Ultra: do not wait on Jira. Paste the fields.

## Autonomous delivery

1. If the user pasted fields: `onboard-from-paste` (`ticket_provider: pasted`). No Jira/Linear MCP.
2. Else read the Jira or Linear ticket that triggered the run.
3. `./evals/score.sh` — yield must be 4/4. If FAIL, stop.
4. `create-spec` → `implement-change` → `validate-change` until `04-validation/report.md` is PASS.
5. Honor `.cursor/hooks.json`. Do not bypass them.
6. Reviewer → `bugbot-review` → `open-github-pr` (draft).
7. Ticket comment: skip MCP when provider is `pasted`. Do not transition to Done.
8. Stop. Humans merge.

**Do not** invoke `start-observability` on a Cloud Agent webhook run. **Do not** merge.

Never invent spec values. Never `terraform apply` outside `requests/<id>/03-terraform` or `terraform/platform`. Cloud Agent VMs usually have no laptop Vault — plan may SKIP. Apply to Vault is local or post-merge.

## Factory DX skills (local IDE)

- `onboard-from-paste` — autonomous delivery from a pasted request (no tracker)
- `run-local-demo` — Grafana + evals + PE-001 apply
- `start-environment` — Vault `-dev` + kubernetes auth mount (no Kind)
- `start-observability` — OTel, Prometheus, Loki, Grafana, Jaeger, Vault
- `show-dashboard` / `factory-status` / `stop-factory`
- `run-evals` / `validate-request` / `apply-onboarding`
- `connect-observability-mcp`

## Runtime

Factory default is **Vault as a binary/compose service**, not Kind.

Vault: `http://127.0.0.1:8200` token `root`.
