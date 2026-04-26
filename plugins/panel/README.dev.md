# Council of Elrond — Developer Guide

This document covers the development workflow for contributors working on the plugin.

---

## Repo structure

```
plugins/panel/
├── .claude-plugin/
│   └── plugin.json                 # Plugin metadata (name, version, author)
├── skills/
│   ├── elrond/
│   │   ├── SKILL.md                # Gateway skill — Elrond routes to council
│   │   └── manifest.json
│   ├── council/
│   │   ├── SKILL.md                # Main council workflow (8 steps)
│   │   └── manifest.json
│   ├── version/
│   │   ├── SKILL.md                # Version display
│   │   └── manifest.json
│   └── shared/
│       └── roles-catalog.md        # Named role directives (Product Manager, UX Designer, etc.)
├── README.md                       # User-facing docs
└── README.dev.md                   # This file

.claude/skills/reload-skills/       # Dev utility (repo-level, not part of any plugin)
.hooks/pre-commit                   # Repo-level hook — install once per clone
```

**Key distinction:** `plugins/panel/skills/` is the source of truth. `.claude/skills/` is the local test install — populated by `/reload-skills` and gitignored.

---

## Local development workflow

### First-time setup

```bash
cp .hooks/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
```

### Edit → Test loop

1. Edit files in `plugins/panel/skills/`
2. Run `/reload-skills` to sync into the local test install
3. Test with `/elrond` or `/council` in this directory
4. Repeat

---

## Version management

The pre-commit hook bumps the patch version automatically for any plugin with staged changes.

- Increments patch in `plugins/panel/.claude-plugin/plugin.json`
- Updates the version string in `plugins/panel/skills/version/SKILL.md`
- Stages both files as part of the commit

To bump minor or major, edit `plugin.json` manually before committing.

---

## Adding a role to the catalog

Edit `plugins/panel/skills/shared/roles-catalog.md`. Each role is a named section with a directive — a 3–4 sentence instruction covering who the role is, what they instinctively look for, and how they push back. Run `/reload-skills` after editing.

---

## Adding a new skill

1. Create `plugins/panel/skills/<name>/SKILL.md`
2. Create `plugins/panel/skills/<name>/manifest.json`
3. Add `.claude/skills/<name>/` to `.gitignore`
4. Run `/reload-skills` — the new skill is auto-discovered

---

## Enabling agent teams

The finalization step (Step 7) uses agent teams if available. Requires Claude Code v2.1.32+ and:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Without this, Step 7 falls back to parallel subagents.

---

## Council workflow overview

| Step | What happens |
|------|-------------|
| 1 | Elrond proposes a roster → **user confirms** |
| 2 | Council assembled from roles catalog |
| 3 | All members analyze in parallel (structured JSON) |
| 4 | Elrond consolidates — equal weight, severity-ordered |
| 5 | Gandalf reviews for coherence and drift |
| 6 | Summary shown to user → **user accepts or redirects** |
| 7 | Council reconvenes (team or parallel) — confidence ratings |
| 8 | Final output: answer + confidence table |
