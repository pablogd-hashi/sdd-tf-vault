# Agent instructions — Platform Engineering Copilot

This repository is a **software factory** for Vault service onboarding.

Prefer **skills** over raw `task` or shell.

## Git branch (do this first)

Factory code is on `cursor/software-factory-8d74`, not `main`. Before any work:

```bash
git fetch origin
git checkout cursor/software-factory-8d74
git pull origin cursor/software-factory-8d74
```

Then create `pe/<KEY>-<service>` from that branch. Never start from stale `main`. If the user says "switch branch", run the checkout above.

## Jira site (only this one)

- Site: `https://edsefsonytv.atlassian.net`
- Project: **PE**
- Board: [PE board 34](https://edsefsonytv.atlassian.net/jira/software/projects/PE/boards/34)
- Cloud id: `c829f01c-71dd-4abe-a246-4def3dfa5c2b`

If a Jira tool is on any other site (especially `agentic-workflow-demo.atlassian.net`), **stop**. That is the wrong cloud. Re-auth the **Atlassian plugin** to `edsefsonytv.atlassian.net`. Do not invent PE-9 from git.

## Jira: plugin vs MCP

| Surface | Use |
|---------|-----|
| **Atlassian plugin** (IDE) | Yes — blog path. Read/comment PE issues on edsefsonytv. |
| **Atlassian MCP** | Only if plugin is absent, and only with `cloudId` = `edsefsonytv.atlassian.net` (or `c829f01c-71dd-4abe-a246-4def3dfa5c2b`). If the site is not granted, stop. |

`.cursor/settings.json` enables `plugins.atlassian`.

## Intake

| Path | Trigger | Grafana |
|------|---------|---------|
| **Jira + plugin** (blog) | Local Agent: `ticket-to-spec` / autonomous `create-spec` for PE-N | No unless asked |
| **Paste** | **onboard this** with fields in the message | No unless asked |
| **Local demo** | **run the local demo** | Yes |
| **Jira webhook** | Cursor automation (Teams) | No |

## Autonomous delivery

1. If the user named a Jira key: read it with the **Atlassian plugin** on **edsefsonytv.atlassian.net** / project PE. `ticket_provider: jira`. If the plugin cannot see that site, stop. Do not reuse a git spec. Do not use the demo Jira site.
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
