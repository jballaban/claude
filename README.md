# claude-plugins

A monorepo of Claude Code plugins.

## Plugins

| Plugin | Description |
|--------|-------------|
| [panel](plugins/panel/) | Convene a panel of domain experts on any question. Three tiers: `/ask`, `/panel`, `/council`. |

## Structure

```
claude-plugins/
├── plugins/
│   └── <plugin-name>/
│       ├── .claude-plugin/plugin.json   # Plugin metadata
│       ├── skills/                       # Skill source files
│       ├── README.md                     # User-facing docs
│       └── README.dev.md                 # Developer docs
├── .claude/skills/reload-skills/        # Dev utility (see below)
├── .hooks/pre-commit                     # Auto-bumps plugin versions on commit
├── reference/                            # Shared reference material
└── .gitignore
```

## Development

See each plugin's `README.dev.md` for plugin-specific development instructions.

For repo-level setup (pre-commit hook installation, reload workflow), see any plugin's `README.dev.md` — the tooling is shared.
