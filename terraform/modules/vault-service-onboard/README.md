# vault-service-onboard

Onboards a service to Vault with least-privilege access:

- **Vault ACL policy** scoped to `secret/teams/{team}/{service_name}/*`
- **Kubernetes auth role** bound to `{namespace}/{service_account}`
- **KV v2 path scaffolding** for each requested secret path

## Usage

```hcl
module "payments_api" {
  source = "../../terraform/modules/vault-service-onboard"

  service_name         = "payments-api"
  team                 = "payments"
  namespace            = "payments"
  service_account      = "payments-api"
  secret_paths         = ["config", "db"]
  kubernetes_auth_path = "kubernetes"
  kv_mount_path        = "secret"
}
```

## Inputs

| Name | Description | Required |
|------|-------------|----------|
| `service_name` | Service identifier | yes |
| `team` | Owning team | yes |
| `namespace` | K8s namespace for SA binding | yes |
| `service_account` | K8s service account name | yes |
| `secret_paths` | Path suffixes to scaffold | yes |
| `kubernetes_auth_path` | K8s auth backend path | no (default: `kubernetes`) |
| `kv_mount_path` | KV v2 mount | no (default: `secret`) |

## Policy example

For `team=payments`, `service_name=payments-api`:

```hcl
path "secret/data/teams/payments/payments-api/*" {
  capabilities = ["read", "list"]
}

path "secret/metadata/teams/payments/payments-api/*" {
  capabilities = ["read", "list"]
}
```

## Notes

- Scaffold secrets contain `_managed_by` and `_scaffold` markers; real secret values are injected separately.
- `lifecycle.ignore_changes` on `data_json` prevents Terraform from overwriting application-managed secret data.
