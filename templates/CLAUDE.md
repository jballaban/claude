# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Framework (non-negotiable)

> Mandatory process, agent roles, quality gates, and universal engineering principles. Nothing below overrides this layer.

@.claude/framework/process.md
@.claude/framework/quality-gates.md
@.claude/framework/architecture-standards.md

---

## Team defaults

> Opinionated technology choices that apply to all projects for this team. Override specific items in `spec/context/conventions.md` with a documented reason.

@.claude/defaults/stack.md
@.claude/defaults/patterns.md

---

## Project knowledge

> Everything agents need to know about this project. The Analyst reads this as its source of truth. The Spec Writer keeps it accurate on every branch.

@spec/context/product.md
@spec/context/tech-stack.md
@spec/context/architecture.md
@spec/context/design-system.md
@spec/context/environments.md
@spec/context/conventions.md
@spec/current/overview.md
@spec/next/overview.md
