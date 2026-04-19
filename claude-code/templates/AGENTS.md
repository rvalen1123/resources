# AGENTS.md

This file defines conventions for agents (and humans) working in **${PROJECT_NAME}**.
Keep it short, keep it accurate. If something here is wrong, fix it — stale instructions
are worse than no instructions.

## Project Overview

${PROJECT_NAME} is ${ONE_SENTENCE_DESCRIPTION}. The primary entry point is
`${ENTRY_POINT}` and the deployable artifact is `${ARTIFACT}`.

Key domains / directories:

- `src/` — application code
- `tests/` — test suites (see Build / Test section for runners)
- `scripts/` — developer tooling, migrations, one-offs
- `docs/` — human-facing documentation

## Tech Stack

- **Language:** ${LANGUAGE} (${VERSION})
- **Package manager:** ${PACKAGE_MANAGER}
- **Framework:** ${FRAMEWORK}
- **Datastore:** ${DATASTORE}
- **CI:** ${CI_PROVIDER}

## Conventions

- Prefer editing existing files over creating new ones.
- No new top-level directories without discussion.
- Secrets never land in the repo — use `.env.local` (gitignored) or the secrets manager.
- Generated files live under `build/` or `dist/` and are gitignored.

## Build / Test / Deploy

```bash
# install deps
${INSTALL_COMMAND}

# run the app locally
${RUN_COMMAND}

# run tests
${TEST_COMMAND}

# lint + format
${LINT_COMMAND}

# deploy
${DEPLOY_COMMAND}
```

Long-running commands: prefer `run_in_background` — don't block the agent loop.

## Code Style

- Follow the formatter. If the formatter disagrees with you, the formatter wins.
- Keep functions focused — if a function needs a table of contents, split it.
- Errors bubble up with context; don't swallow them silently.
- Comments explain *why*, not *what*. The code is the *what*.

## Testing

- New behavior ships with tests. Bug fixes ship with a regression test.
- Tests should be deterministic. Flaky test = broken test.
- Prefer fast unit tests over slow integration tests where the coverage is equivalent.

## PR Guidelines

- One logical change per PR. Split refactors from feature work.
- Title is a short imperative phrase; body explains *why* and lists notable tradeoffs.
- Link to the issue or ticket if one exists.
- Run the full test suite locally before pushing.

## Gotchas

- ${GOTCHA_1}
- ${GOTCHA_2}

## When in doubt

Read the nearest `AGENTS.md` for the directory you're working in. Sub-directory
`AGENTS.md` files override this root file for their scope.
