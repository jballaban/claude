# Panel — Developer Guide

This document covers the development workflow for contributors working on the Panel plugin.

---

## Repo structure

This plugin lives inside a monorepo. Paths below are relative to the repo root.

```
plugins/panel/
├── .claude-plugin/
│   └── plugin.json                 # Plugin metadata (name, version, author)
├── skills/                         # Plugin source — what gets published
│   ├── ask/
│   │   ├── SKILL.md                # Skill instructions (loaded by Claude Code)
│   │   ├── manifest.json           # Skill metadata (tier, models, effort, files)
│   │   └── evaluations.md          # Test scenarios for this tier
│   ├── panel/
│   ├── council/
│   ├── version/
│   └── shared/
│       ├── pipeline.md             # The shared orchestration algorithm
│       └── agents-catalog.md       # Expert domain library for agent synthesis
├── README.md                       # User-facing docs
└── README.dev.md                   # This file

.claude/skills/reload-skills/       # Dev utility (repo-level, not part of any plugin)
.hooks/pre-commit                   # Repo-level hook — install once per clone
reference/                          # Shared reference material across all plugins
```

**Key distinction:** `plugins/panel/skills/` is the source of truth. `.claude/skills/` is the local test install — populated by `/reload-skills` and mostly gitignored.

---

## Local development workflow

### First-time setup

Install the pre-commit hook (run once after cloning):

```bash
cp .hooks/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
```

### Edit → Test loop

1. Edit files in `plugins/panel/skills/`
2. Run `/reload-skills` to sync changes into the local test install
3. Test with `/ask`, `/panel`, or `/council` in this directory
4. Repeat

`/reload-skills` auto-discovers all plugins under `plugins/*/` — no config needed when adding a new plugin.

> Changes to files in `plugins/panel/skills/` are **not** live until you run `/reload-skills`.
> Changes to `.claude/skills/` directly are **not** reflected back to `plugins/panel/skills/`.

---

## Version management

The pre-commit hook bumps the patch version automatically — but only for plugins that have staged changes in their `plugins/<name>/` directory.

- Increments patch in `plugins/panel/.claude-plugin/plugin.json`
- Updates the version string in `plugins/panel/skills/version/SKILL.md`
- Stages both files as part of the commit

To bump minor or major, edit `plugin.json` manually before committing.

---

## Adding a new skill to this plugin

1. Create `plugins/panel/skills/<name>/SKILL.md`
2. Create `plugins/panel/skills/<name>/manifest.json` — copy from an existing skill, update fields
3. Create `plugins/panel/skills/<name>/evaluations.md` — at least 2–3 test scenarios
4. Add the skill directory name to `.gitignore` under the derived skill installs block
5. Run `/reload-skills` — the new skill is auto-discovered

---

## Pipeline architecture

All three tiers (`/ask`, `/panel`, `/council`) share the algorithm in `plugins/panel/skills/shared/pipeline.md`. Tier parameters in each skill's `SKILL.md` control depth:

| Parameter | ask | panel | council |
|-----------|-----|-------|---------|
| `DOMAIN_COUNT` | 3 | 5 | 5 |
| `AGENT_MIN` | 1 | 3 | 7 |
| `AGENT_MAX` | 3 | 7 | 10 |
| Orchestrator effort | medium | high | xhigh |
| Subagent effort | low | medium | high |

---

## Testing

Each skill has `evaluations.md` with pass/fail criteria. Run the scenario, check output against criteria. Re-run evaluations after any change to `pipeline.md` or a skill's `SKILL.md`.

---

## What's gitignored

`.claude/skills/` (except `reload-skills/`) is gitignored — it's derived from plugin sources. After cloning, run `/reload-skills` once to populate the test install.
