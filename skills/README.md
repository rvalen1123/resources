# Skills

Curated custom Claude Code skills + notes on skill design.

## Layout

- `templates/` — ready-to-install skills. Source of truth for `bootstrap/install-skills.sh`. Each directory under `templates/` is one skill; the bootstrap copies every `<skill>/SKILL.md` (and its supporting files) into `~/.claude/skills/<skill>/`.
- `notes/` — design principles, when-to-write-a-skill, reading list (grows as content lands).

## What's in `templates/`

### Generic / reusable

- **branded-docx** — company-branded Word documents via YAML config. Generic replacement for per-company docx skills. Real brand configs live in `configs/` locally and are gitignored.

### Web dev

- **progressive-web-app** — PWA patterns (service workers, Workbox, offline, installability).

### WordPress / WooCommerce pack

- **wp-woocomm-plugin-themes** — WP plugins + WooCommerce child themes (references: themes, plugins, blocks, WP-CLI).
- **woocommerce-backend-dev** — backend PHP dev conventions.
- **woocommerce-code-review** — reviewing against WC coding standards.
- **woocommerce-copy-guidelines** — UI copy rules.
- **woocommerce-dev-cycle** — tests, linting, quality checks.
- **woocommerce-email-editor** — block email editor work.
- **woocommerce-git-commit** — WC repo commit conventions.
- **woocommerce-git-draft-pr** — draft PR creation.
- **woocommerce-markdown** — markdown in WC.
- **woocommerce-performance** — cache priming + perf patterns.

### Integrations / APIs

- **goaffpro-api** — GoAffPro affiliate Admin REST API.

### Research / knowledge

- **research-paper-writing** — ML/AI paper pipeline with NeurIPS / ICML / ICLR / ACL / AAAI / COLM LaTeX templates.
- **research-super-skill** — research + data exploration + statistical analysis + visualization.

## Authoring new skills

See the official skill-creator skill (available via plugins) for the canonical authoring flow. Drop new skill directories into `templates/` — they'll auto-install via `bash bootstrap/install.sh --only skills`.

## Security note

Some skills (like `branded-docx`) reference a local config file for private data (brand kits, API keys, company specifics). Those files stay local — the repo's `configs/.gitignore` enforces it. Never commit `configs/*.yml` unless it's the documented `example-*.yml` schema.
