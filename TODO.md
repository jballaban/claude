# TODO

Remaining work from the 8-stage design captured in [CLAUDE.md](./CLAUDE.md) and [PIPELINE.md](./PIPELINE.md). Each item is something the design specifies and the current implementation is missing.

The pipeline currently runs **Triage → Plan → Dev → QA → Deploy review → PR → Post-merge handoff → Deploy (manual, with success/failure handlers)**. Everything below is what's still on the design board.

## Build items — Stage 6 → 8

- [ ] **Stage 6 deploy-mode picker.** Let the human apply one of `deploy:auto` / `deploy:manual` / `deploy:none` on the PR before merging. Stage 5 should pre-apply `deploy:none` when the diff is doc-only. `post-merge.yml` reads the chosen label and routes (currently hard-coded to manual). Surface the choice in the PR-stage comment so the human knows they need to pick.

- [ ] **Auto-deploy (Stage 7A).** New reusable workflow that:
  - Reads the deploy procedure Stage 5 wrote into its issue comment.
  - Executes it on the runner (consumer's secrets in env; OIDC role for AWS or similar).
  - On success: hands off to Stage 8 (auto path) — relabel `stage:deploy` → `stage:prod-review` and post the verification comment.
  - On failure: hard human gate, no bounce/retry.
  Blocked on: **Stage 5 procedure format** (see Open design questions).

- [ ] **Production verification gate (Stage 8).** Only meaningful when auto-deploy exists. Posts a verification comment with what to check in prod, surfaces auto-rollback as an option when `rollback:auto-available` is set, and offers `claude:rejected-auto` / `claude:rejected` / approve. Manual deploy collapses 7+8 — Stage 8 is auto-path only.

- [ ] **Auto-rollback.** Stage 5 discovers a rollback procedure (similar to discovering the deploy procedure) and sets `rollback:auto-available` when present. Stage 8 reject path with `claude:rejected-auto` triggers the pipeline to execute the procedure on the runner. On failure, degrade to the manual flow we already have.

## Build items — invariants and recovery

- [ ] **Tag-gated serialization on `main`.** Branch protection on `main` requires `HEAD == deployed` tag for any merge. Tag is written on Stage 8 approval (auto) or on Stage 7 signal-complete (manual), or immediately on merge for `deploy:none`. Bootstrap: if no tag exists, the check passes. Blocked on: **Tag mechanism** (see Open design questions).

- [ ] **Auto-revert of main + bounce-to-Plan on Stage 7/8 rejection.** Today the rejection handler tells the human to roll back manually and re-enroll the issue with `claude:work-this`. The designed flow is: pipeline auto-reverts the merge commit on main, advances the tag to the revert SHA, and bounces the issue back to Plan with the rejection reason as context (so Plan can re-evaluate, not just re-run Dev). Requires a `stage:awaiting-rollback` signal step so the human confirms prod is rolled back before main is reverted.

- [ ] **Non-pipeline merge reverse-engineer flow.** Workflow that triggers on a `push` to `main` whose commit didn't come from a pipeline-managed PR. It reverts the commit, creates a fresh issue from the original PR title/commit message, applies `claude:work-this`, has Triage reverse-engineer the diff into a description + Test plan (skipping Plan — the merge is the implicit approval), and enters the pipeline at QA. The one explicit exception to "every Plan PROCEED gates on human approval."

## Open design questions (from CLAUDE.md)

- [ ] **Tag mechanism.** Pick one: git moving tag, GitHub Deployments API, or a `production` tracking branch. All three satisfy the design; differ in tooling, visibility, and audit ergonomics.

- [ ] **Non-pipeline merge detection.** Precise rule for "this commit is non-pipeline." Branch name (`claude/issue-*`) plus linked issue with prior stage labels is the obvious start, but admin pushes and force-pushes need explicit handling.

- [ ] **Stage 5 procedure format.** How the deploy/rollback procedures are encoded in the Stage 5 comment so Stages 7–8 can reliably execute them — fenced shell block, structured YAML, plain prose re-interpreted by an agent? Affects how brittle the executor is.

- [ ] **Permissions.** Scope the GitHub Action's token (repo write, project write, deploy creds) before building anything that depends on extra scopes. The current PAT (`CLAUDE_PIPELINE_PAT`) needs issues/contents/PRs write; the deploy stage will need whatever the deploy procedure runs against (typically AWS via OIDC, or static keys).

## Polish / smaller items

- [ ] **`post-merge.yml` PR body parsing.** The awk extraction of `### Launch checklist` and `### Rollback` from the PR body assumes the PR agent wrote those headers verbatim. If the agent drifts, the extraction silently produces empty sections (we fall back to a "see the merged PR" message). Either tighten the PR-agent contract or read from the Deploy-review issue comment instead, which is structurally cleaner.

- [ ] **PR-agent "PR already exists → DONE" path.** Currently masks the case where the branch has been deleted (which we hit when trying to re-fire PR after a merge). Should at least post a clearer halt comment in that case.

- [ ] **`<details>` accordions in Plan / QA / Deploy-review comments.** Confirm downstream agents reading these comments still parse the Markdown inside `<details>` correctly. Should work — Markdown is Markdown — but worth a real run-through once we hit a long Test plan or rollback procedure.

- [ ] **Closure UX.** The success path leaves the issue with no stage labels and a "close it manually when you're satisfied" comment. The human still has to click close. We deliberately kept this manual per the locked-in rule, but a friendlier prompt might help — e.g. include a one-click GitHub link in the comment.
