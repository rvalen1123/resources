#!/usr/bin/env bash
# Safe symlink helper with dedup. Requires common.sh to be sourced first.
# (common.sh provides: log/warn/err/vlog, file_sha256, backup_suffix,
#  ensure_parent_dir, manifest_record, and the DRY_RUN/CONFLICT_MODE flags.)

# Sanity guard — fail fast if common.sh wasn't sourced.
if ! declare -F manifest_record >/dev/null 2>&1; then
  echo "symlink.sh: lib/common.sh must be sourced before lib/symlink.sh" >&2
  return 1 2>/dev/null || exit 1
fi

# Refuse to touch pathologically-dangerous destinations.
# Extend this list if you find a case that should be blocked.
_is_dangerous_dest() {
  local d="$1"
  case "$d" in
    ""|"/"|"$HOME"|"$HOME/")
      return 0 ;;
  esac
  return 1
}

# Links SRC -> DEST. Behavior controlled by CONFLICT_MODE.
# Returns: 0 = installed/already-correct, 1 = skipped, 2 = error.
safe_link() {
  local src="$1" dest="$2"

  if [[ ! -e "$src" ]]; then
    err "source missing: $src"
    return 2
  fi

  if _is_dangerous_dest "$dest"; then
    err "refusing to operate on dangerous dest: '$dest'"
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
  # Remove it and fall through to the unified install block so the manifest
  # records this entry (previously Layer 2 returned early and left no trace).
  if [[ -f "$dest" && ! -L "$dest" ]]; then
    if [[ "$(file_sha256 "$src")" == "$(file_sha256 "$dest")" ]]; then
      log "content matches; upgrading to symlink: $dest"
      [[ "$DRY_RUN" == 1 ]] || rm "$dest"
      # fall through to install block
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

  # Install (symlink with copy fallback).
  ensure_parent_dir "$dest"
  _do_link "$src" "$dest" || return 2

  # Detect whether the install is a real symlink or a copy (Windows degraded mode).
  local method="symlink"
  if [[ "$DRY_RUN" != 1 && ! -L "$dest" ]]; then
    method="copy"
    warn "installed as copy (not symlink) at: $dest — likely Windows dev mode off"
  fi

  local h
  h="$(file_sha256 "$src")"
  manifest_record "$src" "$dest" "$h" "$method"
  log "linked: $dest -> $src"
  return 0
}

_do_link() {
  local src="$1" dest="$2"
  [[ "$DRY_RUN" == 1 ]] && return 0
  if ! ln -s "$src" "$dest" 2>/dev/null; then
    # Symlink creation may fail on Windows without dev mode. Fallback to copy.
    warn "symlink failed (Windows dev mode off?); copying instead"
    if ! cp "$src" "$dest"; then
      err "copy fallback also failed for: $dest"
      return 2
    fi
  fi
  return 0
}

_interactive_resolve() {
  local src="$1" dest="$2" choice
  echo "---"
  echo "Conflict: $dest"
  echo "Source:   $src"
  diff -u "$dest" "$src" || true
  # Read from /dev/tty so this works when safe_link is called from
  # a `find ... | while read` pipeline that has consumed stdin.
  read -rp "[o]verwrite / [b]ackup+replace / [s]kip? " choice </dev/tty
  case "$choice" in
    o) [[ "$DRY_RUN" == 1 ]] || rm -rf "$dest"; return 0 ;;
    b) [[ "$DRY_RUN" == 1 ]] || mv "$dest" "${dest}$(backup_suffix)"; return 0 ;;
    s) return 1 ;;
    *) return 1 ;;
  esac
}
