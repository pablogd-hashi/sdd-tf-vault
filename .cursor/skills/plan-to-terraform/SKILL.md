---
name: plan-to-terraform
description: Implement Terraform for a Vault service onboarding request from an approved plan. Writes requests/<id>/03-terraform/main.tf calling vault-service-onboard module. Use after plan approval.
disable-model-invocation: true
---

# Plan to Terraform

Implement `requests/<id>/03-terraform/main.tf` from an approved plan.

## Prerequisites

- Approved plan at `requests/<id>/02-plan/plan.md` with engineer sign-off ☑
- Input mapping table fully populated

## Steps

1. **Read** `02-plan/plan.md` input mapping — copy values exactly
2. **Create** `requests/<id>/03-terraform/main.tf` based on `requests/_template/03-terraform/main.tf`
3. **Call module** `../../../terraform/modules/vault-service-onboard` with mapped variables
4. **Include outputs**: `policy_name`, `role_name`, `secret_paths`
5. Run `terraform fmt -recursive` on the directory
6. **Stop** — tell user to run `make validate REQUEST=<id>`

## Rules

- No hardcoded tokens beyond dev defaults in variables
- No values not present in the approved plan
- Do not apply Terraform — validation skill handles plan

## Output

```
requests/<id>/03-terraform/main.tf
```
