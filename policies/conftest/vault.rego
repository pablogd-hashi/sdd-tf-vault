package vault

deny[msg] {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "vault_policy"
  not startswith(resource.values.name, "test-")
  not contains(resource.values.policy, "teams/")
  msg := sprintf("Vault policy %s must scope paths under teams/", [resource.values.name])
}

deny[msg] {
  resource := input.planned_values.root_module.child_modules[_].resources[_]
  resource.type == "vault_policy"
  policy := resource.values.policy
  contains(policy, "capabilities = [\"create\"")
  msg := sprintf("Vault policy %s must not grant create capability on secret paths", [resource.values.name])
}

deny[msg] {
  resource := input.planned_values.root_module.child_modules[_].resources[_]
  resource.type == "vault_policy"
  policy := resource.values.policy
  contains(policy, "capabilities = [\"delete\"")
  msg := sprintf("Vault policy %s must not grant delete capability on secret paths", [resource.values.name])
}

deny[msg] {
  resource := input.planned_values.root_module.child_modules[_].resources[_]
  resource.type == "vault_kubernetes_auth_backend_role"
  count(resource.values.bound_service_account_names) != 1
  msg := sprintf("K8s auth role %s must bind exactly one service account", [resource.values.role_name])
}
