---
name: reload-skills
description: Copies SKILL.md and shared files from all plugin sources (plugins/*/skills/) into the local test location (.claude/skills/) so you can test edits without manually copying files. Not part of any plugin itself.
---

# Reload Skills

Syncs all plugin sources into the local test install so changes are immediately testable.

**Source:** `plugins/*/skills/` (plugin source trees)
**Destination:** `.claude/skills/` (where Claude Code reads skills from)

Plugin-only files (`manifest.json`, `evaluations.md`) are not copied.

## Instructions

Run these commands, then report which files were updated:

```bash
for plugin_dir in plugins/*/; do
  [ -d "${plugin_dir}skills" ] || continue
  for skill_dir in "${plugin_dir}skills/"/*/; do
    skill=$(basename "$skill_dir")
    [ "$skill" = "shared" ] && continue
    mkdir -p ".claude/skills/$skill"
    cp "${skill_dir}SKILL.md" ".claude/skills/$skill/SKILL.md"
  done
  if [ -d "${plugin_dir}skills/shared" ]; then
    cp -r "${plugin_dir}skills/shared/." .claude/skills/shared/
  fi
done
echo "Done."
```

List the destination files to confirm:

```bash
find .claude/skills -type f | sort
```
