---
name: ticket-to-spec
description: Read an approved infrastructure request via Jira (Atlassian MCP) or Linear MCP and write a specification to requests/<ticket-id>/01-spec/spec.md. Use when starting a new workflow from a ticket or when the user asks to create a spec from Jira or Linear.
disable-model-invocation: true
---

# Ticket to Spec

Convert a Jira or Linear infrastructure request into `requests/<ticket-id>/01-spec/spec.md`.

## Prerequisites

- Provider MCP authenticated in Cursor:
  - **jira** → Atlassian MCP
  - **linear** → Linear MCP
- Ticket with required fields (see `ticket-schema` rule)
- Provider known: from user (`TICKET_PROVIDER` / explicit mention), or ask if ambiguous

## Provider → MCP mapping

| Provider | Read issue | MCP tools (examples) |
|----------|------------|----------------------|
| jira | Atlassian MCP | `getJiraIssue` |
| linear | Linear MCP | `get_issue` |

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
   - Set status to `Draft`
7. **Stop** — ask user to review spec and obtain platform lead sign-off before proceeding

## Output

```
requests/PE-123-<service>/01-spec/spec.md
```

Do not create plan or Terraform until spec is approved.
