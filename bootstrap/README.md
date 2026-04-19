# Bootstrap

Installs the curated Claude Code / Codex / Skills / MCP baseline onto a fresh machine. Idempotent — safe to re-run.

## Quickstart

```bash
git clone <this-repo> ~/resources
cd ~/resources
bash bootstrap/install.sh --dry-run    # preview
bash bootstrap/install.sh              # real install (safe mode, backs up conflicts)
```

## What it does

For each topic (`claude-code`, `codex`, `skills`, `mcp`), walks `<topic>/templates/` and symlinks every file (except `.gitkeep`) into the tool's expected location:

- **claude-code** → `$CLAUDE_HOME` (default `~/.claude/`)
- **skills** → `$CLAUDE_HOME/skills/`
- **codex** → `$CODEX_HOME` (default `~/.codex/`)
- **mcp** → `$CLAUDE_HOME` (for client configs like `mcp.json`); `server-*/` starter directories are skipped (reference material, not configs)

## Dedup layers (cheapest first)

1. **Already linked.** Destination is a symlink to our source → skip silently.
2. **Content match.** Destination is a regular file with the same hash → remove it and install (upgrade to symlink).
3. **Conflict.** Destination exists and differs → apply `CONFLICT_MODE` (see flags below).

## Manifest

`~/.claude/.bootstrap-manifest.json` records every install as one JSON object per line:

```json
{"src":"...","dest":"...","hash":"...","method":"symlink|copy","ts":"..."}
```

Enables `--status` (report current state) and `--uninstall` (safe removal).

## Flags

- `--dry-run` — preview actions, touch nothing
- `--only claude-code,mcp` — restrict to a subset of topics (also accepts `--only=X`)
- `--safe` — on conflict, back up the existing file to `<file>.bak-<timestamp>` (DEFAULT)
- `--skip-conflicts` — on conflict, leave the existing file alone
- `--force` — on conflict, overwrite without backup
- `--interactive` — on conflict, show a diff and prompt
- `--status` — report each tracked file as OK / STALE / DRIFTED / DIVERGED / MISSING
- `--uninstall` — remove files the manifest records; preserves user-modified (DRIFTED) files
- `--verbose`, `-v` — extra logging
- `--help`, `-h` — show usage

## `--status` states

- **OK** — file is present and matches what we installed; source unchanged since.
- **STALE** — file is still what we installed, but the source has evolved. Re-run install to update.
- **DRIFTED** — file was modified by something other than us. `--uninstall` will leave it alone.
- **DIVERGED** — (symlink installs) link exists but points somewhere other than our source. Left alone.
- **MISSING** — file is gone (user deleted it).

## Windows notes

For real symlinks on Windows you need **both**:

1. **Developer Mode** enabled (Settings → Privacy & Security → For Developers).
2. Git Bash's `MSYS=winsymlinks:nativestrict` flag set so MSYS uses native Windows symlinks instead of copies.

The bootstrap **sets flag #2 automatically** when it detects a Windows Git Bash / MSYS environment (see `lib/common.sh`). You only need to enable Developer Mode.

If Developer Mode is off, `ln -s` falls back to copying, recording `"method":"copy"` in the manifest with a WARN. Install still works — just not a live link. Re-runs remain idempotent via dedup Layer 2.

To verify native symlinks are working after a real install:

```bash
ls -la ~/.claude/skills/<any-skill>/SKILL.md    # should show "file -> /path/to/resources/..."
bash bootstrap/install.sh --status              # method column should show "symlink"
```

## Adding a new topic installer

1. Create `<topic>/templates/` with files to install.
2. Copy `bootstrap/install-claude-code.sh` to `bootstrap/install-<topic>.sh` and edit `SRC_DIR` / `DEST_DIR`.
3. Add `<topic>` to the `ALL_TOPICS` array in `bootstrap/install.sh`.
4. Run `bootstrap/install.sh --dry-run --only <topic>` to verify.

## Files

- `install.sh` — master dispatcher
- `install-claude-code.sh`, `install-codex.sh`, `install-skills.sh`, `install-mcp.sh` — per-topic installers
- `status.sh` — called via `install.sh --status`
- `uninstall.sh` — called via `install.sh --uninstall`
- `lib/common.sh` — shared helpers (logging, paths, manifest, hashing)
- `lib/symlink.sh` — `safe_link` with three-layer dedup
