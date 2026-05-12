#!/usr/bin/env bash
# Bounce an issue back to a previous stage, tracking a per-stage-pair counter.
# When the counter reaches BOUNCE_LIMIT (default 3), the workflow halts and
# applies claude:awaiting-approval instead of advancing — per CLAUDE.md, this
# is the hard guard against infinite agent loops.
#
# Usage: scripts/bounce.sh <pair> <from-stage> <to-stage> <reason>
#   pair        e.g. "dev-plan" — used in the bounce:<pair>:<N> label
#   from-stage  e.g. "stage:dev" — label to remove
#   to-stage    e.g. "stage:plan" — label to add (only if not halted)
#   reason      free text from the bouncing agent, surfaced in the comment
#
# Env:
#   ISSUE         issue number (required)
#   GH_TOKEN      GitHub token (required)
#   GH_REPO       owner/repo (required)
#   BOUNCE_LIMIT  halt threshold (default 3)

set -euo pipefail

PAIR="$1"
FROM_STAGE="$2"
TO_STAGE="$3"
REASON="${4:-no reason provided}"
LIMIT="${BOUNCE_LIMIT:-3}"

EXISTING=$(gh issue view "$ISSUE" --json labels \
  --jq "[.labels[].name] | map(select(startswith(\"bounce:$PAIR:\"))) | .[0] // empty")

if [[ -n "$EXISTING" ]]; then
  N=$(echo "$EXISTING" | awk -F: '{print $NF}')
  N=$((N + 1))
  gh issue edit "$ISSUE" --remove-label "$EXISTING"
else
  N=1
fi

NEW_LABEL="bounce:$PAIR:$N"
gh label create "$NEW_LABEL" --color "ededed" --description "Bounce counter (auto-managed)" 2>/dev/null || true
gh issue edit "$ISSUE" --add-label "$NEW_LABEL"

COST_SUFFIX=""
if [[ -n "${COST_BLOCK:-}" ]]; then
  COST_SUFFIX=$'\n\n'"$COST_BLOCK"
fi

if [[ "$N" -ge "$LIMIT" ]]; then
  gh issue edit "$ISSUE" --remove-label "$FROM_STAGE" --add-label "claude:awaiting-approval"
  gh issue comment "$ISSUE" --body "🛑 Halted: bounced $N times between \`$FROM_STAGE\` and \`$TO_STAGE\`. Human intervention required. Reason on last bounce: $REASON

To resume after fixing the underlying issue, remove the \`$NEW_LABEL\` label, apply the appropriate stage label manually, and remove \`claude:awaiting-approval\`.${COST_SUFFIX}"
else
  gh issue edit "$ISSUE" --remove-label "$FROM_STAGE" --add-label "$TO_STAGE"
  gh issue comment "$ISSUE" --body "↩️ Bouncing to \`$TO_STAGE\` ($N/$LIMIT): $REASON${COST_SUFFIX}"
fi
