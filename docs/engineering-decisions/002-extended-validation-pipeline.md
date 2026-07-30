# ADR-002: Extended Validation Pipeline

| Status | Accepted |
|--------|----------|
| Date | 2026-07-28 |
| Branch | `feature/autonomous-delivery` |

## Context

Legacy validation (`scripts/validate-request.sh`) runs fmt, validate, tflint, and plan. Autonomous delivery requires stronger evidence before ticket update and reviewer evaluation.

## Decision

Add `scripts/validate-change.sh` with ordered checks:

1. `terraform fmt -check` (auto-fix on failure)
2. `terraform validate`
3. `terraform test` (module + request-level if present)
4. Terratest (`go test`)
5. `conftest test` (Rego policies on plan JSON)
6. `trivy config` (IaC misconfiguration scan)
7. `tflint` (preserved from legacy)
8. `terraform plan` (preserved from legacy)

Legacy `make validate` and `scripts/validate-request.sh` remain **unchanged**.

## Verdict rules

- fmt and validate must pass
- Any **installed** check that runs and fails blocks PASS
- SKIP (tool not installed or Vault unreachable) does not block PASS
- Plan SKIP does not block PASS (same as legacy)

## Rationale

- Explicit ordering matches user requirement
- Separate script avoids breaking golden examples validated by legacy pipeline
- Per-check `.out` files in `04-validation/` provide audit evidence
- Agent skill handles retry loop; script is single-pass and deterministic

## Consequences

- Optional tools improve coverage but are not hard requirements locally
- CI can install conftest/trivy for full coverage
- Module gains `module.tftest.hcl` for plan-only unit tests

## Alternatives considered

1. **Extend validate-request.sh in place** — rejected; would change legacy behaviour and report format
2. **Fail when optional tools missing** — rejected; local dev should work with Terraform + Go only
