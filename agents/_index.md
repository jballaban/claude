# Agents

Each agent is a specialist role in the product team. Skills activate the relevant agents — agents do not contact each other directly.

All agents are installed as a set. Individual agents can be swapped for custom implementations by replacing the relevant `agent.md`.

---

| Agent | Model | Role |
|-------|-------|------|
| [Strategist](strategist/agent.md) | claude-opus-4-7 | Defines business foundation — competitive landscape, target market, monetization model, GTM strategy, and feature principles. Leads `/framework-strategy`. |
| [Analyst](analyst/agent.md) | claude-opus-4-7 | Translates strategy and existing reality into feature specs with acceptance criteria. Leads `/framework-plan` and `/framework-migrate`. |
| [Architect](architect/agent.md) | claude-opus-4-7 | Technical design for every feature. Defines data model, API contracts, and implementation approach. |
| [Marketing](marketing/agent.md) | claude-sonnet-4-6 | Applies GTM strategy to each feature. Defines positioning, onboarding approach, and marketing-critical requirements. |
| [Designer](designer/agent.md) | claude-sonnet-4-6 | Produces wireframes, copy strings, component specs, and Claude Design briefs for every user-facing feature. |
| [Developer](developer/agent.md) | claude-sonnet-4-6 | Implements features test-first against the spec in the GitHub Issue. |
| [QA](qa/agent.md) | claude-sonnet-4-6 | Independent acceptance criteria validation. Single-pass gate before PR is surfaced for review. |
| [Security](security/agent.md) | claude-opus-4-7 | Code and infrastructure review against OWASP Top 10. Gate before PR is surfaced for review. |
| [DevOps](devops/agent.md) | claude-sonnet-4-6 | Infrastructure (CDK), deployments, environments, secrets, rollbacks. |
| [Spec Writer](spec-writer/agent.md) | claude-sonnet-4-6 | Produces and maintains all spec files. Documents sessions, executes writes during migration and planning, and reconciles specs after each merge. |

---

## Agent participation by skill

| Agent | `/framework-migrate` | `/framework-strategy` | `/framework-plan` | `/framework-build` |
|-------|-------------|-------------|---------|----------|
| Strategist | — | ✓ leads | — | — |
| Analyst | ✓ leads | — | ✓ leads | — |
| Architect | ✓ technical | — | ✓ | — |
| Marketing | — | — | ✓ | — |
| Designer | — | — | ✓ | — |
| Developer | — | — | — | ✓ |
| QA | — | — | — | ✓ gate |
| Security | — | — | ✓ review | ✓ gate |
| DevOps | — | — | ✓ review | ✓ |
| Spec Writer | ✓ executes | ✓ | ✓ | ✓ reconcile |
