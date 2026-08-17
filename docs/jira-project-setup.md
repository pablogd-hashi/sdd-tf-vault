# Jira Project Setup

Configure a Jira Free project for Platform Engineering infrastructure requests.

## Create project

1. Go to [Jira](https://www.atlassian.com/software/jira/free) and create a free site
2. Create project **PE** (Platform Engineering) on **https://edsefsonytv.atlassian.net** (board 34).
3. Use **Kanban** or **Team-managed** template

## Issue type

Create or use **Task** with label `infrastructure-request`.

Recommended labels for Jira Free (when custom fields unavailable):

| Label | Example |
|-------|---------|
| `service:payments-api` | Service name |
| `team:payments` | Team |
| `namespace:payments` | K8s namespace |
| `sa:payments-api` | Service account |
| `paths:config,db` | Secret paths |
| `env:local` | Environment |

## Ticket template

**Summary:** Onboard `{service-name}` to Vault

**Description:**

```
## Infrastructure Request

Service name: payments-api
Team: payments
Environment: local
K8s namespace: payments
K8s service account: payments-api
Secret paths: config, db

## Acceptance criteria
- Service can authenticate via Kubernetes auth
- Service can read config and db secrets from Vault
- Policy scoped to payments team paths only

Approver: platform-lead
```

## Workflow statuses

| Status | Maps to repo phase |
|--------|-------------------|
| To Do | Ticket filed |
| In Progress | Human working the ticket in the IDE (manual gated path) |
| **In Progress, agents** | Cursor webhook launches a Cloud Agent — autonomous factory path |
| In Review | PR open |
| Done | Merged and Jira updated |

Add the **In Progress, agents** status and point your existing Cursor webhook at it (same pattern as Linear **In Progress Cursor**).

The webhook lives in the Cursor dashboard (not in git): Jira issue enters **In Progress, agents** → start Cloud Agent on this repo. The agent follows `AGENTS.md`: evals + hooks + spec → Terraform → validate → draft PR. It must **not** start Grafana or Docker Compose.

That is the unattended factory. Grafana stays on the laptop IDE path (`run the local demo`).

If the hook already launches Cloud Agents from an older prompt (especially one hardcoded to **PE-9**), replace the **Instructions** field with the copy-paste block in [AGENTS.md](../AGENTS.md#automation-instructions-copy-paste). The agent must work on **the ticket that triggered the run**, not a fixed demo key. Atlassian access must be **edsefsonytv.atlassian.net**, not `agentic-workflow-demo.atlassian.net`.

## Atlassian plugin in Cursor (blog path)

Enable the **Atlassian** marketplace plugin. This repo turns it on in `.cursor/settings.json`. Authorize **https://edsefsonytv.atlassian.net** (project PE, [board 34](https://edsefsonytv.atlassian.net/jira/software/projects/PE/boards/34)). If the plugin or MCP is on `agentic-workflow-demo.atlassian.net`, it is the wrong cloud — re-auth.

Local Agent chat can then `get` PE-9 and **add a comment** the same way as the first blog. That does **not** use Settings → MCP.

Cloud Agents that only have Atlassian MCP will hit whatever site that OAuth granted (in one run: `agentic-workflow-demo.atlassian.net`, which has no PE project). Do not treat that as “PE-9 is missing.”

## Example tickets

| Key | Summary | Purpose |
|-----|---------|---------|
| PE-001 | Onboard payments-api to Vault | Golden example (in repo) |
| PE-002 | Onboard auth-api to Vault | Live demo ticket |

Create PE-002 for live demos so PE-001 remains the checked-in reference.
