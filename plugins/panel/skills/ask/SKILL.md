---
name: ask
description: Quick multi-domain triage of a task. Identifies the top 3 relevant domains, synthesizes 1–3 task-specific agents on demand, runs them in parallel, consolidates their feedback, and validates with a traffic-light rating round. Returns all steps and a final verdict. Use for small or scoped tasks, quick sanity checks, or to get a fast read before committing to deeper analysis.
---

# Ask

**Tier:** Shallow
**When to use instead:** Deeper domain analysis → `/panel` · Architecture, migrations, high-stakes → `/council`

---

## Tier Parameters

| Parameter | Value |
|-----------|-------|
| `DOMAIN_COUNT` | 3 |
| `AGENT_MIN` | 1 |
| `AGENT_MAX` | 3 |
| `TIER_NAME` | ask |
| `DEPTH_INSTRUCTION` | Be concise. Identify only the most significant concerns — 3 items per field maximum. Skip anything minor. Prioritise blockers and critical risks over everything else. |

At this tier, consolidate aggressively. 3 domains should map to 1–3 agents by blending closely related concerns into a single agent.

---

## Execution

Follow the pipeline in [../shared/pipeline.md](../shared/pipeline.md) using the parameters above.

Agent knowledge base: [../shared/agents-catalog.md](../shared/agents-catalog.md)

**Parallel execution:** When spawning agents in Steps 4 and 6, launch all agents simultaneously in a single response. Never wait for one agent to complete before spawning the next.

**Effort level:** This is a shallow-tier skill. Orchestrator should run at `medium` effort. Subagents run at `low` effort — fast triage, not deep analysis.
