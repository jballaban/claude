# Skills

Skills are slash commands the founder invokes inside Claude Code. Each skill corresponds to one phase of the product lifecycle and activates the agents for that phase.

---

## Skills

| Skill | Trigger | Phase | Description |
|-------|---------|-------|-------------|
| [migrate](framework-migrate/SKILL.md) | `/framework-migrate` | Setup | One-time migration for existing repos. Reconstructs strategy, maps existing features to shallow specs, marks all current main-branch features as built. |
| [strategy](framework-strategy/SKILL.md) | `/framework-strategy` | 1 — Strategy | Define the strategic foundation: competitive landscape, target market, monetization model, GTM approach, and feature principles. Output: `strategy/` folder. |
| [plan](framework-plan/SKILL.md) | `/framework-plan` | 2 — Planning | Plan features from approved strategy. Produces complete specs — business, technical, design, launch, security, infrastructure — and updates the dependency graph. Output: `spec/features/` + `spec/roadmap.md`. |
| [build](framework-build/SKILL.md) | `/framework-build` | 3 — Development | Build the next features in the dependency graph. Reads `spec/roadmap.md` and GitHub branch state, opens issues, implements in parallel, waits for founder to merge PRs. Re-run to advance. |

---

## Sequence

**New project:**
```
/framework-strategy  →  strategy/ committed
    ↓
/framework-plan      →  spec/features/ + spec/roadmap.md committed
    ↓
/framework-build     →  PRs raised  →  founder merges  →  /framework-build  →  ...
```

**Existing project:**
```
/framework-migrate   →  strategy/ + spec/features/ + spec/roadmap.md committed
    ↓
/framework-plan      →  spec new features going forward
    ↓
/framework-build     →  builds from the frontier (existing features already marked built)
```

Each core skill gates the next phase. `/framework-plan` requires `strategy/` to exist. `/framework-build` requires `spec/roadmap.md` to exist.

---

## Adding a skill

1. Create `skills/{skill-name}/SKILL.md` with Claude Code skill frontmatter and instructions
2. Create `skills/{skill-name}/manifest.json` with id, trigger, description, dependencies
3. Add the skill to `.claude-plugin/plugin.json`
4. Update this index
