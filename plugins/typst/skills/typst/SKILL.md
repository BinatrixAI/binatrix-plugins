---
name: typst
description: >
  Generate PDFs from Typst — primarily CVs, résumés, and cover letters using
  @preview/modern-cv (the Awesome-CV look ported to Typst), and also
  presentations (touying) and general documents. Use this skill whenever the
  user says "make me a CV", "build a resume", "convert this to PDF", "PDF
  version", "render as PDF", "need a PDF", "I want a PDF of this", "format as
  Awesome-CV", "professional resume", "cover letter as PDF", or pastes career
  content (jobs, education, skills) and asks for any visual output. Also
  trigger when editing .typ files, when the user mentions typst, typst.toml,
  typst-cli, or Typst Universe packages, when building presentations with
  touying or polylux, or whenever PDF output is requested from existing
  Markdown / chat content. The skill knows how to draft the .typ source, run
  the font preflight (modern-cv needs Roboto, Source Sans Pro, FontAwesome —
  none ship on macOS by default), compile to PDF, render a preview PNG, and
  report the absolute output path. Use this even if the user does not say
  "typst" explicitly — if they want a printable document, this is the path.
license: MIT
metadata:
  version: "1.0.0"
---

# Typst — PDF generation skill (resume-first)

Typst 0.14.x is a modern markup-based typesetting system — think LaTeX, but
the syntax is friendlier and packages auto-download. This skill is tuned for
the workflow the user actually runs most: **turning content into a
polished PDF**, with a strong default for résumés and cover letters via
`@preview/modern-cv` (the Awesome-CV design ported to Typst).

The user's environment: macOS, Typst installed at `/opt/homebrew/bin/typst`,
running inside cmux ("Cowork"). Do not assume any external infrastructure.

## When this skill fires — and what to do first

The user usually shows up in one of three modes:

| What they said / showed                                            | Branch                                       |
|--------------------------------------------------------------------|----------------------------------------------|
| "Make me a CV", pasted job history, "convert my LinkedIn to PDF"   | **Résumé** → `references/resume.md`          |
| "Cover letter for X role", letter to a hiring manager              | **Cover letter** → `references/resume.md` §"Cover letter" (uses `coverletter.with(...)` — NOT `letter.with`) |
| "PDF version", "render as PDF", any non-resume content → PDF       | **Generic PDF** → §"PDF from arbitrary content" below |
| ".typ file is open / has compile errors"                           | **Edit/debug** → `references/syntax.md` + `references/errors.md` |
| "Slides / presentation / deck"                                     | **Slides** → `references/touying.md`         |

When intent is ambiguous (e.g. user pastes a long bio), prefer **résumé** if
the content has dated job/education entries; otherwise treat as **generic
PDF**.

## Quick-start: résumé in 30 seconds

This is the canonical happy path. Defaults: `@preview/modern-cv`, US Letter,
today's date.

```typst
#import "@preview/modern-cv:0.10.0": *

#show: resume.with(
  author: (
    firstname: "Jane",
    lastname: "Doe",
    email: "jane@example.com",
    phone: "(+1) 555-0100",
    github: "janedoe",
    linkedin: "janedoe",
    address: "San Francisco, CA",
    positions: ("Senior Software Engineer",),
  ),
  profile-picture: none,
  date: datetime.today().display(),
  paper-size: "us-letter",
)

= Experience

#resume-entry(
  title: "Senior Engineer",
  location: "Acme Corp — Remote",
  date: "Jun 2019 - Present",
  description: "Platform team",
)

#resume-item[
  - Cut p99 latency 47% by moving reads to edge KV
  - Mentored 4 engineers across two timezones
  - Shipped weekly for 11 months with zero rollbacks
]

= Education

#resume-entry(
  title: "Example University",
  location: "B.S. Computer Science",
  date: "Aug 2014 - May 2019",
  description: "GPA 3.8 / 4.0",
)

= Skills

#resume-item[
  - *Languages:* Rust, Go, TypeScript, Python
  - *Infra:* Cloudflare Workers, AWS, Kubernetes
]
```

Read `references/resume.md` for the full mode (fields, sections, accent
colors, `letter.with(...)` for cover letters, and the neat-cv alternative).

## The 8-step workflow

Whether résumé or generic PDF, follow this loop. It is short on purpose —
each step has at most one decision.

