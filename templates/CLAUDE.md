# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Framework (non-negotiable)

> The following defines the mandatory process, agent roles, quality gates, and architecture standards for this project. What follows in the project context section customises HOW agents work — it does not override WHETHER the process is followed.

@.claude/framework/process.md
@.claude/framework/agents.md
@.claude/framework/quality-gates.md
@.claude/framework/architecture-standards.md

---

## Project extensions

> Add project-specific instructions, agent overrides, or additional process rules here. This section works within the framework above — it does not override mandatory process or agent definitions.

@.claude/project/extensions.md

---

## Project Context

> The following files define this specific project. They inform agent behaviour and decision-making within the framework above.

@.claude/context/product.md
@.claude/context/tech-stack.md
@.claude/context/architecture.md
@.claude/context/design-system.md
@.claude/context/environments.md
@.claude/context/conventions.md

---

## Product Specs

> The spec folder is the source of truth for what this product contains. The Analyst reads these files — not the codebase. Spec accuracy on every branch is maintained by the Spec Writer.

@spec/current/overview.md
@spec/next/overview.md
