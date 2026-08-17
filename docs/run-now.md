# Run a test from Cursor IDE

Everything is a **skill**. Do not memorize `task` or shell. This path is **local Cursor IDE** (laptop Docker). A Cloud Agent cannot start laptop Grafana.

## Green light — one prompt

1. Check out this branch.
2. Start **Docker Desktop** and wait until it is idle (`docker info` works).
3. Open the repo in Cursor. Agent chat (local), not a Cloud Agent.
4. Say:

> **run the local demo**

That skill starts Grafana + Vault, runs evals, validates and applies `PE-001-payments-api`, then prints dashboard URLs.

**Pass:** evals 4/4, validate-change PASS, Grafana at http://127.0.0.1:3000 (`admin` / `admin`).

Optional first time: **connect observability mcp**, then reload MCP in Cursor.

## Same demo, step by step

Say these in order (each is a skill):

1. **start observability**
2. **run evals**
3. **validate PE-001-payments-api**
4. **apply onboarding**
5. **show the dashboard**
6. **factory status**

Tear down: **stop the factory**

| You say | Skill |
|---------|--------|
| run the local demo | `run-local-demo` |
| start observability | `start-observability` |
| start the environment | `start-environment` (Vault only, no Grafana) |
| run evals | `run-evals` |
| validate PE-001 | `validate-request` |
| apply onboarding | `apply-onboarding` |
| show the dashboard | `show-dashboard` |
| factory status | `factory-status` |
| connect grafana mcp | `connect-observability-mcp` |
| stop the factory | `stop-factory` |

## If Grafana is connection refused

Docker is not running, or you have not said **start observability** / **run the local demo** yet. Host Vault (`start the environment`) does **not** bind `:3000`.

## Async Cloud Agent (no Grafana)

Same factory line, no dashboards. Hooks and evals still run.

| Tracker | Move the ticket to |
|---------|-------------------|
| **Jira** (existing hook) | **In Progress, agents** |
| Linear | **In Progress Cursor** |

The Cloud Agent follows `AGENTS.md`: evals 4/4 → `create-spec` → implement → validate PASS → draft PR → comment on the ticket. Humans merge. It does not bind `:3000` and must not say **start observability**.
