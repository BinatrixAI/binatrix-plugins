# Visual verification — read the PNG, not just the exit code

> Compilation success (exit code 0) does **not** mean the output looks right.
> Missing fonts produce fallback squares without erroring. Photos can stretch.
> Contact lines can overflow the page edge. Always render a preview and read
> it before declaring success.

---

## Render preview PNGs

Typst exports PNG directly — no external tools needed.

```bash
# Single page (almost always what you want for a quick check)
typst compile cv.typ /tmp/cv-preview.png --pages 1

# All pages, numbered
typst compile cv.typ /tmp/cv-preview-{0p}.png

# Specific range
typst compile cv.typ /tmp/cv-preview-{0p}.png --pages 1-3

# Higher resolution (default ~144 ppi)
typst compile cv.typ /tmp/cv-preview.png --pages 1 --ppi 300
```

Then `Read` the PNG. Claude is multimodal — looking at the rendered image
catches problems that no structural query will.

---

## Sampling strategy

| Document type            | Pages to check                     |
|--------------------------|------------------------------------|
| Résumé (1 page)          | page 1                             |
| Résumé (2 pages)         | pages 1, 2                         |
| Cover letter (1 page)    | page 1                             |
| Document (≤ 3 pages)     | all                                |
| Document (> 3 pages)     | first, middle, last                |
| Presentation (< 30)      | all slides                         |
| Presentation (30+)       | first 3, middle 3, last 3 + flagged |

---

## What to look at — résumé checklist

When inspecting a CV preview, check:

- [ ] **Name** appears at the top, in the expected font (no fallback squares).
- [ ] **Contact line** (email, phone, github, linkedin) is on one line and
      doesn't run off the right edge of the page.
- [ ] **Section headers** (Education, Experience, Skills) are visually
      distinct from body text.
- [ ] **Date alignment** is consistent — right-edge or vertically aligned
      across entries.
- [ ] **No overflow** off any edge.
- [ ] **Bullets** are readable; no orphan single-word lines.
- [ ] **Photo** (if any) isn't stretched or distorted.
- [ ] **Page count** matches what was intended (single-page CV that
      becomes two pages → tighten bullets).
- [ ] **FontAwesome icons** (github / linkedin / phone) render as glyphs,
      not as fallback rectangles. If they're squares, FontAwesome isn't
      installed — pick a remediation from `references/resume.md` §6.

---

## What to look at — generic doc / report

- [ ] Title page (if any) is centred and clean.
- [ ] Heading hierarchy is visually distinct — H1 > H2 > H3.
- [ ] No blank half-pages (forgotten `#set figure(placement: auto)`).
- [ ] Figures sit near their references, not stranded on later pages.
- [ ] Tables don't overflow the page width.
- [ ] Page numbers present in the footer.
- [ ] Citations/references resolve (no `??` placeholders).

---

## What to look at — slides

- [ ] Title slide populated (metadata from `config-info` came through).
- [ ] Each slide's title is readable and consistent.
- [ ] No more than ~6-8 bullets per slide (cognitive load).
- [ ] No more than 2 callout boxes per slide.
- [ ] Footer/header (if configured) appears on every slide.
- [ ] Code listings fit horizontally; no overflow off the right edge.

---

## Structural validation via `typst query`

For when you want to inspect structure without rendering. Returns JSON.

```bash
# Count and list all headings
typst query doc.typ "heading"

# Just H1
typst query doc.typ "heading.where(level: 1)"

# All figures (and their captions)
typst query doc.typ "figure"

# Find by label
typst query doc.typ "<my-label>"
```

Useful for verifying:

- Section count matches the user's intent
- Required sections (Education, Experience) all present in CV
- Bibliography compiled (no missing citations)

---

## End-of-job reporting

After the workflow finishes, always tell the user:

1. **Absolute PDF path** on its own line, prefixed with `→`:
   ```
   → /Users/dima/Documents/cv.pdf
   ```
2. **One-line summary** of what was generated (pages, template, any
   substitutions like font fallbacks).
3. **The preview PNG inline** so they can sanity-check without opening the
   PDF.
4. **Open command** the user can paste in another cmux pane:
   ```bash
   open /Users/dima/Documents/cv.pdf
   ```
