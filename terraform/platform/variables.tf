variable "vault_addr" {
  type        = string
  description = "Vault API address"
  default     = "http://127.0.0.1:8200"
}

variable "vault_token" {
  type        = string
  description = "Vault root token (dev mode only)"
  default     = "root"
  sensitive   = true
}

variable "kubernetes_auth_path" {
  type        = string
  description = "Path for the Kubernetes auth backend"
  default     = "kubernetes"
}
