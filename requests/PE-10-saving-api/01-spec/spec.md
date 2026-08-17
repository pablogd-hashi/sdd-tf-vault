# Infrastructure Request Specification

| Field | Value |
|-------|-------|
| **Ticket** | PE-10 |
| **Ticket provider** | jira |
| **Status** | Approved |
| **Author** | Platform Engineering |
| **Date** | 2026-08-04 |

## Context

The `saving-api` microservice is being onboarded to Vault in the local environment. The team needs Vault secret paths and a Kubernetes auth role so the application can read configuration and database credentials at runtime via Kubernetes authentication.

Environment: local

## Requirements

| # | Requirement | Source (ticket field) |
|---|-------------|---------------------|
| R1 | Service name: `saving-api` | Service name |
| R2 | Team: `saving` | Team |
| R3 | Kubernetes namespace: `saving` | K8s namespace |
| R4 | Service account: `saving-api` | K8s service account |
| R5 | Secret paths: `config`, `db` | Secret paths |

## Non-goals

- Production Vault cluster changes (local environment only in v1)
- Application secret value injection (paths only)
- Cross-team secret access

## Verification

How we will confirm this request is fulfilled:

- [ ] Service can authenticate via Kubernetes auth
- [ ] Service can read config and db secrets from Vault
- [ ] Policy scoped to saving team paths only
- [ ] Vault policy `saving-saving-api` exists with read/list on team paths only
- [ ] Kubernetes auth role bound to `saving/saving-api`
- [ ] KV paths scaffolded: `secret/teams/saving/saving-api/config` and `secret/teams/saving/saving-api/db`
- [ ] `terraform plan` shows only expected resources
- [ ] Terratest or manual Vault CLI confirms policy content

## Sign-off

| Role | Name | Approved | Date |
|------|------|----------|------|
| Requester | platform-engineering | ☑ | 2026-08-04 |
| Platform lead | platform-lead | ☑ | 2026-08-04 |

Autonomous delivery — spec auto-approved per ADR-001.
