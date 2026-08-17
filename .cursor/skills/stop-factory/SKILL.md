---
name: stop-factory
description: Stop observability compose and host Vault -dev. Use when the user says stop observability, tear down, stop grafana, or stop the factory. Does not delete a Kind cluster unless the user explicitly asks.
---

# Stop Factory

Tear down the local factory runtime.

## Steps

1. Run:

```bash
./observability/scripts/down.sh || true
./platform/scripts/vault-dev-stop.sh || true
# or: task factory:stop
```

2. Confirm Grafana (`:3000`) and Vault (`:8200`) are no longer reachable, or report leftover processes.
3. Do **not** run Kind teardown unless the user explicitly asks to destroy the Kind cluster (`task platform:teardown-kind`).
