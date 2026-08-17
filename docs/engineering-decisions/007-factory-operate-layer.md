# ADR-007: Factory operate layer (OTel + Grafana)

| Status | Accepted |
|--------|----------|
| Date | 2026-08-17 |
| Branch | `cursor/software-factory-8d74` |

## Context

Autonomous delivery produces artifacts and a PR, but operators had no live view of factory yield, cycle time, or Vault after onboard. Causa already proved a local OTel/Grafana stack with Grafana MCP. This repository needed the same **operate** layer pointed at the factory and at Vault, in one Grafana.

## Decision

1. Ship `observability/` Docker Compose: OTel Collector, Prometheus, Loki, Jaeger, Grafana, and Vault `-dev`.
2. Two dashboards in one Grafana: **Factory Operations** and **Vault Onboarding**, correlated by `ticket_id` / `trace_id`.
3. Instrument hooks, `validate-change.sh`, and request apply via OTLP HTTP (`scripts/factory-otel.sh`).
4. Scrape Vault `/v1/sys/metrics?format=prometheus`.
5. Local agent runtime for the observability demo (`mcp-grafana --disable-write` + Prometheus MCP on localhost).
6. Linear webhook → Cloud Agent remains the unattended path and **does not** write to laptop Grafana.

## Rationale

- Compose is not Kubernetes. Vault stays a process, not a Helm chart on Kind.
- Grafana MCP + Prometheus MCP match the Causa local-runtime pattern.
- Skills wrap Taskfile so operators never memorize `task` names.

## Consequences

- Docker is required for the operate demo.
- Cloud Agent webhook demos will not populate these dashboards without a public OTLP endpoint (out of scope).
- Kind remains optional for pod-login proof only.

## Alternatives considered

1. **Kind as the factory runtime** — rejected; nested Kubernetes is the wrong substrate for Cloud Agents and for a local Grafana demo.
2. **Grafana Cloud / public OTLP** — rejected for v1; local compose matches Causa's demo story.
3. **Streamlit console** — rejected; Grafana is the console.
4. **SDK as ticket intake** — rejected; the Cursor webhook on Linear `In Progress Cursor` already starts Cloud Agents.
