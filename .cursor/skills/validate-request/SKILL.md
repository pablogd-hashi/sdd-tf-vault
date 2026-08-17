---
name: validate-request
description: Validate a Vault onboarding request against live Vault (fmt, tests, plan) without posting a ticket comment. Use when the user says validate PE-001, validate-change the golden request, or run validation locally.
---

# Validate Request

Local / IDE validation. Calls `./scripts/validate-change.sh` only.

Do **not** run ticket-update or the reviewer subagent (those belong to autonomous `validate-change` after a real ticket).

## Steps

1. Default request is `PE-001-payments-api` if unnamed.
2. Vault must be reachable. If not, invoke **start observability** or **start the environment** first.
3. Run:

```bash
./scripts/validate-change.sh PE-001-payments-api
```

4. Read `requests/<id>/04-validation/report.md` and report the verdict.
5. On PASS, tell the user they can say **apply onboarding**.
