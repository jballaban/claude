# Panel Evaluations

Test scenarios for verifying `/panel` produces correct standard-tier output.

---

## Scenario 1 — Feature implementation

**Input:**
> Add a Stripe subscription billing system to our Next.js app. Users should be able to choose a plan, upgrade/downgrade, and cancel.

**Expected behavior:**
- 4–5 domains identified (payments, backend, frontend/UX, security, operations)
- 4–6 agents synthesized with task-specific names (e.g., "Stripe Webhook Reliability Specialist", not "Backend Developer")
- Phase assignments present only where they naturally apply; not forced onto every recommendation
- Step 5 consolidation deduplicates webhook handling concerns across agents
- Step 6 validation runs all agents simultaneously, not sequentially

**Pass criteria:**
- [ ] DOMAIN_COUNT respected (≤5 domains)
- [ ] AGENT_MIN/MAX respected (3–7 agents)
- [ ] Agent names are task-specific, not generic role titles
- [ ] Step 5 blockers section present (missing webhook signing secret should appear)
- [ ] Step 6 table shows all agents; overall status present
- [ ] Assumptions & Ambiguity section present if any assumptions were made

---

## Scenario 2 — Ambiguous request (Gate 2 trigger)

**Input:**
> Help me with my project.

**Expected behavior:**
- Gate 2 fires: cannot identify 2 meaningful domains from this request
- 2–3 targeted clarifying questions asked before pipeline proceeds
- Pipeline does NOT run until user responds

**Pass criteria:**
- [ ] Clarifying questions asked (not more than 3)
- [ ] Questions are targeted and specific — not generic ("what kind of project?", "what problem are you solving?", "what do you have so far?")
- [ ] Pipeline does not proceed with assumptions on ambiguous input

---

## Scenario 3 — Cross-domain non-technical request

**Input:**
> We want to launch a developer tool as open source. What do we need to think about?

**Expected behavior:**
- Domains span: community, legal/licensing, documentation, marketing/distribution, product strategy
- No forced technical agents unless the request warrants them
- Step 3 synthesizes agents like "Open Source Community Strategist", "Developer Adoption Specialist"
- Recommendations actionable at a strategic level
- No forced phase structure — this is a strategy question, not an implementation task

**Pass criteria:**
- [ ] At least 3 non-engineering domains represented
- [ ] Legal/licensing domain appears (GPL vs MIT vs Apache is a real concern here)
- [ ] Step 0 context check runs (looks for CLAUDE.md, README, etc.)
- [ ] Step 5 tradeoffs table includes at least one licensing or distribution tradeoff
- [ ] Step 6 PASS/REVIEW/RERUN status present
