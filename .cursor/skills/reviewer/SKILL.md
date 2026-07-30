---
name: reviewer
description: Launch the readonly reviewer subagent with isolated context to evaluate autonomous delivery changes. Records findings in 05-review/reviewer.md. Use after validate-change PASS.
disable-model-invocation: true
---

# Reviewer

Launch the project **reviewer** subagent to evaluate changes. The reviewer receives isolated context, cannot modify files, and only evaluates.

## Prerequisites

- Validation verdict PASS in `requests/<id>/04-validation/report.md`
- Terraform and plan artifacts committed or present on working branch

## Steps

1. Read request ID and confirm validation PASS
2. Launch exactly one **reviewer** subagent via Task tool:

```
subagent_type: reviewer
description: Reviewer evaluation
run_in_background: false
```

Prompt (isolated context — include all evaluation inputs):

```text
Full Repository Path: <absolute repo path>
Request ID: <request-id>

Evaluate spec/plan/terraform alignment for autonomous delivery.
Read only:
- requests/<id>/01-spec/spec.md
- requests/<id>/02-plan/plan.md
- requests/<id>/03-terraform/main.tf
- requests/<id>/04-validation/report.md

Return findings table and PASS/FAIL verdict.
```

The reviewer subagent is defined at `.cursor/agents/reviewer.md` with `readonly: true`.
It cannot modify files — evaluation only.

3. Write subagent output to `requests/<id>/05-review/reviewer.md`:

```markdown
# Reviewer Evaluation

| Field | Value |
|-------|-------|
| **Request** | <id> |
| **Reviewed at** | <iso8601> |
| **Subagent** | reviewer (readonly) |
| **Context** | Isolated — spec, plan, terraform, validation only |

## Findings

| Severity | Location | Finding |
|----------|----------|---------|

## Verdict

- [ ] PASS — no Critical findings
- [ ] FAIL — address Critical findings
```

4. Set verdict:
   - **PASS** if no Critical findings
   - **FAIL** if any Critical findings

## Gate

- Do **not** open PR if Critical findings exist
- Fix issues, re-run `validate-change`, and re-run reviewer

## Output

```
requests/<id>/05-review/reviewer.md
```
