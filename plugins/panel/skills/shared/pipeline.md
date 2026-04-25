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
- `AGENT_MIN` / `AGENT_MAX` — domain agent count range (the adversarial agent is always additional)
- `TIER_NAME` — ask | panel | council
- `DEPTH_INSTRUCTION` — per-tier instruction injected into every domain agent prompt

**Writing effective DEPTH_INSTRUCTION:** Use scoped enumeration ("cover the 3 most significant concerns") or token budgets ("use ~200 tokens") — not sentence counts ("be thorough in 3–5 sentences"), which produce padding rather than depth.

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

Also note the **Advisory Level** for each domain:
- **STANDARD** — model-generated analysis is appropriate; no structural caveat required
- **CONSULT** — domain (e.g., legal, financial, compliance, ethics) requires qualified professional judgment; model analysis should not substitute for it

**Output — Step 2:**
```
| Domain | Catalog Coverage | Status | Advisory Level |
|--------|-----------------|--------|----------------|
| [domain] | [catalog concept(s)] | Covered / Partial / Gap | STANDARD / CONSULT |
```

If any CONSULT-level domain is present, inject this advisory note at the top of Step 5 output (naming the specific domains):
> **Advisory note:** This analysis includes CONSULT-level domain(s): [list]. Model-generated analysis should not substitute for qualified professional judgment in these areas.

---

## Step 3 · Dynamic Agent Synthesis

Build **`AGENT_MIN`–`AGENT_MAX`** domain agents, plus **one adversarial agent** (always included, regardless of tier or agent count).

**Domain agent synthesis rules:**
- Closely related or overlapping domains → consolidate into one blended agent
- Domains with catalog gaps → synthesize from adjacent catalog concepts; explicitly name the gap in the agent's task focus
- Give every agent a task-specific name, not a generic role title ("Stripe Webhook Reliability Specialist" not "Backend Developer")
- Lower tiers: consolidate aggressively. Higher tiers: be granular — one domain can split into multiple focused agents.

**Adversarial agent (always include one):**
- Name: `[Topic] Adversarial Reviewer`
- Mode: blind in Step 4, sighted in Step 6
- Focus: pre-mortem failure analysis and red-team thinking
- Schema: distinct from domain agents — uses attack_vectors / steelman_defense / verdict (see Step 4 adversarial prompt)

For each domain agent, define:
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

Adversarial agent: [Topic] Adversarial Reviewer (blind in Step 4 → sighted in Step 6)
```

---

## Step 4 · Parallel Agent Analysis

Spawn all domain agents **and the adversarial agent simultaneously** (see orchestrator instructions). Wait for all responses before proceeding.

If an agent returns malformed output or fails: note the failure in Step 4 output, mark that domain as "unanalyzed", flag the coverage gap in Step 5, and continue. A single agent failure must not block the pipeline.

### Domain agent prompt

Use this prompt for each domain agent (substitute all bracketed values from Steps 0 and 3):

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

<expert_judgment>
You are an expert, not a yes-man. If the proposed approach is fundamentally flawed, unmaintainable, the wrong tool for the job, or will create problems the user hasn't anticipated — say so directly. Your value comes from honest expert perspective, not from validating whatever is asked. A well-placed disagreement or course-correction is more valuable than polished endorsement of a bad path.

When you disagree with the direction itself (not just implementation details), surface it as a critical or important item. Be specific: what is wrong, why it matters, and what a better path looks like.
</expert_judgment>

<depth_instruction>
[DEPTH_INSTRUCTION]
</depth_instruction>

Return a JSON block inside <agent_analysis> tags. You may include a brief <thinking> block before the JSON.

**Priority levels:**
- `critical` — must be addressed; skipping causes failure, a security issue, or blocks progress entirely
- `important` — should be addressed; skipping creates meaningful risk or lost value but won't necessarily block
- `nice_to_have` — worth doing if time allows; low impact if deferred

**Type labels:**
- `risk` — something that could cause failure or significant harm if not mitigated
- `preserve` — an existing behavior, pattern, or constraint that must not be broken
- `recommendation` — an actionable improvement or best practice
- `question` — a decision or unknown that needs resolution

Omit any priority level your domain has nothing to contribute to. `assumptions` is always outside priority categorization.

<agent_analysis>
{
  "agent": "[NAME]",
  "domain": "[one-line description of your focus]",
  "assumptions": [
    "What you assumed about the request to proceed — omit field if none"
  ],
  "critical": [
    {
      "type": "risk | preserve | recommendation | question",
      "point": "Must be addressed — skipping causes failure, a security issue, or blocks progress entirely"
    }
  ],
  "important": [
    {
      "type": "risk | preserve | recommendation | question",
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
```

