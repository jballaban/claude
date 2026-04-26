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

Agent count is **demand-driven**: figure out how many agents the domains actually require, then cap at `AGENT_MAX`. Never pad to reach a minimum.

Apply tier weights to calculate natural demand:

| Tier | Weight per domain |
|------|------------------|
| Critical | 1.0 — one agent slot per domain (blending allowed if closely related) |
| Important | 0.5 — one agent slot per two domains (round up) |
| Adjacent | 0.25 — one agent slot per four domains (round down) |

If domains are untiered (no categorization provided), assign weight 1.0 to all.

**Calculation:**
```
critical_agents  = n_critical  (minimum; blend related Critical domains if > AGENT_MAX)
important_agents = ceil(n_important × 0.5)
adjacent_agents  = floor(n_adjacent × 0.25)

natural_count = critical_agents + important_agents + adjacent_agents
actual_count  = min(natural_count, AGENT_MAX)
```

If `actual_count` < `natural_count`, trim from the bottom up: drop Adjacent first, then blend Important domains, never drop or merge Critical.

**Hard constraints:**
1. **All Critical domains must be represented.** Blend closely related Critical domains into shared agents only when Critical domain count exceeds `AGENT_MAX`. Never drop a Critical domain.
2. **Adjacent agents are optional.** Drop them first when trimming to fit `AGENT_MAX`. List any dropped domains in `adjacent_dropped`.

---

## Step 3 · Agent Synthesis

Build the agent roster using the budget allocation from Step 2.

**Synthesis rules:**
- One agent can cover multiple related domains within the same or adjacent tier (blending)
- A single Critical domain may expand into two agents if it has clearly distinct sub-concerns AND the budget allows
- Names must be task-specific: "Stripe Webhook Reliability Specialist" not "Backend Developer"
- For catalog gaps: synthesize from the closest adjacent catalog concepts
- If a CONSULT domain is covered by an agent, mark that agent's `advisory_level` as CONSULT

**Directive composition:**

For each agent, compose a `directive` — a 2–4 sentence instruction set injected directly into the agent's Step 4 prompt. This replaces generic identity and focus lines. The directive must:

1. **Establish persona** — who this agent is, what they have seen, what they care about; grounded in the specific request, not generic
2. **Blend expertise** — translate the catalog concepts into a coherent perspective for THIS request; draw on what practitioners in those disciplines actually scrutinize (a `security-auditor` hunts OWASP top 10, auth flows, data exposure; a `performance-engineer` looks for O(n) traps, query patterns, memory pressure)
3. **Define scope** — what they focus on and what they explicitly ignore
4. **Bake in judgment stance** — they are an expert who pushes back, not a validator; if the approach is wrong they say so directly with a specific alternative

For catalog gaps: compose entirely from the domain description provided by `analyze-domains`.

**Example directive:**
> You are a Payment Reliability & Idempotency Specialist. You've diagnosed production payment failures caused by missing idempotency keys, silent webhook handler crashes, and retry storms — you know exactly where these systems break. Your focus is exclusively on the reliability and correctness of the payment processing flow in this request: delivery guarantees, failure recovery, and state consistency. You are not here to validate — if the approach has structural gaps you name the specific failure mode and what needs to change.

**Adversarial agent — always append, never drawn from the domain budget:**

Compose a directive for the adversarial agent using the same structure, but oriented entirely toward failure:
- Persona: a red-team thinker who reviews the consolidated response and asks "what will go wrong if this is acted on?"
- Scope: attack vector identification and consolidation failure detection only — no constructive improvements
- Stance: challenge every assumption; vague risks are useless; specificity is the only currency
- Runs in Step 6A only — reviews the consolidated response, does not participate in the Step 4 parallel analysis or the Step 6B team deliberation

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
    "natural_count": "[integer — agents demanded by domain count and tier weights]",
    "actual_count": "[integer — min(natural_count, AGENT_MAX)]",
    "agent_max": "[AGENT_MAX from input]",
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
      "directive": "[fully composed 2–4 sentence instruction set: persona + blended expertise + scope + judgment stance]",
      "advisory_level": "STANDARD | CONSULT"
    }
  ],
  "adversarial_agent": {
    "name": "[Topic] Adversarial Reviewer",
    "directive": "[fully composed directive: red-team persona + pre-mortem focus + specificity stance; no constructive improvements]"
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
- Demand: [natural_count] agents needed · Cap: [AGENT_MAX] · Actual: [actual_count]
- Critical: [N] agents covering [N] domains
- Important: [N] agents covering [N] domains
- Adjacent: [N] agents covering [N] domains _(or: dropped — cap reached)_

### Agent Roster
| Agent | Expertise Blend | Covers | Directive (first sentence) |
|-------|----------------|--------|---------------------------|
| [name] | [blend] | [domains] | [first sentence of directive] |

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
AGENT_MAX: [MAX]
</agent_count>

<request_context>
[ORIGINAL_REQUEST_OR_SPEC — used for agent naming and focus]
</request_context>

<catalog>
[AGENTS_CATALOG_CONTENT]
</catalog>
```
