# Hand-rolled templates (no `@preview` dependency)

Use these when the user wants a PDF and the content **isn't résumé-shaped**.
Each preamble is self-contained — no external packages, no qk imports, works
offline. For résumés, prefer `@preview/modern-cv` (`references/resume.md`).

> **Before choosing a template — look for visual opportunities.** A flat
> preamble + bullets is rarely what someone means by "make this a PDF I can
> hand to my boss." Read §0 first: it has the patterns (exec-summary
> callout, 2-column grid, green Result callout, eyebrow) that turn a plain
> document into something handout-quality. Most "PDF from prose" requests
> deserve at least one of those patterns.

Pick by content shape:

| Content                                       | Template          |
|-----------------------------------------------|-------------------|
| **Any handout / internal memo / boss-facing PDF** | **§0 Visual patterns + §3 Business Report** |
| Long-form prose, narrative essay              | §1 Essay          |
| Structured analysis, sections + findings      | §2 Research Report |
| Branded client deliverable                    | §3 Business Report |
| Course notes, study material                  | §4 Study Guide    |
| Dense reference, A4 landscape, multi-column   | §5 Cheatsheet     |
| Q&A or problem set                            | §6 Exam           |
| Glossary, taxonomy, reference doc             | §7 Annotated Reference |
| Flashcards, revision Q&A                      | §8 Flashcard      |

---

## 0. Visual patterns for handouts

When prose comes in for a "PDF version" or "handout for my boss" request,
**actively look for these structural beats and reach for the matching
visual treatment.** A flat preamble with bullets is rarely what the user
actually wants — they want something that looks like it was designed.

### Pattern recognition

| What you see in the source                            | Treatment to apply         |
|-------------------------------------------------------|----------------------------|
| A "Background" / "Summary" / "Overview" paragraph     | **Exec-summary callout** at the top |
| Two parallel options / paths / sides / before-after   | **Two-column comparison grid** |
| A quantified outcome ("dropped from X to Y", "cut by 47%") | **Green Result callout** |
| A doc title that summarises everything                | **Eyebrow** (small-caps tagline) + bold title |
| Numbered trade-offs, pros/cons, design constraints    | **Bordered list** or comparison table |
| 3+ related metrics or KPIs                            | **Stat-card row**          |

Reach for **at least one** of these on any prose-to-PDF request. Two or
three is often right — don't over-decorate.

### Helpers — paste these inline near the top of your `.typ`

The patterns below assume the §3 Business Report preamble is loaded (for
`#set page`, `#set text`, brand colours). Add only the helpers you actually
use — don't paste all of them.

```typst
// ---- Visual handout helpers ----

#let brand-primary = rgb("#1d4ed8")    // navy blue accent
#let brand-result  = rgb("#10b981")    // emerald for outcomes / wins
#let brand-warn    = rgb("#d97706")    // amber for risks / trade-offs

// Eyebrow text — small-caps tagline above a bold title
#let eyebrow(tag, title) = {
  text(size: 8.5pt, weight: "bold", tracking: 1.2pt, fill: gray.darken(20%))[#upper(tag)]
  v(2pt)
  text(size: 22pt, weight: "bold")[#title]
  v(0.5em)
}

// Executive-summary callout — put at the top of the doc
#let exec-summary(body) = block(
  width: 100%, inset: 14pt, radius: 6pt, above: 0pt, below: 1.2em,
  fill: rgb("#eff6ff"), stroke: (left: 4pt + brand-primary),
)[
  #text(size: 9pt, weight: "bold", tracking: 1.2pt, fill: brand-primary)[AT A GLANCE]
  #v(4pt)
  #text(size: 10pt)[#body]
]

// Green Result callout — for the quantified outcome line
#let result-callout(body) = block(
  width: 100%, inset: 12pt, radius: 6pt, above: 1em, below: 1em,
  fill: rgb("#ecfdf5"), stroke: (left: 4pt + brand-result),
)[
  #text(size: 9pt, weight: "bold", tracking: 1.2pt, fill: rgb("#047857"))[RESULT]
  #v(4pt)
  #text(size: 10.5pt, weight: "medium")[#body]
]

// Two-column comparison — pass titled cards as content
#let two-col-card(title, accent, body) = block(
  width: 100%, inset: 12pt, radius: 6pt, fill: accent.lighten(92%),
  stroke: (left: 4pt + accent),
)[
  #text(size: 8.5pt, weight: "bold", tracking: 1pt, fill: accent.darken(10%))[#upper(title)]
  #v(4pt)
  #text(size: 10pt)[#body]
]

#let compare(left-title, left-accent, left-body,
             right-title, right-accent, right-body) = grid(
  columns: (1fr, 1fr), gutter: 14pt,
  two-col-card(left-title, left-accent, left-body),
  two-col-card(right-title, right-accent, right-body),
)

// Stat-card — one large number + label
#let stat-card(value, label, accent: brand-primary) = block(
  width: 100%, inset: 12pt, radius: 6pt, fill: accent.lighten(92%),
  stroke: 0.5pt + accent.lighten(50%),
)[
  #align(center)[
    #text(size: 22pt, weight: "bold", fill: accent)[#value]
    #v(-2pt)
    #text(size: 8.5pt, weight: "regular", tracking: 1pt, fill: gray.darken(20%))[#upper(label)]
  ]
]

// Trade-off bordered block — for "Trade-offs we accepted" style sections
#let tradeoff(body) = block(
  width: 100%, inset: 10pt, radius: 4pt, above: 0.5em,
  fill: rgb("#fffbeb"), stroke: (left: 3pt + brand-warn),
)[
  #text(size: 9pt, fill: gray.darken(40%))[#body]
]
```

