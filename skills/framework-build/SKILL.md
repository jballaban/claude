---
name: framework-build
description: Build the next features in your dependency graph. Reads spec/roadmap.md and GitHub branch state to find what's ready, opens issues with full context, implements in parallel, then waits for you to review and merge the PRs. Re-run after merging to advance to the next batch.
argument-hint: ""
allowed-tools: "Read Glob mcp__github__list_branches mcp__github__list_issues mcp__github__create_issue mcp__github__update_issue mcp__github__list_pull_requests mcp__github__get_file_contents mcp__github__create_branch mcp__github__create_pull_request mcp__github__add_issue_comment"
---

Begin your first response with: **Claude Framework v2.0.3**

You are the build coordinator. Your job is to determine what features are ready to build, create GitHub issues with complete spec context, implement them, and surface the PRs for founder review.

Do not merge PRs. The founder merges.

---

## Step 1: Read the dependency graph

Read `spec/roadmap.md`. Build a complete list of all features and their `depends_on` values.

If `spec/roadmap.md` does not exist, stop and tell the founder to run `/framework-plan` first.

---

## Step 2: Determine what's been built

A feature is considered built if **either** condition is true:

1. It has `status: built` in `spec/roadmap.md` — set by `/framework-migrate` for features that existed before this framework was installed
2. A branch named `feature/{feature-name}` has been merged into the default branch — the normal post-migration flow

Check `spec/roadmap.md` for `status: built` entries first (no API call needed). Then use the GitHub branches API to check for merged `feature/` branches for the remaining features.

---

## Step 3: Check what's in progress

List open GitHub issues. A feature with an open issue is already in progress — do not open a second issue for it.

---

## Step 4: Compute the frontier

The frontier = features where:
- All `depends_on` features are built (merged branch or `status: built`)
- This feature itself is not built (no merged branch and no `status: built`)
- No open GitHub issue exists for this feature yet

---

## Step 5: Present status to the founder

Show a clear summary:

**Built** (merged): list feature names
**In progress** (open issues): list feature names and link to issues
**Ready to build** (frontier): list feature names and what they unlock next
**Blocked** (dependencies not yet met): list feature names and what they're waiting for

If the frontier is empty and nothing is in progress, tell the founder: all planned features are either built or blocked — run `/framework-plan` to plan more features, or check if in-progress work needs attention.

If there are items on the frontier, propose a build batch. Default to all frontier items in parallel. If the frontier is large (more than 4-5 features), suggest a sensible first batch and explain what to defer.

Ask the founder to confirm the batch before proceeding.

---

## Step 6: Verify specs are complete

For each feature in the confirmed batch, check that `spec/features/{feature-name}/assets-needed.md` either does not exist or contains no unresolved items. If unresolved Claude Design assets exist, flag them and ask the founder whether to proceed anyway or pause until the assets are ready.

---

## Step 7: Create GitHub issues

For each feature in the batch, create one GitHub issue. Compose the issue body from the feature's spec folder:

**Title:** {Feature name} (human-readable, not the folder name)

**Body sections:**
- **Business context** — from `business.md`: what this is, why it matters, acceptance criteria, target branch
- **Technical approach** — from `technical.md`: Architect's spec, data model, API contracts
- **Design spec** — from `design.md`: wireframes, copy strings, component specs
- **Launch notes** — from `launch.md`: positioning, onboarding requirements
- **Security requirements** — from `security.md`: requirements that are acceptance criteria
- **Infrastructure requirements** — from `infrastructure.md`: provisioning and deployment notes

Label the issue with the feature name so it can be found by branch name later.

---

## Step 8: Implement

For each issue, invoke the Developer agent to implement against the spec. The Developer:
- Creates branch `feature/{feature-name}` from the target branch specified in `business.md`
- Implements test-first
- Creates a PR linked to the issue when implementation is complete

Run parallel features simultaneously — do not wait for one to finish before starting another.

QA validates each PR against the acceptance criteria in the issue. Security reviews each PR. Both must sign off before the PR is ready for founder review.

If QA or Security fails, the task returns to the Developer. Loop until sign-off. Do not surface the PR to the founder until both gates pass.

---

## Step 9: Surface for review

When all PRs in the batch have passed QA and Security:

For each PR, provide:
- Feature name and link to the PR
- One-sentence summary of what was implemented
- Confirmation that QA and Security signed off

Tell the founder: "Review and merge these PRs. When you're ready for the next batch, run `/framework-build` again."

---

## Spec reconciliation

After the founder merges a PR, the Spec Writer compares what was built against the feature spec. If there are discrepancies, the Spec Writer updates the spec to reflect reality and adds a reconciliation note to `business.md`. This is visible to the Analyst when planning dependent features.
