---
name: jira-to-spec
description: Read an approved Jira infrastructure request via Atlassian MCP and write a specification to requests/<ticket-id>/01-spec/spec.md. Use when starting a new workflow from a Jira ticket or when the user asks to create a spec from Jira.
disable-model-invocation: true
---

# Jira to Spec

Convert a Jira infrastructure request into `requests/<ticket-id>/01-spec/spec.md`.

## Prerequisites

- Atlassian MCP authenticated in Cursor
- Jira ticket in project PE with required fields (see `jira-ticket-schema` rule)

## Steps

1. **Read the Jira ticket** via Atlassian MCP using the ticket key (e.g. `PE-123`)
2. **Validate required fields** — reject if service name, team, namespace, SA, or secret paths missing
3. **Create request directory**: `requests/PE-123-<service-name>/`
4. **Copy template** from `requests/_template/01-spec/spec.md`
5. **Fill all sections**:
   - Map Jira fields to requirements R1–R5
   - Write context from ticket description
   - Copy acceptance criteria to verification checklist
   - Set status to `Draft`
6. **Stop** — ask user to review spec and obtain platform lead sign-off before proceeding

## Output

```
requests/PE-123-<service>/01-spec/spec.md
```

Do not create plan or Terraform until spec is approved.
