# From Copilot to Software Factory

*A follow-up to [Spec-Driven Vault Onboarding with Cursor](https://medium.com/@pablogd/spec-driven-vault-onboarding-with-cursor-1eb95cc5aeaf).*

In the previous post I asked a fairly specific question: can the same spec-driven patterns we are using to change software development also be applied to something as process-heavy as Vault onboarding?

The answer I landed on was “yes but” / “yes and”. A ticket becomes a spec, the spec becomes a plan, the plan becomes a thin Terraform wrapper around a reusable module, validation produces a PASS or FAIL that is not an LLM opinion, and a human still merges the PR.

That was the copilot.

Then, as usually happens after a discovery session, someone looks at the whiteboard and asks the next question. Not “can the agent write the Terraform?” — we already proved that. The questions that actually matter in a platform team are more like:

- How do I *operate* this?
- How do I know the factory is healthy, not just that one request looked fine?
- Can it run while my laptop is closed?
- And please, do I really need to memorise a Taskfile to use it?

So I went back to the same repo and tried to turn the copilot into a **software factory**. Same seven phases. Same Vault module. Same rule that agents never invent secret paths. What changed is everything around the workflow: the runtime, the operate layer, the gauges that fire even when the agent is tired, and a way to score yield without asking another model to grade the first one.

The code lives in [`pablogd-hashi/sdd-tf-vault-cursor`](https://github.com/pablogd-hashi/sdd-tf-vault-cursor). If you want to skip the narrative and just run it, there is a five-minute path in [`docs/run-now.md`](https://github.com/pablogd-hashi/sdd-tf-vault-cursor/blob/cursor/software-factory-8d74/docs/run-now.md).

## What I mean by “factory”

A copilot helps you do a job. A factory is a system you can start, score, watch, and stop.

For Vault service onboarding that means four things the original workflow did not have:

1. **A runtime that is not a nested Kubernetes cluster.** Kind was great for proving a pod can log in. It is a terrible substrate for a Cloud Agent VM, and a heavy one for a local demo.
2. **An operate vocabulary in English.** “Start the environment”, “run evals”, “show the dashboard”. Not `task platform:up`.
3. **Gauges that are not prompts.** Cursor Rules are instructions. Hooks are code. If a spec is missing a namespace, the edit is denied. If validation is not PASS, the agent is looped back. If it tries to merge the PR, that is denied too.
4. **Yield you can measure.** Four golden cases, scored by a shell script. No LLM judge. No API key.

If that sounds like I stole the observability story from [Causa](https://medium.com/@pablogd/using-cursor-cloud-agents-for-observability-triage-6ad4ad7b215c) and pointed it at a platform workflow instead of an incident — yes. That was the point.

## The pastry analogy, continued

In the first post I compared Cursor Rules to pastry rules (“never mix dry with wet too early”) and Skills to recipes (“how to make a chocolate cake”).

What a bakery also has, and what the copilot was missing, is the rest of the kitchen:

| Kitchen | Factory |
|---------|---------|
| Oven thermometer | **Hooks** — they fire on file edit, shell, MCP, and stop. They do not care whether you remembered the recipe. |
| Quality check that does not involve tasting | **Evals** — `evals/score.sh` reads checked-in goldens and prints `Yield: 4 passed, 0 failed`. |
| Kitchen display | **Grafana** — Factory Operations and Vault Onboarding, correlated by `ticket_id`. |
| Night shift | **Cloud Agents** — move a Linear ticket to *In Progress Cursor* and a VM runs the autonomous path until a draft PR exists. |

The recipe did not change. The kitchen around it did.

## Runtime: Vault `-dev`, Kind optional

The original demo booted Kind, Helm-installed Vault, then applied platform Terraform that reached into the cluster for a ServiceAccount JWT so Kubernetes auth could be configured for real.

That is still there, behind `task platform:kind`, if you want the pod-login proof. It is no longer the default.

The factory runtime is Vault as a process: Docker Compose service first, `vault server -dev` on the host if Compose is not around. Platform Terraform now only enables the Kubernetes auth *mount*. The JWT / host / CA configuration lives in a separate `terraform/platform-kind` stack, because a Cloud Agent should not have to nest a Kubernetes cluster just to write a Vault policy.

```bash
# In Cursor: “start the environment”
./scripts/factory-environment.sh
```

Vault is at `http://127.0.0.1:8200` with token `root`. The request module still creates the same three things: KV paths under `secret/teams/<team>/<service>/`, a least-privilege ACL policy, and a Kubernetes auth role. You can `vault policy read` them after apply, same as before.

Kind did not become wrong. It became optional. Nested Kubernetes is the wrong substrate for this factory.

## Operate it in English

I like Taskfiles. I do not like demos that start with “first remember these four target names”.

So the factory DX is a small set of Skills that wrap scripts. `go-task` is optional. You can say the same things in Cursor:

| You say | What happens |
|---------|----------------|
| **start the environment** | Vault `-dev` + kubernetes auth mount |
| **start observability** | OTel, Prometheus, Loki, Grafana, Jaeger, Vault |
| **show the dashboard** | Factory Operations + Vault Onboarding URLs |
| **factory status** | Health of Vault and Grafana |
| **run evals** | Deterministic yield on golden tickets |
| **stop the factory** | Tear down compose + host Vault |

Under the hood those skills call `./scripts/factory-environment.sh`, `./evals/score.sh`, `./observability/scripts/up.sh`, and so on. The agent does not have to invent a bootstrap sequence. The operator does not have to become a Taskfile expert.

This is the same idea as the original Skills — `ticket-to-spec`, `plan-to-terraform`, `validate-change` — just pointed at *operating* the factory instead of delivering one request.

## Hooks: the gauges that do not negotiate

Rules tell the agent what “good” looks like. Agents are still language models. On a long autonomous run they will occasionally try to be helpful in the wrong direction: merge the PR because the validation *looked* fine, apply Terraform outside the request directory, write a spec that is missing R3.

Hooks are the part of Cursor I wish I had used earlier. They are small scripts that run on editor events and return `allow` or `deny`. In this repo they live in `.cursor/hooks.json`:

```json
{
  "version": 1,
  "hooks": {
    "afterFileEdit": [
      { "command": ".cursor/hooks/fmt-tf.sh" },
      { "command": ".cursor/hooks/check-spec.sh" }
    ],
    "beforeShellExecution": [
      { "command": ".cursor/hooks/deny-dangerous.sh" }
    ],
    "beforeMCPExecution": [
      { "command": ".cursor/hooks/deny-mcp-merge.sh" }
    ],
    "stop": [
      { "command": ".cursor/hooks/stop-validate.sh", "loop_limit": 3 }
    ]
  }
}
```

What they actually do:

- **`fmt-tf.sh`** — `terraform fmt` any `.tf` file the agent just edited. Always allow. Quiet hygiene.
- **`check-spec.sh`** — if the file is a `01-spec/spec.md` and R1–R5 or `ticket_provider` are missing, **deny the edit**. Incomplete tickets do not become specs.
- **`deny-dangerous.sh`** — no `gh pr merge`, no `git push` to `main`, and `terraform apply` only under `requests/<id>/03-terraform` or `terraform/platform`.
- **`deny-mcp-merge.sh`** — same merge ban on the GitHub MCP tool. Humans merge after reading `reviewer.md` and `bugbot.md`.
- **`stop-validate.sh`** — if an autonomous request has Terraform but `04-validation/report.md` is not PASS, send the agent back. Loop limit 3.

Every deny also emits an OTLP metric (`factory.hook.deny`) when the collector is up. The factory is not only preventing the bad action. It is counting it.

This is the difference I keep coming back to with customers. A Rule is a policy you hope the model will follow. A Hook is a control that still works when it does not.

## Evals: yield without an LLM judge

I do not want to score a software factory by asking another model “did this look right?”. That is how you get a dashboard full of vibes.

`evals/score.sh` reads artifacts that are already in git and checks four things:

| Case | What it scores |
|------|----------------|
| `happy-payments-api` | PE-001 spec fields R1–R5 mapped *verbatim* into `main.tf` |
| `reject-missing-namespace` | An incomplete ticket fixture must not produce Terraform |
| `no-invented-paths` | `secret_paths` is exactly `config,db` — no extras the agent thought would be useful |
| `least-privilege` | Module policy is read/list under `teams/` only. No create, no delete. |

```bash
# In Cursor: “run evals”
./evals/score.sh
# Yield: 4 passed, 0 failed, 4 total
```

No `CURSOR_API_KEY`. No judge prompt. If someone later changes the module to grant `create` on the whole KV mount, yield drops. That is the whole point.

When observability is up, the same script emits `factory.eval.pass` / `factory.eval.total`. Grafana then has a yield panel that is not a screenshot of a chat.

## The operate layer: one Grafana, two dashboards

Autonomous delivery already produced artifacts and a PR. Operators still had no live view of factory yield, cycle time, or Vault after onboard.

I already had a local OTel / Grafana / Prometheus stack in [Causa](https://medium.com/@pablogd/using-cursor-cloud-agents-for-observability-triage-6ad4ad7b215c). This repo needed the same shape, pointed at the factory and at Vault, in one Grafana.

`observability/` is Docker Compose. No Kubernetes. Collector, Prometheus, Loki, Jaeger, Grafana, and Vault `-dev`. Two dashboards, correlated by `ticket_id` / `trace_id`:

- **Factory Operations** — runs, validation PASS ratio, hook denies, eval yield, phase duration by ticket, factory logs.
- **Vault Onboarding** — Vault up, HTTP request rate, apply events by ticket and service, secret paths scaffolded, mixed Vault / factory logs.

Hooks, `validate-change.sh`, and request apply speak OTLP HTTP via `scripts/factory-otel.sh`. Prometheus scrapes Vault’s `/v1/sys/metrics?format=prometheus`. Grafana MCP (`mcp-grafana --disable-write`) and Prometheus MCP point at localhost, so the *local* agent can answer “what is factory yield?” with PromQL instead of guessing.

```bash
# In Cursor: “start observability” then “show the dashboard”
./observability/scripts/up.sh
# Grafana: http://127.0.0.1:3000  (admin / admin)
```

Two honest limits, because they matter in a customer conversation:

1. **Cloud Agents cannot see laptop Grafana.** The Linear webhook path delivers a draft PR. It does not fill these dashboards unless you expose a public OTLP endpoint, which is out of scope for v1.
2. **Compose is the demo console, not production observability.** Same disclaimer as last time: this is a Kind-less laptop factory, not a reason to retire your SRE team.

<!-- Screenshot: Grafana Factory Operations — yield, hook denies, validation PASS ratio -->

<!-- Screenshot: Grafana Vault Onboarding — Vault up, apply events by ticket_id -->

## Three ways to run it

This is the part I wish I had put at the top of the first post. There are now three demos, on purpose.

### A — five minutes, no Docker required

Start Vault `-dev`, score the goldens, validate PE-001 against live Vault, apply, then `vault policy read`. Kind is not involved. go-task is not involved.

```bash
./scripts/factory-environment.sh
./evals/score.sh
./scripts/validate-change.sh PE-001-payments-api
terraform -chdir=requests/PE-001-payments-api/03-terraform apply -auto-approve
vault policy read payments-payments-api
```

**Pass:** evals 4/4, validate-change PASS, policy shows `teams/payments/payments-api`.

### B — Grafana (Docker)

`start observability`, then `show the dashboard`. Query Grafana MCP or Prometheus MCP. This is the local-agent operate demo.

### C — async Cloud Agent (no Grafana)

Create a Linear issue with service, team, namespace, service account, and secret paths. Move it to **In Progress Cursor**. Watch [cursor.com/agents](https://cursor.com/agents). The Cloud Agent follows `AGENTS.md`: `create-spec` → `implement-change` → `validate-change` until PASS → readonly reviewer → Bugbot → draft PR. It does not merge. A human still does.

The autonomous path was already in the repo (ADR-001). What the factory adds is the wiring: an agent-readable `AGENTS.md`, a ticket status that starts a Cloud Agent, and hooks that keep that unattended loop from skipping validation or merging.

## What did *not* change

This is still specification-driven Vault onboarding. I did not replace the seven phases with a mega-prompt.

```
requests/PE-123/
├── 01-spec/          what was requested
├── 02-plan/          how it will be implemented
├── 03-terraform/     the thin module wrapper
├── 04-validation/    PASS / FAIL evidence
├── 05-review/        reviewer + Bugbot
├── 06-pr/            delivery metadata
└── 07-ticket-update/ traceability back to Linear / Jira
```

Manual path still stops for approval after each phase. Autonomous path still auto-continues through implement and validate, still writes the same artifacts, still requires a human to merge.

The Vault module still copies spec fields verbatim. The agent still must not invent `secret_paths`. Conftest, Terratest, `terraform test`, tflint, trivy — still there in `validate-change`.

The factory is an operate layer on top of a workflow I still trust. That was the design constraint. If you skip it, you get a chatbot that talks to Vault. I have seen that whiteboard. It does not end well.

## So, did it work?

Did I turn a two-week onboarding process into a factory you can start in five minutes? Locally, yes. That is still not the point.

I still own every persona. The Linear ticket is still mine. Vault `-dev` with token `root` is not your production cluster. Cloud Agents filling a laptop Grafana is a demo limitation I am not going to hand-wave away.

What I wanted to prove this time is narrower, and I think more useful:

A spec-driven copilot becomes a factory when you can **start it, score it, watch it, and stop it** — and when the controls that keep it honest are scripts, not vibes.

Skills are still the recipes. Rules are still the pastry laws. Hooks, evals, and a Grafana that scrapes both the factory and Vault are what let you treat the whole thing as a system instead of a chat you got lucky with.

If you want to try it, the fastest path is [`docs/run-now.md`](https://github.com/pablogd-hashi/sdd-tf-vault-cursor/blob/cursor/software-factory-8d74/docs/run-now.md) on the `cursor/software-factory-8d74` branch. Break it. Replace Vault with something else. Keep the gauges.

*Previously: [Spec-Driven Vault Onboarding with Cursor](https://medium.com/@pablogd/spec-driven-vault-onboarding-with-cursor-1eb95cc5aeaf). Related: [Using Cursor Cloud Agents for Observability Triage](https://medium.com/@pablogd/using-cursor-cloud-agents-for-observability-triage-6ad4ad7b215c).*
