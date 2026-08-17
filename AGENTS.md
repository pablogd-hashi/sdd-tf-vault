# Agent instructions — Platform Engineering Copilot

This repository is a **software factory** for Vault service onboarding.

Prefer **skills** over raw `task` or shell. Skills invoke scripts. go-task is optional.

First-time local IDE test: user says **run the local demo** ([docs/run-now.md](docs/run-now.md)). Requires Docker Desktop.

## Local demo vs Cloud Agent webhook

| Path | Trigger | What runs | Grafana |
|------|---------|-----------|---------|
| **Local agent / IDE** | You say **run the local demo** | Skills + evals + apply to laptop Vault | Yes (`localhost:3000`) |
| **Cloud Agent** | Jira **In Progress, agents** or Linear **In Progress Cursor** | Autonomous delivery: hooks + evals + draft PR | **No** — skip observability |

Use the existing Jira Cursor webhook. Moving a well-formed PE ticket to **In Progress, agents** is enough. Do not start observability, Docker Compose, or Kind on that path.

## Autonomous delivery (Cloud Agent — Jira or Linear)

When this run was started from a ticket webhook:

1. Read the Jira or Linear ticket that triggered the run (Atlassian MCP or Linear MCP). Provider is `jira` if the ticket came from Jira.
2. `./evals/score.sh` — factory yield must be 4/4. If evals FAIL, stop and report; do not invent a spec.
3. `create-spec` → `implement-change` → `validate-change` until `04-validation/report.md` is PASS.
4. Hooks in `.cursor/hooks.json` run in this checkout (fmt, incomplete-spec reject, deny merge / out-of-scope apply, stop until validation PASS). Do not bypass them.
5. Reviewer subagent → `bugbot-review` → `open-github-pr` (draft).
6. Comment on the ticket. Do not transition to Done.
7. Stop. Humans merge.

**Do not** invoke `start-observability`, `show-dashboard`, or `run-local-demo`. **Do not** merge. **Do not** wait for "approved".

Never invent spec values. Never `terraform apply` outside `requests/<id>/03-terraform` or `terraform/platform`. Cloud Agent VMs usually have no laptop Vault — plan may SKIP; that does not block a draft PR when fmt/validate PASS. Apply to Vault is local or post-merge.

## Factory DX skills (local IDE only)

- `run-local-demo` — full IDE test (Grafana + evals + PE-001 apply)
- `start-environment` — Vault `-dev` + kubernetes auth mount (no Kind)
- `start-observability` — OTel, Prometheus, Loki, Grafana, Jaeger, Vault
- `show-dashboard` — Factory Operations + Vault Onboarding URLs
- `factory-status` — health
- `stop-factory` — tear down compose + host Vault (does not delete Kind)
- `run-evals` — deterministic yield
- `validate-request` — local validate (no ticket comment)
- `apply-onboarding` — terraform apply the request against local Vault
- `connect-observability-mcp` — copy Grafana/Prometheus MCP if missing

## Runtime

Factory default is **Vault as a binary/compose service**, not Kind. Kind (`platform:kind`) is optional proof that a pod can log in.

Vault: `http://127.0.0.1:8200` token `root`.
