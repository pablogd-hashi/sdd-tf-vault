# Linear Project Setup

Configure a Linear team for Platform Engineering infrastructure requests.

## Create team

1. Go to [Linear](https://linear.app/) and create or open a workspace
2. Create team **PE** (Platform Engineering) — key becomes issue prefix (`PE-123`)
3. Optionally create a project **Vault onboarding**

## Issue labels

Recommended labels (mirror the `ticket-schema` rule):

| Label | Example |
|-------|---------|
| `infrastructure-request` | Issue type marker |
| `service:payments-api` | Service name |
| `team:payments` | Team |
| `namespace:payments` | K8s namespace |
| `sa:payments-api` | Service account |
| `secrets:config,db` | Secret paths |
| `env:local` | Environment |

## Issue template

**Title:** Onboard `{service-name}` to Vault

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
| Backlog / Todo | Ticket filed |
| In Progress | Human working the ticket in the IDE (manual gated path) |
| **In Progress Cursor** (or **in progress, agents**) | Cursor webhook launches a Cloud Agent — autonomous factory path |
| In Review | PR open |
| Done | Merged and ticket updated |

Team **Onboarding** already has `In Progress Cursor`. Team **PE** should add the same started-type status if demo tickets are `PE-*`, then point the Cursor webhook at that status.

The webhook lives in the Cursor dashboard (not in git). Recreate it as: Linear issue enters `In Progress Cursor` → start Cloud Agent on this repo. Paste the generic Instructions from [AGENTS.md](../AGENTS.md#automation-instructions-copy-paste) — do not hardcode PE-9 or any other ticket.

Cloud Agents do **not** fill laptop Grafana. For dashboards, use the local agent and say **start observability**.

## Linear MCP in Cursor

1. Copy `.cursor/mcp.json.example` to `.cursor/mcp.json`
2. Open Cursor Settings → MCP
3. Authenticate Linear via OAuth when prompted
4. Set `TICKET_PROVIDER=linear` and `LINEAR_TEAM_KEY=PE` in `.env`
5. Test: ask agent to "list Linear issues for team PE"

## Example issues

| Key | Title | Purpose |
|-----|-------|---------|
| PE-001 | Onboard payments-api to Vault | Golden example (in repo; historically Jira) |
| PE-002 | Onboard auth-api to Vault | Live demo ticket |

Create a live demo issue so PE-001 remains the checked-in reference.

## Provider selection

Record `ticket_provider: linear` in the spec header and in `01-spec/autonomous.json`. Skills choose Linear MCP (`get_issue`, `create_comment`, `update_issue`) when provider is `linear`.
