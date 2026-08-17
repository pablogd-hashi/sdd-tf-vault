# Implementation Plan

| Field | Value |
|-------|-------|
| **Ticket** | PE-10 |
| **Spec reference** | `01-spec/spec.md` |
| **Status** | Approved |
| **Author** | Platform Engineering |
| **Date** | 2026-08-04 |

## Summary

Onboard `saving-api` to Vault using the standard `vault-service-onboard` module. Creates a least-privilege policy, Kubernetes auth role bound to the `saving` namespace service account, and scaffolds `config` and `db` secret paths.

## Module selection

| Component | Choice | Rationale |
|-----------|--------|-----------|
| Terraform module | `terraform/modules/vault-service-onboard` | Standard platform module for Vault service onboarding |

## Input mapping

Values copied verbatim from approved spec — do not invent:

| Module variable | Value | Spec requirement |
|-----------------|-------|------------------|
| `service_name` | `saving-api` | R1 |
| `team` | `saving` | R2 |
| `namespace` | `saving` | R3 |
| `service_account` | `saving-api` | R4 |
| `secret_paths` | `["config", "db"]` | R5 |
| `kubernetes_auth_path` | `kubernetes` | Platform default |
| `kv_mount_path` | `secret` | Platform default |

## Resources created

| Resource | Name | Purpose |
|----------|------|---------|
| `vault_policy` | `saving-saving-api` | Read/list on `secret/teams/saving/saving-api/*` |
| `vault_kubernetes_auth_backend_role` | `saving-saving-api` | Bind to `saving/saving-api` SA |
| `vault_kv_secret_v2` | `config`, `db` | Path scaffolding with lifecycle ignore on data |

## Risk assessment

| Risk | Mitigation |
|------|------------|
| Over-broad policy | Policy scoped to `teams/saving/saving-api/*` only |
| Wrong SA binding | Values taken from spec: namespace `saving`, SA `saving-api` |

## Rollback

```bash
cd requests/PE-10-saving-api/03-terraform
terraform destroy
```

## Sign-off

| Role | Name | Approved | Date |
|------|------|----------|------|
| Platform engineer | platform-engineer | ☑ | 2026-08-04 |

Autonomous delivery — plan auto-approved per ADR-001.
