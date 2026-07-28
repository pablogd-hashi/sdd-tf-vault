# Infrastructure Request Specification

| Field | Value |
|-------|-------|
| **Jira ticket** | PE-9 |
| **Status** | Draft |
| **Author** | Pablo D |
| **Date** | 2026-07-28 |

## Context

The `payments-api` microservice is being onboarded to Vault in the local environment. The team needs Vault secret paths and a Kubernetes auth role so the application can read configuration and database credentials at runtime via Kubernetes authentication.

Environment: local

## Requirements

| # | Requirement | Source (Jira field) |
|---|-------------|---------------------|
| R1 | Service name: `payments-api` | Service name |
| R2 | Team: `payments` | Team |
| R3 | Kubernetes namespace: `payments` | K8s namespace |
| R4 | Service account: `payments-api` | K8s service account |
| R5 | Secret paths: `config`, `db` | Secret paths |

## Non-goals

- Production Vault cluster changes (local environment only in v1)
- Application secret value injection (paths only)
- Cross-team secret access

## Verification

How we will confirm this request is fulfilled:

- [ ] Service can authenticate via Kubernetes auth
- [ ] Service can read config and db secrets from Vault
- [ ] Policy scoped to payments team paths only
- [ ] Vault policy `payments-payments-api` exists with read/list on team paths only
- [ ] Kubernetes auth role bound to `payments/payments-api`
- [ ] KV paths scaffolded: `secret/teams/payments/payments-api/config` and `secret/teams/payments/payments-api/db`
- [ ] `terraform plan` shows only expected resources
- [ ] Terratest or manual Vault CLI confirms policy content

## Sign-off

| Role | Name | Approved | Date |
|------|------|----------|------|
| Requester | Pablo D | ☐ | |
| Platform lead | platform-lead | ☐ | |

**Do not proceed to implementation plan until Platform lead approval is recorded.**
