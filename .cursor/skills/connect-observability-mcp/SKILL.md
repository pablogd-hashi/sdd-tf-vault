---
name: connect-observability-mcp
description: Install localhost Grafana and Prometheus MCP for the local Cursor IDE agent. Use when the user says connect grafana mcp, enable prometheus mcp, or copy mcp.json.
---

# Connect Observability MCP

Local IDE only. Cloud Agents cannot reach laptop Grafana.

## Steps

1. If `.cursor/mcp.json` does not exist, copy `.cursor/mcp.json.example` to `.cursor/mcp.json`.
2. If it already exists, do **not** overwrite. Tell the user to merge the `grafana` and `prometheus` blocks from the example.
3. Ask them to reload MCP in Cursor.
4. Grafana must be up (`start observability`). Then try `list_dashboards` or PromQL `up{job="vault"}`.
