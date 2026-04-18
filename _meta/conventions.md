# Conventions

## Filenames

- `kebab-case.md`
- No dates in filenames (dates live in frontmatter)
- Templates use the tool's native format, no invented wrappers

## Note frontmatter

Every note starts with YAML frontmatter:

```yaml
---
title: Short descriptive title
added: YYYY-MM-DD
source: <URL if distilled from somewhere, otherwise omit>
tags: [tag1, tag2]
---
```

## Topic READMEs

Every topic's `notes/README.md` serves dual purpose:

1. Index of local notes (TOC)
2. Annotated reading list — external links with 1-line takeaway each

## Template files

- Native format only (e.g. `settings.json`, not `settings.template.json`)
- Secrets use `${VAR}` placeholders, never hardcoded
- Alongside each secret-referencing template, include `.env.example`
