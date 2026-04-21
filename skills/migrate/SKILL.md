---
name: migrate
description: Migrate an existing repository into the framework. Reads the codebase and populates context files, feature specs, and roadmap from what already exists. Does not ask questions — gaps are left for /strategy, /plan, and /build to handle. Run once after installing the plugin on an existing project.
argument-hint: ""
allowed-tools: "Read Write Glob WebSearch WebFetch mcp__github__list_branches mcp__github__get_file_contents"
---

You are running a one-time migration. Your job is to extract what already exists in this repository, place it into the framework's structure, and then remove the source files so the repo is left in exactly the state it would be in if this project had started with the framework from day one. No duplication. No leftover docs.

You do not ask questions. You do not invent information. You leave gaps blank — the downstream skills (/strategy, /plan, /build) will handle them through their normal processes.

You will not touch any existing source code. Outside of source code, you have full authority to write, replace, and delete files.

---

## Step 1: Read the repository

Read everything available before writing anything:

- `CLAUDE.md` and any top-level documentation files
- `README` files (root and any significant subdirectories)
- Package manifests (`package.json`, `pyproject.toml`, `Cargo.toml`, `Gemfile`, etc.)
- Folder structure — identify major areas of the codebase
- Any existing `spec/`, `docs/`, `architecture/`, or similar documentation directories
- Environment files (`.env.example`, CI/CD configs) for deployment topology
- Existing `strategy/` documents if present

Tell the founder what you found before writing anything.

---

## Step 2: Populate context files

Write `spec/context/` files from what you can confidently determine. Use the templates below. Leave any section blank (or omit entirely) if you cannot determine it from the existing code and docs — do not speculate.

**`spec/context/product.md`** — what the product is, for whom, and what problem it solves. Draw from README, docs, and any marketing copy in the repo.

**`spec/context/tech-stack.md`** — additional dependencies and services beyond the team defaults. List significant libraries, external APIs, and integrations found in the manifests. Note anything that overrides team defaults.

**`spec/context/architecture.md`** — how the major pieces connect. Describe the folder structure, key modules, data flow where visible, and any non-obvious architectural decisions found in code or comments.

**`spec/context/design-system.md`** — extract brand details, typography, colour palette, and component patterns from any existing design tokens, Tailwind config, CSS variables, or style guides found in the repo. Leave blank if none exist.

**`spec/context/environments.md`** — production and staging URLs, AWS account IDs, region settings, and deployment setup from CI/CD configs, `.env.example`, and infrastructure files.

**`spec/context/conventions.md`** — project-specific patterns and any stack overrides found in the existing codebase. Note any documented technical debt.

If a `spec/context/` file already exists and is populated, preserve its content and only add what is missing.

---

## Step 3: Map existing features

Read the codebase and identify the distinct features — areas of functionality that represent a meaningful unit of product value. Aim for the granularity of a developer describing a PR: not "the whole app" and not "this one function", but "user authentication" or "competition creation flow".

For each feature, create `spec/features/{name}/business.md`:

```markdown
# {Feature Name} — Business Spec

## What it does
<!-- One paragraph describing the feature's purpose and the user value it delivers. -->

## Who uses it
<!-- Which user type or segment. Infer from the code where possible. -->

## Acceptance criteria (inferred)
<!-- What the code does, described as testable conditions.
These are inferred from implementation — not a designed spec.
- [ ] ...
-->

## Dependencies
<!-- Other features that must exist for this one to work. -->

## Migration note
Spec inferred from existing codebase during migration. Status: built.
```

If `spec/features/` already exists with some features mapped, skip those and only add what is missing.

---

## Step 4: Generate the roadmap

Write `spec/roadmap.md` if it does not already exist. Every feature identified in Step 3 gets `status: built`.

```yaml
features:
  - name: auth
    description: User authentication — sign up, sign in, session management
    depends_on: []
    status: built

  - name: user-profile
    description: Profile management and settings
    depends_on: [auth]
    status: built
```

---

## Step 5: Clean up CLAUDE.md

Replace the existing `CLAUDE.md` with the clean framework template below. Any project-specific content from the old CLAUDE.md should already be captured in `spec/context/` above — do not preserve project-specific instructions in CLAUDE.md itself.

```markdown
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
```

---

## Step 6: Remove source files

Now that all content has been extracted into the framework's structure, delete the source files that were consumed. The goal is a clean repo with no duplication between old docs and new spec files.

**Delete:**
- Any standalone documentation files whose content is now in `spec/context/` (e.g. `docs/architecture.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md` if its conventions moved to `spec/context/conventions.md`)
- Any `docs/` or `documentation/` directories that have been fully absorbed
- Any top-level markdown files that described the product, stack, or architecture — that content now lives in `spec/context/`
- Any existing strategy documents that were in non-standard locations and have been moved to `strategy/`

**Trim but keep:**
- `README.md` — keep it, but strip out any detailed documentation sections that moved to `spec/context/`. The README should be left with only: project name, one-line description, and how to get started (install + run). Everything else is now in spec.
- `.env.example` — keep it; it documents required env vars for developers
- Package manifests, CI/CD configs, and all source code — never touch these

**Do not delete** anything you are uncertain about. If a file has content that does not clearly belong in any spec/context file, leave it and note it in the summary.

---

## Finishing

Summarise what was done:

- List each `spec/context/` file and note which sections were populated vs. left blank
- List all features mapped to `spec/features/`
- List all files that were deleted or trimmed
- Note anything left in place because its content could not be cleanly placed

Then tell the founder:

"Migration complete. The repo is now in framework state — all documentation lives in `spec/`, `CLAUDE.md` is clean, and source files have been removed. Review the spec files and fill in any blank sections you care about. When ready, run `/strategy` to establish the strategic foundation — it will work from what's already here and only ask about genuine gaps."
