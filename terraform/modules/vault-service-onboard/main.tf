locals {
  policy_name = "${var.team}-${var.service_name}"
  role_name   = "${var.team}-${var.service_name}"

  # KV v2 data paths for read/list access
  secret_base = "${var.kv_mount_path}/data/teams/${var.team}/${var.service_name}"
  secret_meta = "${var.kv_mount_path}/metadata/teams/${var.team}/${var.service_name}"

  policy_document = <<-EOT
path "${local.secret_base}/*" {
  capabilities = ["read", "list"]
}

path "${local.secret_meta}/*" {
  capabilities = ["read", "list"]
}

path "${local.secret_meta}/" {
  capabilities = ["list"]
}
EOT
}

resource "vault_policy" "service" {
  name   = local.policy_name
  policy = local.policy_document
}

resource "vault_kubernetes_auth_backend_role" "service" {
  backend                          = var.kubernetes_auth_path
  role_name                        = local.role_name
  bound_service_account_names      = [var.service_account]
  bound_service_account_namespaces = [var.namespace]
  token_policies                   = [vault_policy.service.name]
  token_ttl                        = var.token_ttl
  token_max_ttl                    = var.token_max_ttl
}

# Scaffold empty secrets so paths exist and appear in plan output.
resource "vault_kv_secret_v2" "paths" {
  for_each = toset(var.secret_paths)

  mount = var.kv_mount_path
  name  = "teams/${var.team}/${var.service_name}/${each.value}"

  data_json = jsonencode({
    _managed_by = "platform-copilot"
    _scaffold   = true
  })

  lifecycle {
    ignore_changes = [data_json]
  }
}
