---
name: open-github-pr
description: Create a GitHub pull request for an approved infrastructure request using GitHub MCP. Use after Bugbot review PASS.
disable-model-invocation: true
---

# Open GitHub PR

Create a PR for the request and record metadata in `06-pr/metadata.json`.

## Prerequisites

- Bugbot verdict PASS in `05-review/bugbot.md`
- Changes on branch `pe/<ticket>-<service>` (e.g. `pe/PE-001-payments-api`)

## Steps

1. **Commit** all request artifacts if not already committed:

```
requests/<id>/01-spec/
requests/<id>/02-plan/
requests/<id>/03-terraform/
requests/<id>/04-validation/
requests/<id>/05-review/
```

2. **Push branch** to origin
3. **Create PR** via GitHub MCP with title:

```
[PE-XXX] Vault onboard <service-name>
```

4. PR body template:

```markdown
## Summary
Vault service onboarding for `<service-name>` per approved spec PE-XXX.

## Artifacts
- Spec: `requests/<id>/01-spec/spec.md`
- Plan: `requests/<id>/02-plan/plan.md`
- Validation: PASS

## Test plan
- [ ] Review spec/plan sign-offs
- [ ] Review Terraform module inputs match spec
- [ ] Confirm validation report attached
- [ ] Merge after approval
```

5. **Write** `requests/<id>/06-pr/metadata.json`:

```json
{
  "jira_ticket": "PE-XXX",
  "branch": "pe/PE-XXX-<service>",
  "pr_url": "<url from GitHub MCP>",
  "commit_sha": "<sha>",
  "created_at": "<iso8601>"
}
```

6. **Stop** — ask user to review PR before Jira update
