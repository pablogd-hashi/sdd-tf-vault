# ADR-001: Autonomous Delivery Path

| Status | Accepted |
|--------|----------|
| Date | 2026-07-28 |
| Branch | `feature/autonomous-delivery` |

## Context

The repository originally implemented specification-driven development with **human approval gates** between every phase. Platform teams asked for an autonomous path that still produces auditable artifacts but reduces manual handoffs during implementation and validation.

## Decision

Add a parallel **autonomous delivery** workflow alongside the existing manual workflow:

| Manual (unchanged) | Autonomous (new) |
|--------------------|------------------|
| `ticket-to-spec` | `create-spec` |
| `spec-to-plan` + `plan-to-terraform` | `implement-change` |
| `validate-infra` | `validate-change` |
| Human sign-off between phases | Auto-sign-off with audit marker |
| `bugbot-review` | `reviewer` subagent + `bugbot-review` |

Autonomous mode is marked by `requests/<id>/01-spec/autonomous.json`.

## Rationale

- **Preserves existing workflow** — no changes to manual skill behaviour or `make validate`
- **Deterministic validation** — shell scripts produce reports; agent loop fixes and retries explicitly
- **Audit trail** — auto-approved sign-offs include explicit note referencing this ADR
- **Readonly reviewer** — isolated subagent evaluates without modifying files

## Consequences

- Two entry points; agents must check for `autonomous.json` to select path
- Extended validation requires optional tools (conftest, trivy) — skipped when not installed
- Ticket update runs automatically after validation PASS (artifact always written; MCP post by agent)
- PR merge still requires human approval

## Alternatives considered

1. **Replace manual workflow** — rejected; regulated teams need human gates for spec/plan
2. **Single mega-skill** — rejected; explicit skills match existing pattern and are easier to invoke
3. **Hidden auto-retry in scripts** — rejected; agent-visible loop preferred for transparency
