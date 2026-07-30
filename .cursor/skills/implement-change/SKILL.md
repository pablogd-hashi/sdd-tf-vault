---
name: implement-change
description: Implement plan and Terraform from an approved spec for autonomous delivery. Writes 02-plan/plan.md and 03-terraform/main.tf, then invokes validate-change. Use after create-spec or when autonomous implementation is requested.
disable-model-invocation: true
---

# Implement Change

Implement plan and Terraform for a request in **autonomous delivery** mode, then enter the validation loop.

## Prerequisites

- Spec at `requests/<id>/01-spec/spec.md` with status `Approved`
- `requests/<id>/01-spec/autonomous.json` exists (autonomous mode marker)
- Run `./scripts/check-phase-order.sh <id>` — spec must exist

## Steps

1. **Read** `01-spec/spec.md` — extract R1–R5 values verbatim
2. **Create plan** at `requests/<id>/02-plan/plan.md`:
   - Copy template from `requests/_template/02-plan/plan.md`
   - Fill input mapping table from spec (no invention)
   - Mark engineer sign-off ☑ with note: `Autonomous delivery — plan auto-approved per ADR-001`
   - Set status to `Approved`
3. **Create Terraform** at `requests/<id>/03-terraform/main.tf`:
   - Copy from `requests/_template/03-terraform/main.tf`
   - Call module `../../../terraform/modules/vault-service-onboard` with mapped values
   - Include outputs: `policy_name`, `role_name`, `secret_paths`
4. **Run** `terraform fmt -recursive` on `03-terraform/`
5. **Enter validation loop** — invoke `validate-change` skill with the request ID

## Validation loop

```
implement (this skill)
    ↓
validate-change (fmt → validate → test → conftest → trivy)
    ↓
on FAIL: fix Terraform/plan issues, re-run validate-change
    ↓
on PASS: proceed to reviewer subagent
```

Repeat until `04-validation/report.md` shows verdict PASS.

## Rules

- Always use `terraform/modules/vault-service-onboard` — never inline Vault resources
- No hardcoded tokens beyond dev defaults in variables
- No values not present in the approved spec
- Do not apply Terraform — validation handles plan and tests
- Do not skip validation or reviewer phases

## Output

```
requests/<id>/02-plan/plan.md
requests/<id>/03-terraform/main.tf
```

Then delegates to `validate-change`.
