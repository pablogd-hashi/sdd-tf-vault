variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig file"
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  type        = string
  description = "Kubernetes context for the Kind cluster"
  default     = "kind-pe-copilot"
}

variable "vault_addr" {
  type        = string
  description = "Vault API address (port-forwarded from Kind)"
  default     = "http://127.0.0.1:8200"
}

variable "vault_token" {
  type        = string
  description = "Vault root token (dev mode only)"
  default     = "root"
  sensitive   = true
}

variable "vault_namespace" {
  type        = string
  description = "Kubernetes namespace where Vault runs"
  default     = "vault"
}

variable "vault_release" {
  type        = string
  description = "Helm release name for Vault"
  default     = "vault"
}

variable "kubernetes_auth_path" {
  type        = string
  description = "Path for the Kubernetes auth backend"
  default     = "kubernetes"
}
