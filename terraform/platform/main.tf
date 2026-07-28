terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.5"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context
}

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

data "kubernetes_secret" "vault_sa" {
  metadata {
    name      = "vault-sa-token"
    namespace = var.vault_namespace
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = var.kubernetes_auth_path
}

resource "vault_kubernetes_auth_backend_config" "this" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://kubernetes.default.svc:443"
  kubernetes_ca_cert     = data.kubernetes_secret.vault_sa.data["ca.crt"]
  token_reviewer_jwt     = data.kubernetes_secret.vault_sa.data["token"]
  disable_iss_validation = true
}

# Vault dev mode enables KV v2 at secret/ by default; platform layer uses that mount.
