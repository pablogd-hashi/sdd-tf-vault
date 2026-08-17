# Factory evals

Deterministic scorers. No LLM judge. No API key.

```bash
# In Cursor: "run evals"
task factory:evals
```

| Case | What it scores |
|------|----------------|
| `happy-payments-api` | PE-001 spec R1–R5 mapped into `main.tf` |
| `reject-missing-namespace` | Incomplete ticket fixture must not produce Terraform |
| `no-invented-paths` | PE-1 `secret_paths` exactly `config,db` |
| `least-privilege` | Module policy is read/list under `teams/` only |

Scores emit `factory.eval.pass` / `factory.eval.total` to OTel when the collector is up.
