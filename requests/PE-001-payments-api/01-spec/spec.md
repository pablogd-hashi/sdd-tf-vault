# Infrastructure Request Specification

| Field | Value |
|-------|-------|
| **Ticket** | PE-001 |
| **Ticket provider** | jira |
| **Status** | Approved |
| **Author** | payments-team |
| **Date** | 2026-07-28 |

## Context

The `payments-api` microservice is being deployed to the local Kind cluster for integration testing. The team needs Vault secret paths and a Kubernetes auth role so the application can read configuration and database credentials at runtime.

## Requirements

| # | Requirement | Source (ticket field) |
|---|-------------|---------------------|
| R1 | Service name: `payments-api` | Service name |
| R2 | Team: `payments` | Team |
| R3 | Kubernetes namespace: `payments` | K8s namespace |
| R4 | Service account: `payments-api` | K8s service account |
| R5 | Secret paths: `config`, `db` | Secret paths |

## Non-goals

- Production Vault cluster changes (local environment only in v1)
- Injecting real database passwords (path scaffolding only)
- Access to other teams' secret paths

## Verification

How we will confirm this request is fulfilled:

- [x] Vault policy `payments-payments-api` exists with read/list on team paths only
- [x] Kubernetes auth role bound to `payments/payments-api`
- [x] KV paths scaffolded: `secret/teams/payments/payments-api/config` and `.../db`
- [x] `terraform plan` shows only expected resources
- [x] Terratest confirms policy content

## Sign-off

| Role | Name | Approved | Date |
|------|------|----------|------|
| Requester | payments-team | ☑ | 2026-07-28 |
| Platform lead | platform-lead | ☑ | 2026-07-28 |

**Spec approved. Proceed to implementation plan.**
