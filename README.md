# Platform Engineering Copilot

An open-source reference implementation showing how to implement software delivery in regulated platform engineering teams.

This repository demonstrates a **specification-driven workflow** that converts approved infrastructure tickets (Jira or Linear) into production-ready Terraform — with every phase independently reviewable.

## Workflow

An infrastructure request moves through seven numbered phases. Each phase writes one artifact, and each artifact is reviewable on its own.

[![Seven-phase SDD workflow](docs/diagrams/01-workflow-phases.svg)](https://www.figma.com/board/1RbIQpZgVRQr2TzsKe2SiZ)

Each phase lives in its own directory under `requests/<ticket-id>/`, so reviewers can approve specs without reading Terraform, and platform engineers can audit validation evidence without opening the ticket tracker.

Diagrams are authored in FigJam — see the [source board](https://www.figma.com/board/1RbIQpZgVRQr2TzsKe2SiZ) and [docs/figma-diagrams.md](docs/figma-diagrams.md).

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
| [Kind](https://kind.sigs.k8s.io/) | Local Kubernetes cluster |
| [Vault OSS](https://www.vaultproject.io/) | Secrets management (dev mode) |
| [Terraform OSS](https://www.terraform.io/) | Infrastructure as code |
| [Jira Free](https://www.atlassian.com/software/jira/free) or [Linear](https://linear.app/) | Infrastructure request intake |
| [GitHub Free](https://github.com/) | Pull request delivery |
| [Cursor](https://cursor.com/) | Rules, Skills, MCP, Bugbot |

No cloud resources are provisioned. No enterprise licences required.

## Quick start

### Prerequisites

- Docker, Kind, kubectl, Helm, Terraform ≥ 1.5, Go ≥ 1.21
- [go-task](https://taskfile.dev/installation/) (`brew install go-task`) — task runner for the flows below
- Optional: [Vault CLI](https://developer.hashicorp.com/vault/install), [tflint](https://github.com/terraform-linters/tflint)

### Task runner ([go-task](https://taskfile.dev))

Every stack is modelled as a **flow** that supports `up`, `down`, `reset`, and `url`:

| Flow | What it manages | Commands |
|------|-----------------|----------|
| `platform` | Kind cluster + Vault (dev) + Kubernetes auth | `task platform:up` · `platform:down` · `platform:reset` · `platform:url` |
| `request`  | A request's Terraform (`REQUEST=<id>`) | `task request:up REQUEST=<id>` · `request:down` · `request:reset` · `request:url` |

Run `task` (or `task help`) to see everything. Top-level `task up`/`down`/`reset`/`url` are shortcuts for the `platform` flow.

### Bootstrap local platform

```bash
cp .env.example .env
task platform:up      # Kind + Vault dev + port-forward + Kubernetes auth
task platform:url     # print the Vault URL
task test-local       # Terratest against local Vault
```

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
terraform/         Platform bootstrap + reusable vault-service-onboard module
platform/          Kind cluster config + Helm values + bootstrap scripts
.cursor/           Rules and Skills that encode the workflow gates
docs/              Setup guide, demo script, architecture, autonomous delivery, ADRs
docs/diagrams/     FigJam-authored SVG diagrams (see docs/figma-diagrams.md)
policies/          Conftest Rego policies for plan validation
.cursor/agents/    Custom subagents (reviewer)
.cursor/BUGBOT.md  Bugbot PR review rules
tests/             Terratest integration tests
```

## Cursor integrations

| Integration | Role |
|-------------|------|
| **Cursor Rules** | Enforce phase order, spec format, Terraform conventions |
| **Cursor Skills** | Deterministic procedures for each workflow step |
| **Cursor Subagents** | Readonly reviewer for autonomous delivery evaluation |
| **Jira MCP** (Atlassian) | Read Jira tickets, post completion comments |
| **Linear MCP** | Read Linear issues, post completion comments |
| **GitHub MCP** | Create branches and pull requests |
| **Bugbot** | Mandatory code review subagent before PR merge (see `.cursor/BUGBOT.md`) |

Skills are **explicitly invoked** — the agent does not autonomously skip gates in the manual workflow. The autonomous path (`create-spec` → `implement-change` → `validate-change`) runs explicit loops documented in [docs/autonomous-delivery.md](docs/autonomous-delivery.md).

## Design principles

1. **Traceability** — Ticket ID (and provider) threads through every artifact directory
2. **Separation of concerns** — Spec, plan, code, validation, and review are distinct review surfaces
3. **Determinism over autonomy** — Skills are procedures with human approval gates, not open-ended agents
4. **Least privilege** — Vault policies are generated from spec fields and reviewed before implementation
5. **Evidence for auditors** — Validation reports and Bugbot findings are committed artifacts
6. **Local parity** — Same Terraform modules run on Kind/Vault dev and would target real clusters via environment tfvars

## Demo

Follow [docs/demo-walkthrough.md](docs/demo-walkthrough.md) for a ~15 minute end-to-end walkthrough using the golden example at `requests/PE-001-payments-api/`.

## Licence

MIT
