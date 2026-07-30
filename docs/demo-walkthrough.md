# Demo Walkthrough (~15 minutes)

End-to-end demonstration of the Platform Engineering Copilot workflow.

## Before you start

```bash
cp .env.example .env
make bootstrap
make platform-apply
cp .cursor/mcp.json.example .cursor/mcp.json
# Authenticate Atlassian (or Linear) + GitHub MCP in Cursor
```

Golden example (pre-built): `requests/PE-001-payments-api/`

Live demo ticket: create **PE-002** in Jira (see [jira-project-setup.md](jira-project-setup.md)) or Linear (see [linear-project-setup.md](linear-project-setup.md))

---

## Phase 1 — Ticket to Spec (2 min)

**Prompt:**

> Use the ticket-to-spec skill to read ticket PE-002 (provider jira) and create the specification.

**Show:** `requests/PE-002-*/01-spec/spec.md` — requirements mapped to ticket fields, sign-off table.

**Say:** "Spec is independently reviewable. Platform lead approves before any Terraform exists."

**Action:** Mark sign-off ☑ and say "approved".

---

## Phase 2 — Spec to Plan (2 min)

**Prompt:**

> Use the spec-to-plan skill for PE-002.

**Show:** Input mapping table — values copied verbatim from spec.

**Say:** "Plan tells engineers exactly which module and variables. No invention."

**Action:** Approve plan.

---

## Phase 3 — Plan to Terraform (2 min)

**Prompt:**

> Use the plan-to-terraform skill for PE-002.

**Show:** Thin `main.tf` calling `vault-service-onboard` module.

**Say:** "Request layer is a wrapper. Platform module is the reusable product."

---

## Phase 4 — Validation (2 min)

**Prompt:**

> Use the validate-infra skill for PE-002.

```bash
make validate REQUEST=PE-002-<service>
```

**Show:** `04-validation/report.md` with PASS verdict and plan summary.

**Say:** "Evidence artifact for auditors — plan output committed, not ephemeral."

---

## Phase 5 — Bugbot Review (2 min)

**Prompt:**

> Use the bugbot-review skill for PE-002.

**Show:** `05-review/bugbot.md` with findings table.

**Say:** "Mandatory automated review gate before PR. Critical findings block merge."

---

## Phase 6 — GitHub PR (2 min)

**Prompt:**

> Use the open-github-pr skill for PE-002.

**Show:** PR with links to spec/plan/validation artifacts. `06-pr/metadata.json`.

**Say:** "PR description points reviewers to the right phase for their concern."

---

## Phase 7 — Ticket Update (1 min)

**Prompt:**

> Use the ticket-update skill for PE-002.

**Show:** Ticket comment with PR link. `07-ticket-update/comment.md`.

**Say:** "Traceability loop closed — ticket updated with evidence."

---

## Interview talking points

1. **Traceability** — PE-002 threads through every directory
2. **Separation** — spec reviewer never sees Terraform
3. **Determinism** — skills are procedures with gates, not autonomous agents
4. **Evidence** — validation report + Bugbot findings are committed
5. **Local parity** — same modules target real Vault in production via tfvars

## Quick path (golden example only)

If short on time, walk through the pre-built example:

```bash
make validate REQUEST=PE-001-payments-api
cat requests/PE-001-payments-api/01-spec/spec.md
cat requests/PE-001-payments-api/03-terraform/main.tf
cat requests/PE-001-payments-api/04-validation/report.md
```
