# Skills

Skills are slash commands available to the product owner inside Claude Code. They provide shortcuts for common workflow actions.

Each skill lives in its own directory. Install by copying the skill directory to `.claude/skills/` in your project.

---

## Available Skills

| Skill | Trigger | Description |
|-------|---------|-------------|
| [pending](pending/SKILL.md) | `/pending` | Surface all items waiting for product owner input — checkpoint approvals, Analyst questions, Architect escalations. |

---

## Adding a skill

1. Create a directory: `skills/{skill-name}/`
2. Add `SKILL.md` with the Claude Code skill frontmatter and instructions
3. Add `manifest.json` with id, trigger, description, tags, dependencies
4. Add the skill to `bundles/full-team/bundle.json`
5. Update `scripts/install.sh` to copy it to `.claude/skills/`

See [bundles/_index.md](../bundles/_index.md) for how skills are packaged with agents.
