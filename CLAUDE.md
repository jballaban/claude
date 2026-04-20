# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## What this repository is

This is a reusable Claude Code framework — a defined process, agent team, and set of standards for building software products using Claude as the primary development team. It is not a product itself.

You take the files from this repo, drop them into a new project with `scripts/install.sh`, and your project immediately has a structured agent workflow, consistent SOPs, and opinionated architecture standards.

Improvements made here benefit every project that adopts the framework when they next run the install script.

---

## How to adopt this framework in a new project

```bash
# From the root of your target repository
bash path/to/claude-framework/scripts/install.sh
```

Then fill in the generated template files:

| File | What to fill in |
|------|----------------|
| `.claude/context/product.md` | What the product is, who it is for, what problem it solves |
| `.claude/context/tech-stack.md` | Languages, frameworks, key dependencies specific to this project |
| `.claude/context/architecture.md` | How the major pieces connect |
| `.claude/context/design-system.md` | Brand guidelines, tone, colours, typography, asset locations |
| `.claude/context/environments.md` | Dev, staging, production URLs and deployment procedures |
| `.claude/context/conventions.md` | Project-specific patterns and any architecture-standards.md overrides |
| `spec/current/overview.md` | What is live in production right now |
| `spec/next/overview.md` | What the next major release will contain |

---

## How the framework works

The product owner interacts exclusively through Claude. Claude acts as the **Orchestrator** — an administrative coordinator that routes work to a team of specialist agents and enforces the process defined in `.claude/framework/`.

**Agent team:** Orchestrator, Analyst, Architect, Developer, Designer, Marketing, QA, DevOps, Security, Spec Writer

**The product owner never needs to know which agent handles what.** They describe what they want. The Orchestrator handles the rest.

**Two mandatory checkpoints require product owner input:**
1. After the Analyst produces a spec — approve before development begins
2. After QA and Security sign off — approve before deployment

Run `/pending` at any time to see everything waiting on you.

**GitHub is read-only for the product owner.** Issues and PRs are outputs of the process — created and managed by agents. The product owner does not create issues directly.

---

## Repository structure

```
.claude/
  framework/         # Non-negotiable process, agent definitions, quality gates, architecture standards
  skills/pending/    # /pending slash command
templates/
  CLAUDE.md          # Project CLAUDE.md template (copied to target repos)
  .claude/context/   # Project context file templates
spec/
  current/           # Spec for what is live — maintained by Spec Writer
  next/              # Spec for the next major release — maintained by Spec Writer
scripts/
  install.sh         # Copies framework into a target repository
```

---

## Contributing improvements

When you learn something working in a project — a better process step, a missing quality gate, a wrong architecture default — improve it here. Run `install.sh` in your projects to pull in the update.

Framework files (`.claude/framework/`) are always overwritten by `install.sh`. Project context files (`.claude/context/`, `spec/`) are never overwritten — they preserve project-specific work.
