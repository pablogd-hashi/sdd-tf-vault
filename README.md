# Platform Engineering Copilot

An open-source reference implementation showing how to implement software delivery in regulated platform engineering teams.

This repository demonstrates a **specification-driven workflow** that converts approved infrastructure tickets (Jira or Linear) into production-ready Terraform — with every phase independently reviewable.

## Workflow

```
Ticket → Specification → Implementation Plan → Terraform → Validation → Review → GitHub PR → Ticket Update
```

Each phase lives in its own directory under `requests/<ticket-id>/`, so reviewers can approve specs without reading Terraform, and platform engineers can audit validation evidence without opening the ticket tracker.

### Autonomous delivery (optional)

An extended path reduces mid-phase handoffs while preserving auditable artifacts. See [docs/autonomous-delivery.md](docs/autonomous-delivery.md).

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
- Optional: [Vault CLI](https://developer.hashicorp.com/vault/install), [tflint](https://github.com/terraform-linters/tflint)

### Bootstrap local platform

```bash
cp .env.example .env
make bootstrap        # Kind + Vault dev + port-forward
make platform-apply   # Terraform: enable Kubernetes auth
make test-local       # Terratest against local Vault
```

### Run validation on the golden example

```bash
make validate REQUEST=PE-001-payments-api
make validate-change REQUEST=PE-001-payments-api   # extended pipeline
```

See [docs/setup.md](docs/setup.md) for full setup including MCP configuration.

## Repository layout

```
requests/          One folder per ticket; phases are numbered subdirs
terraform/         Platform bootstrap + reusable vault-service-onboard module
platform/          Kind cluster config + Helm values + bootstrap scripts
.cursor/           Rules and Skills that encode the workflow gates
docs/              Setup guide, demo script, architecture, autonomous delivery, ADRs
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

## What this teaches (interview talking points)

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