### Worked example — applying these to a Q4 architecture review

Given prose like:

```markdown
## Q4 Architecture Review — Tablet Monitoring System

### Background
We ship MacroDroid scripts to ~12k Android tablets...

### Hybrid v2.0 Architecture
We moved to a two-path model:
- Data path: MacroDroid → Worker → D1
- Critical path: Power-lost events → immediate webhook

Result: alert latency dropped from 6-8 min to <30 sec.

### Trade-offs we accepted
- D1 cost rose ~22%
- n8n now has two ingestion paths
```

A handout-quality conversion uses the patterns above, **not** plain bullets:

```typst
// Eyebrow + title
#eyebrow("Internal Technical Memo · Jan 2026", [Q4 Architecture Review])

// Exec-summary callout (from "Background")
#exec-summary[
  We ship MacroDroid scripts to ~12k Android tablets in retail locations.
  The legacy 5-minute polling model meant power-loss alerts arrived 6-8
  minutes late — unacceptable for the customer SLA. Q4 we shipped a hybrid
  data/critical-path architecture; this memo summarises the move.
]

= Hybrid v2.0 Architecture

We moved to a two-path model:

// Side-by-side comparison cards (from the two paths)
#compare(
  "Data path",  brand-primary, [
    MacroDroid #sym.arrow.r Cloudflare Worker #sym.arrow.r D1.
    All telemetry batched, ~10 ms write latency. Polled every 5 min.
  ],
  "Critical path", rgb("#dc2626"), [
    Power-lost, critical-battery (\<5%), and recovery events trigger an
    immediate webhook to n8n, bypassing the 5-min poll.
  ],
)

// Green Result callout (from "Result: ...")
#result-callout[
  Alert latency for critical events dropped from 6-8 min to \<30 sec.
]

= Trade-offs we accepted

#tradeoff[D1 cost rose ~22% from the batch writes.]
#tradeoff[n8n now has two ingestion paths instead of one — more surface area to maintain.]
#tradeoff[Some duplication risk on recovery events; mitigated by `status === "offline"` gating.]
```

The result is a document that looks designed, not transcribed. That's the
bar for a "PDF I can hand to my boss."

> **Note on `<` characters**: when you write Typst content like "<5%" or
> "<30 sec" inside body text, escape the `<` as `\<` to avoid the
> label-parse error documented in `references/errors.md`. The example above
> uses `\<` for that reason.

---

## 1. Essay