### Adversarial agent prompt (blind phase)

Use this distinct prompt for the adversarial agent in Step 4:

```
<project_context>
[STEP_0_CONTEXT_SUMMARY]
</project_context>

<request>
[ORIGINAL_REQUEST]
</request>

You are a [TOPIC] Adversarial Reviewer. Your role is to find failure modes — not to endorse the approach.

<focus>
Pre-mortem analysis: assume this plan was implemented exactly as described and produced a bad outcome. What went wrong?
Red team: if you were trying to defeat, circumvent, or cause this approach to fail, how would you do it?
Do NOT offer constructive improvements — only identify failure modes, vulnerabilities, and unconsidered paths.
</focus>

<expert_judgment>
You are the adversarial voice in this analysis. Challenge every assumption. Be specific and concrete — vague risks are not useful. Your value is in surfacing what others miss or avoid saying.
</expert_judgment>

Return a JSON block inside <agent_analysis> tags using the adversarial schema below — NOT the standard domain agent schema.

<agent_analysis>
{
  "agent": "[TOPIC] Adversarial Reviewer",
  "mode": "blind",
  "attack_vectors": [
    {
      "severity": "critical | important",
      "vector": "Specific failure mode, vulnerability, or path to a bad outcome"
    }
  ],
  "steelman_defense": [
    "The strongest argument in favor of this approach that you must acknowledge honestly"
  ],
  "verdict": "fatal | severe | manageable | sound",
  "verdict_reason": "One sentence: what makes this approach fundamentally strong or weak?"
}
</agent_analysis>
```

### Few-shot examples — what good domain agent analysis looks like

<examples>
<example>
Request: We want to build our own authentication system from scratch for our Next.js app rather than use a third-party provider.

Agent: Authentication Architecture Specialist (expertise: nextjs-specialist, backend-developer, security-auditor)

<thinking>
The user has made a direction decision I disagree with. Rolling custom auth is almost always the wrong call for a Next.js app — it's expensive to build, expensive to maintain, and the failure modes are severe. I should say so clearly rather than just helping them do it well.
</thinking>
<agent_analysis>
{
  "agent": "Authentication Architecture Specialist",
  "domain": "Authentication implementation strategy and security architecture for Next.js",
  "critical": [
    { "type": "risk", "point": "Rolling custom auth from scratch is the wrong call for most Next.js applications. Auth is deceptively complex — token rotation, session fixation, credential stuffing, MFA, account recovery, and compliance edge cases take months to get right. A breach or missed edge case has severe consequences. Established providers (NextAuth.js, Auth0, Clerk) have solved these problems under production load." },
    { "type": "recommendation", "point": "Use NextAuth.js (Auth.js) instead — it is purpose-built for Next.js, open source, and handles the full auth lifecycle including OAuth, credentials, JWTs, and database sessions. Custom auth should only be considered if you have compliance requirements that preclude third-party providers or highly unusual session semantics." }
  ],
  "important": [
    { "type": "risk", "point": "If you proceed with custom auth, the maintenance burden is permanent — every security advisory, OAuth spec change, and framework upgrade becomes your team's problem to track and patch." }
  ]
}
</agent_analysis>
</example>

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

### Rendering — Step 4

Parse each agent's JSON and render as readable markdown under a named subheading.

For domain agents:
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

