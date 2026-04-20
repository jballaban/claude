# Process

> **This process is mandatory. Project context and specs inform what agents work on — they do not change when agents are involved, when checkpoints occur, or how feedback loops are handled.**

---

## Entry Point

All requests come from the product owner through Claude to the Orchestrator. The product owner does not initiate work by creating GitHub issues directly. GitHub issues are outputs of this process, not inputs.

When the product owner opens Claude and describes what they want, the Orchestrator receives it and begins the appropriate workflow.

---

## Branch Model

All work targets one of two branches:

| Branch | Environment | Purpose |
|--------|-------------|---------|
| `main` | Production | Work that launches as soon as it is ready |
| `next` | Staging | Work held for the next major release |

The Orchestrator determines target branch based on the Analyst's spec. When ambiguous, it surfaces the question to the product owner before proceeding.

The Orchestrator maintains awareness of all in-flight work on both branches and flags potential conflicts to the Architect.

---

## Human Checkpoints

Two checkpoints are mandatory for every workflow. A third is Architect-initiated.

**Checkpoint 1 — After Analyst:** Product owner approves the business spec before any design or development work begins. Nothing proceeds without this approval.

**Checkpoint 2 — Before DevOps ships:** Product owner reviews the finished work (PR, summary of changes, QA and Security sign-off) before deployment. This is the final go/no-go.

**Checkpoint 3 (conditional) — Architect escalation:** The Architect raises this when uncertain about an approach or proposing something new to the stack. The product owner is pulled in to decide before development continues.

---

## Workflow Patterns

The Orchestrator selects the appropriate pattern based on the nature of the request. Agents marked **(parallel)** are engaged simultaneously; their outputs are collected and routed back to the Analyst to merge into a single updated spec before work continues.

### New Feature

1. **Analyst + Spec Writer** — refine requirements, produce business spec with acceptance criteria, target branch
2. ⛔ **Checkpoint 1:** Product owner approves spec
3. **Architect + Designer + Marketing** *(parallel)* — technical approach, design/copy spec, positioning and marketing requirements
4. *Architect escalates to product owner if uncertain or introducing new stack element (Checkpoint 3)*
5. **Spec Writer** — updates spec to reflect approved design and technical decisions
6. **Developer** — implementation (test-first; unit tests included)
7. **QA + Security** *(parallel)* — independent validation and code security review
8. *If QA or Security fails: task returns to Developer; loop until sign-off*
9. **DevOps** — deploy to feature environment; Security reviews infrastructure post-deployment
10. **Spec Writer** — reconciles spec against what was built
11. ⛔ **Checkpoint 2:** Product owner reviews and approves
12. **DevOps** — merge PR; CI deploys to production (`main`) or staging (`next`)

### Bug Fix

1. **Analyst + Spec Writer** — confirm and scope the bug; document in spec
2. **Architect** — assess for systemic cause before any fix is written
3. *Architect escalates to product owner if systemic issue found (Checkpoint 3)*
4. **Developer** — fix implementation (unit tests included)
5. **QA** — regression validation
6. *If QA fails: task returns to Developer*
7. **Security** — code review
8. ⛔ **Checkpoint 2:** Product owner reviews and approves
9. **DevOps** — merge PR; CI deploys

### Copy / Content Change

1. **Analyst + Spec Writer** — confirm scope
2. **Marketing** — positioning and strategic direction
3. **Designer** — produce updated copy and assets within Marketing's direction
4. **Developer** — implement
5. ⛔ **Checkpoint 2:** Product owner reviews and approves
6. **DevOps** — merge PR; CI deploys

### Infrastructure Change

1. **Analyst + Spec Writer** — confirm scope and risk
2. **Architect + DevOps** *(parallel)* — design approach; assess operational constraints, cost, rollback strategy
3. *Either party escalates to product owner if they cannot reach consensus or if risk warrants it*
4. **DevOps** — CDK implementation
5. **Security** — infrastructure review
6. ⛔ **Checkpoint 2:** Product owner reviews and approves
7. **DevOps** — deploy; Security reviews post-deployment

---

## Feedback Loops

When any agent discovers a problem during implementation or review that requires changing the business spec (the WHAT):

1. Agent reports the problem to the Orchestrator with full context
2. Orchestrator routes to **Analyst** with the problem description
3. Analyst coordinates whatever specialists are needed (Designer, Architect, Marketing, etc.)
4. **Spec Writer** updates the spec to reflect the change
5. Orchestrator routes the updated spec back to the blocked agent
6. Work resumes from the point of interruption

Agents do not resolve business spec gaps themselves. They do not contact other agents directly.

**HOW changes** (purely technical implementation decisions) stay within the Architect/Developer pair and are documented in the GitHub Issue. These do not route back to the Analyst.

---

## GitHub Issue Lifecycle

- **Orchestrator** creates an issue when work begins on a request
- Issue title = the request; body contains the business spec summary (from Analyst) and the technical engagement spec (from Architect)
- Issue is updated at each major workflow step with status
- **Spec Writer** ensures the `spec/` folder reflects the issue content on the working branch
- Bugs found by QA are tracked as separate child issues linked to the parent
- **DevOps** closes the issue when deployment is confirmed

---

## Ephemeral Feature Environments

For every feature branch that requires AWS infrastructure to test:

1. **DevOps** spins up a scoped CDK stack for the branch
2. Developer uses this environment during implementation and testing
3. QA validates against this environment
4. **DevOps** tears down the environment when the branch is merged or deleted

Local-first where possible — frontend can be served locally. AWS environments are spun up only when backend infrastructure is required.

---

## /pending — Surfacing Outstanding Items

When the product owner runs `/pending`, the Orchestrator:

1. Reads all open GitHub issues for the project
2. Identifies items waiting on product owner input: Checkpoint 1 approvals, Checkpoint 2 approvals, Analyst questions, Architect escalations
3. Presents each item with context: what it is, what decision is needed, what is blocked until resolved
4. Collects the product owner's responses
5. Routes each response back into the appropriate workflow step and updates the relevant GitHub issue
