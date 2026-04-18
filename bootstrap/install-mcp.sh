#!/usr/bin/env bash
# Installs MCP-related templates into ~/.claude/ (for client configs like mcp.json).
# Server starters (under server-typescript/, server-python/, etc.) are NOT installed —
# they are reference material to clone, not runtime configs.
#
# Special files that live at $SRC_DIR root:
#   - servers.txt : curated MCP server registration hints. NOT copied; logged only.

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/lib/symlink.sh"

manifest_init

# Normalize trailing slash so "${src#"$SRC_DIR"/}" always strips one prefix.
SRC_DIR="${RESOURCES_ROOT}/mcp/templates"
SRC_DIR="${SRC_DIR%/}"
DEST_DIR="$CLAUDE_HOME"

log "install-mcp: $SRC_DIR -> $DEST_DIR"

if [[ ! -d "$SRC_DIR" ]]; then
  warn "no mcp templates yet: $SRC_DIR — skipping"
  exit 0
fi

# Curated server registrations: log a pointer but don't auto-install.
if [[ -f "$SRC_DIR/servers.txt" ]]; then
  log "curated MCP servers listed in $SRC_DIR/servers.txt"
  log "register them with: claude mcp add <name> <command>"
fi

# Capture the file list up-front. Exclude .gitkeep, servers.txt, and any
# server-* starter directories (those are reference code, not configs).
if ! files="$(find "$SRC_DIR" \
    -type d \( -name 'server-*' -o -name 'servers' \) -prune \
    -o -type f ! -name '.gitkeep' ! -name 'servers.txt' -print 2>&1)"; then
  err "find failed under $SRC_DIR: $files"
  exit 2
fi

rc_overall=0
if [[ -n "$files" ]]; then
  while IFS= read -r src; do
    [[ -z "$src" ]] && continue
    rel="${src#"$SRC_DIR"/}"
    dest="$DEST_DIR/$rel"

    rc=0
    safe_link "$src" "$dest" || rc=$?
    case "$rc" in
      0) ;;
      1) ;;
      2) err "fatal error (rc=2) linking $src"; rc_overall=2 ;;
      *) err "unexpected rc=$rc from safe_link for $src"; rc_overall=2 ;;
    esac
  done <<< "$files"
fi

exit "$rc_overall"
