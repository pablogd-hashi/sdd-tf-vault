output "vault_addr" {
  description = "Vault API address"
  value       = var.vault_addr
}

output "kubernetes_auth_path" {
  description = "Path of the Kubernetes auth backend"
  value       = vault_auth_backend.kubernetes.path
}

output "kv_mount_path" {
  description = "KV v2 mount path for team secrets (enabled by Vault dev mode)"
  value       = "secret"
}
