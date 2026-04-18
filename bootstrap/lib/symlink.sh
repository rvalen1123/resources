#!/usr/bin/env bash
# Safe symlink helper with dedup.
# Source after common.sh.

# Links SRC -> DEST. Behavior controlled by CONFLICT_MODE.
# Returns: 0 = installed/already-correct, 1 = skipped, 2 = error.
safe_link() {
  local src="$1" dest="$2"

  if [[ ! -e "$src" ]]; then
    err "source missing: $src"
    return 2
  fi

  # Layer 1: symlink already points to us.
  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink "$dest")"
    if [[ "$current" == "$src" ]]; then
      vlog "already linked: $dest"
      return 0
    fi
  fi

  # Layer 2: regular file with matching content.
  if [[ -f "$dest" && ! -L "$dest" ]]; then
    if [[ "$(file_sha256 "$src")" == "$(file_sha256 "$dest")" ]]; then
      log "content matches; upgrading to symlink: $dest"
      [[ "$DRY_RUN" == 1 ]] || { rm "$dest" && _do_link "$src" "$dest"; }
      return 0
    fi
  fi

  # Layer 3: conflict. Dest exists, is not ours, differs.
  if [[ -e "$dest" || -L "$dest" ]]; then
    case "$CONFLICT_MODE" in
      safe)
        local backup="${dest}$(backup_suffix)"
        log "conflict; backing up to $backup"
        [[ "$DRY_RUN" == 1 ]] || mv "$dest" "$backup"
        ;;
      skip-conflicts)
        warn "conflict; skipping: $dest"
        return 1
        ;;
      force)
        log "conflict; forcing overwrite: $dest"
        [[ "$DRY_RUN" == 1 ]] || rm -rf "$dest"
        ;;
      interactive)
        _interactive_resolve "$src" "$dest" || return 1
        ;;
      *)
        err "unknown CONFLICT_MODE: $CONFLICT_MODE"
        return 2
        ;;
    esac
  fi

  # Install.
  ensure_parent_dir "$dest"
  _do_link "$src" "$dest"
  local h; h="$(file_sha256 "$src")"
  manifest_record "$src" "$dest" "$h"
  log "linked: $dest -> $src"
  return 0
}

_do_link() {
  local src="$1" dest="$2"
  [[ "$DRY_RUN" == 1 ]] && return 0
  if ! ln -s "$src" "$dest" 2>/dev/null; then
    # Symlink creation may fail on Windows without dev mode. Fallback to copy.
    warn "symlink failed (Windows dev mode off?); copying instead"
    cp "$src" "$dest"
  fi
}

_interactive_resolve() {
  local src="$1" dest="$2"
  echo "---"
  echo "Conflict: $dest"
  echo "Source:   $src"
  diff -u "$dest" "$src" || true
  read -rp "[o]verwrite / [b]ackup+replace / [s]kip? " choice
  case "$choice" in
    o) [[ "$DRY_RUN" == 1 ]] || rm -rf "$dest"; return 0 ;;
    b) [[ "$DRY_RUN" == 1 ]] || mv "$dest" "${dest}$(backup_suffix)"; return 0 ;;
    s) return 1 ;;
    *) return 1 ;;
  esac
}
