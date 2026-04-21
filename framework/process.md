# Process

Three phases. Each phase gates the next. The founder runs a skill to enter a phase, iterates until satisfied, then commits the output before advancing.

---

## Phase 1 — Strategy (`/framework-strategy`)

**Entry:** Founder runs `/framework-strategy` with a product idea or existing context.

**Who:** Strategist leads. Spec Writer documents.

**What happens:** Structured conversation working through five strategic domains — vision, market, monetization, GTM, and principles. The Strategist stress-tests assumptions and produces one document per domain.

**Output:** `strategy/` folder — five documents that constitute the complete strategic foundation.

**Gate:** Founder reviews and commits `strategy/`. Phase 2 cannot begin without an approved `strategy/` folder.

---

## Phase 2 — Planning (`/framework-plan`)

**Entry:** Founder runs `/framework-plan` with a feature name or set of features to plan.

**Who:** Analyst leads. Architect, Marketing agent, Designer, and Spec Writer participate throughout. Security and DevOps do a review pass after each feature is drafted.

**Prerequisite:** `strategy/` folder must exist and be committed. The Analyst reads it before any spec work begins.

**What happens:** For each feature, the team works through business requirements, technical approach, design, launch strategy, security requirements, and infrastructure needs — simultaneously, not sequentially. The Spec Writer produces all written output. Security and DevOps review each completed draft and document their requirements directly into the spec.

**Output per feature:** `spec/features/{feature}/` — seven documents covering every aspect Development needs.

**Output for the session:** `spec/roadmap.md` — dependency graph updated with all newly planned features.

**Claude Design assets:** The Designer produces briefs for assets requiring Claude Design sessions. These are listed in `assets-needed.md` per feature. The founder completes these sessions and places assets in `spec/features/{feature}/assets/` before the feature enters Development.

**Gate:** Founder reviews all feature specs, completes Claude Design sessions, and commits `spec/features/` and `spec/roadmap.md`. `/framework-build` will not proceed on a feature with unresolved `assets-needed.md` items.

---

## Phase 3 — Development (`/framework-build`)

**Entry:** Founder runs `/framework-build`. No argument needed — the skill reads state automatically.

**Who:** Developer implements. QA and Security gate. DevOps handles infrastructure. Spec Writer reconciles after merge.

**Prerequisite:** `spec/roadmap.md` must exist. Feature specs must be committed and complete (no unresolved assets).

**What happens:**

1. `/framework-build` reads `spec/roadmap.md` and GitHub merged branch state to compute the frontier — features whose dependencies are all built and that have no open issue yet.
2. Founder confirms the batch to build (default: all frontier features in parallel).
3. GitHub issues are created with full spec context — business, technical, design, launch, security, and infrastructure all in one issue.
4. Developer implements each feature on branch `feature/{name}`, test-first.
5. QA validates against acceptance criteria. Security reviews the PR. Both must sign off.
6. Founder reviews the ready PRs and merges them.
7. Spec Writer compares what was built against the spec. Discrepancies are noted in `business.md` as reconciliation notes.
8. Founder runs `/framework-build` again — the graph has advanced, new frontier is computed.

**Gate:** Founder reviews and merges PRs. Agents do not merge.

---

## Human checkpoints

| Checkpoint | When | What the founder decides |
|------------|------|-------------------------|
| After `/framework-strategy` | Before `/framework-plan` | Is this the right strategic foundation to build from? |
| After `/framework-plan` (each feature) | Before `/framework-build` on that feature | Is this spec complete and correct? Are all design assets ready? |
| After each `/framework-build` batch | Ongoing | Do these PRs meet the spec? Merge or send back. |

---

## Feedback loops

**Spec gap discovered during Development:** Developer raises a WHAT question (business requirement unclear or wrong) on the GitHub issue. Founder runs `/framework-plan` to update the spec. Development resumes against the updated spec.

**Technical constraint changes the spec:** Architect raises a HOW concern with WHAT implications (e.g., "the approach we specced requires a service that doesn't meet our compliance requirement"). Routes to Analyst via the issue. Spec updated before work continues.

**Strategy changes mid-build:** Founder updates `strategy/` and runs `/framework-plan` on affected features to propagate the change into specs before the next `/framework-build` run.

**Built reality differs from spec:** Spec Writer adds a reconciliation note to `business.md`. If the difference affects dependent features, Analyst reviews the dependent specs before their `/framework-build` run.

---

## Branch model

| Branch | Purpose |
|--------|---------|
| `main` | Production — features targeting `main` ship as soon as they merge |
| `next` | Staging — features targeting `next` hold for a coordinated major release |
| `feature/{name}` | One branch per feature, created by `/framework-build`, merged by the founder |

The target branch for each feature is set in `business.md` during Planning. `/framework-build` creates the feature branch from the correct base.
