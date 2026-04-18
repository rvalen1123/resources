#!/usr/bin/env bash
# Report the state of files recorded in the manifest.
# Called by install.sh when the user passes --status.

source "$(dirname "$0")/lib/common.sh"

if [[ ! -f "$MANIFEST_FILE" ]]; then
  log "no manifest at $MANIFEST_FILE — nothing installed."
  exit 0
fi

log "bootstrap status:"
printf '%-10s  %-7s  %s\n' "STATE" "METHOD" "DEST"

total=0
ok=0
stale=0
drifted=0
diverged=0
missing=0

# The manifest is JSON-lines. We extract fields via sed with a pattern that
# assumes paths and other values don't contain literal `"` or `\` — true for all
# realistic install paths on Git Bash / macOS / Linux. If you hit a path with
# embedded quotes, consider promoting to a real JSON parser (jq / python).
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  src="$(printf '%s' "$line" | sed -E 's/.*"src":"([^"]*)".*/\1/')"
  dest="$(printf '%s' "$line" | sed -E 's/.*"dest":"([^"]*)".*/\1/')"
  recorded_hash="$(printf '%s' "$line" | sed -E 's/.*"hash":"([^"]*)".*/\1/')"
  method="$(printf '%s' "$line" | sed -E 's/.*"method":"([^"]*)".*/\1/')"
  total=$((total + 1))

  state=""

  if [[ ! -e "$dest" && ! -L "$dest" ]]; then
    state="MISSING"
    missing=$((missing + 1))
  elif [[ "$method" == "symlink" ]]; then
    # Expected a symlink. Verify it still points to our src.
    if [[ ! -L "$dest" ]]; then
      state="DRIFTED"
      drifted=$((drifted + 1))
    else
      current_target="$(readlink "$dest")"
      if [[ "$current_target" != "$src" ]]; then
        state="DIVERGED"
        diverged=$((diverged + 1))
      else
        # Link intact; compare src hash to recorded hash.
        if [[ "$(file_sha256 "$src")" == "$recorded_hash" ]]; then
          state="OK"
          ok=$((ok + 1))
        else
          state="STALE"   # src has evolved since install; re-run install to update manifest
          stale=$((stale + 1))
        fi
      fi
    fi
  else
    # method == copy (or anything else treated as a regular file install).
    # Expected a regular file. Verify its content still matches recorded hash.
    if [[ -L "$dest" ]]; then
      state="DIVERGED"   # became a symlink via other means; we didn't install that
      diverged=$((diverged + 1))
    else
      if [[ "$(file_sha256 "$dest")" == "$recorded_hash" ]]; then
        if [[ "$(file_sha256 "$src")" == "$recorded_hash" ]]; then
          state="OK"
          ok=$((ok + 1))
        else
          state="STALE"   # dest still what we installed, but src has evolved
          stale=$((stale + 1))
        fi
      else
        state="DRIFTED"
        drifted=$((drifted + 1))
      fi
    fi
  fi

  printf '%-10s  %-7s  %s\n' "$state" "$method" "$dest"
done < "$MANIFEST_FILE"

echo "---"
log "total=$total  ok=$ok  stale=$stale  drifted=$drifted  diverged=$diverged  missing=$missing"

# Exit code:
#   0 — all OK
#   1 — any inconsistency (stale / drifted / diverged / missing)
if (( ok == total )); then
  exit 0
else
  exit 1
fi
