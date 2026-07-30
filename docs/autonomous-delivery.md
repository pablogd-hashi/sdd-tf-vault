# Autonomous Delivery

Specification-driven **autonomous delivery** extends the existing manual workflow without replacing it. Use this path when you want the agent to implement and validate infrastructure changes with minimal mid-phase handoffs, while still producing auditable artifacts.

## When to use

| Use autonomous | Use manual (default) |
|----------------|----------------------|
| Well-formed tickets (Jira or Linear) with all required fields | Spec/plan need human review before code |
| Standard Vault service onboarding | Non-standard or exploratory requests |
| Local/dev environment delivery | Production-first review gates |

## Quick start

```bash
# On feature branch (never merge autonomous experiments to main without review)
git checkout -b pe/PE-123-payments-api

# In Cursor, invoke skills in order:
# 1. create-spec      — from ticket PE-123 (jira or linear)
# 2. implement-change — plan + terraform (auto-continues to validate)
# 3. validate-change  — loop until PASS
# 4. reviewer         — readonly evaluation
# 5. bugbot-review    — before PR (unchanged)
# 6. open-github-pr   — human merge approval
```

Or run validation manually:

```bash
make validate-change REQUEST=PE-123-payments-api
./scripts/ticket-update-on-validation.sh PE-123-payments-api
```

## Workflow diagram

[![Autonomous validation loop](diagrams/06-autonomous-validation-loop.svg)](https://www.figma.com/board/1RbIQpZgVRQr2TzsKe2SiZ)

## Validation pipeline

`make validate-change REQUEST=<id>` runs checks in order:

| Step | Tool | Required |
|------|------|----------|
| 1 | `terraform fmt -check` | Yes |
| 2 | `terraform validate` | Yes |
| 3 | `terraform test` | Module tests always; request tests if present |
| 4 | Terratest | When Vault reachable |
| 5 | `conftest test` | When `conftest` installed |
| 6 | `trivy config` | When `trivy` installed |
| 7 | `tflint` | When installed |
| 8 | `terraform plan` | When Vault reachable |

Reports are written to `requests/<id>/04-validation/report.md` with per-check `.out` files.

## Autonomous marker

Autonomous requests include `requests/<id>/01-spec/autonomous.json`:

```json
{
  "mode": "autonomous",
  "ticket_id": "PE-123",
  "ticket_provider": "jira",
  "created_at": "2026-07-28T12:00:00Z",
  "next_skill": "implement-change"
}
```

Sign-off tables record: `Autonomous delivery — auto-approved per ADR-001`.

## Reviewer subagent

Defined at `.cursor/agents/reviewer.md`:

- `readonly: true` — cannot modify files
- Isolated context — evaluates spec, plan, terraform, validation only
- Output: `requests/<id>/05-review/reviewer.md`

## Bugbot

Project rules: `.cursor/BUGBOT.md`

Local review skill: `bugbot-review` (unchanged)

## Engineering decisions

All architectural choices are documented in [engineering-decisions/](engineering-decisions/):

- [ADR-001: Autonomous delivery path](engineering-decisions/001-autonomous-delivery-path.md)
- [ADR-002: Extended validation pipeline](engineering-decisions/002-extended-validation-pipeline.md)
- [ADR-003: Readonly reviewer subagent](engineering-decisions/003-readonly-reviewer-subagent.md)
- [ADR-004: Bugbot configuration](engineering-decisions/004-bugbot-configuration.md)
- [ADR-005: Ticket update on validation](engineering-decisions/005-jira-update-on-validation.md)
- [ADR-006: Ticket provider abstraction](engineering-decisions/006-ticket-provider-abstraction.md)

## Backward compatibility

- `make validate` — unchanged legacy pipeline
- Manual skills (`ticket-to-spec`, `spec-to-plan`, etc.) — provider-agnostic
- Golden example `PE-001-payments-api` — validates with legacy pipeline
- Phase directory `07-ticket-update/` — renamed from `07-jira-update/` (ADR-006)
