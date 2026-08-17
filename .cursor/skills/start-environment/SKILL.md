---
name: start-environment
description: Start the software factory environment — Vault in -dev mode and the Kubernetes auth mount. Use when the user says start the environment, bring vault up, start vault, or bootstrap the factory runtime. Does not start Kind.
---

# Start Environment

Start **Vault -dev** (Docker Compose service preferred, host `vault` binary fallback) and apply platform Terraform so the kubernetes auth **mount** exists.

Do **not** create a Kind cluster. Kind is the optional `platform:kind` path only.

## Steps

1. Confirm Docker is running, or that the `vault` binary is on PATH.
2. Run:

```bash
./scripts/factory-environment.sh
```

For Grafana as well, the user should say **start observability** or **run the local demo** instead.

3. Report the Vault URL (default `http://127.0.0.1:8200`, token `root`).
4. If it failed, run `./observability/scripts/status.sh` and show the error.

## Output

Vault reachable; `.platform-state` written; kubernetes auth backend enabled at `auth/kubernetes`.
