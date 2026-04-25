---
name: council
description: Deep exhaustive analysis for high-stakes tasks. Identifies the top 5 relevant domains, synthesizes 7–10 task-specific agents with granular specialization, runs them in parallel, consolidates into a full plan, and validates with a traffic-light rating round. Returns all steps and a final status. Use for greenfield systems, architectural decisions, large migrations, security-critical work, or any request where getting it wrong is expensive.
---

# Council

**Tier:** Deep
**When to use instead:** Quick sanity check → `/ask` · Standard feature work → `/panel`

---

## Tier Parameters

| Parameter | Value |
|-----------|-------|
| `DOMAIN_COUNT` | 5 |
| `AGENT_MIN` | 7 |
| `AGENT_MAX` | 10 |
| `TIER_NAME` | council |
| `DEPTH_INSTRUCTION` | Be exhaustive. Consider edge cases, failure modes, long-term implications over a 6–12 month horizon, team and process impact, and compounding risks. Surface anything that could cause problems now or later — do not self-filter. |

At this tier, be granular. 5 domains should expand into 7–10 agents by breaking each domain into its distinct sub-concerns. A "security" domain might produce a "Threat Modelling Specialist" and a "Compliance & Audit Specialist" as separate agents.

---

## Execution

Follow the pipeline in [../shared/pipeline.md](../shared/pipeline.md) using the parameters above.

Agent knowledge base: [../shared/agents-catalog.md](../shared/agents-catalog.md)

**Parallel execution:** When spawning agents in Steps 4 and 6, launch all agents simultaneously in a single response. Never wait for one agent to complete before spawning the next.

**Effort level:** This is a deep-tier skill. Orchestrator should run at `xhigh` effort. Subagents run at `high` effort — exhaustive analysis, full field coverage expected.
