---
name: ticket-update
description: Post a completion comment to the Jira or Linear ticket via the provider MCP with PR link and validation summary. Use after GitHub PR is created.
disable-model-invocation: true
---

# Ticket Update

Post completion comment to the ticket provider (Jira or Linear) and save draft to `07-ticket-update/comment.md`.

## Prerequisites

- PR created with metadata in `06-pr/metadata.json` (`ticket_id`, `ticket_provider`)
- Provider MCP authenticated:
  - **jira** → Atlassian MCP
  - **linear** → Linear MCP

## Provider → MCP mapping

| Provider | Post comment | Transition / status |
|----------|--------------|---------------------|
| pasted | none — write `07-ticket-update/comment.md` only | skip |
| jira | `addCommentToJiraIssue` | `transitionJiraIssue` (ask user first) |
| linear | `create_comment` | `update_issue` (ask user first) |

## Steps

1. **Read** `06-pr/metadata.json` for PR URL, `ticket_id`, and `ticket_provider`
2. **Read** `04-validation/report.md` for verdict summary
3. **Read** `03-terraform/main.tf` outputs for policy/role names
4. **Write** `requests/<id>/07-ticket-update/comment.md` using template from `requests/_template/07-ticket-update/comment.md`
5. **Post comment** via MCP only for `jira` or `linear`. For `pasted`, skip MCP.
6. **Transition / update status** to Done/In Review if appropriate (ask user first)

## Comment must include

- PR link
- Validation verdict
- Policy and role names created
- Secret paths scaffolded

## Output

```
requests/<id>/07-ticket-update/comment.md
```

Posted comment on ticket PE-XXX (provider: jira|linear).
