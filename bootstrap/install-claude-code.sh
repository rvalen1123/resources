#!/usr/bin/env bash
# Installs Claude Code templates into ~/.claude/.

source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/lib/symlink.sh"

manifest_init

SRC_DIR="$RESOURCES_ROOT/claude-code/templates"
DEST_DIR="$CLAUDE_HOME"

log "install-claude-code: $SRC_DIR -> $DEST_DIR"

if [[ ! -d "$SRC_DIR" ]]; then
  warn "no templates dir yet: $SRC_DIR — skipping"
  exit 0
fi

# Walk templates/ and symlink each file into $DEST_DIR preserving relative paths.
# .gitkeep files are skipped (placeholders only).
rc_overall=0
while IFS= read -r src; do
  rel="${src#"$SRC_DIR"/}"
  dest="$DEST_DIR/$rel"
  set +e
  safe_link "$src" "$dest"
  rc=$?
  set -e
  case "$rc" in
    0) ;;                            # installed / already correct
    1) ;;                            # skipped (skip-conflicts) — not an error
    2) err "fatal error linking $src"; rc_overall=2 ;;
    *) err "unexpected rc=$rc from safe_link for $src"; rc_overall=2 ;;
  esac
done < <(find "$SRC_DIR" -type f ! -name '.gitkeep')

exit "$rc_overall"
