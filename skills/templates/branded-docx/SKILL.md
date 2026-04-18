---
name: branded-docx
description: "Create branded Word (.docx) documents for any company using its brand kit. Load a config YAML with company identity, color palette, fonts, and signature templates. Generic replacement for per-company docx skills. Pair with your own company config file (kept private/local — not in this public repo)."
---

# Branded DocX — Generic Company-Branded Document Skill

## Overview

This skill produces **production-grade, fully branded Word documents** (`.docx`) for any company. It is the generic, brand-agnostic extraction of per-company docx skills: the structural rules (table widths, heading hierarchy, callout box shapes, signature block layout, spacing, accessibility requirements) are fixed by this skill, while every brand-specific value — colors, fonts, company name, domain, logo variants, signature wording — is loaded from a **brand config** file at runtime.

**MANDATORY**: When this skill is active, ALL `.docx` documents must follow the structural rules below. Read this entire file before generating any document code. Load the brand config before picking any colors, fonts, or company strings.

**When to use this skill:**
- Creating any `.docx` deliverable for a specific company (report, memo, playbook, proposal, one-pager, agreement, audit, clinical summary, etc. — see `{{DOCUMENT_TYPES}}`).
- Standardizing brand expression across a portfolio of companies without maintaining a separate skill per company.
- Bootstrapping a new company's document standard in minutes: write the config, invoke the skill.

**When NOT to use it:**
- Generic unbranded docx output — use the base `docx` skill instead.
- PDFs, slides, or spreadsheets — use `pdf`, `pptx`, `xlsx`.

---

## 1. Providing the Brand Kit

This skill is driven by a YAML **brand config**. You must have one available before generating any document. Three equivalent ways to supply it:

1. **Point Claude at a local config path.** Put your real config at e.g. `configs/acme-widgets.yml` next to this skill and tell Claude: "Use the Acme Widgets config at `configs/acme-widgets.yml`." Files matching `configs/*.yml` are gitignored by default — they stay local.
2. **Paste the YAML in chat.** Open `configs/example-brand.yml`, copy it, fill in your values, and paste the result into your message.
3. **Inline overrides.** For one-off experiments, state the values directly ("Primary color `#123456`, heading font Inter, company name Foo Inc.") and Claude will assemble the config internally.

The schema lives in `configs/example-brand.yml`. Every variable the skill references below is defined there with an inline comment. **Do not invent values that aren't in the config** — if something is missing, ask the user.

### Variables this skill expects

Identity:
- `{{COMPANY_NAME}}` — legal or display name (e.g. "Acme Widgets, Inc.")
- `{{COMPANY_NAME_SHORT}}` — short form for headers (e.g. "Acme Widgets")
- `{{COMPANY_DOMAIN}}` — e.g. "acmewidgets.example"
- `{{COMPANY_TAGLINE}}` — optional tagline for cover pages
- `{{DOCUMENT_TYPES}}` — list of document categories this brand produces (e.g. reports, memos, playbooks, proposals, one-pagers, agreements, audits)

Color palette (HEX, with `#` in config; the skill strips `#` when passing to docx-js):
- `{{BRAND_COLOR_PRIMARY}}` / `{{BRAND_COLOR_PRIMARY_NAME}}` — primary accent: H1, table headers, primary dividers
- `{{BRAND_COLOR_ACCENT}}` / `{{BRAND_COLOR_ACCENT_NAME}}` — accent: H2 / callout borders / success indicators
- `{{BRAND_COLOR_SECONDARY}}` / `{{BRAND_COLOR_SECONDARY_NAME}}` — tertiary accent: H3, lighter highlights
- `{{BRAND_COLOR_TEXT_DARK}}` — body text (NEVER pure black)
- `{{BRAND_COLOR_TEXT_MUTED}}` — captions, footnotes, footer text
- `{{BRAND_COLOR_BACKGROUND_LIGHT}}` — alternating table rows, light fills
- `{{BRAND_COLOR_CALLOUT_BG_INFO}}` — info callout fill
- `{{BRAND_COLOR_CALLOUT_BG_SUCCESS}}` — success callout fill
- `{{BRAND_COLOR_WARNING_BORDER}}` — warning callout border
- `{{BRAND_COLOR_WARNING_BG}}` — warning callout fill
- `{{BRAND_COLOR_WHITE}}` — usually `#FFFFFF`, kept configurable for off-white brands
- `{{BRAND_COLOR_BORDER_LIGHT}}` — thin table cell border gray (e.g. `#CCCCCC`)

