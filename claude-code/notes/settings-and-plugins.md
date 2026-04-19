---
title: Settings and plugins
added: 2026-04-19
tags: [settings, plugins]
---

# Settings and plugins

The surface area is small but worth knowing in one place. This is the distilled
version — the official reference is the source of truth for the full key list.

## The three settings files

Claude Code reads settings from (lowest to highest priority):

1. `~/.claude/settings.json` — **user-level**. Personal defaults across every
   project. Checked in to dotfiles or a curated repo like this one.
2. `<repo>/.claude/settings.json` — **project-level**. Conventions for anyone
   working in the repo. Checked in to the repo.
3. `<repo>/.claude/settings.local.json` — **project-local**. Personal overrides
   for a specific repo. **Gitignored by default.** This is where you put
   machine-specific paths, personal permissions, experimental hooks.

Higher layers override lower ones. Arrays (`permissions.allow`, hooks) merge
additively rather than replacing.

## What goes in settings.json

A partial cheat-sheet of the keys you'll actually touch:

- `statusLine` — a command run continuously to render the status bar. Keep it
  fast (sub-100ms) or it will feel sluggish.
- `enabledPlugins` — object of `"plugin-name@marketplace-name": true` pairs.
  This is the canonical source for which plugins are active for this
  installation.
- `hooks` — event → matcher → command mappings. See `hooks-and-automation.md`.
- `permissions` — `allow` / `deny` / `ask` lists of tool patterns. The
  `less-permission-prompts` skill can auto-populate these.
- `model` — pin a default model (e.g. `claude-opus-4-7`).
- `env` — environment variables exported to tool invocations.

## Plugin enablement via marketplace

Plugins are installed from marketplaces. The flow:

1. Add a marketplace with `/plugin marketplace add <owner>/<repo>`.
2. Install plugins from that marketplace with `/plugin install`.
3. The resolver writes to `settings.json` under `enabledPlugins` as
   `"plugin-name@marketplace-name": true`.

To enable a plugin on a new machine you don't need the interactive flow —
just copy the `enabledPlugins` block into the target `settings.json` and
ensure the marketplace is registered. The template in this repo preserves
an opinionated set as reference material.

### Plugin caches

Plugins are cached under `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/cache/<marketplace>/<plugin>/<version>/`.
That's why the reference `statusLine` in the template does a versioned `ls`
+ sort — the directory name changes when the plugin updates and you want the
newest version.

## settings.json vs settings.local.json

Rule of thumb:

| Put it in settings.json | Put it in settings.local.json |
| --- | --- |
| Anything you'd share with a teammate | Anything machine-specific |
| Canonical plugin list | Experimental hook you're debugging |
| Conventions the repo expects | Your personal permissions shortcuts |
| Hooks everyone should run | Paths that only exist on your laptop |

If you find yourself editing `settings.json` to accommodate your machine, move
that piece to `settings.local.json`.

## Gotchas

- JSON doesn't support comments. Some people stash a `_note` key at the top
  to keep a hint near the file — harmless, ignored by the parser.
- `statusLine.command` is a shell string. On Windows it runs through the
  configured shell (Git Bash or equivalent). Portable invocations beat
  hardcoded paths — try `command -v foo` with a fallback.
- Duplicated keys silently resolve to the last occurrence. Keep the file
  clean and validate with `jq . settings.json` before committing.

## See also

- `templates/settings.json` — portable starter, heavy on comments.
- Official reference: <https://docs.anthropic.com/en/docs/claude-code/settings>
