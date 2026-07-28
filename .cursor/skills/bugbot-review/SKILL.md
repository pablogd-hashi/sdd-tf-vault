---
name: bugbot-review
description: Launch Bugbot subagent to review branch changes for a request and record findings in 05-review/bugbot.md. Use after validation PASS and before opening a GitHub PR.
disable-model-invocation: true
---

# Bugbot Review

Run Bugbot on request changes and write `requests/<id>/05-review/bugbot.md`.

## Prerequisites

- Validation verdict PASS in `04-validation/report.md`
- Changes committed on feature branch `pe/<ticket>-<service>`

## Steps

1. Ensure feature branch is checked out with request Terraform changes
2. Launch exactly one `bugbot` subagent:

```
Full Repository Path: <absolute repo path>
Diff: branch changes
```

3. Write findings to `requests/<id>/05-review/bugbot.md`:

```markdown
| Severity | Location | Finding |
|----------|----------|---------|
```

4. Set verdict:
   - **PASS** if no Critical findings
   - **FAIL** if any Critical findings

## Gate

- Do **not** open PR if Critical findings exist
- Fix issues, re-validate, and re-run Bugbot

## Output

```
requests/<id>/05-review/bugbot.md
```