Typography:
- `{{FONT_HEADING}}` — heading font family (e.g. "Source Sans 3")
- `{{FONT_BODY}}` — body font family (often same as heading)
- `{{FONT_BODY_FALLBACK}}` — widely-available fallback (typically "Arial")
- `{{FONT_MONO}}` — optional monospace font for codes/figures (e.g. "Fira Mono")
- `{{FONT_PSYCHOLOGY_NOTE}}` — optional rationale paragraph for why these fonts were chosen

Identity assets:
- `{{LOGO_VARIANTS}}` — list of logo variants the brand provides (full lockup, monogram, monochrome, etc.) with the intended usage for each

Document framing:
- `{{HEADER_TEMPLATE}}` — running-header layout string
- `{{FOOTER_TEMPLATE}}` — running-footer layout string
- `{{SIGNATURE_BLOCK_TEMPLATE}}` — layout description for signature blocks (which fields, which order, which labels are bold)
- `{{CONFIDENTIALITY_LINE}}` — footer confidentiality text (e.g. "Confidential — Acme Widgets, Inc.")

If a variable is marked optional in the config and absent, skip the corresponding feature; do not substitute a hardcoded default from any other brand.

---

## 2. Page Setup (applies to every document regardless of brand)

```
Margins:        1 inch all sides (1440 DXA)
Paper:          Letter (8.5" x 11")
Usable width:   9360 DXA (6.5 inches between margins)
Font:           {{FONT_BODY}} throughout (fallback {{FONT_BODY_FALLBACK}})
Base body size:  11pt (size: 22 in docx-js, which uses half-points)
Language:       "en-US" on the Document constructor (accessibility)
```

---

## 3. Typography Hierarchy

Every document uses this scale. Sizes are in docx-js half-points. Fonts and colors come from the config.

| Element                      | Font              | Size (half-pt) | Weight   | Color                         | Alignment |
|------------------------------|-------------------|----------------|----------|-------------------------------|-----------|
| Document title (company)     | `{{FONT_HEADING}}`| 48             | Bold     | `{{BRAND_COLOR_TEXT_DARK}}`   | Center    |
| Document subtitle            | `{{FONT_HEADING}}`| 36             | Bold     | `{{BRAND_COLOR_TEXT_DARK}}`   | Center    |
| Version line                 | `{{FONT_HEADING}}`| 24             | Italic   | `{{BRAND_COLOR_PRIMARY}}`     | Center    |
| H1 section heading           | `{{FONT_HEADING}}`| 28–34          | Bold     | `{{BRAND_COLOR_PRIMARY}}`     | Left      |
| H2 sub-section               | `{{FONT_HEADING}}`| 24–26          | SemiBold | `{{BRAND_COLOR_ACCENT}}`      | Left      |
| H3                           | `{{FONT_HEADING}}`| 22             | SemiBold | `{{BRAND_COLOR_SECONDARY}}`   | Left      |
| Body                         | `{{FONT_BODY}}`   | 21–22          | Regular  | `{{BRAND_COLOR_TEXT_DARK}}`   | Left      |
| Body emphasis (bold lead-in) | `{{FONT_BODY}}`   | 21–22          | Bold     | `{{BRAND_COLOR_TEXT_DARK}}`   | —         |
| Table header                 | `{{FONT_BODY}}`   | 16–20          | Bold     | `{{BRAND_COLOR_WHITE}}` on `{{BRAND_COLOR_PRIMARY}}` | Center |
| Table body                   | `{{FONT_BODY}}`   | 16–20          | Regular  | `{{BRAND_COLOR_TEXT_DARK}}`   | see §4C  |
| Callout title                | `{{FONT_HEADING}}`| 21             | Bold     | per callout type              | Center    |
| Callout body                 | `{{FONT_BODY}}`   | 19             | Italic   | `{{BRAND_COLOR_TEXT_DARK}}`   | Center    |
| Pull quote                   | `{{FONT_HEADING}}`| 24             | Light It.| `{{BRAND_COLOR_PRIMARY}}`     | Left      |
| Caption / footer             | `{{FONT_BODY}}`   | 15–16          | Regular  | `{{BRAND_COLOR_TEXT_MUTED}}`  | Center    |
| Monospace data (optional)    | `{{FONT_MONO}}`   | 16             | Regular  | `{{BRAND_COLOR_TEXT_DARK}}`   | —         |

**Body text is ALWAYS `{{BRAND_COLOR_TEXT_DARK}}`, never pure `#000000`.** Use monospace only when the brand config supplies `{{FONT_MONO}}` and only for content where character discrimination matters (codes, IDs, tabular figures).

---

## 4. Tables — THE CRITICAL RULES

### Rule 4A: Every table spans the full usable width (9360 DXA)

No narrow tables. Split the 9360 DXA across columns:

