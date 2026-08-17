# From Copilot to Software Factory

As I mentioned in the [previous post](https://medium.com/@pablogd/spec-driven-vault-onboarding-with-cursor-1eb95cc5aeaf), I spent some time trying to take the usual Vault onboarding process ( ticket, spec, Terraform, review, PR) and run it with Cursor the same way we now run spec-driven software work.

The short version, if you skipped that one: a Linear or Jira ticket comes in, a skill turns it into a spec, another one into a plan, then a thin Terraform wrapper around a module that creates the policy, the Kubernetes auth role and the KV paths. Validation is a real `terraform plan` / `terraform test`, not an agent telling you “looks good”. A human still merges.

It worked. Kind cluster on my laptop, I was every persona, I approved my own spec. I even said, please don’t use that blog to tell your security team they are no longer needed :)

Anyway. I published it and then did what I always do after a discovery session: I looked at the whiteboard again.

Because once you map the process, the next question is almost never “can the agent write the Terraform?”. It’s more like: ok, but how do I actually run this? Do I need to remember four `task` targets? Do I really need a full Kind cluster just to create a secret path? And if I leave it running, how do I know it didn’t just skip validation and open a PR anyway?

So I went back to the same repo and tried to turn that copilot into a software factory. Same seven phases, same Vault module, same “don’t invent secret paths” rule. What I added is everything around it.

