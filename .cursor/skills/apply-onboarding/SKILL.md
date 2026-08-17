---
name: apply-onboarding
description: Apply a Vault onboarding request's Terraform against local Vault. Use when the user says apply onboarding, apply PE-001, terraform apply the request, or create the policy and KV paths.
---

# Apply Onboarding

Apply `requests/<id>/03-terraform` to the factory Vault (`http://127.0.0.1:8200`, token `root`).

Never apply outside `requests/<id>/03-terraform` or `terraform/platform`.

## Steps

1. Default request is `PE-001-payments-api` if the user did not name one.
2. Confirm Vault is up (`./observability/scripts/status.sh`). If Vault is down, say **start observability** (full stack) or **start the environment** (Vault only), then retry.
3. Run:

```bash
./scripts/apply-request.sh PE-001-payments-api
```

4. Confirm:

```bash
export VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root
vault policy read payments-payments-api
vault kv get secret/teams/payments/payments-api/config
```

5. Report the policy name and that KV scaffold exists.