```javascript
// 2-column table: columnWidths: [4680, 4680]
// 3-column table: columnWidths: [3120, 3120, 3120]
// Key-value table: columnWidths: [3120, 6240]
// 5-column table:  columnWidths: [1872, 1872, 1872, 1872, 1872]
// Full-width box:  columnWidths: [9360]
```

### Rule 4B: Header rows use solid `{{BRAND_COLOR_PRIMARY}}` background with white bold text, centered

```javascript
new TableCell({
  borders: cellBorders,
  width: { size: WIDTH, type: WidthType.DXA },
  shading: { fill: BRAND_PRIMARY, type: ShadingType.CLEAR }, // ALWAYS ShadingType.CLEAR
  verticalAlign: VerticalAlign.CENTER,
  children: [new Paragraph({
    alignment: AlignmentType.CENTER,
    children: [new TextRun({ text: "Header Text", bold: true, size: 20, color: "FFFFFF" })]
  })],
})
```

Also set `tableHeader: true` on the header TableRow for screen-reader accessibility.

### Rule 4C: Data cell alignment

Use the alignment convention that fits the brand's document style. Two common patterns — pick one at the config level and use it consistently:

- **Center-all pattern**: all data cells center-aligned. Good for summary tables with short values.
- **Leftmost-label pattern**: column 0 LEFT-aligned (it's the row label), columns 1+ CENTER-aligned. Good for data tables with a label column.

Key-value tables (Rule 4D) always left-align the value column for long content; center-align short scalar values.

### Rule 4D: Key-value tables

- Left column: bold `{{BRAND_COLOR_PRIMARY}}` text on `{{BRAND_COLOR_BACKGROUND_LIGHT}}` background, centered
- Right column: regular `{{BRAND_COLOR_TEXT_DARK}}` text, left-aligned for paragraphs, centered for short values

### Rule 4E: Set widths on BOTH the Table and each TableCell

```javascript
new Table({
  columnWidths: [3120, 3120, 3120],  // REQUIRED at table level
  rows: [new TableRow({ cantSplit: true, children: [
    new TableCell({ width: { size: 3120, type: WidthType.DXA }, ... }),  // ALSO on each cell
  ]})],
})
```

### Rule 4F: Keep tables together on the page

- Every TableRow gets `cantSplit: true` by default.
- Paragraph immediately preceding a table gets `keepNext: true`.
- For 15+ row tables, `cantSplit` may be omitted on data rows, but the header + first data row must stay together.

### Rule 4G: Alternating row shading

Tables with 4+ data rows use alternating white / `{{BRAND_COLOR_BACKGROUND_LIGHT}}` row backgrounds to improve scannability. Header row is always `{{BRAND_COLOR_PRIMARY}}`.

### Rule 4H: Callout / disclaimer boxes

Callout boxes are single-cell, full-width (9360 DXA) tables with a thick left accent border. The skill supports four types:

| Type     | Border color                     | Fill color                          | Title color                      |
|----------|----------------------------------|-------------------------------------|----------------------------------|
| info     | `{{BRAND_COLOR_PRIMARY}}`        | `{{BRAND_COLOR_CALLOUT_BG_INFO}}`   | `{{BRAND_COLOR_PRIMARY}}`        |
| success  | `{{BRAND_COLOR_ACCENT}}`         | `{{BRAND_COLOR_CALLOUT_BG_SUCCESS}}`| `{{BRAND_COLOR_ACCENT}}`         |
| action   | `{{BRAND_COLOR_SECONDARY}}`      | `{{BRAND_COLOR_BACKGROUND_LIGHT}}`  | `{{BRAND_COLOR_SECONDARY}}`      |
| warning  | `{{BRAND_COLOR_WARNING_BORDER}}` | `{{BRAND_COLOR_WARNING_BG}}`        | `{{BRAND_COLOR_WARNING_BORDER}}` |

Layout rules for every callout:
- Thick left border (size 8), thin top/bottom/right (size 1), matching color
- Title: CENTERED, bold, in the title color
- Body lines: CENTERED, **italicized**; bold the most important token inside each line
- Generous padding: `margins: { top: 120, bottom: 120, left: 200, right: 200 }`
- 200 DXA vertical margin above and below the callout

### Rule 4I: Summary box style

For "what this package includes" boxes:
- Left + top + bottom border in `{{BRAND_COLOR_PRIMARY}}` (size 3), NO right border
- No background fill (white)
- Contains a bold header line followed by a bullet list

---

## 5. Section Dividers

Between every major section, place a **thin accent divider**: a small cap of `{{BRAND_COLOR_ACCENT}}` on the left, then a `{{BRAND_COLOR_PRIMARY}}` stripe across the rest of the page. Row height is `exact 40` (≈2 pt) so it renders as a crisp line, not an empty row.

```javascript
function divider() {
  return new Table({
    columnWidths: [200, 9160],
    rows: [new TableRow({
      height: { value: 40, rule: "exact" },
      children: [
        new TableCell({
          borders: allNoBorder,
          width: { size: 200, type: WidthType.DXA },
          shading: { fill: BRAND_ACCENT, type: ShadingType.CLEAR },
          children: [new Paragraph({ spacing: sp(0, 0), children: [new TextRun({ text: "", size: 2 })] })],
        }),
        new TableCell({
          borders: allNoBorder,
          width: { size: 9160, type: WidthType.DXA },
          shading: { fill: BRAND_PRIMARY, type: ShadingType.CLEAR },
          children: [new Paragraph({ spacing: sp(0, 0), children: [new TextRun({ text: "", size: 2 })] })],
        }),
      ],
    })],
  });
}
```

**Key details:**
- `height: { value: 40, rule: "exact" }` forces the row to ≈2 pt tall (no default line-height bloat)
- `size: 2` on the empty TextRun prevents Word from padding the paragraph
- Accent cap is 200 DXA (~0.14"), primary fill takes the remaining 9160 DXA
- No borders anywhere — the color fills ARE the divider
- Total width: 200 + 9160 = 9360 (full usable width)

Place a divider:
- Before each H1 section heading
- Before the SIGNATURES heading
- After the last signature block (before the closing line)

---

## 6. Paragraph Patterns

### Bold lead-in pattern

```javascript
new Paragraph({
  spacing: { before: 80, after: 80 },
  children: [
    new TextRun({ text: "Term. ", bold: true, size: 22, color: TEXT_DARK }),
    new TextRun({ text: "This Agreement begins on...", size: 22, color: TEXT_DARK }),
  ],
})
```

### H1 section heading

```javascript
new Paragraph({
  spacing: { before: 360, after: 200 },
  children: [new TextRun({
    text: "1. APPOINTMENT",                 // ALL CAPS for H1
    bold: true, size: 28, color: BRAND_PRIMARY, font: FONT_HEADING,
  })],
})
```

### H2 sub-heading

```javascript
new Paragraph({
  spacing: { before: 280, after: 160 },
  children: [new TextRun({
    text: "Commission Tiers",               // Title Case for H2
    bold: true, size: 24, color: BRAND_ACCENT, font: FONT_HEADING,
  })],
})
```

### H3

```javascript
new Paragraph({
  spacing: { before: 200, after: 120 },
  children: [new TextRun({
    text: "Detail Subhead", bold: true, size: 22, color: BRAND_SECONDARY, font: FONT_HEADING,
  })],
})
```

### Pull quote

```javascript
new Table({
  width: { size: 7200, type: WidthType.DXA },
  columnWidths: [7200],
  rows: [new TableRow({ cantSplit: true, children: [new TableCell({
    borders: {
      top: noBorder, bottom: noBorder, right: noBorder,
      left: { style: BorderStyle.SINGLE, size: 6, color: BRAND_PRIMARY },
    },
    margins: { top: 80, bottom: 80, left: 240, right: 80 },
    children: [
      new Paragraph({ children: [new TextRun({
        text: `\u201C${text}\u201D`, italics: true, size: 24, color: BRAND_PRIMARY, font: FONT_HEADING,
      })] }),
      new Paragraph({ children: [new TextRun({
        text: `\u2014 ${attribution}`, size: 17, color: TEXT_MUTED, font: FONT_BODY,
      })] }),
    ],
  })] })],
})
```

---

## 7. Bullet Lists

Always use Word numbering — NEVER unicode bullets in text:

```javascript
numbering: { config: [{
  reference: "bullets",
  levels: [{
    level: 0,
    format: LevelFormat.BULLET,
    text: "\u2022",
    alignment: AlignmentType.LEFT,
    style: { paragraph: { indent: { left: 720, hanging: 360 } } },
  }],
}]}
```

Inside list items, **bold the scannable anchors**: dollar amounts, time periods, brand names, action keywords (MUST, NEVER, REQUIRED), domain-specific codes. This turns a wall of bullets into something a reader can skim in 3 seconds.

---

## 8. Headers & Footers

### Running header (every page)

Layout per `{{HEADER_TEMPLATE}}` — typical shape:

```javascript
new Header({ children: [new Paragraph({
  alignment: AlignmentType.RIGHT,
  border: { bottom: { style: BorderStyle.SINGLE, size: 2, color: BRAND_PRIMARY, space: 4 } },
  children: [
    mkRun("{{COMPANY_NAME_SHORT}}", { size: 16, bold: true, color: BRAND_PRIMARY }),
    mkRun("  |  ", { size: 16, color: TEXT_MUTED }),
    mkRun("[Document Title]  |  [Date]", { size: 15, color: TEXT_MUTED, italics: true }),
  ],
})]})
```

### Running footer (every page)

Layout per `{{FOOTER_TEMPLATE}}` — typical shape:

```javascript
new Footer({ children: [new Paragraph({
  alignment: AlignmentType.CENTER,
  border: { top: { style: BorderStyle.SINGLE, size: 2, color: BRAND_ACCENT, space: 4 } },
  children: [
    mkRun("{{COMPANY_DOMAIN}}", { size: 15, color: TEXT_MUTED }),
    mkRun("  |  Page ", { size: 15, color: TEXT_MUTED }),
    new TextRun({ children: [PageNumber.CURRENT], font: FONT_BODY, size: 15, color: TEXT_MUTED }),
    mkRun(" of ", { size: 15, color: TEXT_MUTED }),
    new TextRun({ children: [PageNumber.TOTAL_PAGES], font: FONT_BODY, size: 15, color: TEXT_MUTED }),
    mkRun("  |  {{CONFIDENTIALITY_LINE}}", { size: 15, color: TEXT_MUTED }),
  ],
})]})
```

---

## 9. Signature Block Pattern

Signatures ALWAYS start on their own page (`PageBreak` before). Layout per `{{SIGNATURE_BLOCK_TEMPLATE}}` — the canonical shape:

```
[Page break]
"SIGNATURES" — centered, bold, size 32, {{BRAND_COLOR_PRIMARY}}
[Divider]

"IN WITNESS WHEREOF..." — body paragraph

[Company section]
"{{COMPANY_NAME}}" — bold, size 24, {{BRAND_COLOR_PRIMARY}}
"Signature: ___________________________________________"
"Name: [Name]"           // bold label "Name:" + normal value
"Title: [Title]"         // bold label "Title:" + normal value
"Date: ___________"

[300 DXA spacing]

[Counterparty section]
"[COUNTERPARTY ROLE]" — bold, size 24, {{BRAND_COLOR_PRIMARY}}
"Signature: ___________________________________________"
"Name: ___________________________________________"
"Date: ___________________________________________"

[400 DXA spacing]
[Divider]
"END OF AGREEMENT" — centered, bold, italic, size 20, {{BRAND_COLOR_PRIMARY}}
"{{COMPANY_NAME}} — [Doc Type] v[X] [Variant]" — centered, italic, size 18, {{BRAND_COLOR_TEXT_MUTED}}
```

If the config supplies an alternative `{{SIGNATURE_BLOCK_TEMPLATE}}` (e.g. three parties, witness lines, seal placeholder), follow that verbatim.

---

## 10. Spacing Reference

| Context                                   | Before | After |
|-------------------------------------------|--------|-------|
| Title block top padding                   | 600    | 0     |
| Between title lines                       | 0      | 60    |
| After version line                        | 0      | 200   |
| H1 heading                                | 360    | 200   |
| H2 heading                                | 280    | 160   |
| H3 heading                                | 200    | 120   |
| Body paragraph                            | 80     | 80    |
| Bullet items                              | 40     | 40    |
| Table cell padding (top/bottom)           | 40     | 40    |
| Callout box (above / below)               | 200    | 200   |
| Pull quote (above / below)                | 160    | 160   |
| Between major sections                    | —      | 480 min or page break |
| Before company signature block            | 200    | 80    |
| Before counterparty signature block       | 300    | 80    |
| Signature lines                           | 160    | 40    |
| Before END OF AGREEMENT                   | 400    | 0     |

---

## 11. Document Structure Template

Every branded document follows this order unless the config's `{{DOCUMENT_TYPES}}` specifies a document-specific variant:

1. **Title block** — centered: `{{COMPANY_NAME}}`, document type, version, effective date
2. **Parties / recipient block** — bold `{{BRAND_COLOR_PRIMARY}}` labels, values in `{{BRAND_COLOR_TEXT_DARK}}`
3. **Summary box** (optional) — accent-bordered box with bullet highlights
4. **Numbered sections** — each preceded by an accent divider, H1 heading, optional H2/H3 sub-structure
5. **Callout boxes** — interspersed where the content warrants emphasis (alerts, tips, disclaimers)
6. **Data tables** — full-width, header row in `{{BRAND_COLOR_PRIMARY}}`, alternating fills
7. **Signature page** (if applicable) — page break, centered heading, divider, signature blocks
8. **Closing footer** — END OF [DOC TYPE], version line in muted text

---

## 12. Accessibility Requirements (WCAG 2.1 AA)

These are non-negotiable:

- **Contrast**: all configured text/background combinations must clear 4.5:1. If a brand color fails against white, use it for borders / fills only, never for body text. Check combinations before finalizing the config.
- **Minimum sizes**: body 10 pt, table body 8 pt.
- **Heading hierarchy**: sequential (H1 → H2 → H3), no skips.
- **Table headers**: `tableHeader: true` on every header row.
- **Images**: every image MUST have an alt-text description.
- **Language**: `language: "en-US"` on the `Document` constructor.

---

## 13. Common Mistakes to AVOID

- **Tables not full-width** — every table must be 9360 DXA total.
- **Wrong shading type** — ALWAYS `ShadingType.CLEAR`, never `ShadingType.SOLID`.
- **Missing cell widths** — set BOTH `columnWidths` on Table AND `width` on each cell.
- **Unicode bullets** — never use `"• "` text, always use numbering config.
- **Missing dividers** — every H1 section needs an accent divider before it.
- **Wrong brand color shade** — use ONLY the hex values in the config. No "close enough" substitutions.
- **Body text in `#000000`** — always `{{BRAND_COLOR_TEXT_DARK}}`.
- **Overusing the accent color** — accent is for H2, callout borders, and divider caps, not body emphasis.
- **Wrong font** — never Times New Roman. Always `{{FONT_BODY}}` / `{{FONT_HEADING}}` with `{{FONT_BODY_FALLBACK}}` as fallback.
- **`\n` for line breaks** — never. Use separate Paragraph elements.
- **Signatures mid-page** — always start on their own page via PageBreak.
- **Hardcoding company strings** — pull `{{COMPANY_NAME}}`, `{{COMPANY_DOMAIN}}`, etc. from the loaded config.
- **Off-brand colors** — no hex codes that aren't in the config's palette.

---

## 14. Quick-Start Code Skeleton

Replace the `BRAND` and `FONT` constants with values from the loaded config. Everything else is brand-agnostic.

```javascript
const fs = require("fs");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  Header, Footer, AlignmentType, LevelFormat, BorderStyle,
  WidthType, ShadingType, VerticalAlign, PageNumber, PageBreak,
} = require("docx");

// === BRAND KIT (load from config file, e.g. configs/<company>.yml) ===
const BRAND = {
  PRIMARY:           "{{BRAND_COLOR_PRIMARY}}".replace("#", ""),
  ACCENT:            "{{BRAND_COLOR_ACCENT}}".replace("#", ""),
  SECONDARY:         "{{BRAND_COLOR_SECONDARY}}".replace("#", ""),
  TEXT_DARK:         "{{BRAND_COLOR_TEXT_DARK}}".replace("#", ""),
  TEXT_MUTED:        "{{BRAND_COLOR_TEXT_MUTED}}".replace("#", ""),
  BG_LIGHT:          "{{BRAND_COLOR_BACKGROUND_LIGHT}}".replace("#", ""),
  CALLOUT_INFO:      "{{BRAND_COLOR_CALLOUT_BG_INFO}}".replace("#", ""),
  CALLOUT_SUCCESS:   "{{BRAND_COLOR_CALLOUT_BG_SUCCESS}}".replace("#", ""),
  WARN_BORDER:       "{{BRAND_COLOR_WARNING_BORDER}}".replace("#", ""),
  WARN_BG:           "{{BRAND_COLOR_WARNING_BG}}".replace("#", ""),
  WHITE:             "{{BRAND_COLOR_WHITE}}".replace("#", ""),
  BORDER_LIGHT:      "{{BRAND_COLOR_BORDER_LIGHT}}".replace("#", ""),
};

const FONT_HEADING  = "{{FONT_HEADING}}";
const FONT_BODY     = "{{FONT_BODY}}";
const FONT_FALLBACK = "{{FONT_BODY_FALLBACK}}";
const FONT_MONO     = "{{FONT_MONO}}";  // optional; may be empty

const COMPANY_NAME       = "{{COMPANY_NAME}}";
const COMPANY_NAME_SHORT = "{{COMPANY_NAME_SHORT}}";
const COMPANY_DOMAIN     = "{{COMPANY_DOMAIN}}";
const CONFIDENTIALITY    = "{{CONFIDENTIALITY_LINE}}";

// === HELPERS ===
const b = (text, opts = {}) => new TextRun({ text, bold: true, color: BRAND.TEXT_DARK, font: FONT_BODY, ...opts });
const t = (text, opts = {}) => new TextRun({ text, color: BRAND.TEXT_DARK, font: FONT_BODY, ...opts });
const sp = (before = 0, after = 0) => ({ before, after });

const thinBorder   = { style: BorderStyle.SINGLE, size: 1, color: BRAND.BORDER_LIGHT };
const accentBorder = { style: BorderStyle.SINGLE, size: 2, color: BRAND.ACCENT };
const primaryThick = { style: BorderStyle.SINGLE, size: 3, color: BRAND.PRIMARY };
const noBorder     = { style: BorderStyle.NONE, size: 0 };
const cellBorders  = { top: thinBorder, bottom: thinBorder, left: thinBorder, right: thinBorder };
const allNoBorder  = { top: noBorder, bottom: noBorder, left: noBorder, right: noBorder };

function makeCell(children, opts = {}) {
  const { width = 4680, shading, borders = cellBorders, vAlign } = opts;
  const cell = {
    borders,
    width: { size: width, type: WidthType.DXA },
    children: Array.isArray(children) ? children : [children],
  };
  if (shading) cell.shading = { fill: shading, type: ShadingType.CLEAR };
  if (vAlign) cell.verticalAlign = vAlign;
  return new TableCell(cell);
}

function hdrCell(text, width = 3120) {
  return makeCell(
    new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [b(text, { size: 20, color: BRAND.WHITE })],
    }),
    { width, shading: BRAND.PRIMARY, vAlign: VerticalAlign.CENTER }
  );
}

function dCell(text, width = 3120, align = AlignmentType.CENTER) {
  return makeCell(
    new Paragraph({ alignment: align, spacing: sp(40, 40), children: [t(text, { size: 20 })] }),
    { width }
  );
}

function labelCell(text, width = 3120) {
  return makeCell(
    new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [b(text, { size: 20, color: BRAND.PRIMARY })],
    }),
    { width, shading: BRAND.BG_LIGHT }
  );
}

function h1(num, title) {
  return new Paragraph({
    spacing: sp(360, 200),
    children: [b(`${num}. ${title}`, { size: 28, color: BRAND.PRIMARY, font: FONT_HEADING })],
  });
}

function h2(title) {
  return new Paragraph({
    spacing: sp(280, 160),
    children: [b(title, { size: 24, color: BRAND.ACCENT, font: FONT_HEADING })],
  });
}

function h3(title) {
  return new Paragraph({
    spacing: sp(200, 120),
    children: [b(title, { size: 22, color: BRAND.SECONDARY, font: FONT_HEADING })],
  });
}

function body(runs, opts = {}) {
  return new Paragraph({
    spacing: sp(80, 80),
    ...opts,
    children: Array.isArray(runs) ? runs : [t(runs, { size: 22 })],
  });
}

function boldLead(label, text) {
  return new Paragraph({
    spacing: sp(80, 80),
    children: [b(label, { size: 22 }), t(text, { size: 22 })],
  });
}

function bullet(text) {
  return new Paragraph({
    numbering: { reference: "bullets", level: 0 },
    spacing: sp(40, 40),
    children: [t(text, { size: 22 })],
  });
}

function divider() {
  return new Table({
    columnWidths: [200, 9160],
    rows: [new TableRow({
      height: { value: 40, rule: "exact" },
      children: [
        new TableCell({
          borders: allNoBorder,
          width: { size: 200, type: WidthType.DXA },
          shading: { fill: BRAND.ACCENT, type: ShadingType.CLEAR },
          children: [new Paragraph({ spacing: sp(0, 0), children: [new TextRun({ text: "", size: 2 })] })],
        }),
        new TableCell({
          borders: allNoBorder,
          width: { size: 9160, type: WidthType.DXA },
          shading: { fill: BRAND.PRIMARY, type: ShadingType.CLEAR },
          children: [new Paragraph({ spacing: sp(0, 0), children: [new TextRun({ text: "", size: 2 })] })],
        }),
      ],
    })],
  });
}

function callout(title, lines, type = "info") {
  const cfg = {
    info:    { border: BRAND.PRIMARY,     fill: BRAND.CALLOUT_INFO,    title: BRAND.PRIMARY     },
    success: { border: BRAND.ACCENT,      fill: BRAND.CALLOUT_SUCCESS, title: BRAND.ACCENT      },
    action:  { border: BRAND.SECONDARY,   fill: BRAND.BG_LIGHT,        title: BRAND.SECONDARY   },
    warning: { border: BRAND.WARN_BORDER, fill: BRAND.WARN_BG,         title: BRAND.WARN_BORDER },
  }[type];
  return new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: [9360],
    rows: [new TableRow({ cantSplit: true, children: [new TableCell({
      borders: {
        top:    { style: BorderStyle.SINGLE, size: 1, color: cfg.border },
        bottom: { style: BorderStyle.SINGLE, size: 1, color: cfg.border },
        left:   { style: BorderStyle.SINGLE, size: 8, color: cfg.border },
        right:  { style: BorderStyle.SINGLE, size: 1, color: cfg.border },
      },
      width: { size: 9360, type: WidthType.DXA },
      shading: { fill: cfg.fill, type: ShadingType.CLEAR },
      margins: { top: 120, bottom: 120, left: 200, right: 200 },
      children: [
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { after: 100 },
          children: [b(title, { size: 21, color: cfg.title, font: FONT_HEADING })],
        }),
        ...lines.map(line => new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { after: 60 },
          children: buildItalicBoldRuns(line),
        })),
      ],
    })] })],
  });
}

function buildItalicBoldRuns(text) {
  const parts = text.split(/(\*\*.*?\*\*)/g);
  return parts.map(part => {
    if (part.startsWith("**") && part.endsWith("**")) {
      return t(part.slice(2, -2), { italics: true, bold: true, size: 19 });
    }
    return t(part, { italics: true, size: 19 });
  });
}

// === DOCUMENT ===
const doc = new Document({
  styles: { default: { document: { run: { font: FONT_BODY, size: 22, color: BRAND.TEXT_DARK } } } },
  numbering: { config: [{
    reference: "bullets",
    levels: [{
      level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
      style: { paragraph: { indent: { left: 720, hanging: 360 } } },
    }],
  }]},
  sections: [{
    properties: { page: { margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } } },
    headers: { default: new Header({ children: [new Paragraph({
      alignment: AlignmentType.RIGHT,
      children: [t(`${COMPANY_NAME_SHORT} \u2014 Document Type`,
                   { size: 18, italics: true, color: BRAND.PRIMARY })],
    })]})},
    footers: { default: new Footer({ children: [
      new Paragraph({ alignment: AlignmentType.CENTER, children: [
        t("Page ", { size: 18 }),
        new TextRun({ children: [PageNumber.CURRENT], size: 18, color: BRAND.TEXT_DARK, font: FONT_BODY }),
        t(" of ", { size: 18 }),
        new TextRun({ children: [PageNumber.TOTAL_PAGES], size: 18, color: BRAND.TEXT_DARK, font: FONT_BODY }),
      ]}),
      new Paragraph({ alignment: AlignmentType.CENTER,
        children: [t(CONFIDENTIALITY, { size: 16, italics: true, color: BRAND.TEXT_MUTED })] }),
    ]}) },
    children: [
      // BUILD DOCUMENT HERE with the helpers above
    ],
  }],
});

Packer.toBuffer(doc).then(buf => fs.writeFileSync("output.docx", buf));
```

---

## 15. Quick Start — New User

1. Copy `configs/example-brand.yml` to `configs/<your-company>.yml`.
2. Fill in every field for your company. Ask your brand team for hex codes with precision (no eyeballing). Do not commit this file; `configs/.gitignore` keeps it local.
3. In chat, tell Claude: *"Using the `branded-docx` skill, load config at `skills/templates/branded-docx/configs/<your-company>.yml` and generate a [document type] for [purpose]."*
4. Claude reads the skill, loads your config, and produces the `.docx` following the rules above.
5. Validate the output with the base `docx` skill's `python scripts/office/validate.py` before delivering.

---

## 16. Pre-Flight Checklist

Before writing the final `.js` generator file, verify:

- [ ] Brand config loaded; every `{{VARIABLE}}` resolved; no placeholders left in the code
- [ ] All tables use `columnWidths` totaling exactly 9360
- [ ] Every `TableCell` has its own `width` property matching `columnWidths`
- [ ] Header cells: `{{BRAND_COLOR_PRIMARY}}` background, white bold text, centered
- [ ] Key-value label cells: `{{BRAND_COLOR_BACKGROUND_LIGHT}}` bg, bold primary text
- [ ] Callout boxes: thick left border in the type's color, matching fill, centered title + italic body
- [ ] Every H1 section preceded by `divider()`
- [ ] Bold lead-in pattern used for clause openers
- [ ] Bullets use numbering config, not unicode
- [ ] Signatures on their own page (PageBreak before)
- [ ] Running header + footer match `{{HEADER_TEMPLATE}}` / `{{FOOTER_TEMPLATE}}`
- [ ] `{{FONT_BODY}}` / `{{FONT_HEADING}}` set on every run; `{{FONT_BODY_FALLBACK}}` declared
- [ ] Body text color is `{{BRAND_COLOR_TEXT_DARK}}`, NOT pure black
- [ ] Accent color used only for H2, callout borders, divider caps, success indicators
- [ ] `ShadingType.CLEAR` on all shaded cells
- [ ] `cantSplit: true` on every TableRow
- [ ] `tableHeader: true` on every header row (accessibility)
- [ ] `language: "en-US"` on the Document constructor
- [ ] No `\n` anywhere — separate Paragraphs only
- [ ] No colors outside the configured palette
- [ ] Document validated with `python scripts/office/validate.py`
