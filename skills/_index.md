# Skills

Skills are slash commands the founder invokes inside Claude Code. Each skill corresponds to one phase of the product lifecycle and activates the agents for that phase.

---

## The three skills

| Skill | Trigger | Phase | Description |
|-------|---------|-------|-------------|
| [strategy](strategy/SKILL.md) | `/strategy` | 1 — Strategy | Define the strategic foundation: competitive landscape, target market, monetization model, GTM approach, and feature principles. Output: `strategy/` folder. |
| [plan](plan/SKILL.md) | `/plan` | 2 — Planning | Plan features from approved strategy. Produces complete specs — business, technical, design, launch, security, infrastructure — and updates the dependency graph. Output: `spec/features/` + `spec/roadmap.md`. |
| [build](build/SKILL.md) | `/build` | 3 — Development | Build the next features in the dependency graph. Reads `spec/roadmap.md` and GitHub branch state, opens issues, implements in parallel, waits for founder to merge PRs. Re-run to advance. |

---

## Sequence

```
/strategy  →  strategy/ committed
    ↓
/plan      →  spec/features/ + spec/roadmap.md committed
    ↓
/build     →  PRs raised  →  founder merges
    ↓
/build     →  next frontier  →  PRs raised  →  founder merges
    ↓
    ...
```

Each skill gates the next phase. `/plan` requires `strategy/` to exist. `/build` requires `spec/roadmap.md` to exist.

---

## Adding a skill

1. Create `skills/{skill-name}/SKILL.md` with Claude Code skill frontmatter and instructions
2. Create `skills/{skill-name}/manifest.json` with id, trigger, description, dependencies
3. Add the skill to `.claude-plugin/plugin.json`
4. Update this index
