---
name: validate-change
description: Run the full autonomous validation loop (fmt, validate, test, conftest, trivy) and write 04-validation/report.md. Repeats until PASS, then triggers ticket update and reviewer subagent. Use after implement-change or when re-validating autonomous delivery changes.
disable-model-invocation: true
---

# Validate Change

Run the extended validation pipeline for autonomous delivery and write `requests/<id>/04-validation/report.md`.

## Prerequisites

- `requests/<id>/03-terraform/main.tf` exists
- Autonomous marker at `requests/<id>/01-spec/autonomous.json` (or user explicitly requests extended validation)

## Steps

1. Confirm Terraform directory exists
2. Run validation:

```bash
make validate-change REQUEST=<request-id>
```

3. Read `requests/<id>/04-validation/report.md`
4. If **FAIL**:
   - Read failed check details from report and tool output files in `04-validation/`
   - Fix Terraform or policy issues
   - Re-run from step 2
   - Repeat until PASS or user stops the loop
5. If **PASS**:
   - Run ticket update: `./scripts/ticket-update-on-validation.sh <request-id>`
   - Post the draft comment via the provider MCP recorded in `autonomous.json` / comment header (`jira` → Atlassian, `linear` → Linear)
   - Launch **reviewer** subagent (see `.cursor/skills/reviewer/SKILL.md`)
   - Report validation summary to user

## Checks performed (in order)

| Step | Tool | Skip condition |
|------|------|----------------|
| 1 | `terraform fmt -check` | Auto-fix with `terraform fmt` then re-check |
| 2 | `terraform validate` | Never skip |
| 3 | `terraform test` | SKIP if no `.tftest.hcl` in request dir |
| 4 | Terratest (`go test`) | SKIP if `SKIP_VAULT_TESTS=true` or Vault unreachable |
| 5 | `conftest test` | SKIP if `conftest` not installed |
| 6 | `trivy config` | SKIP if `trivy` not installed |
| 7 | `terraform plan` | SKIP if Vault unreachable (same as legacy validate) |
| 8 | `tflint` | SKIP if not installed (legacy check, preserved) |

## Verdict rules

- **PASS** when fmt and validate pass, and no installed check reports FAIL
- Plan SKIP does not block PASS (Vault unavailable)
- conftest/trivy/tflint SKIP does not block PASS when tool not installed
- Any installed check that FAILs blocks PASS

## Output

```
requests/<id>/04-validation/report.md
requests/<id>/04-validation/*.out   (per-check raw output)
requests/<id>/07-ticket-update/comment.md  (after PASS, via script)
requests/<id>/05-review/reviewer.md      (after reviewer subagent)
```

## Gate

Do not open PR until reviewer subagent verdict is recorded in `05-review/reviewer.md`.
