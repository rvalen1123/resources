#!/usr/bin/env bash
# Installs Codex templates into $CODEX_HOME (default: ~/.codex).

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/lib/symlink.sh"

manifest_init

: "${CODEX_HOME:=$HOME/.codex}"
# Normalize trailing slash so "${src#"$SRC_DIR"/}" always strips one prefix.
SRC_DIR="${RESOURCES_ROOT}/codex/templates"
SRC_DIR="${SRC_DIR%/}"
DEST_DIR="$CODEX_HOME"

log "install-codex: $SRC_DIR -> $DEST_DIR"

if [[ ! -d "$SRC_DIR" ]]; then
  warn "no codex templates yet: $SRC_DIR — skipping"
  exit 0
fi

# Capture the file list up-front so a `find` failure is caught here rather than
# silently emptying the loop. Using `<<< "$files"` keeps the loop in the current
# shell so rc_overall mutations survive.
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
