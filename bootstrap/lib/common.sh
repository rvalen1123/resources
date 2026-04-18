#!/usr/bin/env bash
# Common helpers for bootstrap scripts.
# Source this from install-*.sh:  source "$(dirname "$0")/lib/common.sh"

set -euo pipefail

# --- Paths ---
: "${RESOURCES_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
: "${CLAUDE_HOME:=$HOME/.claude}"
MANIFEST_FILE="$CLAUDE_HOME/.bootstrap-manifest.json"

# --- Flags (set by install.sh, read by install-*.sh) ---
: "${DRY_RUN:=0}"
: "${CONFLICT_MODE:=safe}"   # safe | skip-conflicts | force | interactive
: "${VERBOSE:=0}"

# --- Logging ---
log()  { printf '[bootstrap] %s\n' "$*"; }
warn() { printf '[bootstrap] WARN: %s\n' "$*" >&2; }
err()  { printf '[bootstrap] ERROR: %s\n' "$*" >&2; }
vlog() { [[ "$VERBOSE" == 1 ]] && log "$@" || true; }

# --- OS detection ---
detect_os() {
  case "$(uname -s)" in
    Linux*)   echo linux ;;
    Darwin*)  echo macos ;;
    MINGW*|MSYS*|CYGWIN*) echo windows ;;
    *)        echo unknown ;;
  esac
}

# --- File hash ---
file_sha256() {
  local f="$1"
  [[ -f "$f" ]] || { echo ""; return; }
  if command -v sha256sum >/dev/null; then
    sha256sum "$f" | awk '{print $1}'
  else
    shasum -a 256 "$f" | awk '{print $1}'
  fi
}

# --- Timestamped backup suffix ---
backup_suffix() { date +".bak-%Y%m%d-%H%M%S"; }

# --- Ensure parent dir exists ---
ensure_dir() {
  local d
  d="$(dirname "$1")"
  [[ -d "$d" ]] || { vlog "mkdir -p $d"; [[ "$DRY_RUN" == 1 ]] || mkdir -p "$d"; }
}

# --- Manifest helpers (JSON lines, to avoid jq dependency) ---
manifest_init() {
  ensure_dir "$MANIFEST_FILE"
  [[ -f "$MANIFEST_FILE" ]] || { [[ "$DRY_RUN" == 1 ]] || echo "" > "$MANIFEST_FILE"; }
}

manifest_record() {
  local src="$1" dest="$2" hash="$3"
  local entry
  entry=$(printf '{"src":"%s","dest":"%s","hash":"%s","ts":"%s"}' \
    "$src" "$dest" "$hash" "$(date -u +%Y-%m-%dT%H:%M:%SZ)")
  [[ "$DRY_RUN" == 1 ]] || echo "$entry" >> "$MANIFEST_FILE"
}
