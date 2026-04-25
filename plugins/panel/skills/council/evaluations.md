# Council Evaluations

Test scenarios for verifying `/council` produces correct deep-tier exhaustive output.

---

## Scenario 1 — Greenfield system design

**Input:**
> Design a real-time collaborative document editing system like Google Docs. Multiple users should be able to edit simultaneously with conflict resolution and offline support.

**Expected behavior:**
- 5 domains identified (real-time sync, backend, frontend, data/persistence, operational reliability)
- 7–10 granular agents synthesized — domains split into sub-specialists (e.g., "CRDT Conflict Resolution Specialist" and "WebSocket Infrastructure Specialist" from the real-time domain)
- DEPTH_INSTRUCTION produces exhaustive fields: edge cases, 6–12 month implications, failure modes
- Step 5 includes a risk matrix and tradeoffs table (OT vs CRDT, WebSocket vs SSE, etc.)
- Step 6 validation is thorough; red ratings require resolution before proceeding

**Pass criteria:**
- [ ] AGENT_MIN respected (≥7 agents)
- [ ] At least one domain splits into multiple sub-specialists
- [ ] `long_term_implications` field populated by most agents
- [ ] Step 5 tradeoffs table has ≥3 rows
- [ ] Step 6 runs all agents simultaneously (single parallel spawn)
- [ ] If any red rating: RERUN status with specific resolution actions listed

---

## Scenario 2 — High-stakes migration

**Input:**
> We need to migrate our monolithic Rails app (5 years old, 200k users) to microservices on Kubernetes. We have 6 months.

**Expected behavior:**
- Domains include: migration strategy, data, infrastructure, risk/rollback, team/process, timeline
- Agents synthesized with migration-specific focus (e.g., "Strangler Fig Migration Specialist", "Database Decomposition Specialist")
- Multiple blockers identified (data ownership boundaries, team skill gaps, rollback strategy)
- DEPTH_INSTRUCTION triggers failure mode analysis: what breaks at month 3, what if a service boundary is wrong
- Step 5 produces action plan with explicit rollback checkpoints

**Pass criteria:**
- [ ] At least 2 blockers in Step 5 blockers section
- [ ] Assumptions & Ambiguity section present (timeline feasibility should be flagged)
- [ ] Step 6 produces at least one yellow or red rating (migration of this scale always has open questions)

---

## Scenario 3 — Security-critical architecture

**Input:**
> We're building a healthcare data platform that will store patient records and lab results. It needs to be HIPAA compliant and accessible to clinicians via a web app.

**Expected behavior:**
- Compliance domain (HIPAA) elevated to blocker status immediately
- Domains include: compliance/legal, security, data architecture, UX (clinical workflows), infrastructure, audit/logging
- Security domain splits into application security specialist and infrastructure/IAM specialist
- Recommendations include encryption at rest and in transit, audit log requirements, BAA contracts, access control
- Step 5 marks any plan without audit logging or encryption as a blocker — not a risk

**Pass criteria:**
- [ ] HIPAA compliance appears in blockers, not just risks
- [ ] Audit logging appears in action plan
- [ ] At least one `open_question` about BAA (Business Associate Agreement) or data residency
- [ ] Security domain produces at least 2 separate sub-agents
- [ ] Step 6 red rating if any security or compliance blocker was not addressed in Step 5
