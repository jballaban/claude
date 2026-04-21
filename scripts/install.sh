#!/usr/bin/env bash
# Installs the Claude agent framework into a target repository.
# Run from the root of the target repo: bash path/to/install.sh

set -euo pipefail

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-$(pwd)}"

echo "Installing Claude framework into: $TARGET_DIR"
echo "Framework source: $FRAMEWORK_DIR"
echo ""

# Create required directories
mkdir -p \
  "$TARGET_DIR/.claude/framework" \
  "$TARGET_DIR/.claude/defaults" \
  "$TARGET_DIR/.claude/skills/pending" \
  "$TARGET_DIR/.claude/skills/conform" \
  "$TARGET_DIR/spec/context" \
  "$TARGET_DIR/spec/current" \
  "$TARGET_DIR/spec/next"

# Copy framework files (always overwrite — these are non-negotiable)
echo "Copying framework files..."
cp "$FRAMEWORK_DIR/.claude/framework/agents.md"                 "$TARGET_DIR/.claude/framework/agents.md"
cp "$FRAMEWORK_DIR/.claude/framework/process.md"                "$TARGET_DIR/.claude/framework/process.md"
cp "$FRAMEWORK_DIR/.claude/framework/quality-gates.md"          "$TARGET_DIR/.claude/framework/quality-gates.md"
cp "$FRAMEWORK_DIR/.claude/framework/architecture-standards.md" "$TARGET_DIR/.claude/framework/architecture-standards.md"
cp "$FRAMEWORK_DIR/.claude/skills/pending/SKILL.md"             "$TARGET_DIR/.claude/skills/pending/SKILL.md"
cp "$FRAMEWORK_DIR/.claude/skills/conform/SKILL.md"             "$TARGET_DIR/.claude/skills/conform/SKILL.md"

# Copy team defaults (always overwrite — update here to change team-wide stack choices)
echo "Copying team defaults..."
cp "$FRAMEWORK_DIR/.claude/defaults/stack.md"    "$TARGET_DIR/.claude/defaults/stack.md"
cp "$FRAMEWORK_DIR/.claude/defaults/patterns.md" "$TARGET_DIR/.claude/defaults/patterns.md"

# Copy MCP config (always overwrite)
cp "$FRAMEWORK_DIR/.mcp.json" "$TARGET_DIR/.mcp.json"

# CLAUDE.md is always overwritten — it is a managed file.
# Project-specific Claude instructions belong in .claude/project/extensions.md.
echo "Updating CLAUDE.md..."
cp "$FRAMEWORK_DIR/templates/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"

# Copy project-owned files only if they do not already exist
echo "Copying project templates (skipping existing files)..."

copy_if_missing() {
  local src="$1"
  local dst="$2"
  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    echo "  Created: $dst"
  else
    echo "  Skipped (exists): $dst"
  fi
}

copy_if_missing "$FRAMEWORK_DIR/templates/spec/context/product.md"          "$TARGET_DIR/spec/context/product.md"
copy_if_missing "$FRAMEWORK_DIR/templates/spec/context/tech-stack.md"       "$TARGET_DIR/spec/context/tech-stack.md"
copy_if_missing "$FRAMEWORK_DIR/templates/spec/context/architecture.md"     "$TARGET_DIR/spec/context/architecture.md"
copy_if_missing "$FRAMEWORK_DIR/templates/spec/context/design-system.md"    "$TARGET_DIR/spec/context/design-system.md"
copy_if_missing "$FRAMEWORK_DIR/templates/spec/context/environments.md"     "$TARGET_DIR/spec/context/environments.md"
copy_if_missing "$FRAMEWORK_DIR/templates/spec/context/conventions.md"      "$TARGET_DIR/spec/context/conventions.md"
copy_if_missing "$FRAMEWORK_DIR/spec/current/overview.md"                   "$TARGET_DIR/spec/current/overview.md"
copy_if_missing "$FRAMEWORK_DIR/spec/next/overview.md"                      "$TARGET_DIR/spec/next/overview.md"

echo ""
echo "Done. Next steps:"
echo "  1. Set GITHUB_TOKEN in your environment for MCP GitHub access"
echo "  2. Run 'claude mcp list' to verify the GitHub MCP server is connected"
echo "  3. Open Claude and run /conform to complete setup"
