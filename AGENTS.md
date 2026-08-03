# AGENTS.md

## Cursor Cloud specific instructions

This repo is the **Platform Engineering Copilot**: a spec-driven workflow that turns infra
tickets into Terraform that onboards services into **HashiCorp Vault** (KV v2 paths + a
least-privilege ACL policy + a Kubernetes auth role). The reusable module is
`terraform/modules/vault-service-onboard`; the golden example lives in
`requests/PE-001-payments-api/`. Standard commands are in the `Makefile` and `README.md` —
prefer those; this section only records the non-obvious Cloud-VM caveats.

### Kind does NOT work in the Cursor Cloud VM — run Vault in Docker instead

`make bootstrap` / `make platform-apply` create a **Kind** cluster, which **fails** in this
VM. The node's `systemd` aborts with `Failed to create /init.scope control group: Structure
needs cleaning` because the VM's namespace-root cgroup is `domain threaded` and the
`memory`/`io`/`hugetlb` controllers cannot be delegated to child cgroups (host-provisioning
limitation; not fixable from inside the VM). This is the documented Cursor Cloud constraint —
full Kubernetes is unsupported here.

The Kind cluster only exists to (a) host Vault and (b) provide a service-account token for
Vault's k8s auth config. Everything the product actually tests talks to Vault over
`http://127.0.0.1:8200`, so run Vault directly in Docker (dev mode) instead:

```bash
docker run -d --name vault-dev --cap-add=IPC_LOCK \
  -e VAULT_DEV_ROOT_TOKEN_ID=root -e VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200 \
  -p 8200:8200 hashicorp/vault
export VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root
vault auth enable -path=kubernetes kubernetes   # what `make platform-apply` would enable
```

Dev mode auto-enables KV v2 at `secret/` and uses root token `root` — matching `.env.example`
and the scripts' defaults.

### Create `.platform-state` so the Make targets work without Kind

The Make targets (`test-local`, `validate`, `validate-change`) `source ./.platform-state`,
which `make bootstrap` normally writes. Under `/bin/sh` (dash), sourcing a **missing**
`.platform-state` is a fatal error that aborts the recipe before it runs anything (you'll see
`make: *** [Makefile:56: test-local] Error 2`). Since we skip `make bootstrap`, create it
manually (it's gitignored):

```bash
printf 'KIND_CLUSTER_NAME=pe-copilot\nVAULT_ADDR=http://127.0.0.1:8200\nVAULT_TOKEN=root\nPF_PID=\nKUBECONFIG_CONTEXT=kind-pe-copilot\n' > .platform-state
```

### Running tests and validation (all pass against Docker Vault)

- `make test-local` — Terratest: applies the module against Vault, asserts policy/role, destroys.
- `make validate REQUEST=PE-001-payments-api` — fmt + validate + plan.
- `make validate-change REQUEST=PE-001-payments-api` — extended: + `terraform test` + Terratest + trivy.
- Module unit tests: `cd terraform/modules/vault-service-onboard && terraform test`.

### Optional linters: keep tflint and conftest UNINSTALLED

`tflint` and `conftest` are optional (README). With the **committed** configs they cannot pass,
and installing them turns `make validate*` red, so leave them out (the scripts then report
`SKIP`, which is the intended PASS state shown in the committed `04-validation/report.md`):

- `tflint`: `requests/PE-001-payments-api/03-terraform/.tflint.hcl` requires a `plugin "vault"`
  with no `source`, and no `terraform-linters/tflint-ruleset-vault` exists to install.
- `conftest`: `policies/conftest/vault.rego` uses legacy Rego v0 syntax and
  `policies/conftest/terraform/vault_module.rego` has no `package` declaration, so modern
  conftest (OPA v1) fails to load them.

`trivy` works and is kept (reports `PASS`).

### Docker in this VM

Docker requires the `fuse-overlayfs` storage driver (kernel rejects `overlay2`:
`failed to mount overlay: invalid argument`) and `iptables-legacy`; these are set up by the
update script's daemon config. There is no systemd, so `dockerd` is started manually (e.g. in a
tmux session: `sudo dockerd`). If `docker` needs sudo, run `sudo chmod 666 /var/run/docker.sock`.
