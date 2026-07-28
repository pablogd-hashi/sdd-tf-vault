output "policy_name" {
  description = "Name of the Vault ACL policy"
  value       = vault_policy.service.name
}

output "role_name" {
  description = "Name of the Kubernetes auth role"
  value       = vault_kubernetes_auth_backend_role.service.role_name
}

output "secret_paths" {
  description = "Full KV v2 paths for onboarded secrets"
  value       = [for p in var.secret_paths : "${var.kv_mount_path}/teams/${var.team}/${var.service_name}/${p}"]
}

output "auth_backend" {
  description = "Kubernetes auth backend path"
  value       = var.kubernetes_auth_path
}
