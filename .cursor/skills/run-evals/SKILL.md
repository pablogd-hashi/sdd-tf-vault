---
name: run-evals
description: Run deterministic software-factory evals (golden tickets, no LLM judge). Use when the user says run evals, check factory yield, or score the factory.
---

# Run Evals

Score checked-in golden artifacts. No `CURSOR_API_KEY` required.

## Cases

- happy-payments-api — PE-001 spec R1–R5 mapped into Terraform
- reject-missing-namespace — incomplete ticket must not produce Terraform
- no-invented-paths — secret_paths exactly as specified
- least-privilege — module policy is read/list under `teams/` only

## Steps

1. Run:

```bash
task factory:evals
```

2. Report PASS/FAIL per case and the yield line (`N passed, M failed`).
3. If observability is up, scores are also emitted as `factory.eval.pass` / `factory.eval.total` to OTel.
