terraform {
  required_version = ">= 1.5.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.5"
    }
  }
}

variable "vault_addr" {
  type        = string
  description = "Vault API address"
  default     = "http://127.0.0.1:8200"
}

variable "vault_token" {
  type        = string
  description = "Vault token (dev mode only)"
  default     = "root"
  sensitive   = true
}

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

module "service_onboard" {
  source = "../../../terraform/modules/vault-service-onboard"

  service_name         = "SERVICE_NAME"
  team                 = "TEAM"
  namespace            = "NAMESPACE"
  service_account      = "SERVICE_ACCOUNT"
  secret_paths         = ["config", "db"]
  kubernetes_auth_path = "kubernetes"
  kv_mount_path        = "secret"
}

output "policy_name" {
  value = module.service_onboard.policy_name
}

output "role_name" {
  value = module.service_onboard.role_name
}

output "secret_paths" {
  value = module.service_onboard.secret_paths
}
