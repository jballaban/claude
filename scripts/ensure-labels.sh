#!/usr/bin/env bash
# Ensure every label listed in the manifest exists in the current repo.
# Idempotent: existing labels are left alone (color/description are not
# updated, so a human can re-skin them without the workflow stomping on it).
# Dynamic labels (e.g. bounce:<from>-<to>:<N>) are not in the manifest;
# they are created on demand by the workflow that needs them.
#
# Usage:   scripts/ensure-labels.sh [manifest.json]
# Default: config/labels.json
# Env:     GH_TOKEN must be set (workflow context provides it).

set -euo pipefail

MANIFEST="${1:-config/labels.json}"

if [ ! -f "$MANIFEST" ]; then
  echo "Label manifest not found: $MANIFEST" >&2
  exit 1
fi

EXISTING=$(gh label list --limit 200 --json name --jq '[.[].name] | join("\n")')

jq -c '.[]' "$MANIFEST" | while read -r row; do
  name=$(echo "$row" | jq -r '.name')
  color=$(echo "$row" | jq -r '.color')
  desc=$(echo "$row" | jq -r '.description')
  if ! printf '%s\n' "$EXISTING" | grep -Fxq "$name"; then
    echo "Creating label: $name"
    gh label create "$name" --color "$color" --description "$desc"
  fi
done
