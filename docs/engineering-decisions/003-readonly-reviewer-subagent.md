# ADR-003: Readonly Reviewer Subagent

| Status | Accepted |
|--------|----------|
| Date | 2026-07-28 |
| Branch | `feature/autonomous-delivery` |

## Context

Autonomous delivery removes human gates during implement and validate phases. An independent evaluation step is needed before PR creation to catch spec drift and security issues.

## Decision

Implement reviewer as:

1. **Custom subagent** at `.cursor/agents/reviewer.md` with `readonly: true`
2. **Skill** at `.cursor/skills/reviewer/SKILL.md` to launch and record findings
3. **Artifact** at `requests/<id>/05-review/reviewer.md`

The reviewer receives **isolated context** — only spec, plan, terraform, and validation report paths are provided in the prompt. It cannot modify files.

## Evaluation checklist

- Spec R1–R5 → plan → terraform traceability
- Module usage (no inlined Vault resources)
- Least-privilege policy paths
- Validation PASS evidence
- Naming conventions

## Rationale

- `readonly: true` enforced at subagent config level
- Isolated context prevents conversation history bias
- Separate artifact from Bugbot (`bugbot.md`) — reviewer checks traceability; Bugbot checks code quality
- Both required before PR in autonomous path

## Consequences

- Extra review artifact for autonomous requests
- Manual workflow unchanged (reviewer optional unless autonomous marker present)
- Reviewer runs after validation PASS, before Bugbot

## Alternatives considered

1. **Reuse Bugbot only** — rejected; Bugbot runs on PR diffs, not spec alignment
2. **Human-only review** — rejected; defeats autonomous delivery goal for implement/validate phases
