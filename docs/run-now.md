# Run a test right now

Two tests. Start with **A** (no Docker). Do **B** when Docker Desktop is running if you want Grafana.

In Cursor you can say the skill names. Equivalents are scripts — **go-task is optional**.

## A — five minutes (Vault + evals + golden onboard)

From the repo root, on branch `cursor/software-factory-8d74`:

```bash
# 1. Factory runtime (Vault -dev, no Kind)
./scripts/factory-environment.sh

# 2. Yield (no API key)
./evals/score.sh

# 3. Validate the golden request against live Vault
./scripts/validate-change.sh PE-001-payments-api

# 4. Apply onboarding (creates policy, k8s auth role, KV paths)
terraform -chdir=requests/PE-001-payments-api/03-terraform init -input=false
terraform -chdir=requests/PE-001-payments-api/03-terraform apply -auto-approve

# 5. Confirm in Vault
export VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root
vault policy read payments-payments-api
vault read auth/kubernetes/role/payments-payments-api
vault kv get secret/teams/payments/payments-api/config
```

In Cursor, the same sequence is:

1. **start the environment**
2. **run evals**
3. “validate-change PE-001-payments-api, then apply that request’s Terraform”

**Pass:** evals 4/4, validate-change PASS, `vault policy read` shows `teams/payments/payments-api`.

Tear down Vault only:

```bash
./platform/scripts/vault-dev-stop.sh
```

(Compose Vault is stopped with **stop the factory** / `./observability/scripts/down.sh`.)

## B — Grafana dashboards (Docker required)

```bash
./observability/scripts/up.sh
./observability/scripts/dashboards.sh
```

Or say **start observability** then **show the dashboard**.

| URL | Login |
|-----|--------|
| http://127.0.0.1:3000 | admin / admin |
| [Factory Operations](http://127.0.0.1:3000/d/factory-operations/factory-operations) | |
| [Vault Onboarding](http://127.0.0.1:3000/d/vault-onboarding/vault-onboarding) | |
| http://127.0.0.1:9090 | Prometheus |

Copy MCP so the local agent can query them:

```bash
cp .cursor/mcp.json.example .cursor/mcp.json
# reload MCP in Cursor
```

Then: “list Grafana dashboards” or “PromQL: up{job=\"vault\"}”.

Cloud Agents cannot see laptop Grafana. This path is **local IDE / local agent only**.

## C — async Cloud Agent (no Grafana)

1. Create a Linear issue with service, team, namespace, SA, secret paths.
2. Move it to **In Progress Cursor**.
3. Watch [cursor.com/agents](https://cursor.com/agents) — it should open a draft PR.

## If something is already running

```bash
./observability/scripts/status.sh
curl -sf http://127.0.0.1:8200/v1/sys/health && echo Vault_OK
```

Host Vault `-dev` from a previous session is enough for test **A**. You do not need to restart it unless `curl` fails.
