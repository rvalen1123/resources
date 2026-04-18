# Resources

Personal curated library for AI agent development: Claude Code, Codex, custom Skills, MCP, and agent theory. Dual-purpose as (a) an idempotent bootstrap for any new machine, (b) a browseable reference library of templates + notes per topic.

## Quickstart

```bash
# On a new machine
git clone <repo-url> ~/resources
cd ~/resources
bash bootstrap/install.sh --dry-run    # preview
bash bootstrap/install.sh              # safe install (backs up any conflicts)
```

See [`bootstrap/README.md`](bootstrap/README.md) for flags, conflict modes, `--status`, and `--uninstall`.

## Layout

| Folder               | Purpose                                                        |
| -------------------- | -------------------------------------------------------------- |
| `claude-code/`       | Claude Code CLI templates + notes                              |
| `codex/`             | Codex configs + notes                                          |
| `skills/`            | Custom skill authoring: templates + notes                      |
| `mcp/`               | MCP server/client templates + curated servers                  |
| `agent-theory/`      | Conceptual notes (ReAct, memory, RAG). Notes-only.             |
| `bootstrap/`         | Install scripts. Entrypoint: `bootstrap/install.sh`.           |
| `need-to-organize/`  | Inbox. Drop anything here; I'll triage on request.             |
| `_meta/`             | Conventions, changelog, reading queue, filing cheat sheet.     |

## Topic folder shape

Every topic (except `agent-theory/`, which is notes-only) follows:

```
<topic>/
├── README.md        # what this is, why it matters
├── templates/       # copy-paste-ready files (source of truth for bootstrap)
└── notes/
    ├── README.md    # annotated reading list + TOC of local notes (added as notes grow)
    └── *.md         # distilled learnings, one file per subtopic
```

## Workflow

- **Filing new material:** drop in `need-to-organize/` and ask for triage, or file directly per [`_meta/how-to-add-entries.md`](_meta/how-to-add-entries.md).
- **Conventions:** [`_meta/conventions.md`](_meta/conventions.md) — frontmatter, filenames, tag rules.
- **What changed recently:** [`_meta/changelog.md`](_meta/changelog.md) — dated log of structural changes.
- **What I want to read:** [`_meta/reading-queue.md`](_meta/reading-queue.md) — URLs waiting to become notes.

## License

Personal library. No license specified — treat as all-rights-reserved by default. If you stumbled across this and want to use something, ask.
