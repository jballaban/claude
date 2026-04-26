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
- [Step 6: Adversarial Review](#step-6--adversarial-review)
- [Step 7: Team Deliberation](#step-7--team-deliberation)
- [Step 8: Final Output](#step-8--final-output)

---

## Tier Parameters

Injected by the calling skill:
- `DOMAIN_COUNT` — how many top domains to identify
- `AGENT_MAX` — maximum domain agents (the adversarial agent is always additional and does not count against this)
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

Spawn the `analyze-domains` skill as a **Sonnet subagent**, passing:
- The original request
- The project context summary from Step 0

`analyze-domains` returns a three-tiered domain list (up to 10 total):
- **Critical** — core to the scope; analysis is incomplete without coverage
- **Important** — highly relevant secondary domains; analysis is weaker without them
- **Adjacent** — may apply depending on scope; each carries a condition that would make it fully applicable

Use the `analyze-domains` output directly as Step 1's domain list. Do not re-rank or re-derive domains.

The full tiered list passes directly to `assemble-agents` in Steps 2–3, which enforces the agent budget. Do not filter or truncate domains here.

Also carry forward any **assumptions** or **ambiguities** surfaced by `analyze-domains`.

**Output — Step 1:**

Render the `analyze-domains` markdown output directly:

```markdown
## Domain Analysis

**Critical** _(must be covered)_
- **[domain]** — [rationale]

**Important** _(should be covered)_
- **[domain]** — [rationale]

**Adjacent** _(cover if scope confirms)_
- **[domain]** — [rationale] _(applies if: [condition])_
```

Then append:
```
Assumptions:
- [Any assumption made to proceed — what was assumed and why]

Ambiguities:
- [Any open question where different answers would lead to materially different analysis]
```

---

## Steps 2–3 · Agent Assembly

Read [agents-catalog.md](agents-catalog.md), then spawn the `assemble-agents` skill as a **Sonnet subagent**, passing:
- The tiered domain list from Step 1
- `AGENT_MAX` from tier parameters
- The original request (for agent naming and focus)
- The full catalog content just read

`assemble-agents` performs both catalog coverage mapping and agent synthesis in one pass, using tier-weighted budget allocation:
- **Critical domains** (weight 1.0) — must all be represented
- **Important domains** (weight 0.5) — should be represented; may be blended when constrained
- **Adjacent domains** (weight 0.25) — included only if agent budget allows after Critical and Important are covered

The subagent always appends one adversarial agent slot to the roster. The adversarial agent does not count against the domain budget — it is always additional.

If `assemble-agents` returns any `consult_domains`, carry the advisory note forward to Step 5 output:
> **Advisory note:** This analysis includes CONSULT-level domain(s): [list]. Model-generated analysis should not substitute for qualified professional judgment in these areas.

**Output — Steps 2–3:**

Render both parts of the `assemble-agents` output under separate labels in the Step 7 Analysis section:

```markdown
### Step 2 · Coverage
[coverage table from assemble-agents output]

### Step 3 · Agent Roster
[agent roster table + adversarial agent line from assemble-agents output]
```

---

## Step 4 · Parallel Agent Analysis

Spawn all **domain agents simultaneously** (see orchestrator instructions). Do NOT spawn the adversarial agent here — it runs in Step 6A with full visibility of the consolidated response.

Wait for all domain agent responses before proceeding.

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

[DIRECTIVE — the fully composed directive from the assemble-agents roster for this agent]

<depth_instruction>
[DEPTH_INSTRUCTION]
</depth_instruction>

**Do NOT write any code, create any files, or take any action. Return only the <agent_analysis> JSON block below.**

You may include a brief <thinking> block before the JSON.

**Priority levels:**
- `critical` — must be addressed; skipping causes failure, a security issue, or blocks progress entirely
- `important` — should be addressed; skipping creates meaningful risk or lost value but won't necessarily block
- `nice_to_have` — worth doing if time allows; low impact if deferred

Omit any priority level your domain has nothing to contribute to. `assumptions` is always outside priority categorization.

Each finding is a `point` (the concern or observation) with an optional `suggestion` (what to do about it). Omit `suggestion` only when the finding is a genuine unknown with no clear action yet.

<agent_analysis>
{
  "agent": "[NAME]",
  "domain": "[one-line description of your focus]",
  "assumptions": [
    "What you assumed about the request to proceed — omit field if none"
  ],
  "critical": [
    {
      "point": "Must be addressed — skipping causes failure, a security issue, or blocks progress entirely",
      "suggestion": "What to do about it — omit only if genuinely unresolved"
    }
  ],
  "important": [
    {
      "point": "Should be addressed — skipping creates meaningful risk or lost value",
      "suggestion": "What to do about it — omit only if genuinely unresolved"
    }
  ],
  "nice_to_have": [
    {
      "point": "Worth doing if time allows — low impact if deferred",
      "suggestion": "What to do about it — omit only if genuinely unresolved"
    }
  ]
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
    {
      "point": "Rolling custom auth from scratch is the wrong call for most Next.js applications. Auth is deceptively complex — token rotation, session fixation, credential stuffing, MFA, account recovery, and compliance edge cases take months to get right. A breach or missed edge case has severe consequences.",
      "suggestion": "Use NextAuth.js (Auth.js) instead — purpose-built for Next.js, open source, handles the full auth lifecycle including OAuth, credentials, JWTs, and database sessions. Only build custom if compliance requirements explicitly preclude third-party providers."
    }
  ],
  "important": [
    {
      "point": "If you proceed with custom auth, the maintenance burden is permanent — every security advisory, OAuth spec change, and framework upgrade becomes your team's problem to track and patch.",
      "suggestion": "Budget ongoing security maintenance as a line item before committing to custom auth; if that's not feasible, it's another argument for a provider."
    }
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
    {
      "point": "Storing JWT in localStorage exposes tokens to XSS attacks — any injected script can exfiltrate the token.",
      "suggestion": "Use httpOnly, Secure, SameSite=Strict cookies exclusively — this is not a preference, it's the only safe default."
    }
  ],
  "important": [
    {
      "point": "Without a token refresh mechanism, users are silently logged out when tokens expire, with no warning.",
      "suggestion": "Implement a /api/auth/refresh endpoint with silent refresh logic triggered before expiry — probe remaining TTL on each authenticated request."
    },
    {
      "point": "Session duration policy is unspecified — short-lived tokens with refresh and long-lived single tokens have very different security/UX tradeoffs."
    }
  ],
  "nice_to_have": [
    {
      "point": "Rolling custom token logic has well-known edge cases that are easy to miss.",
      "suggestion": "Use next-auth if the project hasn't committed deeply to custom — it handles rotation, storage, and provider integration out of the box."
    }
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
    {
      "point": "Generic error messages like 'invalid credentials' frustrate users and increase support volume — users can't self-serve if they don't know whether it's a wrong password, missing account, or locked state.",
      "suggestion": "Return distinct messages for wrong password, account not found, and account locked — each with a clear next action."
    },
    {
      "point": "Aggressive session timeouts increase re-login friction and measurably hurt retention, especially on low-frequency workflows.",
      "suggestion": "Calibrate timeout to actual usage patterns; offer session extension prompts rather than silent expiry."
    },
    {
      "point": "Forgotten password links buried below the form are frequently missed at exactly the moment of highest frustration.",
      "suggestion": "Surface the forgotten password link above the submit button, not below — users scan top to bottom when they fail."
    }
  ],
  "nice_to_have": [
    {
      "point": "Returning users on trusted devices expect a 'remember me' option — without it, re-login friction compounds over time.",
      "suggestion": "Add a remember me checkbox that extends session TTL for that device."
    },
    {
      "point": "Social login scope (Google / GitHub) is unspecified — deferring it later is more expensive than deciding now."
    },
    {
      "point": "Enterprise accounts may require stricter session policies than individual users — unresolved if multi-tenant is in scope."
    }
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
- [point] → [suggestion] _(omit arrow + suggestion if none)_

**Important** _(omit section if none)_
- [point] → [suggestion] _(omit arrow + suggestion if none)_

**Nice to have** _(omit section if none)_
- [point] → [suggestion] _(omit arrow + suggestion if none)_
```

_(The adversarial agent does not appear in Step 4 rendering — it runs in Step 6A.)_

---

## Step 5 · Consolidation

Merge all domain agent outputs into a **consolidated answer** to the original question. The output shape follows the nature of the question — not a fixed format imposed regardless of what was asked.

**Dual weighting:** Apply a combined weight to each item when merging:

| | Critical item | Important item | Nice-to-have item |
|--|--------------|---------------|------------------|
| **Critical domain agent** | 9 | 6 | 3 |
| **Important domain agent** | 6 | 4 | 2 |
| **Adjacent domain agent** | 3 | 2 | 1 |

Higher weight = higher precedence. When agents disagree:
- Clearly unequal weights → use the higher-weight position; note the dissent
- Equal or near-equal weights on a critical item → preserve as an explicit tradeoff; do not silently resolve

**Consolidation rules:**
1. **Answer the question directly**: Lead with what the panel concludes, recommends, or decides.
2. **Deduplicate across agents**: Merge identical or near-identical concerns; note all source agents.
3. **Weight-order the findings**: Higher-weight items appear first within each section.
4. **Preserve disagreements as tradeoffs**: Near-equal weight conflicts on critical items surface as explicit tradeoffs.
5. **Separate risks from decisions**: Risks belong in their own section, not buried in the main answer.
6. **Flag unresolved questions**: Decisions or unknowns that could materially change the answer belong in Open Questions.
7. **Verify coverage**: Confirm every Step 1 domain is represented; flag any gaps.

_Note: adversarial review happens in Step 6A after this consolidation — do not attempt to anticipate it here._

**Output — Step 5:**

_If any CONSULT-level domain was identified in Step 2, inject this advisory note first:_
> **Advisory note:** This analysis includes CONSULT-level domain(s): [list]. Model-generated analysis should not substitute for qualified professional judgment in these areas.

```markdown
### Findings

[Direct answer to the question asked — what the panel recommends, concludes, or advises. Shape this to fit the question: a recommendation for decision questions, a spec outline for design questions, a risk summary for evaluation questions, etc.]

### Key Decisions _(omit if none)_
| Decision | Recommendation | Rationale |
|----------|---------------|-----------|
| [decision point] | [chosen approach] | [why, based on agent consensus] |

### Tradeoffs _(omit if none)_
| Topic | Option A | Option B | Recommendation |
|-------|----------|----------|----------------|

### Risks _(omit if none)_
- `risk` [concern] _(source: agent)_

### Open Questions _(omit if none)_
- [Decision or unknown that could materially change the answer] _(source: agent)_

### Coverage Gaps _(omit if none)_
- [Domain]: not addressed
```

---

## Step 6 · Adversarial Review

Spawn the adversarial agent from the roster as a **single subagent**. It receives only the original request and the consolidated response — it does not see individual domain agent analyses.

```
<project_context>
[STEP_0_CONTEXT_SUMMARY]
</project_context>

<request>
[ORIGINAL_REQUEST]
</request>

<consolidated_response>
[STEP_5_OUTPUT]
</consolidated_response>

[DIRECTIVE — the adversarial directive from the assemble-agents roster]

**Do NOT write any code, create any files, or take any action. Return only the <adversarial_review> JSON block below.**

Challenge the consolidated response against the original request:
1. Does it actually address what was asked, or has it drifted?
2. What failure modes, risks, or gaps does it fail to surface or downplay?
3. What did consolidation distort, soften, or lose?
4. If this response were acted on as-is, what would go wrong?

<adversarial_review>
{
  "agent": "[TOPIC] Adversarial Reviewer",
  "unaddressed_gaps": ["Things the original request needed that the consolidated response misses — omit if none"],
  "consolidation_failures": ["Where consolidation distorted, softened, or lost important concerns — omit if none"],
  "attack_vectors": ["Failure modes or risks not adequately captured — omit if none"],
  "verdict": "fatal | severe | manageable | sound",
  "verdict_reason": "One sentence: what makes the consolidated response fundamentally sound or flawed?"
}
</adversarial_review>
```

**Rendering — Step 6:**
```markdown
### Adversarial Review
**Verdict:** [fatal | severe | manageable | sound] — [verdict_reason]

**Unaddressed gaps:** _(omit if none)_
- [gap]

**Consolidation failures:** _(omit if none)_
- [failure]

**Attack vectors:** _(omit if none)_
- [vector]
```

---

## Step 7 · Team Deliberation

Step 6 must complete before Step 7 begins.

Spawn an **agent team** (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` — see fallback below).

**Team composition:**
- Lead: pipeline orchestrator
- Teammates: all domain agents from the Step 3 roster only — the adversarial agent does NOT join the team; their Phase A output is provided as context

**What each teammate receives:**
- Original request and project context
- The consolidated response from Step 5
- The adversarial review from Phase A
- Their own Step 4 analysis

**Team goal:** Fine-tune and validate the consolidated response. Not rebuild from scratch. Teammates deliberate directly with each other via messaging. When alignment is reached (or the team identifies irreconcilable disagreements), each teammate submits a final rating.

**Teammate spawn prompt:**
```
<project_context>
[STEP_0_CONTEXT_SUMMARY]
</project_context>

<request>
[ORIGINAL_REQUEST]
</request>

<consolidated_response>
[STEP_5_OUTPUT]
</consolidated_response>

<adversarial_feedback>
[PHASE_A_OUTPUT]
</adversarial_feedback>

<your_prior_analysis>
[THIS AGENT'S STEP 4 JSON OUTPUT]
</your_prior_analysis>

[DIRECTIVE from assemble-agents roster for this agent]

Your goal is to fine-tune and validate the consolidated response — not rebuild it.

Review whether your prior concerns were addressed. Discuss directly with other teammates where you disagree. Pay particular attention to the adversarial feedback — it identifies gaps and distortions the team should resolve before signing off.

When the team reaches a shared position, submit your final rating to the lead.
```

**Team output — collected by the lead:**

Each teammate submits:
```json
{
  "agent": "[NAME]",
  "alignment": "agree | partial | disagree",
  "amendments": ["Specific changes to the consolidated response the team agreed on — omit if none"],
  "unresolved": ["Concerns that remain unaddressed — omit if none"]
}
```

**Team rating (determined by the lead from teammate submissions):**
- 🟢 **Green** — all teammates agree or partial with no significant unresolved concerns
- 🟡 **Yellow** — majority aligned; specific caveats documented; proceed with awareness
- 🔴 **Red** — significant misalignment; unresolved concerns that materially affect the response
  - Sub-type `scope_drift`: team flagged that the consolidated response drifted from the original request

**Rendering — Step 7:**
```markdown
| Teammate | Alignment | Unresolved |
|----------|-----------|-----------|
| [Agent Name] | agree / partial / disagree | [concern or —] |

**Amendments agreed:** _(omit if none)_
- [amendment]

**Team Rating: 🟢 Green / 🟡 Yellow / 🔴 Red**
[If yellow or red: specific caveats or unresolved concerns]
```

---

### Fallback — if agent teams are not enabled

If `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is not set, run Phase B as parallel subagents instead. Each domain agent receives the same inputs as the team spawn prompt above and returns an individual alignment JSON. The orchestrator aggregates: all agree → 🟢, any partial no disagree → 🟡, any disagree → 🔴.

---

## Step 8 · Final Output

Present the run **result-first**: the Result section appears at the top before the analysis detail. Use the tier-specific template for the Result section, then render all steps (0–7) after the `---` divider.

**The Result section is always the first thing the user sees.** Status, plan, and caveats come before agent analyses. This applies to all three status paths (🟢 Green, 🟡 Yellow, 🔴 Red).

---

### /ask output template

Result section target: ~200 words. Direct answer only — no agent attribution, no tradeoffs table.

```markdown
# /ask: [one-line summary of the question]

## Result
**Status: 🟢 Green / 🟡 Yellow / 🔴 Red**

[If REVIEW — one-line caution per concern, inline]

[Direct answer to the question — concise, 3–5 bullets or a short paragraph. Shape to fit: recommendations, key conclusions, or a brief outline.]

_This analysis reflects a single model's perspective — validate independently before acting._

---

## Analysis

### Step 0 · Context
[Step 0 output]

### Step 1 · Domains
[Step 1 output]

### Step 2 · Coverage
[Step 2 output]

### Step 3 · Agent Roster
[Step 3 output]

### Step 4 · Agent Analyses
[Step 4 rendered output — each agent under its own subheading]

### Step 5 · Consolidated Findings
[Step 5 output]

### Step 6 · Adversarial Review
[Step 6 output]

### Step 7 · Team Deliberation
[Step 7 team table + team rating]
```

---

### /panel output template

Result section target: ~400–600 words. Full findings with key decisions and tradeoffs. One-paragraph epistemic caveat.

```markdown
# /panel: [one-line summary of the question]

## Result
**Status: 🟢 Green / 🟡 Yellow / 🔴 Red**

[If REVIEW:]
**Cautions noted — proceed with awareness:**
| Agent / Reviewer | Concern |
|-----------------|---------|
| [Name] | [yellow reason] |

### Findings
[Direct answer to the question — shaped to fit. Recommendation for decision questions, design outline for spec questions, risk summary for evaluation questions.]

### Key Decisions _(omit if none)_
[Key decisions table]

### Tradeoffs _(omit if none)_
[Tradeoffs table]

### Risks _(omit if none)_
[Risk list]

> **Note on independence:** All agents in this analysis share the same underlying model weights. They can surface different concerns but cannot provide genuinely independent validation. For decisions with significant consequences, seek qualified domain expert review.

---

## Analysis

### Step 0 · Context
[Step 0 output]

### Step 1 · Domains
[Step 1 output]

### Step 2 · Coverage
[Step 2 output]

### Step 3 · Agent Roster
[Step 3 output]

### Step 4 · Agent Analyses
[Step 4 rendered output — each agent under its own subheading]

### Step 5 · Consolidated Findings
[Step 5 output]

### Step 6 · Adversarial Review
[Step 6 output]

### Step 7 · Team Deliberation
[Step 7 team table + team rating]
```

---

### /council output template

Result section: full document. Dedicated Confidence & Limitations section. All steps shown in full.

```markdown
# /council: [one-line summary of the question]

## Result
**Status: 🟢 Green / 🟡 Yellow / 🔴 Red**

[If REVIEW:]
**Cautions noted — proceed with awareness:**
| Agent / Reviewer | Concern |
|-----------------|---------|
| [Name] | [yellow reason] |

### Findings
[Full answer to the question — shaped to fit. Comprehensive recommendation, design spec, or analysis as appropriate.]

### Key Decisions _(omit if none)_
[Key decisions table]

### Tradeoffs
[Full tradeoffs table]

### Risks
[Full risk list]

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

### Step 3 · Agent Roster
[Step 3 output]

### Step 4 · Agent Analyses
[Step 4 rendered output — each agent under its own subheading]

### Step 5 · Consolidated Findings
[Step 5 output]

### Step 6 · Adversarial Review
[Step 6 output]

### Step 7 · Team Deliberation
[Step 7 team table + team rating]
```

---

### Status-specific Result content

These slots apply within the tier templates above.

**If 🟢 Green:** Render findings and epistemic caveat only. No additional notes needed.

**If 🟡 Yellow:** Add the caveats table before the findings. Answer is sound; proceed with awareness of flagged items.

```markdown
**Caveats — proceed with awareness:**
| Teammate | Concern |
|----------|---------|
| [Name] | [unresolved concern] |
```

**If 🔴 Red:** Replace the findings with:

```markdown
## Result
**Status: 🔴 Red**

The team could not align on the consolidated response. The following concerns remain unresolved:

| Teammate | Unresolved Concern |
|----------|--------------------|
| [Name] | [specific concern] |

**Adversarial verdict:** [fatal | severe | manageable | sound] — [verdict_reason]

To proceed: resolve the concerns above and re-run, or accept the response with explicit awareness of the unresolved items.
Tier: [same tier, or escalate to `/council` if systemic issues across multiple domains]
```

**If 🔴 Red (scope_drift):** The team flagged that the consolidated response drifted from the original request:

```markdown
## Result
**Status: 🔴 Red — Scope Drift**

The consolidated response drifted from what was originally asked. Re-run with a clarified prompt:

---
[COMPLETE REVISED PROMPT — drafted in full by the orchestrator, ready to paste as-is]
---
```

---

This pipeline produces analysis only.
