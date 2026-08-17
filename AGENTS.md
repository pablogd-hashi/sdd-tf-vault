# Agent instructions — Platform Engineering Copilot

This repository is a **software factory** for Vault service onboarding.

Prefer **skills** over raw `task` or shell.

## Jira: plugin vs MCP (do not mix these up)

| Surface | What it is | Jira site | Ultra |
|---------|------------|-----------|-------|
| **Atlassian plugin** (IDE) | Marketplace plugin. Blog path. Read issue + add comment. | The site you authorized in the plugin | Works |
| **Atlassian MCP** (`mcp.json` / Cloud Agent) | Separate OAuth. This environment was stuck on `agentic-workflow-demo.atlassian.net` (no PE project). | Often the wrong site | Optional; not required for the blog loop |

This repo enables the plugin in `.cursor/settings.json` (`plugins.atlassian`). Skills must use **plugin Jira tools**, not MCP, when the plugin is present.

Cloud Agent **Jira webhooks** are a different product (often Teams). They are not how the blog posted comments.

## Intake

| Path | Trigger | Grafana |
|------|---------|---------|
| **Jira + plugin** (blog) | Local Agent: `ticket-to-spec` / autonomous `create-spec` for PE-N | No unless asked |
| **Paste** | **onboard this** with fields in the message | No unless asked |
| **Local demo** | **run the local demo** | Yes |
| **Jira webhook** | Cursor automation (Teams) | No |

## Autonomous delivery

1. If the user named a Jira key: read it with the **Atlassian plugin**. `ticket_provider: jira`. If the plugin cannot see project PE, stop. Do not reuse a git spec. Do not use MCP.
2. If they pasted fields and no Jira key: `onboard-from-paste`.
3. `./evals/score.sh` — 4/4 or stop.
4. `create-spec` → `implement-change` → `validate-change` until PASS.
5. Honor `.cursor/hooks.json`.
6. Reviewer → bugbot → draft PR. Do not merge.
7. `ticket-update`: comment via the **Atlassian plugin**. Skip MCP.
8. Stop. Humans merge.

Never invent spec values. Never `terraform apply` outside `requests/<id>/03-terraform` or `terraform/platform`.

## Factory DX skills

- `onboard-from-paste` — no tracker
- `run-local-demo` / `start-observability` / `show-dashboard` / `factory-status` / `stop-factory`
- `run-evals` / `validate-request` / `apply-onboarding`

Vault: `http://127.0.0.1:8200` token `root`.
