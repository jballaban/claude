# Claude Framework

A marketplace of agents and skills for building software products with Claude Code. Install it into any project and you have a full product team — Strategist, Analyst, Architect, Developer, Designer, QA, DevOps, Security, and more — orchestrated through three workflow skills.

---

## Install

**Prerequisites:** Claude Code CLI, a GitHub token in `GITHUB_TOKEN`

Add this repo as a marketplace, then install:

```
/plugin marketplace add jballaban/claude
/plugin install claude-framework
```

That's it. The plugin installs all 10 agents and all skills in one step.

**After installing**, fill in the generated context files:

| File | What to fill in |
|------|----------------|
| `spec/context/product.md` | What the product is, who it's for, what problem it solves |
| `spec/context/tech-stack.md` | Dependencies and services additive to or overriding the team defaults |
| `spec/context/architecture.md` | How the major pieces connect |
| `spec/context/design-system.md` | Brand guidelines, tone, colours, typography, asset locations |
| `spec/context/environments.md` | URLs, AWS account IDs, and one-time CI/CD setup steps |
| `spec/context/conventions.md` | Project-specific patterns and stack overrides with reasons |

Verify the install worked:

```
/strategy
```

---

## How it works

You describe what you want. The agents handle the rest. There are three phases:

### Phase 1 — Strategy `/strategy`

The Strategist leads a structured conversation. You end up with five documents: product vision, market positioning, monetization model, go-to-market approach, and feature prioritization principles. The Spec Writer keeps the record.

### Phase 2 — Planning `/plan`

The Analyst leads the full team through feature specs. Each feature gets a business spec (acceptance criteria, success metrics), a technical spec (architecture, data model, API contracts), a design spec (wireframes, copy), a launch spec (marketing positioning, onboarding), and security and infrastructure specs. You approve the spec before development starts.

### Phase 3 — Development `/build`

The Developer implements the dependency graph frontier — features whose dependencies are already built. GitHub issues are opened with full context, branches are created, tests are written first, PRs are raised. QA validates acceptance criteria. Security reviews the code. PRs surface to you for merge.

Re-run `/build` after merging to advance to the next set of features.

### Existing repos `/migrate`

Run once to onboard an existing codebase. The team reconstructs strategy from the code and your conversation, maps existing functionality to shallow specs, and marks everything currently in `main` as built. Then run `/plan` and `/build` as normal.

---

## Agents

| Agent | Model | Phase | Role |
|-------|-------|-------|------|
| Strategist | Opus | Strategy | Business foundation — vision, market, monetization, GTM |
| Analyst | Opus | Planning | Feature specification — nothing ships without an analyst-approved spec |
| Spec Writer | Sonnet | All | Written spec outputs and accuracy across all phases |
| Architect | Opus | Planning + Dev | Technical approach, data models, API contracts |
| Developer | Sonnet | Development | Test-first implementation against technical engagement specs |
| Designer | Sonnet | Planning + Dev | Wireframes, copy strings, component specs |
| Marketing | Sonnet | Planning + Dev | Positioning, onboarding, marketing-critical requirements |
| QA | Sonnet | Development | Independent validation against acceptance criteria |
| DevOps | Sonnet | Development | Infrastructure (CDK/TypeScript), deployments, releases |
| Security | Opus | Development | Independent security review — OWASP Top 10 baseline |

---

## Framework

Three non-negotiable files apply to all projects:

- **[framework/process.md](framework/process.md)** — the three-phase workflow, human checkpoints, and feedback loops
- **[framework/quality-gates.md](framework/quality-gates.md)** — four mandatory gates before a PR surfaces to you
- **[framework/architecture-standards.md](framework/architecture-standards.md)** — universal engineering principles (code-first, simple over complex, minimal dependencies, latest stable, automated deployments, security baseline)

---

## Defaults

The team has opinionated technology defaults. Projects inherit these and override where needed.

- **[defaults/stack.md](defaults/stack.md)** — AWS serverless (Lambda/Fargate/CDK), TypeScript strict, Next.js App Router, Expo, Aurora Serverless v2, Cognito, Stripe, GitHub Actions
- **[defaults/patterns.md](defaults/patterns.md)** — Authoritative references and team decisions

---

## Contributing

When you learn something working in a project — a better process step, a missing quality gate, a wrong default — improve it here.

**New agent:** create `agents/{name}/agent.md` + `manifest.json`, add to `.claude-plugin/plugin.json`.

**New skill:** create `skills/{name}/SKILL.md` + `manifest.json`, add to `.claude-plugin/plugin.json`. Declare agent dependencies in `manifest.json`.

See [agents/_index.md](agents/_index.md) and [skills/_index.md](skills/_index.md) to browse what exists.
