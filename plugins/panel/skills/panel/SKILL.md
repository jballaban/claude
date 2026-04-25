---
name: panel
description: Standard multi-domain analysis of a task. Identifies the top 5 relevant domains, synthesizes 3–7 task-specific agents on demand, runs them in parallel, consolidates their feedback, and validates with a traffic-light rating round. Returns all steps and a final status. Use for most feature work, strategic decisions, bug fixes with non-obvious scope, or any task before beginning execution.
---

# Panel

**Tier:** Standard
**When to use instead:** Quick sanity check → `/ask` · Architecture, migrations, high-stakes → `/council`

---

## Tier Parameters

| Parameter | Value |
|-----------|-------|
| `DOMAIN_COUNT` | 5 |
| `AGENT_MIN` | 3 |
| `AGENT_MAX` | 7 |
| `TIER_NAME` | panel |
| `DEPTH_INSTRUCTION` | Be thorough and specific. Cover all meaningful concerns in your domain. Provide actionable recommendations. Don't pad — if a field has nothing worth saying, omit it. |

At this tier, balance consolidation with coverage. Closely related concerns can share an agent, but distinct domains should have dedicated representation.

---

## Execution

Follow the pipeline in [../shared/pipeline.md](../shared/pipeline.md) using the parameters above.

Agent knowledge base: [../shared/agents-catalog.md](../shared/agents-catalog.md)

**Parallel execution:** When spawning agents in Steps 4 and 6, launch all agents simultaneously in a single response. Never wait for one agent to complete before spawning the next.

**Effort level:** This is a standard-tier skill. Orchestrator should run at `high` effort. Subagents run at `medium` effort — thorough but not exhaustive.
