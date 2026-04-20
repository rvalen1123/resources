#!/usr/bin/env bash
# Common helpers for bootstrap scripts.
# Source this from install-*.sh:  source "$(dirname "$0")/lib/common.sh"

# Note: 'set -euo pipefail' intentionally propagates to sourcing scripts
# — all bootstrap scripts must fail loud on errors and unset variables.
set -euo pipefail

# --- Paths ---
: "${RESOURCES_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
: "${CLAUDE_HOME:=$HOME/.claude}"
readonly MANIFEST_FILE="$CLAUDE_HOME/.bootstrap-manifest.json"

# --- Flags (set by install.sh, read by install-*.sh) ---
: "${DRY_RUN:=0}"
: "${CONFLICT_MODE:=safe}"   # safe | skip-conflicts | force | interactive
: "${VERBOSE:=0}"

# --- Logging ---
log()  { printf '[bootstrap] %s\n' "$*"; }
warn() { printf '[bootstrap] WARN: %s\n' "$*" >&2; }
err()  { printf '[bootstrap] ERROR: %s\n' "$*" >&2; }
vlog() { [[ "$VERBOSE" == 1 ]] && log "$@"; return 0; }

# --- OS detection ---
detect_os() {
  case "$(uname -s)" in
    Linux*)   echo linux ;;
    Darwin*)  echo macos ;;
    MINGW*|MSYS*|CYGWIN*) echo windows ;;
    *)        echo unknown ;;
  esac
}

# On Windows Git Bash / MSYS, `ln -s` silently copies instead of creating real
# symlinks unless MSYS is configured to use native Windows symlinks AND Windows
# Developer Mode is enabled. We auto-set the flag so users don't have to
# remember it; if dev mode is off, `ln -s` will still fail and our _do_link
# fallback in symlink.sh will copy with a WARN (the pre-existing degraded mode).
if [[ "$(detect_os)" == "windows" ]]; then
  export MSYS="${MSYS:+$MSYS }winsymlinks:nativestrict"
fi

# --- File hash ---
# NOTE: Returns empty string + success (0) on missing file. This contract is
# load-bearing: callers under `set -e` compare hashes via command substitution
# (e.g. in symlink.sh), and returning nonzero would abort the caller.
file_sha256() {
  local f="$1"
  [[ -f "$f" ]] || { echo ""; return 0; }
  if command -v sha256sum >/dev/null; then
    sha256sum "$f" | awk '{print $1}'
  else
    shasum -a 256 "$f" | awk '{print $1}'
  fi
}

# --- Timestamped backup suffix ---
backup_suffix() { date +".bak-%Y%m%d-%H%M%S"; }

# --- Ensure the parent directory of a given path exists ---
ensure_parent_dir() {
  local d
  d="$(dirname "$1")"
  [[ -d "$d" ]] || { vlog "mkdir -p $d"; [[ "$DRY_RUN" == 1 ]] || mkdir -p "$d"; }
}

# --- Manifest helpers (JSON lines, to avoid jq dependency) ---
# Escape a string for safe embedding in a JSON string literal.
_json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"    # backslash first (must be before quote)
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

manifest_init() {
  ensure_parent_dir "$MANIFEST_FILE"
  [[ -f "$MANIFEST_FILE" ]] || { [[ "$DRY_RUN" == 1 ]] || : > "$MANIFEST_FILE"; }
}

manifest_record() {
  local src dest hash method entry
  src="$(_json_escape "$1")"
  dest="$(_json_escape "$2")"
  hash="$(_json_escape "$3")"
  method="$(_json_escape "${4:-symlink}")"

  # Dedup: if an entry with the same src, dest, hash, method already exists, skip.
  # We match on a distinctive substring (the src+dest+hash+method tuple) rather than
  # full-line equality to ignore the changing ts field.
  if [[ "$DRY_RUN" != 1 && -f "$MANIFEST_FILE" ]]; then
    local needle
    needle="\"src\":\"${src}\",\"dest\":\"${dest}\",\"hash\":\"${hash}\",\"method\":\"${method}\""
    if grep -qF "$needle" "$MANIFEST_FILE"; then
      vlog "manifest: entry exists for $dest — skip record"
      return 0
    fi
  fi

  entry=$(printf '{"src":"%s","dest":"%s","hash":"%s","method":"%s","ts":"%s"}' \
    "$src" "$dest" "$hash" "$method" "$(date -u +%Y-%m-%dT%H:%M:%SZ)")
  [[ "$DRY_RUN" == 1 ]] || echo "$entry" >> "$MANIFEST_FILE"
}
