---
name: spec-to-plan
description: Write an implementation plan from an approved specification at requests/<id>/02-plan/plan.md. Use after spec approval and before Terraform implementation.
disable-model-invocation: true
---

# Spec to Plan

Create `requests/<id>/02-plan/plan.md` from an approved spec.

## Prerequisites

- Approved spec at `requests/<id>/01-spec/spec.md` with platform lead sign-off ☑
- Run `./scripts/check-phase-order.sh <id>` — spec must exist

## Steps

1. **Read** `01-spec/spec.md` — extract R1–R5 values
2. **Copy template** from `requests/_template/02-plan/plan.md`
3. **Fill sections**:
   - Input mapping table: copy values verbatim from spec (no invention)
   - Resources table: list `vault_policy`, `vault_kubernetes_auth_backend_role`, `vault_kv_secret_v2`
   - Risk assessment: over-broad policy, wrong SA binding
   - Rollback: `terraform destroy` command with correct path
4. Set status to `Draft`
5. **Stop** — ask platform engineer to review and approve plan

## Module

Always use `terraform/modules/vault-service-onboard`. Never inline Vault resources.

## Output

```
requests/<id>/02-plan/plan.md
```

Do not create Terraform until plan is approved.
