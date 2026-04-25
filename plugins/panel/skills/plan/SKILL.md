---
name: plan
description: Takes a spec and produces a phased implementation plan with independently executable tasks per phase. Runs the spec through the panel pipeline — asking domain experts to identify the work items their domain requires and their dependencies — then synthesizes a dependency-ordered phase structure. Phases are sequential; tasks within each phase are parallelizable. Output is a plan only — no implementation.
---

# Plan

**Built on:** Panel pipeline
**When to use:** You have a spec (from `/panel`, `/council`, or written yourself) and want to break it into executable phases.
**When to use panel/council first:** If you don't have a spec yet, run `/panel` or `/council` to build one, then pass the result to `/plan`.

---

## Tier Parameters

| Parameter | Value |
|-----------|-------|
| `DOMAIN_COUNT` | 5 |
| `AGENT_MIN` | 3 |
| `AGENT_MAX` | 7 |
| `TIER_NAME` | plan |
| `DEPTH_INSTRUCTION` | Analyze the spec to identify every concrete work item your domain would own in implementing it. Classify each item as: **foundational** (other work depends on it existing first), **core** (primary deliverable), or **hardening** (polish, edge cases, production-readiness). Note any dependencies between items — if item B requires item A to exist first, say so explicitly. Size each item as roughly one developer's work item (a single PR, a day or two of focused work). Do not write code or create files — identify and classify work only. |

---

## How /plan works

/plan runs the panel pipeline with one specific question:

> **"Given this spec, what work items does each domain require, and in what order must they be done?"**

Domain experts analyze the spec from their perspective, identify their work items, and note dependencies. These are synthesized into phases where:
- **Phases are sequential** — Phase N must be complete before Phase N+1 begins
- **Tasks within a phase are independent** — any task in a phase can be started without waiting for another task in the same phase

---

## Execution

**This skill produces a plan only. No code, no files, no implementation.**

**Parallel execution:** Launch all agents simultaneously in Steps 4 and 6. Never wait for one to complete before spawning the next.

---

## Steps 0–4

Follow Steps 0–4 exactly as defined in [../shared/pipeline.md](../shared/pipeline.md), with these specifics:

- The **request** passed to agents is: `"Given the following spec, identify the implementation work items your domain requires and their dependencies: [SPEC]"`
- Use the `DEPTH_INSTRUCTION` from this skill's tier parameters above (not the shared pipeline's depth instruction)
- Include the always-present adversarial agent from Step 3

---

## Step 5 · Phased Consolidation

Merge all agent outputs into a **phased implementation plan**. This replaces the shared pipeline's Step 5 consolidation.

**Phasing rules:**
1. Let dependencies determine the number of phases — do not force a fixed count
2. Phase 1 is always foundational: infrastructure, schemas, contracts, tooling — things every other phase depends on
3. Foundational items from agents → Phase 1; core items → middle phases; hardening items → final phase(s)
4. If a task in a phase depends on another task in the same phase, promote the dependency to the previous phase
5. Each phase must produce a testable or demonstrable outcome — not just intermediate state
6. Name phases by what they deliver ("API Foundation", "Core Auth", "User Dashboard", "Production Hardening"), not just a number
7. Fold adversarial attack vectors into the Risks section, or into the phase plan if they require a specific mitigation task

**Task granularity:** One developer, one PR, roughly a day or two. "Build JWT validation middleware" — not "implement auth" or "add the JWT secret to config."

**Output — Step 5:**

_If any CONSULT-level domain was identified in Step 2, inject first:_
> **Advisory note:** This plan includes CONSULT-level domain(s): [list]. Model-generated analysis should not substitute for qualified professional judgment in these areas.

```markdown
## Phased Plan

### Phase 1 — [Name]
**Prerequisite:** none
**Delivers:** [what this phase produces and what it unlocks]

| # | Task | Domain | Notes |
|---|------|--------|-------|
| 1.1 | [concrete task] | [domain] | [dependency or parallelism note if needed] |
| 1.2 | [concrete task] | [domain] | |

### Phase 2 — [Name]
**Prerequisite:** Phase 1 complete
**Delivers:** [what this phase produces]

| # | Task | Domain | Notes |
|---|------|--------|-------|
| 2.1 | [concrete task] | [domain] | |

[...additional phases as the work requires...]

### Risks
- `risk` [concern that affects phasing or execution] _(source: agent)_

### Open Questions _(omit if none)_
- [Unresolved decision that could change the plan] _(source: agent)_
```

---

## Step 6 · Validation Round

Run three tracks **simultaneously** using the validation prompts from [../shared/pipeline.md](../shared/pipeline.md) Step 6, substituting `[STEP_5_OUTPUT]` with the phased plan above.

The Naive Plan Reviewer (Track A) checks whether the phases cover everything in the spec.
The scope-only domain agents (Track B) check whether phasing introduced scope beyond the spec.
The sighted adversarial agent (Track C) checks whether the phase ordering is sound and task independence assumptions hold.

Use the same rating definitions and overall status (PASS / REVIEW / RERUN / RESCOPE) from the shared pipeline.

---

## Step 7 · Final Output

**Result-first.** Phased plan before analysis detail.

**If PASS or REVIEW:**

```markdown
# /plan: [one-line description of what is being planned]

## Result
**Status: ✅ PASS** (or ⚠️ REVIEW)

[If REVIEW:]
**Cautions — proceed with awareness:**
| Source | Concern |
|--------|---------|
| [agent/reviewer] | [yellow reason] |

[Full phased plan from Step 5]

> All agents in this analysis share the same underlying model weights — consensus reflects consistency, not independent validation. Treat this plan as structured input for your own judgment.

---

## Analysis

### Step 0 · Context
[Step 0 output]

### Step 1 · Domains
[Step 1 output]

### Step 2 · Coverage
[Step 2 output]

### Step 3 · Agents
[Step 3 output]

### Step 4 · Agent Analyses
[Step 4 rendered output]

### Step 5 · Phased Plan
[Step 5 output]

### Step 6 · Validation
[Step 6 table + overall status]
```

**If RERUN:**

```markdown
## Result
**Status: 🔴 RERUN**

The following concerns prevent a reliable phase plan from being produced:

| Source | Issue |
|--------|-------|
| [agent/reviewer] | [red reason] |

Resolve:
- [ ] [specific fix]

Re-run scope: domains [list] + adversarial agent
Prompt addition: "[additional context needed]"
```

**If RESCOPE:**

```markdown
## Result
**Status: 🔴 RESCOPE**

The plan revealed scope beyond the provided spec. Re-run with:

---
[COMPLETE REVISED PROMPT — drafted in full by the orchestrator, ready to paste as-is]
---
```
