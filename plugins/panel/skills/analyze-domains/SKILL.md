---
name: analyze-domains
description: Identifies the relevant domains (expertise areas) for a given prompt or spec, ranked across three tiers — critical, important, and adjacent. Used by the panel pipeline to determine which expert perspectives need representation before assembling agents. Always runs on Sonnet.
model: sonnet
---

# Analyze Domains

**Purpose:** Identify and tier the expertise domains relevant to a prompt or spec.
**Always runs on:** Sonnet — domain identification is a structured classification task that does not benefit from deeper model reasoning. Sonnet provides consistent, well-calibrated output for this job.
**No depth parameter** — this task is fixed-scope regardless of which tier (ask/panel/council/plan) invoked it.

---

## Instructions

Given the prompt or spec below, identify up to **10** relevant domains — the expertise areas, disciplines, or perspectives that would have something meaningful to contribute to analyzing or executing on it.

**Do NOT write code, create files, or take any action. Return only the analysis below.**

Distribute domains across three tiers:

### Critical
Domains that are **core to the scope** — if these aren't covered, the analysis will be fundamentally incomplete or wrong. These are the non-negotiable perspectives.

### Important
Domains that are **highly relevant and secondary** — meaningful contributors that should be represented. The analysis would be weaker without them, but the core wouldn't collapse.

### Adjacent
Domains the orchestrator **believes may apply but is not certain**, or **areas that could be impacted depending on the exact scope**. Include these when: (a) they're clearly relevant but the request doesn't confirm it, or (b) they represent a risk surface worth checking. For each adjacent domain, note the condition that would make it fully applicable.

---

## Ranking guidance

- Cast wide before narrowing — consider technical, business, legal, UX, operational, security, data, and organizational perspectives
- Prefer specificity: "Payment Processing Security" over "Security"
- A domain belongs in Critical if removing it would leave a significant blind spot in the analysis
- A domain belongs in Adjacent if you'd include it in a council but skip it in a quick ask
- Cap at 10 total across all three tiers; fewer is fine if the scope is narrow

---

## Output format

Return the analysis inside `<domain_analysis>` tags using this structure:

<domain_analysis>
{
  "critical": [
    {
      "domain": "[domain name]",
      "rationale": "[one sentence: why this is core to the scope]"
    }
  ],
  "important": [
    {
      "domain": "[domain name]",
      "rationale": "[one sentence: why this is a meaningful secondary perspective]"
    }
  ],
  "adjacent": [
    {
      "domain": "[domain name]",
      "rationale": "[one sentence: why this might apply]",
      "condition": "[what scope or context would make this fully applicable]"
    }
  ]
}
</domain_analysis>

Then render the analysis as readable markdown:

```markdown
## Domain Analysis

**Critical** _(must be covered)_
- **[domain]** — [rationale]

**Important** _(should be covered)_
- **[domain]** — [rationale]

**Adjacent** _(cover if scope confirms)_
- **[domain]** — [rationale] _(applies if: [condition])_
```

---

## Input

```
<project_context>
[PROJECT_CONTEXT]
</project_context>

<prompt>
[PROMPT_OR_SPEC]
</prompt>
```
