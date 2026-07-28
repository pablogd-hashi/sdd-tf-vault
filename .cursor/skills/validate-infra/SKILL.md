---
name: validate-infra
description: Run the validation pipeline for a request and write results to 04-validation/report.md. Use after Terraform implementation and before Bugbot review.
disable-model-invocation: true
---

# Validate Infrastructure

Run validation and write `requests/<id>/04-validation/report.md`.

## Steps

1. Confirm `03-terraform/main.tf` exists
2. Run validation:

```bash
make validate REQUEST=<request-id>
```

3. Read the generated `04-validation/report.md`
4. If **FAIL**: fix Terraform issues and re-run until PASS
5. If **PASS**: tell user validation succeeded; proceed to Bugbot review

## Checks performed

| Check | Tool |
|-------|------|
| Format | `terraform fmt -check` |
| Syntax | `terraform validate` |
| Lint | `tflint` (if installed) |
| Plan | `terraform plan` against local Vault |

If plan is skipped because Vault is unreachable, validation still **PASS**es when fmt and validate succeed. For full plan validation:

```bash
make bootstrap && make platform-apply
make validate REQUEST=<request-id>
```
