.PHONY: bootstrap teardown platform-init platform-apply platform-destroy validate validate-change validate-all test test-local check-phase demo help

ROOT_DIR := $(shell pwd)
REQUEST ?= PE-001-payments-api
KIND_CLUSTER_NAME ?= pe-copilot

help:
	@echo "Platform Engineering Copilot — local commands"
	@echo ""
	@echo "  make bootstrap          Create Kind cluster + Vault dev + port-forward"
	@echo "  make teardown           Delete Kind cluster"
	@echo "  make platform-init      Terraform init for platform layer"
	@echo "  make platform-apply     Apply platform Terraform (K8s auth)"
	@echo "  make platform-destroy   Destroy platform Terraform"
	@echo "  make validate REQUEST=         Validate a request (legacy: fmt, validate, plan)"
	@echo "  make validate-change REQUEST=  Extended validation (fmt, validate, test, conftest, trivy)"
	@echo "  make validate-all              Validate all requests (legacy pipeline)"
	@echo "  make test               Run Terratest (skips if Vault unavailable)"
	@echo "  make test-local         Run Terratest against local Vault"
	@echo "  make check-phase REQUEST=  Check phase order gates"
	@echo "  make demo               Print demo walkthrough path"

bootstrap:
	chmod +x platform/scripts/bootstrap.sh platform/scripts/teardown.sh scripts/*.sh
	./platform/scripts/bootstrap.sh

teardown:
	./platform/scripts/teardown.sh

platform-init:
	cd terraform/platform && terraform init

platform-apply: bootstrap platform-init
	cd terraform/platform && terraform apply -auto-approve

platform-destroy:
	cd terraform/platform && terraform destroy -auto-approve

validate:
	./scripts/ensure-vault-ready.sh || true
	./scripts/validate-request.sh $(REQUEST)

validate-change:
	chmod +x scripts/validate-change.sh scripts/ticket-update-on-validation.sh
	./scripts/ensure-vault-ready.sh || true
	./scripts/validate-change.sh $(REQUEST)

validate-all:
	./scripts/validate-all.sh

test:
	cd tests && go test -v -timeout 10m ./...

test-local:
	@./scripts/ensure-vault-ready.sh || (echo "Run 'make bootstrap && make platform-apply' first" && exit 1)
	@. ./.platform-state 2>/dev/null; export VAULT_ADDR=$${VAULT_ADDR:-http://127.0.0.1:8200}; \
	 export VAULT_TOKEN=$${VAULT_TOKEN:-root}; \
	 cd tests && go test -v -count=1 -timeout 10m ./...

check-phase:
	./scripts/check-phase-order.sh $(REQUEST)

demo:
	@echo "Demo walkthrough: docs/demo-walkthrough.md"
	@echo "Golden example:   requests/PE-001-payments-api/"