For the adversarial agent:
```markdown
### [Topic] Adversarial Reviewer _(blind)_

**Attack Vectors:**
- `[severity]` [vector]

**Steelman Defense:**
- [point]

**Verdict:** [fatal | severe | manageable | sound] — [verdict_reason]
```

---

## Step 5 · Consolidation

Merge all domain agent outputs into a **sequenced action plan** — an ordered list of concrete actions with dependencies, not a triage list grouped by severity.

**Consolidation rules:**
1. **Identify actionable items**: From all agents' critical and important outputs, extract discrete actions (recommendations that specify a concrete step, and risks that require a specific mitigation). These become action plan steps.
2. **Identify informational items**: Risks and preserves that inform execution but don't map to a single discrete action — these become "Risks to Monitor."
3. **Sequence by dependency**: Order actions by: (a) prerequisites — what must exist before this can proceed; (b) reversibility — irreversible actions later where possible; (c) priority — critical-sourced items before important-sourced items when ordering is otherwise ambiguous.
4. **Deduplicate across agents**: Merge identical or near-identical concerns; note all source agents.
5. **Preserve disagreements as tradeoffs**: Where agents disagree on approach or priority, surface both sides as a tradeoff — do not silently resolve.
6. **Verify coverage**: Confirm every Step 1 domain is represented; flag any gaps.
7. **Integrate adversarial findings**: Include the adversarial agent's attack vectors in "Risks to Monitor" or as specific action items if active mitigation is required.

**Output — Step 5:**

_If any CONSULT-level domain was identified in Step 2, inject this advisory note first:_
> **Advisory note:** This analysis includes CONSULT-level domain(s): [list]. Model-generated analysis should not substitute for qualified professional judgment in these areas.

```markdown
### Action Plan

| Step | Action | Prerequisites | Domain(s) | Reversible |
|------|--------|---------------|-----------|------------|
| 1 | [concrete action] | none | [domain] | yes |
| 2 | [concrete action] | step 1 | [domain] | yes |

### Risks to Monitor
- `risk` [concern] _(source: agent-a, agent-b)_

### Tradeoffs _(omit if none)_
| Topic | Option A | Option B | Recommendation |
|-------|----------|----------|----------------|

### Open Questions _(omit if none)_
- [Decision or unknown requiring resolution before or during execution] _(source: agent)_

### Coverage Gaps _(omit if none)_
- [Domain]: not addressed in plan
```

---

## Step 6 · Validation Round

Run three validation tracks **simultaneously**. Wait for all responses before proceeding.

### Track A — Naive Plan Reviewer

A fresh-prompt subagent with **no access to Step 4 agent analyses**. Checks whether the plan achieves the original request from an independent perspective.

```
<request>
[ORIGINAL_REQUEST]
</request>

<plan>
[STEP_5_OUTPUT]
</plan>

You are reviewing a plan produced by a multi-agent analysis system. You have NOT seen the agents' analyses — only the original request and the final plan.

**Do NOT write any code, create any files, or take any action. Return only the <validation> JSON block below.**

Evaluate: Does this plan actually achieve what was requested? Is anything the user asked for missing? Is anything in the plan disconnected from the request?

Return a JSON block inside <validation> tags:

<validation>
{
  "reviewer": "Naive Plan Reviewer",
  "gaps": ["Things the user asked for that the plan does not address — omit if none"],
  "additions": ["Things in the plan not connected to the request — omit if none"],
  "rating": "green | yellow | red",
  "type": "deficiency | scope_change",
  "reason": "Required if yellow or red — name the specific gap or addition"
}
</validation>

Omit `gaps`, `additions`, and `type` if none.
```

### Track B — Scope-only domain agents

Original Step 4 domain agents re-prompted to check scope change only. The intent check from the old Step 6 is replaced by the Naive Plan Reviewer — domain agents no longer re-validate their own intent.

