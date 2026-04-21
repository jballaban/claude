# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## What this repository is

This is a **marketplace of agents and skills** for building software products with Claude Code. It is not a product itself.

**Skills** are Claude Code's native plugin mechanism — slash commands installed into `.claude/skills/`. **Agents** are the context those skills depend on — role definitions loaded into CLAUDE.md so Claude knows how to behave when a skill invokes a role.

The install script handles both layers. Run it once in a new project and you have a working team.

---

## How the two layers work

```
Skills (.claude/skills/)          — the plugin layer
  └── /pending                    — invokes the Orchestrator agent
        └── depends on →

Agent context (.claude/framework/agents.md)  — the context layer
  └── Orchestrator, Analyst, Architect, Developer, ...
```

Skills are Claude Code plugins: user-invocable slash commands. They invoke agents by role. For that to work, the agent definitions must be present in context — loaded via CLAUDE.md `@` includes. The plugin install handles both layers.

---

## Installation

### Prerequisites

- Claude Code CLI installed
- Git
- A GitHub token in your environment (`GITHUB_TOKEN`) for GitHub MCP access

### Install into a new project

```
/plugin marketplace add jballaban/claude
/plugin install claude-framework
```

The plugin installs all 10 agents and all skills into your project in one step.

### After installation

Fill in the generated context files:

| File | What to fill in |
|------|----------------|
| `spec/context/product.md` | What the product is, who it is for, what problem it solves |
| `spec/context/tech-stack.md` | Dependencies and services additive to or overriding the team defaults |
| `spec/context/architecture.md` | How the major pieces connect |
| `spec/context/design-system.md` | Brand guidelines, tone, colours, typography, asset locations |
| `spec/context/environments.md` | URLs, AWS account IDs, and one-time CI/CD setup steps |
| `spec/context/conventions.md` | Project-specific patterns and stack overrides with reasons |
| `spec/current/overview.md` | What is live in production right now |
| `spec/next/overview.md` | What the next major release will contain |

### Verify the installation

```bash
/pending
```

If `/pending` responds, both layers are working — the skill is installed and the agent context is loaded.

### Updating an existing project

```
/plugin update claude-framework
```

`spec/` is never overwritten. All project-specific work is preserved.

---

## How the framework works

The product owner interacts exclusively through Claude. Skills are the entry points. The first skill most projects use is `/pending`.

**Agent team:** Orchestrator, Analyst, Spec Writer, Architect, Developer, Designer, Marketing, QA, DevOps, Security

**The product owner never needs to know which agent handles what.** They describe what they want. The Orchestrator handles the rest.

**Two mandatory checkpoints require product owner input:**
1. After the Analyst produces a spec — approve before development begins
2. After QA and Security sign off — approve before deployment

**GitHub is read-only for the product owner.** Issues and PRs are outputs of the process — created and managed by agents.

---

## Marketplace structure

```
.claude-plugin/
  plugin.json           # Plugin metadata — id, agents, skills

agents/
  _index.md             # Browse all agents
  {agent}/
    agent.md            # Agent definition — role, model, responsibilities
    manifest.json       # Metadata — category, tags, dependencies

skills/
  _index.md             # Browse all skills
  {skill}/
    SKILL.md            # Claude Code skill definition (slash command)
    manifest.json       # Metadata — trigger, dependencies on agents

framework/
  process.md            # Workflow patterns, checkpoints, feedback loops
  quality-gates.md      # 4 gates that must pass before deployment
  architecture-standards.md  # Universal engineering principles

defaults/
  stack.md              # Team technology choices (AWS, TypeScript, Next.js, etc.)
  patterns.md           # Authoritative references and team decisions

templates/
  CLAUDE.md             # Project CLAUDE.md template — loads agent context via @includes
  spec/context/         # Project context file templates

catalog.md              # Root marketplace index
```

---

## Contributing improvements

When you learn something working in a project — a better process step, a missing quality gate, a wrong default, a new team decision — improve it here.

**To add a new agent:** create `agents/{name}/agent.md` + `manifest.json`, add to `.claude-plugin/plugin.json`.

**To add a new skill:** create `skills/{name}/SKILL.md` + `manifest.json`, add to `.claude-plugin/plugin.json`. Declare which agents the skill depends on in `manifest.json`.
