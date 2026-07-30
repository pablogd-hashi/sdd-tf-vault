# Diagrams

All documentation diagrams are authored in FigJam and exported to `docs/diagrams/` as SVG so they render inline on GitHub and in the docs.

**Source board:** [Platform Engineering Copilot — Documentation Diagrams](https://www.figma.com/board/1RbIQpZgVRQr2TzsKe2SiZ)

| Diagram | File | Used in |
|---------|------|---------|
| Seven-phase SDD workflow | [`diagrams/01-workflow-phases.svg`](diagrams/01-workflow-phases.svg) | [README](../README.md), [demo-walkthrough.md](demo-walkthrough.md) |
| System overview | [`diagrams/02-system-overview.svg`](diagrams/02-system-overview.svg) | [architecture.md](architecture.md) |
| Two delivery paths (manual vs autonomous) | [`diagrams/03-two-delivery-paths.svg`](diagrams/03-two-delivery-paths.svg) | [architecture.md](architecture.md) |
| End-to-end flow (sequence) | [`diagrams/04-end-to-end-flow.svg`](diagrams/04-end-to-end-flow.svg) | [architecture.md](architecture.md) |
| Infrastructure layers | [`diagrams/05-infrastructure-layers.svg`](diagrams/05-infrastructure-layers.svg) | [architecture.md](architecture.md), [setup.md](setup.md) |
| Autonomous validation loop | [`diagrams/06-autonomous-validation-loop.svg`](diagrams/06-autonomous-validation-loop.svg) | [autonomous-delivery.md](autonomous-delivery.md) |

## Updating a diagram

1. Open the [source board](https://www.figma.com/board/1RbIQpZgVRQr2TzsKe2SiZ) in FigJam and edit the diagram.
2. Export the frame as SVG and overwrite the matching file in `docs/diagrams/`.
3. Keep the file name stable so the doc references continue to resolve.
