terraform {
  required_version = ">= 1.5.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.5"
    }
  }
}

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

# Factory default: enable Kubernetes auth mount so request modules can write
# roles. Cluster JWT configuration lives in terraform/platform-kind (optional).
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = var.kubernetes_auth_path
}

# Vault -dev enables KV v2 at secret/ by default; platform layer uses that mount.