1. **Identify intent** (résumé / cover letter / generic doc / slides).
2. **Confirm output path.** If the user gave one, respect it. Otherwise write
   to `./cv.typ` + `./cv.pdf` in the cwd (or `./output.typ` / `./output.pdf`
   for non-résumé). Always print the absolute path at the end.
3. **Run the font preflight** before the first compile — see next section.
   For résumés, this is required (modern-cv depends on Roboto / Source Sans
   Pro / FontAwesome).
4. **Draft the `.typ` source.** Pull fields from the user's content. If a
   field is unknown, ask once — do not invent names, dates, or employers.
5. **Compile**: `typst compile <file>.typ`. The PDF lands next to the source.
6. **Render a preview PNG** of page 1 (and the last page for multi-page docs):
   `typst compile <file>.typ /tmp/<name>-preview-{0p}.png --pages 1` (or a range).
7. **Spot-check** by reading the PNG. Look for fallback squares (missing
   fonts), overflow off the page edge, contact-line cutoff, photo stretch.
8. **Report back**: absolute PDF path + the preview PNG inline + a one-line
   summary of what was generated. Mention any font fallbacks that fired.

## Font preflight (do this before the first compile)

modern-cv wants three fonts that macOS does not ship by default. Run this
diagnostic in Bash to see what is missing:

```bash
typst fonts 2>/dev/null | grep -iE "roboto|source sans|font ?awesome" | sort -u
```

If all three appear in output → compile as-is.

If any are missing → pick one path:

- **A. Run the bundled preflight script** for a friendlier diagnostic +
  brew commands ready to paste:

  ```bash
  bash "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/plugins/cache/binatrix-plugins/typst/1.0.0}/skills/typst/scripts/preflight-fonts.sh"
  ```

  (Path falls back to a sensible local default if the env var is not set.
  Adjust to wherever the skill lives.)

- **B. Install via Homebrew** (one-time, ~30 seconds):

  ```bash
  brew install --cask font-roboto font-source-sans-3 font-fontawesome
  ```

- **C. Override to bundled fonts** (no install, slight design loss): pass
  `font:` and `header-font:` into `resume.with(...)`. New Computer Modern
  ships with Typst, so this always works:

  ```typst
  #show: resume.with(
    ...,
    font: "New Computer Modern",
    header-font: "New Computer Modern",
  )
  ```

  FontAwesome icons (github/linkedin/phone) render as fallback squares
  without the icon font. If the user dislikes that, drop the icon-backed
  fields from `author: (...)` and keep contact info as plain text in a
  separate `= Contact` section.

**Default behaviour when no user preference is stated:** try the install
(path B) once. If that errors or is declined, fall back to overrides (path C)
and note the choice in the summary you report back.

## PDF from arbitrary content

If the user has prose, structured notes, or a Markdown doc and says "make
this a PDF", route by content shape (do not force everything into modern-cv):

| Content shape                            | Template / preamble                         |
|------------------------------------------|---------------------------------------------|
| Long-form prose, narrative essay         | Essay preamble — `references/templates.md`  |
| Structured analysis with sections + data | Research Report preamble                    |
| Branded client deliverable, internal memo, handout | Business Report preamble + **visual patterns** (see below) |
| Course notes, study material             | Study Guide preamble                        |
| Dense reference, A4 landscape, columns   | Cheatsheet preamble                         |
| Q&A or problem set                       | Exam / Flashcard preamble                   |
| Glossary, taxonomy                       | Annotated Reference preamble                |

### Look for visual opportunities in the prose

A flat preamble + bullet points is rarely what the user wants from a
"PDF I can hand to my boss" request. Before you start writing the `.typ`,
scan the source for structural beats and reach for richer Typst patterns:

| What you spot in the prose                                  | Visual treatment                                                  |
|-------------------------------------------------------------|-------------------------------------------------------------------|
| A "Background" or "Summary" paragraph at the top            | **Exec-summary callout** ("AT A GLANCE" tinted box at the top)    |
| Two parallel options / paths / sides / before-and-after     | **Two-column grid** with titled cards                             |
| A quantified outcome ("dropped from 6-8 min to <30 sec")    | **Green Result callout**                                          |
| A doc title that summarises everything                      | **Eyebrow** (small-caps tagline) + bold title                     |
| 3-5 trade-offs / pros-and-cons                              | **Bordered list** or a comparison table                           |

These patterns live in `references/templates.md` §"Visual patterns for
handouts" — pull the helper functions you need rather than hand-rolling.
The single biggest quality improvement on prose-to-PDF work is whether you
reach for these. A printable handout is not just text on a page.

