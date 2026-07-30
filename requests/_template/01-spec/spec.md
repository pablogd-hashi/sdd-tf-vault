# Infrastructure Request Specification

| Field | Value |
|-------|-------|
| **Ticket** | PE-XXX |
| **Ticket provider** | jira |
| **Status** | Draft |
| **Author** | |
| **Date** | |

## Context

<!-- Why is this request needed? Link to service documentation or architecture decision. -->

## Requirements

| # | Requirement | Source (ticket field) |
|---|-------------|---------------------|
| R1 | | Service name |
| R2 | | Team |
| R3 | | K8s namespace |
| R4 | | K8s service account |
| R5 | | Secret paths |

## Non-goals

- Production Vault cluster changes (local environment only in v1)
- Application secret value injection (paths only)
- Cross-team secret access

## Verification

How we will confirm this request is fulfilled:

- [ ] Vault policy `{team}-{service_name}` exists with read/list on team paths only
- [ ] Kubernetes auth role bound to `{namespace}/{service_account}`
- [ ] KV paths scaffolded: `secret/teams/{team}/{service_name}/{path}` for each requested path
- [ ] `terraform plan` shows only expected resources
- [ ] Terratest or manual Vault CLI confirms policy content

## Sign-off

| Role | Name | Approved | Date |
|------|------|----------|------|
| Requester | | ☐ | |
| Platform lead | | ☐ | |

**Do not proceed to implementation plan until Platform lead approval is recorded.**
