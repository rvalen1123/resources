#!/usr/bin/env bash
# Remove files the bootstrap installed (entries recorded in the manifest).
# Only removes destinations that are provably still "ours":
#   - symlink method: dest must be a symlink pointing to our recorded src.
#   - copy method: dest must have the recorded content hash (i.e. unchanged
#     since install). This avoids clobbering files the user has edited.
# Anything else is warned-and-skipped.

source "$(dirname "$0")/lib/common.sh"

if [[ ! -f "$MANIFEST_FILE" ]]; then
  log "no manifest at $MANIFEST_FILE — nothing to uninstall."
  exit 0
fi

log "uninstalling entries recorded in $MANIFEST_FILE"
[[ "${DRY_RUN:-0}" == 1 ]] && log "dry-run — no files will be removed"

total=0
removed=0
skipped=0
missing=0

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  src="$(printf '%s' "$line" | sed -E 's/.*"src":"([^"]*)".*/\1/')"
  dest="$(printf '%s' "$line" | sed -E 's/.*"dest":"([^"]*)".*/\1/')"
  recorded_hash="$(printf '%s' "$line" | sed -E 's/.*"hash":"([^"]*)".*/\1/')"
  method="$(printf '%s' "$line" | sed -E 's/.*"method":"([^"]*)".*/\1/')"
  total=$((total + 1))

  if [[ ! -e "$dest" && ! -L "$dest" ]]; then
    vlog "already missing: $dest"
    missing=$((missing + 1))
    continue
  fi

  case "$method" in
    symlink)
      if [[ ! -L "$dest" ]]; then
        warn "not our symlink anymore (became a regular file?): $dest — leaving alone"
        skipped=$((skipped + 1))
        continue
      fi
      current_target="$(readlink "$dest")"
      if [[ "$current_target" != "$src" ]]; then
        warn "symlink at $dest no longer points to us (target: $current_target) — leaving alone"
        skipped=$((skipped + 1))
        continue
      fi
      log "removing symlink: $dest"
      [[ "${DRY_RUN:-0}" == 1 ]] || rm "$dest"
      removed=$((removed + 1))
      ;;

    copy|"")
      # Copy install (or legacy entry with no method field). Only remove if
      # the current content matches what we recorded — i.e. user hasn't
      # edited the file since install.
      if [[ -L "$dest" ]]; then
        warn "unexpected symlink at $dest (manifest says copy) — leaving alone"
        skipped=$((skipped + 1))
        continue
      fi
      current_hash="$(file_sha256 "$dest")"
      if [[ "$current_hash" != "$recorded_hash" ]]; then
        warn "content changed since install (DRIFTED): $dest — leaving alone"
        skipped=$((skipped + 1))
        continue
      fi
      log "removing copy: $dest"
      [[ "${DRY_RUN:-0}" == 1 ]] || rm "$dest"
      removed=$((removed + 1))
      ;;

    *)
      warn "unknown method '$method' for $dest — leaving alone"
      skipped=$((skipped + 1))
      ;;
  esac
done < "$MANIFEST_FILE"

# Archive the manifest — gives the user a paper trail and clears state.
if [[ "${DRY_RUN:-0}" != 1 ]]; then
  archive="${MANIFEST_FILE}$(backup_suffix)"
  mv "$MANIFEST_FILE" "$archive"
  log "manifest archived to: $archive"
fi

echo "---"
log "uninstall: total=$total removed=$removed skipped=$skipped missing=$missing"
