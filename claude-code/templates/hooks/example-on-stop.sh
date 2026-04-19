#!/usr/bin/env bash
# Example Claude Code hook: fires on the Stop event.
#
# The Stop event runs when Claude finishes responding to a turn. This hook
# appends a single line to a log file so you can see session activity over time.
#
# Hook input arrives on stdin as a JSON object. We pull session_id out of it.
# If jq isn't installed we fall back to a grep + cut pipeline so this works
# out of the box on minimal systems.

set -euo pipefail

LOG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/logs"
LOG_FILE="$LOG_DIR/stop-events.log"

mkdir -p "$LOG_DIR"

input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  session_id="$(printf '%s' "$input" | jq -r '.session_id // "unknown"')"
else
  session_id="$(printf '%s' "$input" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]+"' | cut -d'"' -f4)"
  session_id="${session_id:-unknown}"
fi

timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '%s\tstop\tsession=%s\n' "$timestamp" "$session_id" >> "$LOG_FILE"

# Hooks must exit 0 on success. Non-zero exit surfaces as an error to Claude.
exit 0
