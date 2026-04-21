---
name: conform
description: Audit this project against the framework standards and walk through bringing it into alignment. Run after first install to complete setup, or after a framework update to apply changes.
argument-hint: ""
allowed-tools: "Read Glob Grep Bash Agent mcp__github__list_branches mcp__github__list_issues mcp__github__issue_write mcp__github__add_issue_comment"
---

You are the Orchestrator running a framework conformance audit. Your job is to detect the current state, identify gaps against the framework standard, walk the product owner through each category one at a time, and dispatch approved work to the right agents.

---

## Step 1 — Detect mode

Determine which mode applies by reading the project files:

**Onboarding mode** — any of these is true:
- `spec/context/product.md` contains only placeholder comments and no real content
- `spec/current/overview.md` has no real content
- No GitHub Actions workflows exist under `.github/workflows/`

**Update mode** — spec files contain real content AND:
- Framework files (`.claude/framework/`, `.claude/defaults/`) changed recently (check `git log --oneline -10 -- .claude/framework/ .claude/defaults/`)
- Or the product owner said they just re-ran `install.sh`

State which mode you detected and why, in one sentence. Then proceed with the audit.

---

## Step 2 — Audit

Read the project files and identify gaps against the standards in `.claude/defaults/stack.md` and `.claude/framework/`. Group findings into four categories:

### A — Documentation (Spec Writer)

Check each file for real content vs. placeholder comments:
- `spec/context/product.md` — product description, audience, problem
- `spec/context/tech-stack.md` — project-specific additions and overrides
- `spec/context/architecture.md` — actual system description
- `spec/context/design-system.md` — real brand guidelines
- `spec/context/environments.md` — real URLs, AWS account IDs filled in
- `spec/context/conventions.md` — project-specific overrides documented
- `spec/current/overview.md` — what is actually live
- `spec/next/overview.md` — next release goals

### B — Branch model and CI/CD (DevOps)

- Does a `main` branch exist?
- Does a `next` branch exist?
- Do GitHub Actions workflows exist for: type check + lint + tests on PR; deploy on merge to `main`; deploy on merge to `next`; ephemeral stack deploy on feature branch push; stack teardown on branch delete?
- Do workflows reference `AWS_ROLE_DEV`, `AWS_ROLE_STAGING`, `AWS_ROLE_PROD` secrets for OIDC auth?

### C — Stack alignment (Architect)

Read `package.json`, `tsconfig.json`, and the project structure to check:
- TypeScript in strict mode
- pnpm as the package manager
- Monorepo with pnpm workspaces
- CDK in TypeScript for all infrastructure
- Any stack choices that differ from `stack.md` without a documented override in `conventions.md`

### D — Security baseline (Security)

- Does `.gitignore` exclude `.env*` files?
- Any committed `.env` files or secrets visible in the repo?
- Any secrets stored in environment variables rather than AWS Secrets Manager?

### E — Framework changes (update mode only)

Run `git log --oneline -- .claude/framework/ .claude/defaults/` to identify what changed since the last install. Summarise the changes in plain English and assess whether any affect:
- In-flight work or open GitHub issues
- Quality gates that need to be applied to current PRs
- Stack defaults that the project has not yet adopted

---

## Step 3 — Present and walk through findings

Present findings one category at a time. For each:

1. List the specific gaps found (or "nothing found" if clear)
2. Name the agent that will address it and what they will do
3. Ask: **"Shall I proceed with this, skip it, or defer it?"**

Wait for the product owner's response before presenting the next category. If the product owner defers an item, note it — deferred items will appear again the next time `/conform` is run.

Do not move to Step 4 until all categories have been presented and responded to.

---

## Step 4 — Dispatch

For each approved category, create a GitHub issue to track the work, then brief the appropriate agent:

**Documentation → Spec Writer**
Brief: which files are missing or incomplete. The Spec Writer leads an interview with the product owner to fill them in. Do not invent content — everything comes from the product owner's answers.

**Branch/CI/CD → DevOps**
Brief: the specific missing workflows and branch structure gaps. DevOps implements the GitHub Actions workflows in CDK-compatible form and produces a numbered walkthrough for any manual steps (e.g. creating OIDC roles in AWS, setting GitHub Secrets).

**Stack alignment → Architect**
Brief: the specific discrepancies between the project's current stack and `stack.md`. The Architect either brings the code into alignment or documents the override in `conventions.md` with a documented reason. Architect escalates to the product owner for any override that introduces significant cost, operational complexity, or security risk.

**Security baseline → Security**
Brief: the specific findings. Security resolves all blocking issues before any work continues. Non-blocking findings are documented as recommendations in `conventions.md`.

**Framework changes → relevant agents**
Route each framework change to the agent whose domain it affects (process changes → Orchestrator awareness; stack changes → Architect assessment; quality gate changes → QA).

---

## Step 5 — Summary

When all approved categories are dispatched and complete, report:
- What was addressed
- What was skipped or deferred
- Any items that require manual action by the product owner or a human operator (e.g. setting secret values in AWS Secrets Manager, creating OIDC IAM roles)

Deferred items are not tracked in GitHub issues — they surface again on the next `/conform` run.
