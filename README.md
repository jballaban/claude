# claude.workflow

A template GitHub Actions pipeline that lets Claude take a GitHub issue from triage to a reviewable PR. Drop it into any repo by adding one workflow file and one secret.

## What it does

When you label an issue with `claude:work-this`, an agent-driven pipeline runs on your repo's GitHub Actions runner:

**Triage → Plan → Development → Verification → Deployment → PR (human review).**

Each stage's status lives on the issue as labels (`stage:triage`, `stage:plan`, …). Every state change writes a short comment to the issue, so the comment thread is the audit log. The pipeline halts and asks for help if it ping-pongs between two stages three times.

See [CLAUDE.md](./CLAUDE.md) for the full design and the locked-in decisions.

## Status

| Stage | Built |
|---|---|
| Triage | ✅ |
| Plan | ✅ |
| Development | ✅ |
| Verification (QA) | ✅ |
| Deploy review | ✅ |
| PR / Human review | ✅ |

All six stages are scaffolded.

## Setup in a consuming repo

You need: Claude Code installed locally (to generate the OAuth token once), and write access to the repo.

**1. Generate a Claude Code OAuth token.**
On your local machine, run:

```
claude setup-token
```

It will open a browser, you sign in, and a token is printed (starts with `sk-ant-oat-…`). This token uses your Claude Code subscription — no separate API key or billing setup is required. It does not expire on a short cycle, so one token covers all your consuming repos.

**2. Create a fine-grained pipeline PAT.**
GitHub deliberately suppresses workflow runs that would be triggered by the default `GITHUB_TOKEN`, so stage-to-stage label transitions need to be made by a user-owned token. Generate one at github.com/settings/personal-access-tokens → "Generate new fine-grained token":

- Resource owner: your user (or the org that owns the consuming repos)
- Repository access: only the repos you want the pipeline to run on
- Repository permissions: `Issues: Read and write`, `Contents: Read and write`, `Pull requests: Read and write`, `Metadata: Read-only`
- Expiration: pick something you'll renew (PATs cannot be no-expiration)

**3. Add both secrets to the repo.**
Settings → Secrets and variables → Actions → New repository secret:
- `CLAUDE_CODE_OAUTH_TOKEN` — the OAuth token from step 1
- `CLAUDE_PIPELINE_PAT` — the PAT from step 2

**4. Add the workflow file.**
Create `.github/workflows/claude.yml` in your repo with the contents of [`examples/consuming-repo/claude.yml`](./examples/consuming-repo/claude.yml). It references this template repo via `uses:` and is ~120 lines.

**5. Commit and push.**

Labels are created automatically on the first run — no manual setup. The first time you label an issue with `claude:work-this`, the workflow creates the pipeline labels in your repo, then starts Triage.

## Using it

Apply the `claude:work-this` label to any open issue. Watch the issue thread for the Triage agent's first comment.

The Triage agent will end its comment with one of three decisions:

- **`READY`** — scope is clear, advances to `stage:plan`.
- **`ASK`** — applies `claude:awaiting-approval`. Answer the questions in the thread, then remove the label to re-run.
- **`SPLIT`** — issue is too large. File the proposed child issues, then remove `claude:awaiting-approval` to proceed.

To reject an agent's output at any stage, apply the `claude:rejected` label.

## Labels reference

| Label | Purpose |
|---|---|
| `claude:work-this` | Apply to enroll an issue. Consumed by the workflow on entry. |
| `stage:triage` / `stage:plan` / `stage:dev` / `stage:qa` / `stage:deploy-review` / `stage:pr` | Current stage. Exactly one is set while the pipeline is running. |
| `claude:awaiting-approval` | Pipeline is paused for human input. Remove to advance, or apply `claude:rejected` to reject. |
| `claude:rejected` | Human rejected the current stage's output. |
| `bounce:<from>-<to>:<N>` | Bounce counter between two adjacent stages. Created on demand. At `N=3` the pipeline halts and asks for human help. |

## Requirements

- A repo with GitHub Actions enabled.
- A Claude Code subscription (Pro, Max, or any plan that supports `claude setup-token`). Agent runs bill against your subscription, not against an API key.
- No local Claude Code session needs to be running. Everything runs in your repo's runner.

## Repo layout

| Path | What |
|---|---|
| `.github/workflows/` | Reusable workflows (one per stage) |
| `agents/<stage>/prompt.md` | System prompt defining each agent's contract |
| `scripts/ensure-labels.sh` | Idempotent label creator |
| `config/labels.json` | Label manifest (names, colors, descriptions) |
| `examples/consuming-repo/` | Drop-in workflow snippet for downstream repos |
