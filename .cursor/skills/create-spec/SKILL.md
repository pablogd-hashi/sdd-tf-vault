---
name: create-spec
description: Create a specification from a Jira or Linear ticket for autonomous delivery. Writes requests/<ticket-id>/01-spec/spec.md and marks it ready for implement-change. Use when starting autonomous delivery or when the user asks to create-spec from a ticket.
disable-model-invocation: true
---

# Create Spec

Create `requests/<ticket-id>/01-spec/spec.md` from a Jira or Linear infrastructure request for the **autonomous delivery** path.

This skill is the entry point for specification-driven autonomous delivery. It does **not** replace `ticket-to-spec` (manual gated workflow).

## Prerequisites

- Provider MCP authenticated in Cursor:
  - **jira** → Atlassian MCP
  - **linear** → Linear MCP
- Ticket with required fields (see `ticket-schema` rule)
- Provider known: from user (`TICKET_PROVIDER` / explicit mention), or ask if ambiguous
- Feature branch checked out: `feature/autonomous-delivery` or `pe/<ticket>-<service>`

## Provider → MCP mapping

| Provider | Read issue |
|----------|------------|
| jira | Atlassian MCP (`getJiraIssue`) |
| linear | Linear MCP (`get_issue`) |

## Steps

1. **Resolve provider** — `jira` or `linear` (default from `TICKET_PROVIDER` env if unset)
2. **Read the ticket** via the provider MCP using the ticket key (e.g. `PE-123`)
3. **Validate required fields** — reject if service name, team, namespace, SA, or secret paths missing
4. **Create request directory**: `requests/PE-123-<service-name>/`
5. **Copy template** from `requests/_template/01-spec/spec.md`
6. **Fill all sections**:
   - Record **Ticket** and **Ticket provider** in the header table
   - Map ticket fields to requirements R1–R5
   - Write context from ticket description
   - Copy acceptance criteria to verification checklist
   - Set status to `Approved`
   - Mark platform lead sign-off ☑ with note: `Autonomous delivery — spec auto-approved per ADR-001`
7. **Write** `requests/<id>/01-spec/autonomous.json`:

```json
{
  "mode": "autonomous",
  "ticket_id": "PE-XXX",
  "ticket_provider": "jira",
  "created_at": "<iso8601>",
  "next_skill": "implement-change"
}
```

8. **Proceed immediately** to `implement-change` — do not wait for human approval in autonomous mode

## Output

```
requests/PE-123-<service>/01-spec/spec.md
requests/PE-123-<service>/01-spec/autonomous.json
```

## Rules

- Never invent values — copy from ticket fields only
- Do not create plan or Terraform in this skill
- If `01-spec/autonomous.json` already exists with same ticket, confirm idempotency before overwriting
