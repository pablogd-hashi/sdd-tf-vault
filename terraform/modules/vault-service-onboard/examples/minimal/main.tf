terraform {
  required_version = ">= 1.5.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.5"
    }
  }
}

variable "service_name" {
  type = string
}

variable "team" {
  type = string
}

variable "namespace" {
  type = string
}

variable "service_account" {
  type = string
}

variable "secret_paths" {
  type = list(string)
}

variable "kubernetes_auth_path" {
  type    = string
  default = "kubernetes"
}

variable "kv_mount_path" {
  type    = string
  default = "secret"
}

variable "vault_addr" {
  type = string
}

variable "vault_token" {
  type      = string
  sensitive = true
}

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

module "under_test" {
  source = "../../"

  service_name         = var.service_name
  team                 = var.team
  namespace            = var.namespace
  service_account      = var.service_account
  secret_paths         = var.secret_paths
  kubernetes_auth_path = var.kubernetes_auth_path
  kv_mount_path        = var.kv_mount_path
}

output "policy_name" {
  value = module.under_test.policy_name
}

output "role_name" {
  value = module.under_test.role_name
}

output "secret_paths" {
  value = module.under_test.secret_paths
}