The repo is still [here](https://github.com/pablogd-hashi/sdd-tf-vault-cursor) if you want to skip ahead and break things. There’s a five-minute path in `docs/run-now.md`.

## Why a factory?

I keep using that word, so let me be concrete.

The first version was a copilot: you sit in Cursor, you invoke `ticket-to-spec`, you approve, you invoke the next skill, and so on. That’s useful, and it’s still there ( the manual path didn’t go anywhere).

A factory, at least in this experiment, is the same workflow plus: I can start it without Kind, I can tell Cursor “start the environment” instead of memorising a Taskfile, I can score whether the goldens still pass without asking another LLM, I can open Grafana and see yield / hook denies / whether Vault is up, and I can move a Linear ticket to In Progress Cursor and let a Cloud Agent run the autonomous path until there’s a draft PR.

If that last part sounds familiar, it’s because I already did something similar in [Causa](https://medium.com/@pablogd/using-cursor-cloud-agents-for-observability-triage-6ad4ad7b215c) for observability triage. This time I pointed that idea at onboarding instead of an incident.

## Kind was getting in the way

I like Kind. For the first post it made sense: prove that a pod can actually log in to Vault with its Kubernetes identity.

For a factory, and especially for a Cloud Agent running in a VM, spinning a Kubernetes cluster just to write a Vault policy is… a lot. Nested Kubernetes is not a great substrate for this.

So the default runtime is now Vault in `-dev` mode. Docker Compose if you have Docker, otherwise the `vault` binary on the host. Platform Terraform only enables the Kubernetes auth mount. The JWT / host / CA bit moved to `terraform/platform-kind`, and you only run that if you still want the pod-login proof.

In Cursor you can just say:

> start the environment

which runs `./scripts/factory-environment.sh`. Vault is at `http://127.0.0.1:8200`, token `root`. After you apply a request you can still do the same check as last time:

```
vault policy read payments-payments-api
vault kv get secret/teams/payments/payments-api/config
```

Kind is still there, behind `task platform:kind`. It’s optional now, which is the whole point.

## Skills, again ( and this time you can talk to them)

I already used the pastry analogy last time, so I won’t repeat the whole thing. Skills = the recipe, Rules = the bits you never skip, no matter the flavour.

What I was missing is that operating the factory was still a bunch of Taskfile names I had to remember during a demo. I like Taskfiles. I don’t like starting a walkthrough with “ok first you run `task platform:up`, wait, unless you wanted Grafana, then it’s a different target”.

So I added a few skills that are just English:

- start the environment
- start observability
- show the dashboard
- factory status
- run evals
- stop the factory

They call scripts. `go-task` is optional. Same idea as `ticket-to-spec` / `plan-to-terraform`, just pointed at running the thing rather than delivering one request.

## Hooks

This is the part I wish I had used in the first version.

Rules are great, but they are still instructions. Agents are still language models. On a long autonomous run they will occasionally try to be helpful in the wrong way: merge the PR because validation *looked* fine, `terraform apply` in the wrong directory, write a spec that’s missing the namespace.

Hooks are small scripts that Cursor runs on file edit, before a shell command, before MCP, and when the agent wants to stop. They return allow or deny. Not a suggestion. Deny.

The ones in this repo look like this:

```
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

`fmt-tf.sh` just runs `terraform fmt` on whatever `.tf` the agent touched. `check-spec.sh` denies the edit if `spec.md` is missing R1–R5 or the ticket provider. `deny-dangerous.sh` blocks `gh pr merge`, push to main, and `terraform apply` outside `requests/<id>/03-terraform` or `terraform/platform`. Same merge ban on the GitHub MCP tool. And `stop-validate.sh` is the important one for the autonomous path: if there’s Terraform but `04-validation/report.md` is not PASS, send the agent back. Loop limit 3.

I don’t want an agent telling me the implementation looks correct. That was true for validation in the first post, and it’s the same reason hooks exist here. A rule is something you hope it follows. A hook still works when it doesn’t.

When the collector is up, denies also go out as an OTLP metric, so you can actually see them in Grafana instead of finding out later that it tried to merge.

## Evals

Same energy as validation. I don’t want to score this by asking another model “did it look right?”.

There’s a script, `evals/score.sh`. No API key. It reads artifacts that are already in git:

- happy path: PE-001 spec fields actually landed in `main.tf` ( service, team, namespace, SA, `config` + `db`)
- incomplete ticket: missing namespace must not produce Terraform
- no invented paths: `secret_paths` is exactly what the spec said, not what the agent thought would be useful
- least privilege: the module policy is read/list under `teams/` only. No create, no delete.

You say **run evals** in Cursor, or just run the script:

```
./evals/score.sh
# Yield: 4 passed, 0 failed, 4 total
```

If someone later “improves” the module and grants `create` on the whole mount, yield drops. That’s the idea.

## Dashboards

This is where Causa comes back.

In that post I already had a local stack: OTel, Prometheus, Loki, Grafana, Jaeger. I didn’t want to invent a new console for this repo, so I took the same shape and pointed it at the factory and at Vault.

`observability/` is Docker Compose. No Kubernetes. Two dashboards in one Grafana:

- Factory Operations: runs, validation PASS ratio, hook denies, eval yield, duration by ticket
- Vault Onboarding: is Vault up, HTTP rate, apply events by ticket / service, secret paths created

Say **start observability**, then **show the dashboard**. Grafana is `http://127.0.0.1:3000` ( admin/admin). Prometheus scrapes Vault’s `/v1/sys/metrics?format=prometheus`. There’s also Grafana MCP ( read-only) and Prometheus MCP on localhost, so the local agent can answer “what’s factory yield?” with PromQL instead of guessing.

Two caveats, because they always come up:

Cloud Agents cannot see Grafana on your laptop. The Linear webhook path will open a draft PR. It will not fill these dashboards unless you expose a public OTLP endpoint, which I didn’t do for this version.

And this is still a demo console. Same as last time with Kind: don’t take a screenshot of localhost:3000 to your SRE team as the new production observability platform.

## Let’s actually run it

Three ways, on purpose.

**A. Five minutes, no Docker.** Start Vault, score the goldens, validate PE-001, apply, read the policy. No Kind, no go-task.

```
./scripts/factory-environment.sh
./evals/score.sh
./scripts/validate-change.sh PE-001-payments-api
terraform -chdir=requests/PE-001-payments-api/03-terraform apply -auto-approve
vault policy read payments-payments-api
```

Pass looks like: evals 4/4, validate-change PASS, policy contains `teams/payments/payments-api`.

**B. Grafana.** Docker required. `start observability`, then `show the dashboard`. This is the local operate demo.

**C. Cloud Agent.** Create a Linear issue with service, team, namespace, SA and secret paths. Move it to **In Progress Cursor**. Watch [cursor.com/agents](https://cursor.com/agents). It follows `AGENTS.md`: create-spec → implement-change → validate-change until PASS → reviewer → Bugbot → draft PR. It does not merge. You still do.

The autonomous path was already in the repo from last time. What I added is the wiring: `AGENTS.md`, a ticket status that actually starts a Cloud Agent, and the hooks so that unattended loop can’t skip validation or merge on its own.

And just to be clear, I didn’t throw away the seven phases. You still get:

```
requests/PE-123/
├── 01-spec/
├── 02-plan/
├── 03-terraform/
├── 04-validation/
├── 05-review/
├── 06-pr/
└── 07-ticket-update/
```

Manual path still stops for approval. Autonomous path still writes the same artifacts. The module still copies spec fields as they are. Asking an agent to just “onboard this application to Vault” and hoping for the best is still never a good recipe.

## So, did it work?

Did I turn a two-week onboarding process into a factory you start in five minutes? Well, technically yes, but that’s not really the point of this exercise right?.

I still control every persona, the Linear ticket is mine, Vault `-dev` with token `root` is not production, and Cloud Agents filling a laptop Grafana is a limitation I’m not going to pretend isn’t there.

My goal this time was simpler than “replace the platform team”. I wanted to see whether the copilot from the first post could become something you start, score, watch and stop, with controls that are scripts rather than hoping the model behaves.

I think the answer is the same as last time: yes but, or yes and. Skills are still the recipe, rules are still the pastry laws. Hooks, evals and a Grafana that scrapes both the factory and Vault are what make it feel like a system instead of a chat that got lucky.

The repo is open source if you want to try it, break it, replace Vault with something else. Fastest path is `docs/run-now.md` on the `cursor/software-factory-8d74` branch.
