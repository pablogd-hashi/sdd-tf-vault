---
name: onboard-from-paste
description: Start autonomous Vault onboarding from a pasted request (no Jira, no Linear). Use when the user pastes an Infrastructure Request, says onboard this, paste a ticket, or skip the tracker. Cursor Ultra / local Agent path.
---

# Onboard From Paste

No Jira webhook. No Linear. The user message **is** the ticket.

Cursor Ultra does not run Jira-triggered Cloud Agent automations (Teams plan). This skill is the factory intake that still works: paste fields → same autonomous chain → draft PR.

## Required fields in the paste

Copy from `.cursor/rules/ticket-schema.mdc`. Reject if any of these are missing — do not invent:

- Service name
- Team
- Environment
- K8s namespace
- K8s service account
- Secret paths
- Acceptance criteria
- Approver

Optional ticket id (e.g. `PE-10`). If omitted, use `PE-paste-<service-name>`.

## Steps

1. Parse the paste. Set `ticket_provider` to `pasted`.
2. Follow `create-spec` then `implement-change` → `validate-change` until PASS (same as `AGENTS.md` autonomous delivery).
3. Write `autonomous.json` with `"ticket_provider": "pasted"`.
4. Reviewer → bugbot → draft PR. Do not merge.
5. Write `07-ticket-update/comment.md`. **Do not** call Atlassian or Linear MCP.
6. If this is a local IDE run and the user wants Vault applied, they can say **apply onboarding** after PASS. Do not start Grafana unless they ask.

## Paste template

```
Ticket: PE-paste-auth-api
Service name: auth-api
Team: platform
Environment: local
K8s namespace: platform
K8s service account: auth-api
Secret paths: config, db
Approver: platform-lead

Acceptance criteria
- Service can authenticate via Kubernetes auth
- Service can read config and db secrets from Vault
- Policy scoped to platform team paths only
```
