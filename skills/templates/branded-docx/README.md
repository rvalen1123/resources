# branded-docx

A generic, reusable Claude Code skill for producing fully branded Word (`.docx`)
documents for any company. It encodes the structural rules (table widths,
heading hierarchy, callout layouts, signature blocks, accessibility) once, and
loads the brand-specific values — colors, fonts, company name, domain, signature
templates — from a YAML config at runtime.

## How it differs from the generic `docx` skill

- The base `docx` skill produces unbranded, structurally valid `.docx` output.
- `branded-docx` extends it with a strict brand system: every color, font, and
  company string is resolved from a config file, and every structural decision
  (table sizes, spacing, callout shapes) is pinned by the skill itself.
- You only need one copy of this skill to serve any number of brands — one
  config file per company replaces the need for a bespoke per-company skill.

## Config pattern

- `configs/example-brand.yml` is the schema. Every variable the skill expects
  is defined there with an inline comment. Uses fake "Acme Widgets" values.
- To onboard your company: copy it to `configs/<your-company>.yml`, fill in
  every field, and tell Claude the path when you invoke the skill.
- Files matching `configs/*.yml` are gitignored (only `example-brand.yml` is
  allowed). Drop `company-a.yml`, `company-b.yml`, etc. into `configs/` and
  they stay local to your machine.

## Security

Real brand kits are confidential and NOT committed to this repo. The
`configs/.gitignore` enforces this by excluding every `*.yml` / `*.yaml` file
except the documented example. Verify with `git status` before committing.

## Usage

Read `SKILL.md` for the full rule set, variable list, and quick-start code
skeleton. In chat, invoke with: "Use the branded-docx skill with config at
`skills/templates/branded-docx/configs/<your-company>.yml` to generate [doc]."
