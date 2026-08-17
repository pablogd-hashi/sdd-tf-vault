---
name: ticket-update
description: Post a completion comment to the Jira ticket via the Atlassian Cursor plugin (preferred) or Linear. Use after GitHub PR is created. Do not require MCP.
disable-model-invocation: true
---

# Ticket Update

Post a completion comment and save the draft to `07-ticket-update/comment.md`.

**Jira site (required):** `https://edsefsonytv.atlassian.net` — project PE, [board 34](https://edsefsonytv.atlassian.net/jira/software/projects/PE/boards/34). Cloud id `c829f01c-71dd-4abe-a246-4def3dfa5c2b`. Never use `agentic-workflow-demo.atlassian.net`.

**Linear:** Linear plugin or Linear MCP.

**pasted:** write the comment file only; skip Jira/Linear.

## Prerequisites

- PR metadata in `06-pr/metadata.json` (`ticket_id`, `ticket_provider`)
- For `jira`: Atlassian plugin enabled (`.cursor/settings.json` → `plugins.atlassian`)

## Provider → tools

| Provider | Comment | Notes |
|----------|---------|--------|
| jira | Atlassian **plugin** add-comment (or equivalent Jira tool) | Plugin first. MCP only if plugin is absent. |
| linear | Linear plugin / `create_comment` | |
| pasted | none — `07-ticket-update/comment.md` only | skip |

## Steps

1. **Read** `06-pr/metadata.json` for PR URL, `ticket_id`, and `ticket_provider`
2. **Read** `04-validation/report.md` for verdict summary
3. **Read** `03-terraform/main.tf` outputs for policy/role names
4. **Write** `requests/<id>/07-ticket-update/comment.md` using template from `requests/_template/07-ticket-update/comment.md`
5. **Post comment:** Jira → Atlassian plugin. Linear → Linear plugin. `pasted` → skip. Do not use MCP when the plugin works.
6. **Do not** transition to Done unless the user asks.

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
