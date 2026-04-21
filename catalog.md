# Marketplace Catalog

A marketplace of agents and skills for building software products with Claude Code.

**Skills** are Claude Code's native plugin mechanism — slash commands the product owner invokes. **Agents** are the context those skills depend on — role definitions loaded so Claude knows how to behave when a skill invokes a role. Both are installed together as a single plugin.

---

## Installation

### Prerequisites

- Claude Code CLI installed
- `GITHUB_TOKEN` in your environment (for GitHub MCP access)

### Install

```
/plugin install claude-framework@claude-plugins-official
```

Installs all 10 agents and all skills into your project in one step.

### After installation

Fill in the project context files created in `spec/context/`:

| File | What to fill in |
|------|----------------|
| `spec/context/product.md` | What the product is, who it's for, what problem it solves |
| `spec/context/tech-stack.md` | Additional dependencies and stack overrides |
| `spec/context/architecture.md` | How the major pieces connect |
| `spec/context/design-system.md` | Brand guidelines, tone, colours, typography |
| `spec/context/environments.md` | URLs, AWS account IDs, CI/CD setup |
| `spec/context/conventions.md` | Project-specific patterns and stack overrides |
| `spec/current/overview.md` | What is live in production right now |
| `spec/next/overview.md` | What the next major release will contain |

### Verify

```
/pending
```

If `/pending` responds, both layers are working — the skill is installed and the agent context is loaded.

### Update

```
/plugin update claude-framework
```

`spec/` is never overwritten. All project-specific work is preserved.

---

## How it works

```
Skills               ← what you invoke
  /pending  ──►  Orchestrator
                     └── Analyst, Architect, Developer, ...

Agents               ← context skills depend on
  10 specialist roles, loaded automatically by the plugin
```

Skills are entry points. Agents are the roles they invoke. The plugin installs both.

---

## Skills

| Skill | Trigger | Agents used | Description |
|-------|---------|-------------|-------------|
| [pending](skills/pending/SKILL.md) | `/pending` | Orchestrator | Surface all items waiting for product owner input — checkpoint approvals, Analyst questions, Architect escalations. |

→ [Browse all skills](skills/_index.md)

---

## Agents

| Agent | Model | Category | Description |
|-------|-------|----------|-------------|
| [Orchestrator](agents/orchestrator/agent.md) | Opus 4.7 | Coordination | Product owner's entry point. Routes requests, owns GitHub, enforces process. |
| [Analyst](agents/analyst/agent.md) | Opus 4.7 | Strategy | Owns the business spec. Nothing gets built without an approved spec. |
| [Architect](agents/architect/agent.md) | Opus 4.7 | Technical | Designs technical approach. Writes the implementation brief before development begins. |
| [Developer](agents/developer/agent.md) | Sonnet 4.6 | Implementation | Implements features and fixes test-first against the Architect's spec. |
| [Designer](agents/designer/agent.md) | Sonnet 4.6 | Design | Brand, copy, UX, and asset execution within Marketing's strategic direction. |
| [Marketing](agents/marketing/agent.md) | Sonnet 4.6 | Strategy | Go-to-market strategy and positioning. Sets direction for user-facing features. |
| [QA](agents/qa/agent.md) | Sonnet 4.6 | Quality | Independent acceptance criteria validation. Single-pass gate before Checkpoint 2. |
| [DevOps](agents/devops/agent.md) | Sonnet 4.6 | Infrastructure | CDK infrastructure, deployments, environments, secrets, rollbacks. |
| [Security](agents/security/agent.md) | Opus 4.7 | Quality | Code and infrastructure review against OWASP Top 10. Gate before Checkpoint 2. |
| [Spec Writer](agents/spec-writer/agent.md) | Sonnet 4.6 | Documentation | Maintains spec/ as the living source of truth across all branches. |

→ [Browse all agents](agents/_index.md)

---

## Framework

Non-negotiable process and engineering standards included with the plugin.

| File | Description |
|------|-------------|
| [process.md](framework/process.md) | Workflow patterns, human checkpoints, feedback loops, GitHub issue lifecycle |
| [quality-gates.md](framework/quality-gates.md) | 4 gates that must pass before deployment |
| [architecture-standards.md](framework/architecture-standards.md) | Universal engineering principles all agents follow |

---

## Defaults

Opinionated team-wide technology choices. Override per-project in `spec/context/conventions.md`.

| File | Description |
|------|-------------|
| [stack.md](defaults/stack.md) | AWS serverless, TypeScript, Next.js, Cognito, Stripe, PostHog, Sentry, and more |
| [patterns.md](defaults/patterns.md) | Authoritative reference links and team-specific decisions |
