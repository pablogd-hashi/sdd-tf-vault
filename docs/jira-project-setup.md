# Jira Project Setup

Configure a Jira Free project for Platform Engineering infrastructure requests.

## Create project

1. Go to [Jira](https://www.atlassian.com/software/jira/free) and create a free site
2. Create project **PE** (Platform Engineering)
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

Add the agents status if you wire a Cursor webhook to Jira. Cloud Agents do not fill laptop Grafana; use the local agent and **start observability** for dashboards.

## Atlassian MCP in Cursor

1. Copy `.cursor/mcp.json.example` to `.cursor/mcp.json`
2. Open Cursor Settings → MCP
3. Authenticate Atlassian via OAuth when prompted
4. Test: ask agent to "search Jira for PE project tickets"

## Example tickets

| Key | Summary | Purpose |
|-----|---------|---------|
| PE-001 | Onboard payments-api to Vault | Golden example (in repo) |
| PE-002 | Onboard auth-api to Vault | Live demo ticket |

Create PE-002 for live demos so PE-001 remains the checked-in reference.
