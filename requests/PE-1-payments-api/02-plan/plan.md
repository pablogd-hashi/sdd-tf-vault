# Implementation Plan

| Field | Value |
|-------|-------|
| **Ticket** | PE-1 |
| **Spec reference** | `01-spec/spec.md` |
| **Status** | Approved |
| **Author** | Pablo Diaz |
| **Date** | 2026-08-03 |

## Summary

Onboard `payments-api` to Vault using the standard `vault-service-onboard` module. Creates a least-privilege policy, Kubernetes auth role bound to the `payments` namespace service account, and scaffolds `config` and `db` secret paths.

## Module selection

| Component | Choice | Rationale |
|-----------|--------|-----------|
| Terraform module | `terraform/modules/vault-service-onboard` | Standard platform module for Vault service onboarding |

## Input mapping

Values copied verbatim from approved spec — do not invent:

| Module variable | Value | Spec requirement |
|-----------------|-------|------------------|
| `service_name` | `payments-api` | R1 |
| `team` | `payments` | R2 |
| `namespace` | `payments` | R3 |
| `service_account` | `payments-api` | R4 |
| `secret_paths` | `["config", "db"]` | R5 |
| `kubernetes_auth_path` | `kubernetes` | Platform default |
| `kv_mount_path` | `secret` | Platform default |

## Resources created

| Resource | Name | Purpose |
|----------|------|---------|
| `vault_policy` | `payments-payments-api` | Read/list on `secret/teams/payments/payments-api/*` |
| `vault_kubernetes_auth_backend_role` | `payments-payments-api` | Bind to `payments/payments-api` SA |
| `vault_kv_secret_v2` | `config`, `db` | Path scaffolding with lifecycle ignore on data |

## Risk assessment

| Risk | Mitigation |
|------|------------|
| Over-broad policy | Policy scoped to `teams/payments/payments-api/*` only |
| Wrong SA binding | Values taken from spec: namespace `payments`, SA `payments-api` |

## Rollback

```bash
cd requests/PE-1-payments-api/03-terraform
terraform destroy
```

## Sign-off

| Role | Name | Approved | Date |
|------|------|----------|------|
| Platform engineer | platform-engineer | ☑ | 2026-08-03 |

Autonomous delivery — plan auto-approved per ADR-001.
