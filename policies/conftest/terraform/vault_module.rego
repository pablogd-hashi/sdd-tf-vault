# Conftest policy: request Terraform must use vault-service-onboard module

deny[msg] {
  input.resource_changes
  not uses_module
  msg := "Request Terraform must call vault-service-onboard module, not inline Vault resources"
}

uses_module {
  some i
  input.resource_changes[i].type == "module"
  contains(input.resource_changes[i].module_address, "vault-service-onboard")
}

# When parsing HCL directly (no plan), check module blocks in parsed config
deny[msg] {
  input.module
  count({m | m := input.module[_]; contains(m.source, "vault-service-onboard")}) == 0
  msg := "Module source must reference vault-service-onboard"
}

deny[msg] {
  input.resource
  some name
  resource := input.resource[name]
  resource.type == "vault_policy"
  msg := sprintf("Inlined vault_policy resource '%s' forbidden — use vault-service-onboard module", [name])
}

deny[msg] {
  input.resource
  some name
  resource := input.resource[name]
  resource.type == "vault_kubernetes_auth_backend_role"
  msg := sprintf("Inlined vault_kubernetes_auth_backend_role '%s' forbidden — use vault-service-onboard module", [name])
}
