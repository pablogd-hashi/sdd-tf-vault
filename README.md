# Platform Engineering Copilot

Specification-driven **software factory** for Vault service onboarding: tickets become Terraform, with hooks, evals, and Grafana.

**Test it now (Cursor IDE):** start Docker Desktop, then say **run the local demo**. Details: [docs/run-now.md](docs/run-now.md).

## Operate the factory (skills only)

In Cursor Agent chat, say:

| You say | What happens |
|---------|----------------|
| **onboard this** (paste the fields) | Autonomous delivery, no Jira/Linear |
| **run the local demo** | Grafana + Vault + evals + apply PE-001 |
| **start the environment** | Vault `-dev` + kubernetes auth mount (no Kind) |
| **start observability** | OTel, Prometheus, Loki, Grafana, Jaeger, Vault |
| **run evals** | Deterministic yield on golden tickets |
| **validate PE-001** | Local validate-change (no ticket post) |
| **apply onboarding** | Policy, k8s role, KV paths on local Vault |
| **show the dashboard** | Factory Operations + Vault Onboarding |
| **factory status** | Health of Vault and Grafana |
| **connect grafana mcp** | Localhost Grafana + Prometheus MCP |
| **stop the factory** | Tear down compose + host Vault |

Grafana: http://127.0.0.1:3000 (admin/admin) — [Factory Operations](http://127.0.0.1:3000/d/factory-operations/factory-operations) and [Vault Onboarding](http://127.0.0.1:3000/d/vault-onboarding/vault-onboarding).

Async intake on **Cursor Ultra**: paste the request and say **onboard this** (no Jira, no Linear). Jira webhooks need Cursor Teams. Linear is optional.

## Workflow

An infrastructure request moves through seven numbered phases. Each phase writes one artifact, and each artifact is reviewable on its own.

