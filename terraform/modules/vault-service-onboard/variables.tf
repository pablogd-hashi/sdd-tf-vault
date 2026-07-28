variable "service_name" {
  type        = string
  description = "Name of the service being onboarded (e.g. payments-api)"
}

variable "team" {
  type        = string
  description = "Team owning the service (e.g. payments)"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace for the service account"
}

variable "service_account" {
  type        = string
  description = "Kubernetes service account name bound to the Vault role"
}

variable "secret_paths" {
  type        = list(string)
  description = "Secret path suffixes under teams/{team}/{service_name}/ (e.g. [\"config\", \"db\"])"
}

variable "kubernetes_auth_path" {
  type        = string
  description = "Path of the Kubernetes auth backend (from platform outputs)"
  default     = "kubernetes"
}

variable "kv_mount_path" {
  type        = string
  description = "KV v2 mount path (from platform outputs)"
  default     = "secret"
}

variable "token_ttl" {
  type        = number
  description = "Default token TTL in seconds for the Kubernetes auth role"
  default     = 3600
}

variable "token_max_ttl" {
  type        = number
  description = "Maximum token TTL in seconds for the Kubernetes auth role"
  default     = 7200
}
