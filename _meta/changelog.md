# Changelog

## 2026-04-18

### Added
- `skills/templates/branded-docx/` — generic company-branded Word document skill with YAML-config pattern. Extraction of shared structure from two in-house per-company brand skills. Real company configs stay local (gitignored in `configs/`).
- `skills/templates/goaffpro-api/` — GoAffPro affiliate program Admin REST API skill.
- `skills/templates/progressive-web-app/` — PWA skill (service workers, Workbox, offline, installability).
- `skills/templates/research-paper-writing/` — ML/AI research paper pipeline (NeurIPS / ICML / ICLR / ACL / AAAI / COLM templates, LaTeX sources only — compiled PDFs stripped).
- `skills/templates/research-super-skill/` — research knowledge + data analysis + visualization skill.
- `skills/templates/woocommerce-*` (9 skills) — WooCommerce backend dev, code review, copy guidelines, dev cycle, email editor, git commit, draft PR, markdown, performance.
- `skills/templates/wp-woocomm-plugin-themes/` — WordPress + WooCommerce plugin/theme dev with references (woocommerce-themes, wordpress-plugins, wp-cli, woocommerce-blocks).

### Moved / Removed
- Pulled non-skill binary artifacts out of the inbox before committing (signed contracts, partner packages, order forms, an installer `.exe`, compiled PDFs, misc imagery). Relocated outside the repo; none were ever committed.
- Stripped compiled PDFs from `research-paper-writing/templates/*/` (conference templates keep their LaTeX source).
- Moved redundant `.skill` zip archives out of `skills/` (extracted versions are kept).
- Two in-house per-company docx skills held back — the public repo ships the generic `branded-docx` template instead. Company-specific brand data stays in `~/.claude/skills/` locally, outside the public repo.
- `.claude/` project-local state added to `.gitignore` (this repo is a library, not a CC-using project).

## 2026-04-17

- Scaffolded repo (directory skeleton, `_meta/` workflow docs, bootstrap system with 3-layer dedup, install/status/uninstall flow).