### Markdown source → Typst headings

When the user pastes Markdown, **preserve the heading depth**. Don't
collapse everything to `=`.

| Markdown | Typst |
|----------|-------|
| `# H1`   | `= H1`  |
| `## H2`  | `== H2` |
| `### H3` | `=== H3`|
| `#### H4`| `==== H4`|

Same compile-and-preview pattern as the résumé workflow. The templates are
self-contained — no `@preview` dependency — so they work even when
network/package resolution is flaky.

## CLI you actually need

```bash
typst compile doc.typ                       # → doc.pdf
typst watch doc.typ                          # recompile on save
typst compile doc.typ --root ..              # for paths outside doc's dir
typst compile doc.typ /tmp/out.png --pages 1 # preview a single page
typst compile doc.typ /tmp/out-{0p}.png      # all pages as numbered PNGs
typst fonts                                  # list installed fonts
typst query doc.typ "heading"                # structural JSON dump
```

For inputs from the shell:

```bash
typst compile cv.typ --input name="Jane Doe" --input role="Engineer"
```

Inside the doc: `#let name = sys.inputs.at("name", default: "Friend")`.

## Smart defaults (apply unless the user overrides)

1. **Always** `#set figure(placement: auto)` for multi-page docs — prevents blank half-pages.
2. **Always** escape `$` in body text (currency). Bare `$5,000` opens math mode.
3. **Always** quote multi-letter math identifiers: `$"NPV"$`, never `$NPV$`.
4. **Always** use `sym.*` over `emoji.*` — the sym module is complete; emoji has gaps.
5. **Always** pin `@preview` versions (e.g. `:0.10.0`, not unversioned) — the namespace is experimental.
6. **Always** use touying 0.6.x for slides — old `register()` API is gone (`references/touying.md`).
7. **Always** preview as PNG and `Read` it back after compile. Exit code 0 ≠ correct output.

## Compile errors — top 5

| Error                       | Cause                                      | Fix                                  |
|-----------------------------|--------------------------------------------|--------------------------------------|
| `unclosed delimiter`        | bare `$`, `_`, or `*` in content           | `\$`, `......` for blanks, `\*`      |
| `unknown variable: NPV`     | adjacent letters parsed as one identifier  | `$"NPV"$` (quoted, upright)          |
| `unclosed label`            | `<text>` parsed as label (incl. CJK `<` `>`) | `\<` `\>` or words or fullwidth `＜＞` |
| `unknown variable: True`    | `#func()(...)` chained as a call           | insert `~` between `)` and `(`        |
| `module emoji does not contain X` | not all emoji exist                  | use `sym.*` equivalent               |

Full catalogue with deeper math-mode traps: `references/errors.md`.

## Reference index — load these on demand

| When you need…                                       | Read…                          |
|------------------------------------------------------|--------------------------------|
| The full résumé workflow + modern-cv reference + neat-cv | `references/resume.md`     |
| Syntax (markup, functions, set/show, math, lists)    | `references/syntax.md`         |
| Error catalogue (top 12 with fixes)                  | `references/errors.md`         |
| Hand-rolled templates (essay, report, study guide, …) | `references/templates.md`     |
| Touying 0.6.x presentation API                       | `references/touying.md`        |
| `@preview` package list (writing + slides)           | `references/packages.md`       |
| Math-mode pitfalls (currency, CJK `<>`, commas)      | `references/math.md`           |
| Symbols (`sym.*`) cheatsheet                         | `references/symbols.md`        |
| Visual verification + structural query               | `references/verification.md`   |

## Version notes (0.13 → 0.14)

- Tagged PDFs / PDF/UA-1 are the default since 0.14 — alt text becomes important.
- `image("file.pdf")` works (PDF as image format), since 0.14.
- `table.header(...)` repeats headers across pages, since 0.14.
- `pdf.attach` replaces deprecated `pdf.embed`.
- `curve` replaces deprecated `path`.
- `polylux:0.3.x` is incompatible with 0.14 — use `touying:0.6.x` instead.

## Output conventions (reiterating because this matters)

- Always write a `.typ` source next to the PDF — never just the PDF.
- Always render and `Read` a preview PNG before declaring success.
- Always report the **absolute** path to the PDF in the final message, on a
  line by itself, so the user can `open <path>` from another cmux pane.
- Never overwrite an unrelated `.typ` file. If the chosen path already
  exists and isn't recognisably the in-progress doc, ask before clobbering.