```typst
#set page(paper: "a4", margin: (x: 2.5cm, y: 3cm),
  header: context {
    if counter(page).get().first() > 2 [
      #set text(9pt, fill: gray.darken(20%))
      #emph[Document Title] #h(1fr) Author Name
      #v(2pt); #line(length: 100%, stroke: 0.4pt + gray)
    ]
  },
  footer: context {
    set align(center); set text(9pt, fill: gray.darken(20%))
    counter(page).display("— 1 —")
  },
)
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true, leading: 0.7em, first-line-indent: 1.5em)

#show heading.where(level: 1): it => {
  set par(first-line-indent: 0em)
  pagebreak(weak: true); v(1em)
  text(size: 20pt, weight: "bold", fill: rgb("#1a365d"), it.body); v(0.3em)
}
#show heading.where(level: 2): it => {
  set par(first-line-indent: 0em); v(1.2em)
  text(size: 14pt, weight: "bold", fill: rgb("#2c5282"), it.body); v(0.5em)
}

#let blockquote(body) = {
  set par(first-line-indent: 0em)
  block(inset: (left: 2em, right: 1em, y: 0.8em),
    stroke: (left: 3pt + rgb("#3182ce").lighten(60%)),
    fill: rgb("#f7fafc"), body)
}
```

## 2. Research Report

```typst
#set document(title: "Report Title", author: "Author")
#set page(paper: "a4", margin: (x: 2cm, y: 2.5cm))
#set text(font: "New Computer Modern", size: 10pt)
#set par(leading: 0.65em, justify: true)
#set heading(numbering: "1.1")
#set figure(placement: auto)

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(1em); text(size: 18pt, weight: "bold", fill: rgb("#1e3a5f"), it); v(0.4em)
}
#show heading.where(level: 2): it => {
  v(0.6em); text(size: 13pt, weight: "bold", fill: rgb("#2563eb"), it); v(0.2em)
}

#let callout(title, fg, bg, border, body) = block(
  width: 100%, inset: 10pt, radius: 3pt, fill: bg, stroke: 0.5pt + border,
)[
  #text(size: 9pt, weight: "bold", fill: fg)[#title] #v(0.2em)
  #text(size: 9.5pt)[#body]
]
#let tip(body)      = callout("Tip",       rgb("#004d40"), rgb("#e0f2f1"), rgb("#00897b"), body)
#let warning(body)  = callout("Warning",   rgb("#991b1b"), rgb("#fef2f2"), rgb("#dc2626"), body)
#let keypoint(body) = callout("Key Point", rgb("#1e3a5f"), rgb("#f0f4ff"), rgb("#2563eb"), body)
```

## 3. Business Report (branded)

```typst
#let brand-primary = rgb("#0033a0")
#let brand-gold    = rgb("#c5a247")

#set page(paper: "a4", margin: (x: 2cm, y: 2.5cm), numbering: "1")
#set text(font: "New Computer Modern", size: 10pt)
#set par(leading: 0.6em, justify: true)
#set figure(placement: auto)

#show heading.where(level: 1): it => {
  v(10pt)
  block(width: 100%)[
    #block(fill: brand-primary, inset: (x: 12pt, y: 8pt), radius: (top: 4pt),
      width: 100%, text(fill: white, weight: "bold", size: 13pt, it.body))
    #block(fill: brand-primary.lighten(85%), inset: 0pt, width: 100%, height: 2pt)
  ]
  v(6pt)
}
#show heading.where(level: 2): it => {
  v(6pt)
  block[
    #text(fill: brand-primary, weight: "bold", size: 11pt, it.body)
    #v(-2pt); #line(length: 40%, stroke: 1pt + brand-gold)
  ]
  v(4pt)
}
```

## 4. Study Guide

```typst
#set page(paper: "a4", margin: 2cm, numbering: "1")
#set text(font: "Libertinus Serif", size: 10.5pt)
#set par(leading: 0.65em, justify: true)
#set heading(numbering: "1.1")
#set figure(placement: auto)

#show heading.where(level: 1): it => {
  v(0.8em)
  text(size: 16pt, weight: "bold", fill: rgb("#1565c0"), it)
  v(0.2em); line(length: 100%, stroke: 1pt + rgb("#1565c0").lighten(60%))
  v(0.3em)
}
#show heading.where(level: 2): it => {
  v(0.5em); text(size: 12pt, weight: "bold", fill: rgb("#1565c0"), it); v(0.15em)
}
```

Note: Libertinus Serif must be installed or fall back via `font: ("Libertinus Serif", "New Computer Modern")`.

## 5. Cheatsheet (A4 landscape, dense)

