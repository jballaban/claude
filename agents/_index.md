# Agents

Each agent is a specialist role in the build team. The Orchestrator routes work between them; agents do not contact each other directly.

All agents are installed as a set — the `full-team` bundle. Individual agents can be swapped for custom implementations by replacing the relevant `agent.md`.

---

## Coordination

| Agent | Model | Role |
|-------|-------|------|
| [Orchestrator](orchestrator/agent.md) | claude-opus-4-7 | Product owner's single point of contact. Routes requests, owns GitHub issue state, enforces process. |

## Strategy

| Agent | Model | Role |
|-------|-------|------|
| [Analyst](analyst/agent.md) | claude-opus-4-7 | Owns the business specification. Refines requirements, surfaces edge cases, approves before development begins. |
| [Marketing](marketing/agent.md) | claude-sonnet-4-6 | Go-to-market strategy and positioning. Sets direction for Designer on user-facing features. |

## Technical

| Agent | Model | Role |
|-------|-------|------|
| [Architect](architect/agent.md) | claude-opus-4-7 | Technical design for every feature. Writes the implementation brief into the GitHub Issue. |
| [Developer](developer/agent.md) | claude-sonnet-4-6 | Implements features and fixes test-first against the Architect's spec. |
| [DevOps](devops/agent.md) | claude-sonnet-4-6 | Infrastructure (CDK), deployments, environments, secrets, rollbacks. |

## Design

| Agent | Model | Role |
|-------|-------|------|
| [Designer](designer/agent.md) | claude-sonnet-4-6 | Brand, copy, UX, and asset execution within Marketing's strategic direction. |

## Quality

| Agent | Model | Role |
|-------|-------|------|
| [QA](qa/agent.md) | claude-sonnet-4-6 | Independent acceptance criteria validation. Single-pass gate before Checkpoint 2. |
| [Security](security/agent.md) | claude-opus-4-7 | Code and infrastructure review against OWASP Top 10. Gate before Checkpoint 2. |

## Documentation

| Agent | Model | Role |
|-------|-------|------|
| [Spec Writer](spec-writer/agent.md) | claude-sonnet-4-6 | Maintains spec/ as the living source of truth. Works alongside the Analyst. |

---

## Agent dependencies

`required` agents are part of every workflow. `optional` agents are engaged only for relevant work types:

- **Marketing** — user-facing features and launches; skipped for backend, infra, bug fixes
- **Designer** — user-facing features; skipped when no copy or UX changes are needed

See [bundles/_index.md](../bundles/_index.md) for pre-packaged installation sets.
