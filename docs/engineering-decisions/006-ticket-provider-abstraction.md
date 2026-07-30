# ADR-006: Ticket Provider Abstraction (Jira + Linear)

| Status | Accepted |
|--------|----------|
| Date | 2026-07-30 |
| Branch | current |

## Context

Intake and completion updates were hardcoded to Jira (skills `jira-to-spec` / `jira-update`, phase `07-jira-update/`, field `jira_ticket`). Linear MCP is available and teams may use either tracker. Jira and Linear issue IDs share the `TEAM-123` shape, so provider cannot be inferred from the ID alone.

## Decision

1. Introduce provider-agnostic skills `ticket-to-spec` and `ticket-update` (replace Jira-named skills)
2. Record `ticket_provider` (`jira` | `linear`) and `ticket_id` per request (spec header, `autonomous.json`, `06-pr/metadata.json`)
3. Rename phase directory to `07-ticket-update/` and script to `ticket-update-on-validation.sh`
4. Agent selects MCP from recorded provider:
   - jira → Atlassian (`getJiraIssue`, `addCommentToJiraIssue`, `transitionJiraIssue`)
   - linear → Linear (`get_issue`, `create_comment`, `update_issue`)
5. Default provider from `TICKET_PROVIDER` env when not set per-request
6. Shared field schema in `.cursor/rules/ticket-schema.mdc`

## Rationale

- Avoid duplicating the full skill/script/template surface for each tracker
- Explicit provider field avoids ambiguous ID parsing
- Deterministic scripts remain MCP-agnostic; posting stays agent-driven

## Consequences

- Existing request artifacts updated to generic field names
- Docs include both [jira-project-setup.md](../jira-project-setup.md) and [linear-project-setup.md](../linear-project-setup.md)
- Golden example retains `ticket_provider: jira` for continuity

## Alternatives considered

1. **Parallel Jira + Linear skill trees** — rejected; high duplication
2. **Replace Jira entirely with Linear** — rejected; keep both providers
3. **Infer provider from ID prefix** — rejected; prefixes collide across systems
