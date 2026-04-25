# Orchestration Pipeline

Shared algorithm for `/ask`, `/panel`, and `/council`. Each skill defines its tier parameters; this pipeline executes identically across all three.

## Contents
- [Tier Parameters](#tier-parameters)
- [Orchestrator Instructions](#orchestrator-instructions)
- [Pre-flight: Complexity & Ambiguity Check](#pre-flight--complexity--ambiguity-check)
- [Step 0: Context Gathering](#step-0--context-gathering)
- [Step 1: Domain Identification](#step-1--domain-identification)
- [Step 2: Coverage Check](#step-2--coverage-check)
- [Step 3: Dynamic Agent Synthesis](#step-3--dynamic-agent-synthesis)
- [Step 4: Parallel Agent Analysis](#step-4--parallel-agent-analysis)
- [Step 5: Consolidation](#step-5--consolidation)
- [Step 6: Validation Round](#step-6--validation-round)
- [Step 7: Final Output](#step-7--final-output)

---

## Tier Parameters

Injected by the calling skill:
- `DOMAIN_COUNT` — how many top domains to identify
- `AGENT_MIN` / `AGENT_MAX` — agent count range
- `TIER_NAME` — ask | panel | council
- `DEPTH_INSTRUCTION` — per-tier instruction injected into every agent prompt

Agent responses are structured by **priority level** — critical, important, nice-to-have — with each item carrying a **type** label describing its nature. Assumptions are collected separately, outside priority categorization.

---

## Orchestrator Instructions

<use_parallel_tool_calls>
When spawning agents in Steps 4 and 6, launch ALL agents simultaneously in a single response. Never wait for one agent to complete before spawning the next. Independent agent calls must always run in parallel.
</use_parallel_tool_calls>

---

## Pre-flight · Complexity & Ambiguity Check

Before running the pipeline, apply two gates in order:

**Gate 1 — Complexity check:** Would a single direct response serve this request better than multi-agent analysis? If the request is a simple factual question, a quick definition, a one-line fix, or anything that doesn't benefit from multiple domain perspectives — answer it directly. Skip the pipeline entirely.

**Gate 2 — Ambiguity check:** Can you identify at least 2 meaningful domains from this request as written?
- **Yes** → proceed to Step 0
- **No** → ask the user 2–3 targeted clarifying questions. Do not proceed until answered. Triggers: "make it better", "fix the thing", "help with my project", no subject matter identifiable.

If the request is directionally clear but missing some details, proceed and state your assumptions explicitly at the top of Step 1 output.

---

## Step 0 · Context Gathering

Gather available project context before identifying domains. This prevents agents from analyzing in a vacuum.

1. **Check for CLAUDE.md** — if it exists, read it. Extract: tech stack, conventions, constraints, relevant project context.
2. **Check for spec or docs** — look for `spec/`, `docs/`, `README.md`. Read any directly relevant to the request.
3. **Check for stack signals** — look for `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `*.csproj`, or equivalent. Extract the stack if identifiable.
4. **If no project files exist** — note "no project context available" and proceed.

Produce a brief context summary (3–6 sentences max) appended to every agent prompt.

**Output — Step 0:**
```
## Project Context
[Summary of what was found, or "No project context available."]
Stack: [identified stack or "unknown"]
Constraints: [any relevant constraints from CLAUDE.md or specs]
```

---

## Step 1 · Domain Identification

Using the request and project context from Step 0, identify every domain, discipline, or perspective that could offer meaningful insight. Cast wide — do not limit to technical domains.

Consider:
- **Subject matter** — what is this actually about? (software, business, marketing, legal, design, operations, finance, UX, security, data, etc.)
- **Stakeholder perspectives** — who is affected? (users, developers, operators, executives, customers, regulators, etc.)
- **Risk dimensions** — what could go wrong? (technical, business, compliance, reputational, operational)
- **Outcome dimensions** — what does success require? (correctness, adoption, revenue, safety, maintainability, speed, etc.)

Rank all identified domains by relevance. Take the top **`DOMAIN_COUNT`**.

Also surface any **assumptions** made to proceed (where the request was underspecified) and any **ambiguities** that could materially change the analysis if resolved differently.

**Output — Step 1:**
```
Identified domains (ranked):
1. [Domain] — [one sentence: why it's relevant to this request]
2. [Domain] — [one sentence]
...

Assumptions:
- [Any assumption made to proceed — what was assumed and why]

Ambiguities:
- [Any open question where different answers would lead to materially different analysis]
```

---

## Step 2 · Coverage Check

Open [agents-catalog.md](agents-catalog.md). For each identified domain, check whether catalog expertise exists that covers it.

For each domain:
- **Covered** — one or more catalog concepts map directly
- **Partial** — catalog has adjacent territory but not a direct match
- **Gap** — no catalog concept covers this domain (will need a fully synthesized agent)

Ignore catalog concepts irrelevant to the request type (e.g. language specialists for a pure business strategy question).

**Output — Step 2:**
```
| Domain | Catalog Coverage | Status |
|--------|-----------------|--------|
| [domain] | [catalog concept(s)] | Covered / Partial / Gap |
```

---

## Step 3 · Dynamic Agent Synthesis

Build **`AGENT_MIN`–`AGENT_MAX`** agents ensuring every identified domain has representation.

**Synthesis rules:**
- Closely related or overlapping domains → consolidate into one blended agent
- Domains with catalog gaps → synthesize from adjacent catalog concepts; explicitly name the gap in the agent's task focus
- Give every agent a task-specific name, not a generic role title ("Stripe Webhook Reliability Specialist" not "Backend Developer")
- Lower tiers: consolidate aggressively. Higher tiers: be granular — one domain can split into multiple focused agents.

For each synthesized agent, define:
```
Name: [task-specific title]
Expertise blend: [catalog concepts drawn from, or "synthesized: [domain]" for gaps]
Covers: [which Step 1 domains]
Focus: [what specific aspect of THIS request this agent analyzes]
```

**Output — Step 3:**
```
| Agent | Expertise Blend | Covers | Focus |
|-------|----------------|--------|-------|
```

---

## Step 4 · Parallel Agent Analysis

Spawn all synthesized agents **simultaneously** (see orchestrator instructions above). Wait for all responses before proceeding.

If an agent returns malformed output or fails: note the failure in Step 4 output, mark that agent's domain as "unanalyzed", flag the coverage gap in Step 5, and continue with remaining agents. A single agent failure must not block the pipeline.

Use this prompt for each agent (substitute all bracketed values from Step 0 and Step 3):

```
<project_context>
[STEP_0_CONTEXT_SUMMARY]
</project_context>

<request>
[ORIGINAL_REQUEST]
</request>

You are a [NAME] with expertise in [EXPERTISE_BLEND].

<focus>
Analyze the request from the perspective of [FOCUS] only.
Focus strictly on what your domain sees, requires, and would own.
</focus>

<depth_instruction>
[DEPTH_INSTRUCTION]
</depth_instruction>

You may include a brief <thinking> block to show your reasoning before the JSON — this is optional but helpful.

Return a JSON block inside <agent_analysis> tags:

<agent_analysis>
{
  "agent": "[NAME]",
  "domain": "[one-line description of your focus]",
  "assumptions": [
    "What you assumed about the request to proceed — omit field if none"
  ],
  "critical": [
    {
      "type": "blocker | risk | preserve | recommendation | question",
      "point": "Must be addressed — skipping causes failure, a security issue, or blocks progress entirely"
    }
  ],
  "important": [
    {
      "type": "blocker | risk | preserve | recommendation | question",
      "point": "Should be addressed — skipping creates meaningful risk or lost value"
    }
  ],
  "nice_to_have": [
    {
      "type": "recommendation | question",
      "point": "Worth doing if time allows — low impact if deferred"
    }
  ]
}
</agent_analysis>

**Priority levels:**
- `critical` — must be addressed; skipping causes failure, a security issue, or blocks progress entirely
- `important` — should be addressed; skipping creates meaningful risk or lost value but won't necessarily block
- `nice_to_have` — worth doing if time allows; low impact if deferred

**Type labels:**
- `blocker` — a prerequisite that must be resolved before work can proceed
- `risk` — something that could cause failure or significant harm if not mitigated
- `preserve` — an existing behavior, pattern, or constraint that must not be broken
- `recommendation` — an actionable improvement or best practice
- `question` — a decision or unknown that needs resolution

Omit any priority level your domain has nothing to contribute to. `assumptions` is always outside priority categorization.
```

**Few-shot examples — what good agent analysis looks like:**

<examples>
<example>
Request: Build a JWT authentication system for a Next.js application.

Agent: JWT Implementation Specialist (expertise: nextjs-specialist, backend-developer, security-auditor)

<thinking>
Token storage is the most critical issue — localStorage is the common mistake and it's a hard security flaw, not a preference. The refresh flow is important but won't block launch if deferred carefully. Using next-auth is a nice-to-have optimization.
</thinking>
<agent_analysis>
{
  "agent": "JWT Implementation Specialist",
  "domain": "Token-based authentication implementation in Next.js",
  "critical": [
    { "type": "risk", "point": "Storing JWT in localStorage exposes tokens to XSS attacks — httpOnly, Secure, SameSite=Strict cookies are the only safe default" }
  ],
  "important": [
    { "type": "risk", "point": "Without a token refresh mechanism, users will be silently logged out when tokens expire" },
    { "type": "recommendation", "point": "Implement a /api/auth/refresh endpoint with silent refresh logic triggered before expiry" },
    { "type": "question", "point": "What is the desired session duration — short-lived tokens with refresh, or long-lived single tokens?" }
  ],
  "nice_to_have": [
    { "type": "recommendation", "point": "Use next-auth rather than rolling custom token logic — it handles edge cases that are easy to miss" }
  ]
}
</agent_analysis>
</example>

<example>
Request: Build a JWT authentication system for a Next.js application.

Agent: User Experience & Conversion Specialist (expertise: ux-researcher, product-manager)

<thinking>
The technical team will handle token mechanics. My domain is user-facing flow — login friction, error clarity, session UX. Vague error messages are an important issue that drives real support cost. Social login and remember-me are lower priority.
</thinking>
<agent_analysis>
{
  "agent": "User Experience & Conversion Specialist",
  "domain": "User-facing authentication flow, friction, and conversion impact",
  "important": [
    { "type": "risk", "point": "Generic error messages like 'invalid credentials' frustrate users and increase support load — distinguish wrong password, account not found, and account locked" },
    { "type": "risk", "point": "Aggressive session timeouts increase re-login friction and measurably hurt retention" },
    { "type": "recommendation", "point": "Surface the forgotten password link prominently before users hit frustration — not hidden below the form" }
  ],
  "nice_to_have": [
    { "type": "recommendation", "point": "Offer a 'remember me' option that extends session duration for returning users on trusted devices" },
    { "type": "question", "point": "Is social login (Google / GitHub) in scope for this release or deferred?" },
    { "type": "question", "point": "Should enterprise accounts have stricter session policies than individual users?" }
  ]
}
</agent_analysis>
</example>
</examples>

**Rendering — Step 4:**
Parse each agent's JSON and render as readable markdown under a named subheading:

```markdown
### [Agent Name]
**Domain:** [domain]

**Assumptions:** _(omit section if none)_
- [assumption]

**Critical** _(omit section if none)_
- `[type]` [point]

**Important** _(omit section if none)_
- `[type]` [point]

**Nice to have** _(omit section if none)_
- `[type]` [point]
```

---

## Step 5 · Consolidation

Merge all Step 4 outputs into a single coherent plan.

1. **Deduplicate** — merge identical or near-identical concerns across agents, noting all sources
2. **Respect priority** — preserve each item at its highest assigned level across agents; never silently downgrade a critical item
3. **Preserve disagreements** — where agents assign different priorities to the same concern, surface both as a tradeoff; do not silently resolve
4. **Ordering within levels** — within Critical: blockers first, then risks, then preserves; within Important and Nice to have: recommendations and questions after risks and preserves
5. **Coverage check** — verify every Step 1 domain appears somewhere in the plan; flag any that don't (including domains from agents that failed in Step 4)

**Output — Step 5:**
```markdown
### Assumptions & Ambiguity
- [Assumption or ambiguity that could change the analysis] _(agent)_

_(Omit section if none)_

### Critical
- `[type]` [Point] _(sources: agent-a, agent-b)_

### Important
- `[type]` [Point] _(agent)_

### Nice to Have
- `[type]` [Point] _(agent)_

### Tradeoffs
| Topic | Option A | Option B | Recommendation |
|-------|----------|----------|----------------|

### Coverage gaps _(if any Step 1 domains are unrepresented)_
- [Domain]: not addressed in plan
```

---

## Step 6 · Validation Round

Spawn all agents **simultaneously** for a rating pass. Each agent receives the original request, the consolidated plan, and their own Step 4 analysis — so they can check whether their specific concerns were addressed.

Use this prompt for each agent:

```
<request>
[ORIGINAL_REQUEST]
</request>

<your_previous_analysis>
[THIS_AGENT'S_FULL_STEP_4_JSON_OUTPUT]
</your_previous_analysis>

<consolidated_plan>
[STEP_5_OUTPUT]
</consolidated_plan>

You are a [NAME] with expertise in [EXPERTISE_BLEND].

Review the consolidated plan from your domain's perspective only.
Check whether your critical items were addressed, your important concerns acknowledged, and your recommendations reflected.

Return a JSON block inside <validation> tags:

<validation>
{
  "agent": "[NAME]",
  "rating": "green|yellow|red",
  "reason": "Required if yellow or red — one sentence. Yellow: concerns present but plan is broadly usable. Red: a blocker or critical gap was not addressed and proceeding risks real harm."
}
</validation>
```

**Few-shot examples — what good validation looks like:**

<examples>
<example>
Scenario: Validating a consolidated plan for the JWT authentication system above.

Green — all concerns addressed:
<validation>
{ "agent": "JWT Implementation Specialist", "rating": "green", "reason": null }
</validation>

Yellow — minor gap remains:
<validation>
{ "agent": "User Experience & Conversion Specialist", "rating": "yellow", "reason": "Silent token refresh wasn't included in the plan — users will see unexpected session timeouts at launch." }
</validation>

Red — blocker was not addressed:
<validation>
{ "agent": "Security Specialist", "rating": "red", "reason": "My blocker about httpOnly cookies was not addressed — the plan still references localStorage for token storage, which is a launch-blocking security flaw." }
</validation>
</example>
</examples>

**Rating definitions:**
- 🟢 **Green** — domain concerns are adequately addressed; proceed with confidence
- 🟡 **Yellow** — minor gaps or unresolved questions remain; proceed with caution
- 🔴 **Red** — a critical item from this agent's Step 4 was not addressed in the plan

**Overall status:**
- All green → **PASS**
- Any yellow, no red → **REVIEW**
- Any red → **RERUN**

**Output — Step 6:**
```
| Agent | Rating | Reason |
|-------|--------|--------|
| [Name] | 🟢 | — |
| [Name] | 🟡 | [reason] |
| [Name] | 🔴 | [reason] |

Overall: PASS | REVIEW | RERUN
```

---

## Step 7 · Final Output

Present the complete run to the user. Include every step.

```markdown
# /[TIER_NAME]: [one-line task summary]

## Step 0 · Context
[Step 0 output]

## Step 1 · Domains
[Step 1 output]

## Step 2 · Coverage
[Step 2 output]

## Step 3 · Agents
[Step 3 output]

## Step 4 · Agent Analyses
[Step 4 rendered output — each agent under its own subheading]

## Step 5 · Consolidated Plan
[Step 5 output]

## Step 6 · Validation
[Step 6 table + overall status]

---

## Result
```

**If PASS:**
```markdown
**Status: ✅ PASS**
All agents satisfied with the plan. Proceed with confidence.

[Restate the Step 5 consolidated plan cleanly, without agent attribution noise]
```

**If REVIEW:**
```markdown
**Status: ⚠️ REVIEW**
Plan is sound — proceed with these cautions noted:

| Agent | Concern |
|-------|---------|
| [Name] | [yellow reason] |

[Restate the Step 5 consolidated plan]
```

**If RERUN:**
```markdown
**Status: 🔴 RERUN**
The following critical concerns were not addressed in the plan:

| Agent | Unresolved Issue |
|-------|-----------------|
| [Name] | [red reason] |

Before re-running, resolve:
- [ ] [Specific action addressing red concern 1]
- [ ] [Specific action addressing red concern 2]

Suggested re-run:
Tier: [same tier if concerns are targeted — escalate to `/council` if multiple red flags or systemic issues]
Add to your prompt: "[Draft the additional context or constraint that addresses the flagged concerns]"
```

This pipeline produces analysis only.
