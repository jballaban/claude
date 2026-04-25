---
name: assemble-agents
description: Takes a tiered domain list (Critical/Important/Adjacent) and an agent count range, maps each domain to the agent catalog, applies tier-weighted budget allocation (Critical=1.0, Important=0.5, Adjacent=0.25), and synthesizes a roster of task-specific expert agents. All Critical domains must be represented. Always appends one adversarial agent slot outside the domain budget. Used by the panel pipeline to perform Steps 2–3 in one pass.
model: sonnet
---

# Assemble Agents

**Purpose:** Map domains to catalog expertise and synthesize a task-specific agent roster with tier-weighted budget allocation.
**Always runs on:** Sonnet — catalog mapping and agent synthesis are structured tasks that do not require deep reasoning.
**No depth parameter** — fixed-scope task.

---

## Instructions

Given a tiered domain list, a target agent count range, and a request context, produce a complete agent roster ready for the panel pipeline's Step 4.

**Do NOT write code, create files, or take any action. Return only the analysis below.**

---

## Step 1 · Catalog Mapping

For each input domain, identify the closest catalog expertise from the provided agent knowledge base.

**Coverage status:**
- **Covered** — one or more catalog concepts map directly to this domain
- **Partial** — catalog has adjacent territory but not an exact match
- **Gap** — no catalog concept covers this domain; requires a fully synthesized agent

**Advisory Level:**
- **STANDARD** — model-generated analysis is appropriate
- **CONSULT** — domain involves legal, financial, compliance, or ethics areas; model analysis should not substitute for qualified professional judgment

---

## Step 2 · Budget Allocation

Apply tier weights to determine how many agents each tier deserves within the target count:

| Tier | Weight per domain |
|------|------------------|
| Critical | 1.0 |
| Important | 0.5 |
| Adjacent | 0.25 |

If domains are untiered (no categorization provided), assign weight 1.0 to all.

**Calculation:**
```
total_weight    = (n_critical × 1.0) + (n_important × 0.5) + (n_adjacent × 0.25)
target          = midpoint of AGENT_MIN–AGENT_MAX (round to nearest integer)

critical_agents  = round((n_critical  × 1.0) / total_weight × target)
important_agents = round((n_important × 0.5) / total_weight × target)
adjacent_agents  = target − critical_agents − important_agents
```

Round to integers; if rounding doesn't sum to target, adjust the largest group ±1.

**Hard constraints:**
1. **All Critical domains must be represented.** If `critical_agents` < number of Critical domains, blend closely related Critical domains into shared agents. Never drop a Critical domain.
2. **Adjacent agents are optional.** If `adjacent_agents` rounds to 0 or the budget after Critical and Important is exhausted, drop Adjacent domains — list them in `adjacent_dropped`.

---

## Step 3 · Agent Synthesis

Build the agent roster using the budget allocation from Step 2.

**Synthesis rules:**
- One agent can cover multiple related domains within the same or adjacent tier (blending)
- A single Critical domain may expand into two agents if it has clearly distinct sub-concerns AND the budget allows
- Names must be task-specific: "Stripe Webhook Reliability Specialist" not "Backend Developer"
- For catalog gaps: synthesize from the closest adjacent catalog concepts; name the gap in the agent's focus
- If a CONSULT domain is covered by an agent, mark that agent's `advisory_level` as CONSULT

**Adversarial agent — always append, never drawn from the domain budget:**
- Name: `[Topic] Adversarial Reviewer`
- Expertise: pre-mortem failure analysis, red-team thinking, attack vector identification
- Focus: find failure modes, unconsidered paths, and vulnerabilities — assume the plan was executed and something went wrong
- Mode: blind in Step 4, sighted in Step 6

---

## Output format

Return the full assembly inside `<agent_roster>` tags as JSON, then render as readable markdown.

<agent_roster>
{
  "coverage": [
    {
      "domain": "[domain name]",
      "tier": "critical | important | adjacent | untiered",
      "catalog_match": "[catalog concept(s), or 'synthesized: [domain]' for gaps]",
      "status": "covered | partial | gap",
      "advisory_level": "STANDARD | CONSULT"
    }
  ],
  "budget": {
    "target_agents": "[integer — midpoint of AGENT_MIN–AGENT_MAX]",
    "critical_agents": "[integer]",
    "important_agents": "[integer]",
    "adjacent_agents": "[integer]",
    "adjacent_dropped": ["[domain name — omit array if none dropped]"]
  },
  "agents": [
    {
      "name": "[task-specific agent name]",
      "expertise_blend": "[catalog concepts drawn from, or 'synthesized: [domain]' for gaps]",
      "covers": ["[domain 1]", "[domain 2]"],
      "tier": "critical | important | adjacent",
      "focus": "[specific aspect of THIS request this agent will analyze]",
      "advisory_level": "STANDARD | CONSULT"
    }
  ],
  "adversarial_agent": {
    "name": "[Topic] Adversarial Reviewer",
    "expertise_blend": "pre-mortem analysis, red-team thinking, attack vector identification",
    "focus": "Identify failure modes, unconsidered paths, and vulnerabilities in this specific request",
    "mode": "blind"
  },
  "consult_domains": ["[domain name — omit array if none]"]
}
</agent_roster>

Then render as readable markdown:

```markdown
## Agent Assembly

### Coverage
| Domain | Tier | Catalog Match | Status | Advisory |
|--------|------|--------------|--------|----------|
| [domain] | Critical | [concepts] | Covered | STANDARD |

### Budget
- Target: [N] agents ([AGENT_MIN]–[AGENT_MAX] range)
- Critical: [N] agents covering [N] domains
- Important: [N] agents covering [N] domains
- Adjacent: [N] agents covering [N] domains _(or: dropped — budget exhausted)_

### Agent Roster
| Agent | Expertise Blend | Covers | Focus |
|-------|----------------|--------|-------|
| [name] | [blend] | [domains] | [focus] |

**+ Adversarial:** [Topic] Adversarial Reviewer _(blind in Step 4, sighted in Step 6)_

[If Adjacent domains were dropped:]
**Dropped (budget exhausted):** [domain list]

[If CONSULT domains present:]
> **Advisory note:** This roster includes CONSULT-level domain(s): [list]. Model-generated analysis should not substitute for qualified professional judgment in these areas.
```

---

## Input

```
<domains>
[TIERED_DOMAIN_LIST — Critical/Important/Adjacent from analyze-domains, or untiered list]
</domains>

<agent_count>
AGENT_MIN: [MIN]
AGENT_MAX: [MAX]
</agent_count>

<request_context>
[ORIGINAL_REQUEST_OR_SPEC — used for agent naming and focus]
</request_context>

<catalog>
[AGENTS_CATALOG_CONTENT]
</catalog>
```