```
<request>
[ORIGINAL_REQUEST]
</request>

<consolidated_plan>
[STEP_5_OUTPUT]
</consolidated_plan>

You are a [NAME] with expertise in [EXPERTISE_BLEND].

**Do NOT write any code, create any files, or take any action. Return only the <validation> JSON block below.**

Perform ONE check only:

**Scope check:** Does the consolidated plan introduce material new scope that was not present in the original request? If yes — would that new scope change your domain's analysis significantly enough that your prior analysis is incomplete or wrong?

Return a JSON block inside <validation> tags:

<validation>
{
  "agent": "[NAME]",
  "rating": "green | red",
  "type": "scope_change",
  "reason": "Required if red — describe the new scope and why it invalidates your prior analysis"
}
</validation>

Rating must be green or red/scope_change only. Omit `type` if green.
```

### Track C — Sighted adversarial agent

The adversarial agent from Step 4, now with full visibility of all agent analyses and the consolidated plan.

```
<request>
[ORIGINAL_REQUEST]
</request>

<your_blind_analysis>
[ADVERSARIAL AGENT'S STEP 4 JSON OUTPUT]
</your_blind_analysis>

<all_agent_analyses>
[ALL STEP 4 DOMAIN AGENT JSON OUTPUTS]
</all_agent_analyses>

<consolidated_plan>
[STEP_5_OUTPUT]
</consolidated_plan>

You are the [TOPIC] Adversarial Reviewer. In Step 4, you analyzed this request blind. You now have full visibility of all agent analyses and the consolidated plan.

**Do NOT write any code, create any files, or take any action. Return only the <validation> JSON block below.**

Review adversarially:
1. Were your blind attack vectors addressed in the plan, dismissed, or ignored?
2. Do you see new failure modes now that you can see the full picture?
3. Does the plan's sequencing introduce risk (wrong ordering, missing prerequisites)?
4. Were critical concerns from other agents lost or distorted in consolidation?

Return a JSON block inside <validation> tags:

<validation>
{
  "agent": "[TOPIC] Adversarial Reviewer",
  "mode": "sighted",
  "unresolved_vectors": ["Vectors from blind analysis not addressed by the plan — omit if none"],
  "new_vectors": ["New failure modes visible after seeing the full picture — omit if none"],
  "consolidation_distortions": ["Concerns present in agents but lost or undermined in consolidation — omit if none"],
  "rating": "green | yellow | red",
  "type": "deficiency | scope_change",
  "reason": "Required if yellow or red"
}
</validation>

Omit `type` if green.
```

**Rating definitions:**
- 🟢 **Green** — no material gaps, scope changes, or unaddressed failure modes
- 🟡 **Yellow** — non-critical gaps, minor distortions, or manageable failure modes not addressed
- 🔴 **Red (deficiency)** — critical gap, key concern missing or intent undermined, or fatal/severe attack vectors unaddressed
- 🔴 **Red (scope_change)** — consolidated plan introduced material new scope that invalidates prior analysis

**Overall status:**
- All green → **PASS**
- Any yellow, no red → **REVIEW**
- Any red (deficiency only) → **RERUN**
- Any red (scope_change) → **RESCOPE**

**RERUN-DELTA:** On RERUN, only re-spawn domain agents whose domains had red deficiencies plus the adversarial agent. Do not re-run all agents when only a subset had issues.

**Output — Step 6:**
```
| Track | Agent / Reviewer | Rating | Type | Reason |
|-------|-----------------|--------|------|--------|
| A — Naive | Naive Plan Reviewer | 🟢 | — | — |
| B — Scope | [Agent Name] | 🟢 | — | — |
| C — Adversarial | [Topic] Adversarial Reviewer | 🟡 | deficiency | [reason] |

Overall: PASS | REVIEW | RERUN | RESCOPE
```

---

## Step 7 · Final Output

Present the run **result-first**: the Result section appears at the top before the analysis detail. Use the tier-specific template for the Result section, then render all steps (0–6) after the `---` divider.

**The Result section is always the first thing the user sees.** Status, plan, and caveats come before agent analyses. This applies to all four status paths (PASS, REVIEW, RERUN, RESCOPE).

---

### /ask output template

Result section target: ~200 words. Action list only — no agent attribution, no tradeoffs table.

