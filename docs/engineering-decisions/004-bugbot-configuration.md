# ADR-004: Bugbot Configuration

| Status | Accepted |
|--------|----------|
| Date | 2026-07-28 |
| Branch | `feature/autonomous-delivery` |

## Context

Bugbot reviews PRs on GitHub but does not read `.cursor/rules/`. Project-specific review standards need a dedicated configuration file.

## Decision

Add `.cursor/BUGBOT.md` with:

- Critical findings that block merge (spec drift, inlined resources, over-broad policies)
- High findings (naming, sensitive variables, missing outputs)
- Path-specific review focus for specs, plans, terraform, and modules
- Autonomous delivery additions (reviewer.md required, extended validation)

Existing `bugbot-review` skill unchanged — still launches Bugbot subagent and writes `05-review/bugbot.md`.

## Rationale

- Official Bugbot format per Cursor docs
- Hierarchical rules can be extended per subdirectory later
- Keeps Bugbot concerns separate from agent rules (`workflow-gates.mdc`)

## Consequences

- Bugbot on GitHub uses project rules automatically when enabled
- Local Bugbot subagent skill complements GitHub Bugbot
- Team-wide rules can be added in Cursor dashboard separately

## Alternatives considered

1. **Duplicate rules in BUGBOT.md and rules/** — rejected for agent rules; Bugbot cannot read rules/
2. **Only dashboard rules** — rejected; not version-controlled or reviewable in PRs
