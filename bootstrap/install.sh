#!/usr/bin/env bash
# Master bootstrap entrypoint.
# Installs Claude Code / Codex / Skills / MCP templates onto this machine.
#
# Installers are invoked as subprocesses (`bash path/to/install-X.sh`), not sourced.
# This keeps each topic's failures scoped and prevents `exit` in any installer from
# killing the dispatcher.

source "$(dirname "$0")/lib/common.sh"

usage() {
  cat <<EOF
Usage: install.sh [flags]

Flags:
  --dry-run              Preview actions without changing the filesystem.
  --verbose, -v          Extra logging.
  --only LIST            Comma-separated subset: claude-code,codex,skills,mcp.
                         Also accepts --only=LIST. Default: all four.
  --safe                 Conflict mode: back up existing files (DEFAULT).
  --skip-conflicts       Conflict mode: leave existing files alone.
  --force                Conflict mode: overwrite without backup.
  --interactive          Conflict mode: prompt per-file with diff.
  --status               Print installed / drifted / missing files (no changes).
  --uninstall            Remove everything this repo installed (uses manifest).
  -h, --help             Show this message.
EOF
}

ONLY=""
ACTION="install"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)         export DRY_RUN=1 ;;
    --verbose|-v)      export VERBOSE=1 ;;
    --only=*)          ONLY="${1#--only=}" ;;
    --only)
      if [[ $# -lt 2 || -z "$2" ]]; then
        err "--only requires a non-empty argument (e.g. --only claude-code,mcp)"
        exit 2
      fi
      ONLY="$2"; shift ;;
    --safe)            export CONFLICT_MODE=safe ;;
    --skip-conflicts)  export CONFLICT_MODE=skip-conflicts ;;
    --force)           export CONFLICT_MODE=force ;;
    --interactive)     export CONFLICT_MODE=interactive ;;
    --status)          ACTION=status ;;
    --uninstall)       ACTION=uninstall ;;
    -h|--help)         usage; exit 0 ;;
    *)                 err "unknown flag: $1"; usage; exit 2 ;;
  esac
  shift
done

# Route to status / uninstall helpers if requested.
# These scripts are implemented in Tasks 11 and 12. If they aren't there yet,
# print a clear message instead of crashing.
if [[ "$ACTION" == "status" ]]; then
  script="$(dirname "$0")/status.sh"
  if [[ -x "$script" || -f "$script" ]]; then
    bash "$script"
    exit $?
  else
    err "status.sh not yet implemented (Task 11)"
    exit 3
  fi
fi

if [[ "$ACTION" == "uninstall" ]]; then
  script="$(dirname "$0")/uninstall.sh"
  if [[ -x "$script" || -f "$script" ]]; then
    bash "$script"
    exit $?
  else
    err "uninstall.sh not yet implemented (Task 12)"
    exit 3
  fi
fi

ALL_TOPICS=(claude-code codex skills mcp)
if [[ -n "$ONLY" ]]; then
  # Validate each topic in --only is known.
  IFS=',' read -ra TOPICS <<< "$ONLY"
  for t in "${TOPICS[@]}"; do
    valid=0
    for known in "${ALL_TOPICS[@]}"; do
      [[ "$t" == "$known" ]] && valid=1 && break
    done
    if [[ "$valid" -ne 1 ]]; then
      err "unknown topic in --only: '$t' (valid: ${ALL_TOPICS[*]})"
      exit 2
    fi
  done
else
  TOPICS=("${ALL_TOPICS[@]}")
fi

log "installing topics: ${TOPICS[*]}"
log "dry-run=${DRY_RUN:-0} conflict-mode=${CONFLICT_MODE:-safe} verbose=${VERBOSE:-0}"

rc_overall=0
for t in "${TOPICS[@]}"; do
  script="$(dirname "$0")/install-$t.sh"
  if [[ -x "$script" || -f "$script" ]]; then
    if ! bash "$script"; then
      err "installer failed: install-$t.sh (continuing)"
      rc_overall=2
    fi
  else
    err "missing installer: install-$t.sh (expected in $(dirname "$0"))"
    rc_overall=2
  fi
done

if [[ "$rc_overall" -eq 0 ]]; then
  log "done."
else
  warn "done — with errors (rc=$rc_overall)."
fi

exit "$rc_overall"
