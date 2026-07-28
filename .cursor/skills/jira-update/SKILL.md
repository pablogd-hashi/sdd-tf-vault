---
name: jira-update
description: Post a completion comment to the Jira ticket via Atlassian MCP with PR link and validation summary. Use after GitHub PR is created.
disable-model-invocation: true
---

# Jira Update

Post completion comment to Jira and save draft to `07-jira-update/comment.md`.

## Prerequisites

- PR created with metadata in `06-pr/metadata.json`
- Atlassian MCP authenticated

## Steps

1. **Read** `06-pr/metadata.json` for PR URL and ticket ID
2. **Read** `04-validation/report.md` for verdict summary
3. **Read** `03-terraform/main.tf` outputs for policy/role names
4. **Write** `requests/<id>/07-jira-update/comment.md` using template from `requests/_template/07-jira-update/comment.md`
5. **Post comment** to Jira ticket via Atlassian MCP
6. **Transition ticket** to Done/In Review if appropriate (ask user first)

## Comment must include

- PR link
- Validation verdict
- Policy and role names created
- Secret paths scaffolded

## Output

```
requests/<id>/07-jira-update/comment.md
```

Posted comment on Jira ticket PE-XXX.
