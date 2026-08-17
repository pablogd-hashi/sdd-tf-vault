# Setup Guide

Everything in this repository runs locally. No cloud resources are provisioned. The Terraform layers below sit on top of a local Kind + Vault runtime:

[![Infrastructure layers](diagrams/05-infrastructure-layers.svg)](https://www.figma.com/board/1RbIQpZgVRQr2TzsKe2SiZ)

## Prerequisites

| Tool | Minimum version | Install |
|------|-----------------|---------|
| Docker | 24+ | [docker.com](https://www.docker.com/) |
| Kind | 0.22+ | `brew install kind` |
| kubectl | 1.28+ | `brew install kubectl` |
| Helm | 3.14+ | `brew install helm` |
| Terraform | 1.5+ | `brew install terraform` |
| Go | 1.21+ | `brew install go` |
| Task | 3.x | `brew install go-task` |
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
task platform:up
```

This runs three steps in sequence:

1. Create a Kind cluster named `pe-copilot`, install Vault in dev mode via Helm, and start a port-forward to `http://127.0.0.1:8200`
2. Apply platform Terraform — enables Kubernetes auth backend at `auth/kubernetes` and KV v2 mount at `secret/`
3. Print the Vault URL

You can also run the steps individually:

```bash
task platform:bootstrap   # cluster + Vault + port-forward only
task platform:apply       # Terraform only
task platform:url         # print URL
task platform:status      # check Vault health
```

Verify:

```bash
kubectl get pods -n vault --context kind-pe-copilot
curl -s http://127.0.0.1:8200/v1/sys/health | jq .
```

Terraform state is written to `.terraform-platform.tfstate`.

## Run tests

```bash
task test-local
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

### Slack (optional)

Slack MCP enables the `notify-slack` skill: post workflow notifications, query pending tickets, and confirm ticket creation from Cursor.

1. Create a Slack app at [api.slack.com/apps](https://api.slack.com/apps) with the following bot token scopes:
   - `chat:write`, `channels:read`, `channels:history`, `channels:join`
2. Install the app to your workspace and copy the **Bot User OAuth Token** (`xoxb-…`)
3. Copy your **Team ID** from workspace settings (starts with `T`)
4. Add both to `.env`:

   ```bash
   SLACK_BOT_TOKEN=xoxb-your-token
   SLACK_TEAM_ID=T0123456789
   SLACK_DEFAULT_CHANNEL=#infra-onboarding
   ```

5. Invite the bot to `#infra-onboarding`: `/invite @your-app-name`
6. Slack MCP runs via `npx @modelcontextprotocol/server-slack` (configured in `.cursor/mcp.json.example`); reload MCP servers in Cursor after setting env vars

**Skill usage:**

```
notify-slack: PE-123 spec is ready for review
notify-slack: Which Jira tickets are pending?
notify-slack: Create a Linear ticket for auth-service onboarding and confirm in Slack
```

See `.cursor/skills/notify-slack/SKILL.md` for the full scenario reference.

### Presentation skill (optional)

The public presentation skill is vendored at `vendor/presentation_skill`. Cursor discovers it as the `presentation` skill (`.cursor/skills/presentation/SKILL.md`). Image generation uses Cursor's image tool; optional provider keys stay in workspace `.env`.

```bash
python3 -m venv vendor/presentation_skill/.venv
vendor/presentation_skill/.venv/bin/pip install -e 'vendor/presentation_skill[dev]'
bash vendor/presentation_skill/scripts/presentation-skill "Topic" --mode image --output decks/topic
```

## Validate a request

```bash
task validate REQUEST=PE-001-payments-api
task validate-change REQUEST=PE-001-payments-api   # extended pipeline
```

If Vault is not reachable, run `task platform:up` first.

## Teardown

```bash
task platform:down
```

This destroys platform Terraform and deletes the Kind cluster. To start fresh:

```bash
task platform:reset   # down + up in one command
```

> The original `make` targets still work (`make bootstrap`, `make platform-apply`, `make validate ...`); `task` is the recommended interface.
