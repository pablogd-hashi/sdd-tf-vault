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

## Jira site

When the ticket is Jira, use **https://edsefsonytv.atlassian.net** (project **PE**). If a Jira tool is on another site (especially `agentic-workflow-demo.atlassian.net`), stop and re-auth. Do not invent a spec from git.

Prefer the **Atlassian plugin** for read/comment. Atlassian MCP is a fallback with `cloudId` = `edsefsonytv.atlassian.net` (or `c829f01c-71dd-4abe-a246-4def3dfa5c2b`).

## Autonomous delivery (Cloud Agent — Jira or Linear)

When this run was started from a ticket webhook:

1. Identify **this run's ticket** from the trigger (Jira work item, Linear issue, or webhook JSON `ticket_id`). Never assume `PE-9`, `PE-001`, or any other key.
2. Read that ticket via Atlassian plugin/MCP or Linear MCP. Provider is `jira` if the ticket came from Jira.
3. `./evals/score.sh` — factory yield must be 4/4. If evals FAIL, stop and report; do not invent a spec.
4. `create-spec` → `implement-change` → `validate-change` until `04-validation/report.md` is PASS.
5. Hooks in `.cursor/hooks.json` run in this checkout (fmt, incomplete-spec reject, deny merge / out-of-scope apply, stop until validation PASS). Do not bypass them.
6. Reviewer subagent → `bugbot-review` → `open-github-pr` (draft).
7. Comment on **this run's ticket**. Do not transition to Done.
8. Stop. Humans merge.

**Do not** invoke `start-observability`, `show-dashboard`, or `run-local-demo`. **Do not** merge. **Do not** wait for "approved".

Never invent spec values. Never copy `requests/PE-9-payments-api/` or `requests/PE-001-payments-api/` as the live spec. Never `terraform apply` outside `requests/<id>/03-terraform` or `terraform/platform`. Cloud Agent VMs usually have no laptop Vault — plan may SKIP; that does not block a draft PR when fmt/validate PASS. Apply to Vault is local or post-merge.

### Automation Instructions (copy-paste)

Paste this into the Cursor Automation / Jira Cloud Agent **Instructions** field. Do **not** hardcode a ticket key, site hostname, or board id.

```
Follow AGENTS.md autonomous delivery for the ticket that started this run.

Ticket identity (in order):
1. The Jira or Linear work item attached to this Cloud Agent trigger
2. Else webhook JSON: ticket_id, ticket_provider (jira|linear), status, summary

Do not assume PE-9, PE-001, payments-api, or any other key.
Do not Rovo-search for a hardcoded issue.
Do not reuse requests/PE-9-payments-api/ or requests/PE-001-payments-api/ from git as the spec.

Guards:
- If this is a Jira status trigger, continue only for status "In Progress, agents".
- If this is a Linear status trigger, continue only for status "In Progress Cursor".
- If ticket_id cannot be determined, stop. Do not invent a ticket.
- Read the live ticket via Atlassian MCP (jira) or Linear MCP (linear).
- If required onboarding fields are missing, comment on that ticket listing them, then stop.

Then:
1. ./evals/score.sh — stop if not 4/4
2. create-spec → implement-change → validate-change until PASS
3. reviewer → bugbot-review → open-github-pr (draft only)
4. Comment on this run's ticket. Do not transition to Done. Do not merge.

Do not start observability, Docker Compose, or Kind.
Branch: pe/<KEY>-<service>
```

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
- `onboard-from-paste` — no tracker; fields in the message

## Runtime

Factory default is **Vault as a binary/compose service**, not Kind. Kind (`platform:kind`) is optional proof that a pod can log in.

Vault: `http://127.0.0.1:8200` token `root`.