```markdown
# /ask: [one-line task summary]

## Result
**Status: [STATUS emoji + word]**

[If REVIEW — one-line caution per concern, inline]

1. [Action]
2. [Action]
3. [Action]

_This analysis reflects a single model's perspective — validate independently before acting._

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
[Step 4 rendered output — each agent under its own subheading]

### Step 5 · Consolidated Plan
[Step 5 output]

### Step 6 · Validation
[Step 6 table + overall status]
```

---

### /panel output template

Result section target: ~400–600 words. Sequenced plan with tradeoffs. One-paragraph epistemic caveat.

```markdown
# /panel: [one-line task summary]

## Result
**Status: [STATUS emoji + word]**

[If REVIEW:]
**Cautions noted — proceed with awareness:**
| Agent / Reviewer | Concern |
|-----------------|---------|
| [Name] | [yellow reason] |

### Action Plan
[Sequenced action plan — table or numbered list with prerequisites]

### Tradeoffs _(omit if none)_
[Tradeoffs table]

> **Note on independence:** All agents in this analysis share the same underlying model weights. They can surface different concerns but cannot provide genuinely independent validation. For decisions with significant consequences, seek qualified domain expert review.

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
[Step 4 rendered output — each agent under its own subheading]

### Step 5 · Consolidated Plan
[Step 5 output]

### Step 6 · Validation
[Step 6 table + overall status]
```

---

### /council output template

Result section: full document. Dedicated Confidence & Limitations section. Architecture decision rationale. All steps shown in full.

```markdown
# /council: [one-line task summary]

## Result
**Status: [STATUS emoji + word]**

[If REVIEW:]
**Cautions noted — proceed with awareness:**
| Agent / Reviewer | Concern |
|-----------------|---------|
| [Name] | [yellow reason] |

### Action Plan
[Full sequenced action plan table]

### Tradeoffs
[Full tradeoffs table]

### Open Questions
[Open questions list]

### Confidence & Limitations
All agents in this analysis share the same model weights and training data. Consensus across agents reflects consistency, not independence — they can identify different concerns but cannot provide genuinely independent validation.

[If CONSULT domains were identified in Step 2:]
**Domains requiring professional review:** [list]
This analysis should inform but not replace qualified professional judgment for these areas.

For high-stakes decisions, treat this analysis as structured preparation for — not a substitute for — expert review.

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
[Step 4 rendered output — each agent under its own subheading]

### Step 5 · Consolidated Plan
[Step 5 output]

### Step 6 · Validation
[Step 6 table + overall status]
```

---

### Status-specific Result content

These slots apply within the tier templates above.

**If PASS:** Render the action plan and epistemic caveat only. No additional notes needed.

**If REVIEW:** Add the caution table before the action plan (as shown in the templates). Plan is sound; proceed with awareness of flagged items.

**If RERUN:** Replace the action plan with:

```markdown
## Result
**Status: 🔴 RERUN**

The following critical concerns were not adequately addressed. Resolve before executing:

| Agent / Reviewer | Unresolved Issue |
|-----------------|-----------------|
| [Name] | [red reason] |

Resolve:
- [ ] [Specific action addressing concern 1]
- [ ] [Specific action addressing concern 2]

**Re-run (RERUN-DELTA — only deficient domains + adversarial):**
Tier: [same tier, or escalate to `/council` if multiple red flags or systemic issues]
Re-run scope: agents covering [list of deficient domains] + adversarial agent
Prompt addition: "[specific context or constraint to add]"
```

**If RESCOPE:** Replace the action plan with:

```markdown
## Result
**Status: 🔴 RESCOPE**

The consolidated plan introduced scope not present in the original request. Prior analyses are incomplete for the expanded scope — do not patch.

| Agent / Reviewer | Scope Change Identified |
|-----------------|------------------------|
| [Name] | [what new scope appeared and why it invalidates prior analysis] |

Use the revised prompt below for a full pipeline re-run:

---
[COMPLETE REVISED PROMPT — drafted in full by the orchestrator, incorporating both the original request and the new scope, ready to paste as-is]
---

Tier: [same tier or escalate if expanded scope increases complexity]
```

---

This pipeline produces analysis only.
