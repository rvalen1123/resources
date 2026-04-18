#!/usr/bin/env bash
# Installs Claude Code templates into ~/.claude/.

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/lib/symlink.sh"

manifest_init

# Normalize trailing slash so "${src#"$SRC_DIR"/}" always strips one prefix.
SRC_DIR="${RESOURCES_ROOT}/claude-code/templates"
SRC_DIR="${SRC_DIR%/}"
DEST_DIR="$CLAUDE_HOME"

log "install-claude-code: $SRC_DIR -> $DEST_DIR"

if [[ ! -d "$SRC_DIR" ]]; then
  warn "no templates dir yet: $SRC_DIR — skipping"
  exit 0
fi

# Capture the file list up-front so a `find` failure (missing path, permissions)
# is caught here rather than silently emptying the loop. We use a variable +
# process-substitution `<<< "$files"` to walk it; that keeps the loop in the
# current shell so rc_overall mutations survive (a plain pipe into `while` would
# run the loop in a subshell and lose the update).
if ! files="$(find "$SRC_DIR" -type f ! -name '.gitkeep' 2>&1)"; then
  err "find failed under $SRC_DIR: $files"
  exit 2
fi

rc_overall=0
if [[ -n "$files" ]]; then
  while IFS= read -r src; do
    [[ -z "$src" ]] && continue
    rel="${src#"$SRC_DIR"/}"
    dest="$DEST_DIR/$rel"

    # Capture safe_link's rc without letting `set -e` abort on rc=1 (skip-conflicts).
    rc=0
    safe_link "$src" "$dest" || rc=$?
    case "$rc" in
      0) ;;  # installed / already correct
      1) ;;  # skipped (skip-conflicts) — not an error
      2) err "fatal error (rc=2) linking $src"; rc_overall=2 ;;
      *) err "unexpected rc=$rc from safe_link for $src"; rc_overall=2 ;;
    esac
  done <<< "$files"
fi

exit "$rc_overall"
