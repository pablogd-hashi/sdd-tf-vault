# Module-level terraform tests (plan-only, no Vault required)
# Run from module root: terraform init && terraform test

mock_provider "vault" {}

run "policy_name_follows_convention" {
  command = plan

  module {
    source = "./examples/minimal"
  }

  variables {
    service_name    = "payments-api"
    team            = "payments"
    namespace       = "payments"
    service_account = "payments-api"
    secret_paths    = ["config", "db"]
    vault_addr      = "http://127.0.0.1:8200"
    vault_token     = "root"
  }

  assert {
    condition     = output.policy_name == "payments-payments-api"
    error_message = "Policy name must be {team}-{service_name}"
  }
}

run "role_name_matches_policy" {
  command = plan

  module {
    source = "./examples/minimal"
  }

  variables {
    service_name    = "payments-api"
    team            = "payments"
    namespace       = "payments"
    service_account = "payments-api"
    secret_paths    = ["config"]
    vault_addr      = "http://127.0.0.1:8200"
    vault_token     = "root"
  }

  assert {
    condition     = output.role_name == output.policy_name
    error_message = "Role name must match policy name"
  }
}

run "secret_paths_count" {
  command = plan

  module {
    source = "./examples/minimal"
  }

  variables {
    service_name    = "payments-api"
    team            = "payments"
    namespace       = "payments"
    service_account = "payments-api"
    secret_paths    = ["config", "db"]
    vault_addr      = "http://127.0.0.1:8200"
    vault_token     = "root"
  }

  assert {
    condition     = length(output.secret_paths) == 2
    error_message = "Must expose one secret path per requested path"
  }
}
