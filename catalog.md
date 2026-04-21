# Marketplace Catalog

A marketplace of agents and skills for building software products with Claude Code.

**Skills** are Claude Code's native plugin mechanism — slash commands the founder invokes. **Agents** are the specialist roles those skills activate. Both are installed together as a single plugin.

---

## Installation

### Prerequisites

- Claude Code CLI installed
- `GITHUB_TOKEN` in your environment (for GitHub MCP access)

### Install

```
/plugin install claude-framework@claude-plugins-official
```

Installs all 10 agents and all 3 skills into your project in one step.

### After installation

Fill in the project context files in `spec/context/`:

| File | What to fill in |
|------|----------------|
| `spec/context/tech-stack.md` | Additional dependencies and stack overrides |
| `spec/context/architecture.md` | How the major pieces connect (fill in after `/plan`) |
| `spec/context/design-system.md` | Brand guidelines, colours, typography |
| `spec/context/environments.md` | URLs, AWS account IDs, CI/CD setup |
| `spec/context/conventions.md` | Project-specific patterns and stack overrides |

### Verify

```
/strategy
```

If `/strategy` starts a conversation, the skill is installed and the Strategist agent is loaded.

### Update

```
/plugin update claude-framework
```

`strategy/` and `spec/` are never overwritten. All project work is preserved.

---

## How it works

```
/strategy  →  Strategist + Spec Writer
               └── strategy/ (vision, market, monetization, gtm, principles)
                        ↓
/plan      →  Analyst + Architect + Marketing + Designer + Spec Writer
               └── spec/features/{feature}/ × N
               └── spec/roadmap.md (dependency graph)
                        ↓
/build     →  Developer + QA + Security + DevOps + Spec Writer
               └── PRs on feature/{name} branches
               └── Founder merges → /build advances the graph
```

---

## Skills

| Skill | Trigger | Phase | Description |
|-------|---------|-------|-------------|
| [strategy](skills/strategy/SKILL.md) | `/strategy` | 1 | Define the strategic foundation — competitive landscape, target market, monetization, GTM, principles. |
| [plan](skills/plan/SKILL.md) | `/plan` | 2 | Plan features from approved strategy. Complete specs with business, technical, design, launch, security, and infrastructure context. |
| [build](skills/build/SKILL.md) | `/build` | 3 | Build the dependency graph frontier. Opens issues, implements in parallel, surfaces PRs for founder review. Re-run to advance. |

→ [Browse all skills](skills/_index.md)

---

## Agents

| Agent | Model | Phase | Description |
|-------|-------|-------|-------------|
| [Strategist](agents/strategist/agent.md) | Opus 4.7 | Strategy | Competitive research, business model, monetization, GTM strategy. Leads `/strategy` sessions. |
| [Analyst](agents/analyst/agent.md) | Opus 4.7 | Planning | Leads Planning sessions. Translates strategy into feature specs with acceptance criteria. |
| [Architect](agents/architect/agent.md) | Opus 4.7 | Planning | Technical design — data model, API contracts, implementation approach. |
| [Marketing](agents/marketing/agent.md) | Sonnet 4.6 | Planning | Feature positioning, onboarding approach, marketing-critical requirements. |
| [Designer](agents/designer/agent.md) | Sonnet 4.6 | Planning | Wireframes, copy strings, component specs, Claude Design asset briefs. |
| [Developer](agents/developer/agent.md) | Sonnet 4.6 | Development | Implements features test-first against the spec. |
| [QA](agents/qa/agent.md) | Sonnet 4.6 | Development | Independent acceptance criteria validation. Gate before PR review. |
| [Security](agents/security/agent.md) | Opus 4.7 | Planning + Development | Security requirements in Planning; code and infrastructure review in Development. |
| [DevOps](agents/devops/agent.md) | Sonnet 4.6 | Planning + Development | Infrastructure requirements in Planning; CDK, deployments, environments in Development. |
| [Spec Writer](agents/spec-writer/agent.md) | Sonnet 4.6 | All phases | Documents strategy sessions, produces all spec files, reconciles specs after merge. |

→ [Browse all agents](agents/_index.md)

---

## Framework

Non-negotiable process and engineering standards included with the plugin.

| File | Description |
|------|-------------|
| [process.md](framework/process.md) | Three-phase workflow — strategy, planning, development — with gates, feedback loops, and branch model |
| [quality-gates.md](framework/quality-gates.md) | Gates that must pass before a PR is surfaced for founder review |
| [architecture-standards.md](framework/architecture-standards.md) | Universal engineering principles all agents follow |

---

## Defaults

Opinionated team-wide technology choices. Override per-project in `spec/context/conventions.md`.

| File | Description |
|------|-------------|
| [stack.md](defaults/stack.md) | AWS serverless, TypeScript, Next.js, Cognito, Stripe, PostHog, Sentry, and more |
| [patterns.md](defaults/patterns.md) | Authoritative reference links and team-specific decisions |
