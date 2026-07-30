# ADR-005: Automatic Ticket Update After Validation

| Status | Accepted (superseded in part by ADR-006) |
|--------|----------|
| Date | 2026-07-28 |
| Branch | `feature/autonomous-delivery` |

## Context

Manual workflow posts ticket comments after PR creation (`ticket-update` skill, formerly `jira-update`). Autonomous delivery should notify requesters earlier — when validation passes.

## Decision

Add `scripts/ticket-update-on-validation.sh` (formerly `jira-update-on-validation.sh`) that:

1. Verifies validation report shows PASS (refuses otherwise)
2. Writes `requests/<id>/07-ticket-update/comment.md` deterministically
3. Agent posts comment via the provider MCP (Atlassian for jira, Linear for linear)

Manual `ticket-update` skill remains for PR-completion comments.

## Rationale

- Script produces auditable artifact even if MCP unavailable
- Fail-closed: no ticket update on validation FAIL
- Reuses comment template structure from manual workflow

## Consequences

- Autonomous requests may have ticket comment before PR exists
- Comment notes that PR/reviewer steps are pending
- Manual workflow unchanged (aside from provider abstraction in ADR-006)

## Alternatives considered

1. **Fully automated ticket transition to Done** — rejected; human should confirm PR merge
2. **Skip ticket update until PR** — rejected; user requirement for auto-update after validation

## Supersession note

ADR-006 generalizes this script and phase directory from Jira-only naming to a provider-agnostic ticket abstraction. The fail-closed + artifact-first design is unchanged.
