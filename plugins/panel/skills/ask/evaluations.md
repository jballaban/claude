# Ask Evaluations

Test scenarios for verifying `/ask` produces correct shallow-tier output.

---

## Scenario 1 — Simple technical request

**Input:**
> Add input validation to the user registration form.

**Expected behavior:**
- Gate 1 passes (not trivial — has surface area across frontend, backend, UX)
- Gate 2 passes (at least 2 meaningful domains: UI/UX, backend validation, security)
- 2–3 domains identified; agents consolidated to 1–2
- Each agent returns ≤3 items per field
- Step 6 produces at least one rating; overall status is PASS or REVIEW
- Total output is concise — not a full architecture review

**Pass criteria:**
- [ ] Pre-flight gates both pass without asking clarifying questions
- [ ] DOMAIN_COUNT respected (≤3 domains)
- [ ] AGENT_MAX respected (≤3 agents spawned)
- [ ] Agent fields are brief (no wall-of-text recommendations)
- [ ] Step 6 validation table present with ratings

---

## Scenario 2 — Non-technical / business request

**Input:**
> How do we reduce customer churn for our SaaS product?

**Expected behavior:**
- Gate 1 passes (multi-domain, not a one-liner answer)
- Domains identified are non-technical: product, marketing, customer success, pricing — NOT code/security
- Synthesized agents reflect business disciplines, not engineering roles
- Recommendations are strategic, not implementation steps

**Pass criteria:**
- [ ] No technical agents synthesized (no `backend-developer`, `security-auditor`, etc.)
- [ ] At least one business/product domain represented
- [ ] Step 5 consolidated plan reflects business strategy framing
- [ ] Step 6 validation passes

---

## Scenario 3 — Trivial request (Gate 1 bypass)

**Input:**
> What does `Array.prototype.reduce` do?

**Expected behavior:**
- Gate 1 fires: this is a factual definition, not a planning task
- Pipeline skipped entirely
- Direct answer returned

**Pass criteria:**
- [ ] No pipeline steps executed
- [ ] No agents spawned
- [ ] Answer returned directly in ≤3 sentences
