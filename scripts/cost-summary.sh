#!/usr/bin/env bash
# Compute this run's agent cost and the running total for the issue.
#
# This-run cost: sum of every `total_cost_usd` field in the claude-code-action
# execution file (one record per Claude SDK call; the file format may be a JSON
# array, JSONL, or a stream of pretty-printed objects — grep handles all three).
#
# Issue total: most recent `<!-- claude-cost: <N> --> ` marker the workflow
# previously embedded in a transition comment. The marker renders invisibly,
# so the comment body stays clean for humans but stays parseable for us.
#
# Usage:   scripts/cost-summary.sh <execution-file>
# Env:     ISSUE, GH_TOKEN, GH_REPO required.
# Stdout:  multi-line cost summary to splice into a transition comment.
# Outputs: writes run= and total= to $GITHUB_OUTPUT if set.

set -euo pipefail

EXEC_FILE="${1:-}"
RUN_COST="0"
if [[ -n "$EXEC_FILE" && -f "$EXEC_FILE" ]]; then
  RUN_COST=$(grep -oE '"total_cost_usd"[[:space:]]*:[[:space:]]*[0-9.eE+-]+' "$EXEC_FILE" \
    | grep -oE '[0-9.eE+-]+$' \
    | awk '{s+=$1} END {if (NR==0) print 0; else printf "%.4f", s}')
fi

PRIOR_TOTAL=$(gh issue view "$ISSUE" --json comments --jq '.comments[].body' 2>/dev/null \
  | grep -oE 'claude-cost: [0-9.]+' \
  | awk '{print $NF}' \
  | tail -1 || true)
PRIOR_TOTAL="${PRIOR_TOTAL:-0}"

TOTAL=$(awk -v a="$RUN_COST" -v b="$PRIOR_TOTAL" 'BEGIN { printf "%.4f", a+b }')

cat <<EOF
💰 Cost: \$${RUN_COST} (this run) | \$${TOTAL} (issue total)
<!-- claude-cost: ${TOTAL} -->
EOF

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "run=$RUN_COST"
    echo "total=$TOTAL"
  } >> "$GITHUB_OUTPUT"
fi
