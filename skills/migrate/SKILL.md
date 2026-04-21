---
name: migrate
description: Migrate an existing repository into the three-phase framework. Reconstructs strategy from the codebase and founder conversation, maps existing features into shallow spec entries, and marks everything currently in main as built. Run once after installing the plugin on an existing project.
argument-hint: ""
allowed-tools: "Read Write Glob WebSearch WebFetch mcp__github__list_branches mcp__github__get_file_contents"
---

You are running a one-time migration. Your job is to bring an existing repository into the framework without disrupting anything already built.

You will not touch any existing code. You will not create branches or issues. You will only produce files in `strategy/` and `spec/`.

---

## Step 1: Assess what already exists

Check for:
- `strategy/` — if it exists and is populated, skip Phase A below and tell the founder
- `spec/roadmap.md` — if it exists, skip Phase B and tell the founder
- `spec/features/` — note any feature folders already present

Read the following to understand the project before asking any questions:
- README and any top-level documentation files
- Package manifests (package.json, pyproject.toml, Gemfile, etc.) for dependencies
- Folder structure — identify major areas of the codebase
- Any existing spec, docs, or architecture files

Tell the founder what you found before proceeding.

---

## Phase A: Strategy reconstruction

The Strategist leads this phase. The Spec Writer documents.

You have read the codebase. You have a partial picture of the product. Your job now is to fill the gaps that cannot be inferred from code — particularly the business intent, target market, and go-to-market thinking.

Do not ask about things you can already infer. Ask about what is genuinely unknown:

- Who is the primary target customer? (code shows what was built; not always who it was built for)
- What is the monetization model? (rarely visible in code)
- What is the GTM strategy — how are customers acquired?
- What does success look like in one to three years?
- Are there strategic constraints — things this product will deliberately not do?

Work through the five strategic domains, skipping any that are clearly answered by the code and existing docs. Produce all five `strategy/` documents. Write each document as you complete it — do not batch.

Documents to produce:
- `strategy/vision.md`
- `strategy/market.md`
- `strategy/monetization.md`
- `strategy/gtm.md`
- `strategy/principles.md`

---

## Phase B: Feature mapping

The Analyst leads this phase. The Spec Writer documents.

Read the codebase thoroughly. Identify the distinct features — areas of functionality that represent a meaningful unit of product value. Aim for the granularity a developer would use when describing a PR: not "the whole app" and not "this one function", but "user authentication" or "competition creation flow".

For each feature:

1. Give it a short, lowercase, hyphenated name (this will become `spec/features/{name}/`)
2. Write a shallow `business.md` — see format below
3. Identify its dependencies: which other features does it rely on to function?

**Shallow business.md format:**

```markdown
# {Feature Name} — Business Spec

## What it does
<!-- One paragraph describing the feature's purpose and the user value it delivers. -->

## Who uses it
<!-- Which user type or segment. Infer from the code if not documented. -->

## Acceptance criteria (inferred)
<!-- What the code does, described as testable conditions.
These are inferred from implementation — not a designed spec.
- [ ] ...
- [ ] ...
-->

## Dependencies
<!-- Other features that must exist for this one to work (user-facing dependencies). -->

## Migration note
Spec inferred from existing codebase during migration. This is not a designed spec.
Status: built — this feature is already live in main.
```

Write each feature's `business.md` to `spec/features/{feature-name}/business.md`.

---

## Phase C: Roadmap generation

After all features are mapped, produce `spec/roadmap.md`.

Every feature identified in Phase B gets `status: built`. The dependency graph should reflect what you found — features that depend on other features should list them in `depends_on`.

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

## Finishing

When all three phases are complete:

1. Summarise what was produced:
   - List the five strategy documents
   - List all features mapped, with their dependency relationships
   - Note any areas of the codebase that were ambiguous or not mapped to a feature

2. Flag any gaps — things the code suggested but you could not confidently map to a feature or strategic decision.

3. Tell the founder: "Review `strategy/` and `spec/features/`. When you're satisfied, commit these files. From this point, use `/plan` to spec new features and `/build` to build them — existing features are marked as built and the dependency graph will advance from here."
