# How to Add Entries

## Quick filing

1. If you know where it goes → drop it in `<topic>/templates/` or `<topic>/notes/`
2. If you're not sure → drop it in `need-to-organize/`
3. Add it to `_meta/changelog.md` with today's date

## Adding a note

1. Pick the right topic folder
2. Create `<topic>/notes/<kebab-case-name>.md`
3. Add YAML frontmatter (see `conventions.md`)
4. Link from `<topic>/notes/README.md`

## Adding a template

1. Drop native-format file into `<topic>/templates/`
2. If bootstrap should install it, ensure the relevant `bootstrap/install-<topic>.sh` knows about it
3. Run `bootstrap/install.sh --dry-run` to preview
