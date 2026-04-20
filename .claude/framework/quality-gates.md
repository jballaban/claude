# Quality Gates

> **All gates must pass before Checkpoint 2. DevOps does not merge or deploy without product owner approval at Checkpoint 2.**

---

## Gate 1 — Spec Completeness (post-Analyst, pre-development)

Before any design or code work begins:

- [ ] Acceptance criteria are explicit and testable
- [ ] Edge cases are documented
- [ ] Scope boundaries are clearly defined — what is explicitly out of scope is stated
- [ ] Target branch is specified (`main` or `next`)
- [ ] Product owner has approved the spec at Checkpoint 1
- [ ] Spec Writer has updated the `spec/` folder on the working branch

## Gate 2 — Implementation Readiness (pre-Developer)

Before the Developer begins:

- [ ] Technical engagement spec written into the GitHub Issue by the Architect
- [ ] Design/copy spec provided by the Designer (for user-facing changes)
- [ ] Marketing direction provided (for user-facing features and launches)
- [ ] No unresolved Architect escalations (Checkpoint 3 cleared if raised)

## Gate 3 — Pre-Ship (post-QA and Security, pre-Checkpoint 2)

Before the product owner reviews:

- [ ] All acceptance criteria pass QA validation
- [ ] QA has explicitly signed off
- [ ] No blocking Security findings on the PR
- [ ] Post-deployment infrastructure Security review passed (for infrastructure changes)
- [ ] Marketing requirements met for user-facing changes (search indexability, social metadata, conversion considerations addressed)
- [ ] Designer has validated any new assets meet brand guidelines
- [ ] Spec Writer has reconciled `spec/` against what was actually built
- [ ] No open blocking issues on the PR

## Gate 4 — Deployment Authorization

Before DevOps merges and deploys:

- [ ] Product owner has explicitly approved at Checkpoint 2
- [ ] All Gate 3 items confirmed
- [ ] DevOps has defined a rollback strategy for this deployment
- [ ] For destructive changes: affected data has been backed up surgically before execution
- [ ] Deployment procedure follows `environments.md`
