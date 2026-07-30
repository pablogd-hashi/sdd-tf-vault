# Setup Guide

Everything in this repository runs locally. No cloud resources are provisioned.

## Prerequisites

| Tool | Minimum version | Install |
|------|-----------------|---------|
| Docker | 24+ | [docker.com](https://www.docker.com/) |
| Kind | 0.22+ | `brew install kind` |
| kubectl | 1.28+ | `brew install kubectl` |
| Helm | 3.14+ | `brew install helm` |
| Terraform | 1.5+ | `brew install terraform` |
| Go | 1.21+ | `brew install go` |
| tflint | 0.50+ | `brew install tflint` (optional) |
| Vault CLI | 1.15+ | `brew install vault` (optional) |

## Environment configuration

```bash
cp .env.example .env
# Edit .env with TICKET_PROVIDER (jira|linear), provider credentials, and GitHub owner
```

Never commit `.env`. Vault credentials for dev mode are documented in bootstrap output (`root` token).

## Bootstrap local platform

```bash
make bootstrap
```

This will:

1. Create a Kind cluster named `pe-copilot`
2. Install Vault in dev mode via Helm
3. Port-forward Vault to `http://127.0.0.1:8200`
4. Create a service account token secret for Kubernetes auth

Verify:

```bash
kubectl get pods -n vault --context kind-pe-copilot
curl -s http://127.0.0.1:8200/v1/sys/health | jq .
```

## Apply platform Terraform

```bash
make platform-apply
```

This configures:

- Kubernetes auth backend at `auth/kubernetes`
- KV v2 mount at `secret/`

Outputs are written to Terraform state at `.terraform-platform.tfstate`.

## Run tests

```bash
make test-local
```

Terratest applies the `vault-service-onboard` module against local Vault and verifies policy and auth role creation.

## MCP configuration (Cursor)

Copy the example MCP config and authenticate:

```bash
cp .cursor/mcp.json.example .cursor/mcp.json
```

### Atlassian (Jira)

1. Open Cursor → Settings → MCP
2. Ensure the Atlassian server is configured with URL `https://mcp.atlassian.com/v1/mcp/authv2`
3. Complete OAuth when prompted
4. See [jira-project-setup.md](jira-project-setup.md) for project configuration

### Linear

1. Open Cursor → Settings → MCP
2. Ensure the Linear server is configured (see `.cursor/mcp.json.example`)
3. Complete OAuth when prompted
4. See [linear-project-setup.md](linear-project-setup.md) for team/issue configuration
5. Set `TICKET_PROVIDER=linear` in `.env` when Linear is the default intake

### GitHub

1. Create a Personal Access Token with `repo` scope
2. Export `GITHUB_PERSONAL_ACCESS_TOKEN` in your shell or `.env`
3. GitHub MCP runs via Docker: `ghcr.io/github/github-mcp-server`

## Validate a request

```bash
make validate REQUEST=PE-001-payments-api
```

If Vault is not reachable, run `./scripts/ensure-vault-ready.sh` or `make bootstrap` first.

## Teardown

```bash
make teardown
```

This stops the port-forward and deletes the Kind cluster.
