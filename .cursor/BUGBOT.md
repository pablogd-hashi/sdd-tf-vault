# Bugbot rules for Platform Engineering Copilot
#
# Bugbot reads this file on PR review. It does NOT read .cursor/rules/.
# See: https://cursor.com/docs/bugbot

## Scope

This repository implements specification-driven Vault service onboarding.
Reviews must enforce traceability, least privilege, and phase artifact completeness.

## Critical findings (block merge)

- **Spec drift**: Terraform module inputs do not match values in `requests/*/02-plan/plan.md` input mapping table
- **Inlined resources**: Request Terraform inlines `vault_policy`, `vault_kubernetes_auth_backend_role`, or `vault_kv_secret_v2` instead of calling `terraform/modules/vault-service-onboard`
- **Over-broad policy**: Vault policy grants access outside `secret/data/teams/{team}/{service}/*` and corresponding metadata paths
- **Hardcoded secrets**: Production tokens or credentials hardcoded in Terraform (dev `root` default in variables is acceptable for local-only)
- **Missing validation**: PR changes `requests/*/03-terraform/` without updated `04-validation/report.md` showing PASS
- **Phase skip**: Terraform added without corresponding spec and plan artifacts in the same request directory

## High findings

- Policy or role naming does not follow `{team}-{service_name}` convention
- `vault_token` variable missing `sensitive = true`
- Secret paths not under `teams/{team}/{service_name}/` prefix
- Missing Terraform outputs: `policy_name`, `role_name`, `secret_paths`

## Review focus by path

### `requests/*/01-spec/spec.md`

- Requirements R1–R5 populated from ticket fields (Jira or Linear)
- Sign-off recorded before implementation artifacts exist

### `requests/*/02-plan/plan.md`

- Input mapping copies spec values verbatim
- Resources table lists expected Vault resources only

### `requests/*/03-terraform/main.tf`

- Uses module source `../../../terraform/modules/vault-service-onboard`
- Module inputs match plan exactly

### `terraform/modules/vault-service-onboard/`

- Policy document uses read/list only on team-scoped paths
- K8s role binds single namespace and single service account

### `scripts/`, `Makefile`

- Do not weaken validation gates
- Preserve backward compatibility of `make validate` (legacy pipeline)

## Autonomous delivery

When `requests/*/01-spec/autonomous.json` exists:

- Auto-approved sign-offs are acceptable per ADR-001
- Require `05-review/reviewer.md` in addition to `05-review/bugbot.md` before merge
- Validation must use extended pipeline (`scripts/validate-change.sh`)

## Non-goals for Bugbot

- Do not flag dev-mode `vault_token = "root"` default in request variables
- Do not require cloud-specific resources (local Kind/Vault only)
- Do not suggest redesigns of the phase directory structure
