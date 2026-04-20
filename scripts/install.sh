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
  "$TARGET_DIR/.claude/skills/pending" \
  "$TARGET_DIR/.claude/context" \
  "$TARGET_DIR/.claude/project" \
  "$TARGET_DIR/spec/current" \
  "$TARGET_DIR/spec/next"

# Copy framework files (always overwrite — these are non-negotiable)
echo "Copying framework files..."
cp "$FRAMEWORK_DIR/.claude/framework/agents.md"                "$TARGET_DIR/.claude/framework/agents.md"
cp "$FRAMEWORK_DIR/.claude/framework/process.md"               "$TARGET_DIR/.claude/framework/process.md"
cp "$FRAMEWORK_DIR/.claude/framework/quality-gates.md"         "$TARGET_DIR/.claude/framework/quality-gates.md"
cp "$FRAMEWORK_DIR/.claude/framework/architecture-standards.md" "$TARGET_DIR/.claude/framework/architecture-standards.md"
cp "$FRAMEWORK_DIR/.claude/skills/pending/SKILL.md"            "$TARGET_DIR/.claude/skills/pending/SKILL.md"

# Copy MCP config (always overwrite)
cp "$FRAMEWORK_DIR/.mcp.json" "$TARGET_DIR/.mcp.json"

# CLAUDE.md is always overwritten — it is a managed file.
# Project-specific instructions belong in .claude/project/extensions.md, not here.
echo "Updating CLAUDE.md..."
cp "$FRAMEWORK_DIR/templates/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"

# Copy template files only if they do not already exist (preserve project customisation)
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

copy_if_missing "$FRAMEWORK_DIR/templates/.claude/project/extensions.md"          "$TARGET_DIR/.claude/project/extensions.md"
copy_if_missing "$FRAMEWORK_DIR/templates/.claude/context/product.md"             "$TARGET_DIR/.claude/context/product.md"
copy_if_missing "$FRAMEWORK_DIR/templates/.claude/context/tech-stack.md"          "$TARGET_DIR/.claude/context/tech-stack.md"
copy_if_missing "$FRAMEWORK_DIR/templates/.claude/context/architecture.md"        "$TARGET_DIR/.claude/context/architecture.md"
copy_if_missing "$FRAMEWORK_DIR/templates/.claude/context/design-system.md"       "$TARGET_DIR/.claude/context/design-system.md"
copy_if_missing "$FRAMEWORK_DIR/templates/.claude/context/environments.md"        "$TARGET_DIR/.claude/context/environments.md"
copy_if_missing "$FRAMEWORK_DIR/templates/.claude/context/conventions.md"         "$TARGET_DIR/.claude/context/conventions.md"
copy_if_missing "$FRAMEWORK_DIR/spec/current/overview.md"                         "$TARGET_DIR/spec/current/overview.md"
copy_if_missing "$FRAMEWORK_DIR/spec/next/overview.md"                            "$TARGET_DIR/spec/next/overview.md"

echo ""
echo "Done. Next steps:"
echo "  1. Fill in .claude/context/*.md with your project details"
echo "  2. Update spec/current/overview.md with what is live"
echo "  3. Update spec/next/overview.md with your next release goals"
echo "  4. Set GITHUB_TOKEN in your environment for MCP GitHub access"
echo "  5. Run 'claude mcp list' to verify the GitHub MCP server is connected"
