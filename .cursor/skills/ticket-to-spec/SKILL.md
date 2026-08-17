---
name: ticket-to-spec
description: Read an approved infrastructure request via the Atlassian Cursor plugin (Jira, preferred) or Linear and write a specification. Do not require MCP.
disable-model-invocation: true
---

# Ticket to Spec

Convert a Jira or Linear infrastructure request into `requests/<ticket-id>/01-spec/spec.md`.

## Prerequisites

- For **jira**: Atlassian Cursor **plugin** (Jira). Not MCP.
- For **linear**: Linear plugin or Linear MCP
- For **pasted**: the user message is the ticket
- Ticket with required fields (see `ticket-schema` rule)
- Provider known: from user (`TICKET_PROVIDER` / explicit mention), or ask if ambiguous

## Provider → source mapping

| Provider | Read issue |
|----------|------------|
| jira | Atlassian **plugin** (get issue / search PE). MCP only if plugin is absent. |
| linear | Linear plugin |
| pasted | User paste |

## Steps

1. **Resolve provider** — `jira` or `linear` (default from `TICKET_PROVIDER` env if unset)
2. **Read the ticket** — Jira via the Atlassian plugin. If the plugin cannot see project PE, stop (wrong site). Do not reuse a git spec.
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
