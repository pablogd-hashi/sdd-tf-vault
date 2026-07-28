# Implementation Plan

| Field | Value |
|-------|-------|
| **Jira ticket** | PE-XXX |
| **Spec reference** | `01-spec/spec.md` |
| **Status** | Draft |
| **Author** | |
| **Date** | |

## Summary

One paragraph describing what Terraform will create and why.

## Module selection

| Component | Choice | Rationale |
|-----------|--------|-----------|
| Terraform module | `terraform/modules/vault-service-onboard` | Standard platform module for Vault service onboarding |

## Input mapping

Values copied verbatim from approved spec — do not invent:

| Module variable | Value | Spec requirement |
|-----------------|-------|------------------|
| `service_name` | | R1 |
| `team` | | R2 |
| `namespace` | | R3 |
| `service_account` | | R4 |
| `secret_paths` | | R5 |
| `kubernetes_auth_path` | `kubernetes` | Platform default |
| `kv_mount_path` | `secret` | Platform default |

## Resources created

| Resource | Name | Purpose |
|----------|------|---------|
| `vault_policy` | `{team}-{service_name}` | Least-privilege read/list |
| `vault_kubernetes_auth_backend_role` | `{team}-{service_name}` | SA binding |
| `vault_kv_secret_v2` | per path in `secret_paths` | Path scaffolding |

## Risk assessment

| Risk | Mitigation |
|------|------------|
| Over-broad policy | Policy scoped to single service path prefix |
| Wrong SA binding | Values taken from spec, validated in plan review |

## Rollback

```bash
cd requests/PE-XXX/03-terraform
terraform destroy
```

## Sign-off

| Role | Name | Approved | Date |
|------|------|----------|------|
| Platform engineer | | ☐ | |

**Do not proceed to Terraform until Platform engineer approval is recorded.**