[![Seven-phase SDD workflow](docs/diagrams/01-workflow-phases.svg)](https://www.figma.com/board/1RbIQpZgVRQr2TzsKe2SiZ)

Each phase lives in its own directory under `requests/<ticket-id>/`, so reviewers can approve specs without reading Terraform, and platform engineers can audit validation evidence without opening the ticket tracker.


### Two delivery paths

The same phases run in one of two modes:

| Path | Entry skill | Human gates |
|------|-------------|-------------|
| **Manual** (default) | `ticket-to-spec` | Stop for approval after each phase |
| **Autonomous** (optional) | `create-spec` | Implement + validate loop runs unattended; PR merge still needs a human |

The autonomous path adds a validation retry loop and a readonly reviewer subagent while keeping the same artifacts. See [docs/autonomous-delivery.md](docs/autonomous-delivery.md).

```
create-spec → implement-change → validate-change (loop) → ticket update → reviewer → bugbot → PR
```

## What this delivers

For each approved **Vault service onboarding** request, the copilot produces:

- **KV v2 secret paths** under `secret/teams/<team>/<service>/`
- **Least-privilege Vault ACL policy** scoped to those paths
- **Kubernetes auth role** bound to a Kind service account

## Stack (all OSS, runs locally)

| Component | Purpose |
|-----------|---------|
| [Vault OSS](https://www.vaultproject.io/) | Secrets management (`-dev` binary or compose — factory default) |
| [Kind](https://kind.sigs.k8s.io/) | Optional laptop path to prove a pod can log in |
| [Grafana](https://grafana.com/) + Prometheus + Loki + Jaeger + OTel | Factory + Vault dashboards |
| [Terraform OSS](https://www.terraform.io/) | Infrastructure as code |
| [Jira Free](https://www.atlassian.com/software/jira/free) or [Linear](https://linear.app/) | Infrastructure request intake |
| [GitHub Free](https://github.com/) | Pull request delivery |
| [Slack](https://slack.com/) | Workflow notifications (optional) |
| [Cursor](https://cursor.com/) | Rules, Skills, Hooks, MCP, Bugbot |

No cloud resources are provisioned. No enterprise licences required.

## Quick start

### Prerequisites

- Terraform ≥ 1.5, Go ≥ 1.21, Vault CLI **or** Docker
- Docker — only for Grafana / observability
- [go-task](https://taskfile.dev/installation/) — optional; skills call scripts directly
- Kind / kubectl / Helm — optional Kind path only

### Task runner ([go-task](https://taskfile.dev)) — optional

Skills call scripts. If you have `task` installed, `task factory:environment` is the same as `./scripts/factory-environment.sh`.

| Flow | What it manages |
|------|-----------------|
| `factory` | Vault `-dev` + Grafana stack |
| `platform` | Vault `-dev` (or `platform:kind` for Kind) |
| `request` | Per-request Terraform (`REQUEST=<id>`) |

### Bootstrap factory runtime (no Kind)

Say **start the environment** in Cursor, or:

```bash
cp .env.example .env
task factory:environment      # Vault -dev + kubernetes auth mount
task factory:observability    # Grafana / Prometheus / OTel (includes Vault)
task factory:status
```

Optional Kind path (pod-login proof only): `task platform:kind`.

### Provision a request and read its URL/outputs

```bash
task request:up REQUEST=PE-001-payments-api    # apply the request's Terraform
task request:url REQUEST=PE-001-payments-api   # Vault URL + policy/role/secret paths
task request:down REQUEST=PE-001-payments-api  # tear it back down
```

### Run validation on the golden example

```bash
task validate REQUEST=PE-001-payments-api
task validate-change REQUEST=PE-001-payments-api   # extended pipeline
```

> The original `make` targets still work (`make bootstrap`, `make platform-apply`, `make validate ...`); the Taskfile is the recommended interface.

See [docs/setup.md](docs/setup.md) for full setup including MCP configuration.

## Repository layout

```
requests/          One folder per ticket; phases are numbered subdirs
terraform/         Platform (Vault-only) + optional platform-kind + vault-service-onboard
platform/          Vault -dev config + optional Kind/Helm scripts
observability/     Compose: OTel, Prometheus, Loki, Grafana, Jaeger, Vault
evals/             Deterministic factory yield tests
.cursor/           Rules, Skills, Hooks, MCP example
docs/              Setup, demo, architecture, ADRs
policies/          Conftest Rego policies
tests/             Terratest integration tests
```

## Cursor integrations

| Integration | Role |
|-------------|------|
| **Cursor Rules** | Enforce phase order, spec format, Terraform conventions |
| **Cursor Skills** | Factory DX (`start-environment`, …) plus workflow phases |
| **Cursor Hooks** | Deterministic gauges — fmt, spec fields, deny merge, validation stop |
| **Cursor Subagents** | Readonly reviewer for autonomous delivery evaluation |
| **Jira MCP** (Atlassian) | Read Jira tickets, post completion comments |
| **Linear MCP** | Read Linear issues, post completion comments |
| **GitHub MCP** | Create branches and pull requests |
| **Grafana MCP** | Dashboards and PromQL via Grafana (local demo) |
| **Prometheus MCP** | Raw PromQL against localhost:9090 |
| **Slack MCP** | Workflow notifications (optional) |
| **Bugbot** | Mandatory code review before PR merge |

Skills are **explicitly invoked** — the agent does not autonomously skip gates in the manual workflow. The autonomous path (`create-spec` → `implement-change` → `validate-change`) runs explicit loops documented in [docs/autonomous-delivery.md](docs/autonomous-delivery.md).

## Design principles

1. **Traceability** — Ticket ID (and provider) threads through every artifact directory
2. **Separation of concerns** — Spec, plan, code, validation, and review are distinct review surfaces
3. **Determinism over autonomy** — Skills are procedures with human approval gates, not open-ended agents
4. **Least privilege** — Vault policies are generated from spec fields and reviewed before implementation
5. **Evidence for auditors** — Validation reports and Bugbot findings are committed artifacts
6. **Local parity** — Same Terraform modules run on Kind/Vault dev and would target real clusters via environment tfvars

## Demo

**Fastest:** [docs/run-now.md](docs/run-now.md)

Full script: [docs/demo-walkthrough.md](docs/demo-walkthrough.md). Golden example: `requests/PE-001-payments-api/`.

## Licence

MIT
