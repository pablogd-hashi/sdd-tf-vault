---
name: create-spec
description: Create a specification from a pasted request or a Jira/Linear ticket for autonomous delivery. Writes requests/<ticket-id>/01-spec/spec.md and marks it ready for implement-change. Use when starting autonomous delivery, onboard-from-paste, or create-spec from a ticket.
disable-model-invocation: true
---

# Create Spec

Create `requests/<ticket-id>/01-spec/spec.md` from a **pasted** infrastructure request or from Jira/Linear for the **autonomous delivery** path.

This skill is the entry point for specification-driven autonomous delivery. It does **not** replace `ticket-to-spec` (manual gated workflow).

## Prerequisites

- Ticket with required fields (see `ticket-schema` rule)
- Provider: `pasted` if the user pasted the fields. Otherwise **jira** via the Atlassian plugin on `edsefsonytv.atlassian.net` (project PE), or **linear**.
- Feature branch: `pe/<ticket>-<service>`

## Provider → source mapping

| Provider | Read issue |
|----------|------------|
| pasted | The user message / paste |
| jira | Atlassian **plugin** (Jira). MCP only if plugin is absent. |
| linear | Linear plugin / `get_issue` |

If the user names a Jira key (PE-9), use the plugin. Do not call Atlassian MCP while the plugin can see the issue.

## Steps

1. **Resolve provider** — `pasted` | `jira` | `linear` (paste wins; else `TICKET_PROVIDER`)
2. **Read the ticket** from the paste or the Atlassian plugin. Ticket id: from the user (`PE-9`) or `PE-paste-<service-name>`.
3. **Validate required fields** — reject if service name, team, namespace, SA, or secret paths missing
4. **Create request directory**: `requests/<ticket-id>-<service-name>/` (if ticket id already includes the service, do not double it)
5. **Copy template** from `requests/_template/01-spec/spec.md`
6. **Fill all sections**:
   - Record **Ticket** and **Ticket provider** (`pasted` | `jira` | `linear`)
   - Map fields to requirements R1–R5
   - Set status to `Approved`
   - Mark platform lead sign-off ☑ with note: `Autonomous delivery — spec auto-approved per ADR-001`
7. **Write** `requests/<id>/01-spec/autonomous.json` with `ticket_provider` set correctly (`pasted` when applicable)
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