```typst
#set page(paper: "a4", flipped: true, margin: (x: 1cm, y: 1cm))
#set text(font: "New Computer Modern", size: 8pt)
#set par(leading: 0.45em, spacing: 0.5em, justify: true)
#set heading(numbering: none)

#let navy = rgb("#0d47a1")
#let accent = rgb("#1976d2")

#show heading.where(level: 1): it => {
  block(fill: navy, inset: (x: 6pt, y: 4pt), radius: 2pt, width: 100%,
    text(fill: white, weight: "bold", size: 9pt, it.body))
  v(2pt)
}

#columns(3, gutter: 8pt)[
  // Content here — short paragraphs, tables, formula boxes
]
```

## 6. Exam / Problem Set

```typst
#let show-answers = false   // flip true for answer-key build

#set page(paper: "a4", margin: 2cm, numbering: "1")
#set text(font: "New Computer Modern", size: 10.5pt)
#set par(leading: 0.65em, justify: true)
#set heading(numbering: none)

#align(center)[
  #text(size: 16pt, weight: "bold")[Course Name — Final Exam]
  #v(4pt)
  #text(size: 10pt)[
    Date: #datetime.today().display() #h(2em) Time: 2 hours #h(2em) Total: 100 marks
  ]
]
#v(1em); #line(length: 100%, stroke: 1pt); v(1em)

#let question(num, marks, body) = block(inset: 8pt, fill: rgb("#f5f5f5"), radius: 3pt, width: 100%)[
  *Question #num* #h(1fr) _(#marks marks)_
  #v(0.3em); body
]
#let answer(body) = if show-answers {
  block(inset: 8pt, fill: rgb("#e8f5e9"), radius: 3pt, width: 100%,
    stroke: (left: 3pt + rgb("#00897b")))[#body]
} else { v(5cm) }

#question(1, 10)[Define X and explain its significance.]
#answer[Sample answer here.]
```

## 7. Annotated Reference / Glossary

```typst
#set page(margin: (x: 2.5cm, y: 2.5cm), numbering: "1")
#set text(font: "New Computer Modern", size: 10.5pt)
#set par(leading: 0.7em)
#set heading(numbering: "1.1")

#show heading.where(level: 1): it => {
  v(0.8em); line(length: 100%, stroke: 1pt + rgb("#1e3a5f")); v(0.3em)
  text(size: 14pt, weight: "bold", fill: rgb("#1e3a5f"), it); v(0.3em)
}

#let concept(term, def) = {
  text(weight: "bold")[#term] + [ --- ] + def; v(0.15em)
}
```

For cross-referenced glossaries with acronym expansion, see
`@preview/glossarium:0.5.10` in `references/packages.md`.

## 8. Flashcard / Q&A

```typst
#set page(paper: "a4", margin: 1.5cm)
#set text(font: "New Computer Modern", size: 11pt)

#let flashcard(question, answer) = {
  block(width: 100%, inset: 16pt, radius: 6pt, above: 1em, below: 0em,
    fill: rgb("#f0f4ff"), stroke: 1.5pt + rgb("#1565c0"))[
    #text(weight: "bold", size: 10pt, fill: rgb("#1565c0"))[Q:]
    #v(4pt); #text(size: 11pt)[#question]
  ]
  block(width: 100%, inset: 16pt, radius: 6pt, above: 0em, below: 1em,
    fill: rgb("#f0faf0"), stroke: 1.5pt + rgb("#00897b"))[
    #text(weight: "bold", size: 10pt, fill: rgb("#00897b"))[A:]
    #v(4pt); #text(size: 10pt)[#answer]
  ]
  line(length: 100%, stroke: (dash: "dashed", paint: luma(200), thickness: 0.5pt))
}

#align(center, text(size: 18pt, weight: "bold")[Revision Flashcards])
#v(1em)

#flashcard([What is X?], [X is ...])
```

---

## Page-layout cheatsheet (apply to any template)

- `#set figure(placement: auto)` — always for multi-page documents.
- Body size: 10–11pt for reading docs, 8–9pt for cheatsheets, 14–16pt for slide headers.
- Margins: 2cm (general), 2.5cm (essay), 1cm (cheatsheet), 1.5cm (CV).
- `#set par(leading: ...)` — 0.5em compact, 0.65em normal, 0.7em loose.
- For long documents (>500 lines), split into `main.typ` + `lib.typ` +
  `sections/01-intro.typ` etc., and compile `main.typ --root .`.
