---
name: plan
description: Breaks a spec, feature, or goal into a phased implementation plan with independently executable tasks per phase. Uses multi-domain expert analysis to identify all required work, then synthesizes a dependency-ordered phase structure. Phases are sequential; tasks within each phase are parallelizable. Output is a structured plan only — never implementation.
---

# Plan

**Tier:** Standard
**When to use instead:** Quick feasibility check → `/ask` · Deep architecture review → `/council`

---

## Tier Parameters

| Parameter | Value |
|-----------|-------|
| `DOMAIN_COUNT` | 5 |
| `AGENT_MIN` | 3 |
| `AGENT_MAX` | 7 |
| `TIER_NAME` | plan |
| `DEPTH_INSTRUCTION` | Think in concrete work items your domain would own. For each item, note whether it is foundational (other work depends on it existing first), core (the primary deliverable), or hardening (polish, edge cases, scale). Be specific enough that a developer could pick this up as a task. Avoid abstract concerns — translate them into something buildable. |

---

## Execution

**This skill produces a plan only. No code, no files, no implementation.**

**Parallel execution:** When spawning agents in Steps 4 and 6, launch ALL agents simultaneously in a single response. Never wait for one agent to complete before spawning the next.

---

## Steps 0–3

Follow Steps 0–3 exactly as defined in [../shared/pipeline.md](../shared/pipeline.md):
- Step 0: Context Gathering
- Step 1: Domain Identification
- Step 2: Coverage Check (including Advisory Level)
- Step 3: Dynamic Agent Synthesis (including the always-present adversarial agent)

---

## Step 4 · Parallel Agent Analysis

Use the domain agent prompt and adversarial agent prompt exactly as defined in [../shared/pipeline.md](../shared/pipeline.md) Step 4, including the no-code constraint and the `DEPTH_INSTRUCTION` from this skill's tier parameters above.

Render agent outputs using the Step 4 markdown format from the shared pipeline.

---

## Step 5 · Phased Consolidation

Merge all agent outputs into a **phased implementation plan**.

**Core constraint:**
- Phases are **sequential** — Phase N must be fully complete before Phase N+1 begins
- Tasks within a phase are **independent** — any task in a phase can be started without waiting for another task in the same phase to finish
- A developer could pick up any single task in a phase and work it to completion in isolation

**Phasing rules:**
1. Let the dependencies determine the number of phases — do not force a fixed count
2. Phase 1 is always foundational: infrastructure, schemas, contracts, tooling — things every other phase depends on
3. Critical agent items become early-phase tasks; important items become mid-phase; nice-to-have items become late-phase or a final hardening phase
4. If a task in a phase depends on another task in the same phase, promote the dependency to the previous phase
5. Each phase should produce a testable or demonstrable outcome — not just intermediate work
6. Name phases by what they deliver ("API Foundation", "Core Authentication", "User Dashboard", "Production Hardening"), not just by number
7. Integrate adversarial agent's attack vectors: if a vector points to a structural risk in the phasing order, resequence; otherwise add to Risks section

**Task granularity:** Size tasks as roughly one developer's work item — one PR, a day or two of focused work. Too coarse: "implement authentication." Right: "Build JWT generation and validation middleware." Too fine: "Create the users table migration."

**Output — Step 5:**

_If any CONSULT-level domain was identified in Step 2, inject first:_
> **Advisory note:** This plan includes CONSULT-level domain(s): [list]. Model-generated analysis should not substitute for qualified professional judgment in these areas.

```markdown
## Phased Plan

### Phase 1 — [Name]
**Prerequisite:** none
**Delivers:** [what this phase produces and what it unlocks for the next phase]

| # | Task | Domain | Notes |
|---|------|--------|-------|
| 1.1 | [concrete task description] | [domain] | [optional: parallelism or dependency note] |
| 1.2 | [concrete task description] | [domain] | |

### Phase 2 — [Name]
**Prerequisite:** Phase 1 complete
**Delivers:** [what this phase produces]

| # | Task | Domain | Notes |
|---|------|--------|-------|
| 2.1 | [concrete task description] | [domain] | |

[...additional phases as the work requires...]

### Risks & Open Questions
- `risk` [concern that could affect phasing or task execution] _(source: agent)_
- `question` [unresolved decision that could change the plan] _(source: agent)_
```

---

## Step 6 · Validation Round

Run three tracks **simultaneously** using the validation prompts from [../shared/pipeline.md](../shared/pipeline.md) Step 6, substituting `[STEP_5_OUTPUT]` with the phased plan above.

The Naive Plan Reviewer (Track A) checks whether the phases cover everything requested.
The scope-only domain agents (Track B) check whether the phasing introduced scope beyond the original request.
The sighted adversarial agent (Track C) checks whether the phase ordering is sound and task independence assumptions hold.

Use the same rating definitions and overall status logic (PASS / REVIEW / RERUN / RESCOPE) from the shared pipeline.

---

## Step 7 · Final Output

**Result-first.** The phased plan appears before analysis detail.

```markdown
# /plan: [one-line description of what is being planned]

## Result
**Status: [STATUS emoji + word]**
```

**If PASS or REVIEW:**

```markdown
## Result
**Status: ✅ PASS** (or ⚠️ REVIEW)

[If REVIEW — caution table before the plan:]
**Cautions — proceed with awareness:**
| Source | Concern |
|--------|---------|
| [agent/reviewer] | [yellow reason] |

[The full phased plan from Step 5]

> All agents in this analysis share the same underlying model weights — consensus reflects consistency, not independent validation. Treat this plan as structured input for your own judgment, not a prescription.

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

The following concerns prevent a reliable plan from being produced. Resolve before re-running:

| Source | Issue |
|--------|-------|
| [agent/reviewer] | [red reason] |

Resolve:
- [ ] [specific fix 1]
- [ ] [specific fix 2]

**Re-run (RERUN-DELTA — deficient domains + adversarial only):**
Tier: /plan (or escalate to `/council` if concerns are systemic)
Re-run scope: domains [list] + adversarial agent
Prompt addition: "[specific context to add]"
```

**If RESCOPE:**

```markdown
## Result
**Status: 🔴 RESCOPE**

The plan revealed scope beyond the original request. Prior analyses are incomplete for the expanded scope — do not patch.

| Source | Scope Change |
|--------|-------------|
| [agent/reviewer] | [what new scope appeared] |

Use the revised prompt below for a full re-run:

---
[COMPLETE REVISED PROMPT — drafted in full by the orchestrator, ready to paste as-is]
---

Tier: /plan (or escalate if expanded scope increases complexity)
```
