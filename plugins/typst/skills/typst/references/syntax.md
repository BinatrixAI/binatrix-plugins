# Typst syntax — the parts you actually use

Sourced from the official "Typst for LaTeX users" guide and adapted for the
résumé-and-PDF workflow that this skill is tuned for.

---

## Document anatomy

A `.typ` file is markup by default. No preamble required — start writing.
The `#` prefix switches into code mode for a single expression.

```typst
#set page(paper: "a4", margin: 2cm)
#set text(font: "New Computer Modern", size: 11pt)
#set par(leading: 0.65em, justify: true)

= Heading 1
== Heading 2
=== Heading 3

A paragraph in *bold*, _italic_, and `monospace`.
```

## Markdown → Typst heading mapping

When the user pastes Markdown and wants it as a Typst document, preserve
the heading depth. Don't collapse everything to `=` (a frequent mistake).

| Markdown  | Typst    |
|-----------|----------|
| `# H1`    | `= H1`   |
| `## H2`   | `== H2`  |
| `### H3`  | `=== H3` |
| `#### H4` | `==== H4`|

## Markup ↔ LaTeX

| Element       | LaTeX                          | Typst                         |
|---------------|--------------------------------|-------------------------------|
| Strong (bold) | `\textbf{x}`                   | `*x*`                         |
| Emphasis      | `\emph{x}`                     | `_x_`                         |
| Monospace     | `\texttt{x}`                   | `` `x` ``                     |
| Link          | `\url{...}`                    | `https://...` (auto-detected) |
| Label         | `\label{intro}`                | `<intro>`                     |
| Reference     | `\ref{intro}`                  | `@intro`                      |
| Citation      | `\cite{key}`                   | `@key`                        |
| H1 heading    | `\section{X}`                  | `= X`                         |
| H2 heading    | `\subsection{X}`               | `== X`                        |
| Bullet list   | `\begin{itemize} \item ...`    | `- item`                      |
| Numbered      | `\begin{enumerate} \item ...`  | `+ item`                      |
| Term list     | `\begin{description} ...`      | `/ Term: definition`          |
| Image         | `\includegraphics{f}`          | `image("f.png")`              |

## The three "modes"

- **Markup mode** — the default. Plain text + `*emphasis*` + `[content blocks]`.
- **Code mode** — opened with `#` (one expression) or `{ ... }` (a block).
- **Math mode** — opened with `$ ... $` (inline) or `$ ... $` with spaces / newlines (display).

```typst
#let five = 5             // code: variable binding
I have #five fingers.      // back in markup, # expression
{ let x = 5; x + 1 }       // code block, returns 6
[*bold* text]              // content block, can hold markup
"plain string"             // string, no markup
```

## `set` rules — defaults for the rest of the scope

```typst
#set page(paper: "a4", margin: 2cm)
#set text(font: "New Computer Modern", size: 11pt)
#set par(leading: 0.65em, justify: true)
#set enum(numbering: "I.")
#set heading(numbering: "1.1")
#set figure(placement: auto)   // ALWAYS for multi-page docs
```

## `show` rules — redefine appearance of an element kind

```typst
// Every level-1 heading: navy, big, with spacing
#show heading.where(level: 1): it => {
  v(0.8em)
  text(size: 16pt, weight: "bold", fill: rgb("#1e3a5f"), it)
  v(0.3em)
}

// All raw blocks: monospace via Fira Code
#show raw: set text(font: "Fira Code")

// Apply a template function
#import "@preview/charged-ieee:0.1.0": ieee
#show: ieee.with(title: "My Paper", authors: ("Alice",))
```

`show` is Typst's `\renewcommand`. It can transform any element type:
`heading`, `raw`, `figure`, `table`, `link`, `quote`, etc.

## Functions

```typst
#rect()                                    // bare call
#underline([_underlined_ text])            // content arg
#calc.max(3, 2 * 4)                        // dotted access
#rect(width: 2cm, height: 1cm, stroke: red)   // named args

// Trailing content (square brackets)
#rect(fill: aqua)[Hello]
// Equivalent to:
#rect(fill: aqua, body: [Hello])
```

`let` defines variables and functions:

```typst
#let five = 5
#let inc(i) = i + 1
#let banner(text) = block(fill: blue.lighten(80%), inset: 8pt, text)

I have #inc(five) fingers.
#banner[Important notice here.]
```

## Lists

```typst
// Unordered
- Fast
- Flexible
  - Nested item

// Ordered
+ Step one
+ Step two

// Term list
/ Typst: a typesetting system
/ LaTeX: also a typesetting system
```

## Math (résumé / cover-letter is unlikely to need this, but)

```typst
The sum is $sum_(k=1)^n k = (n(n+1)) / 2$.

$ f(x) = (x + 1) / x $    // display (spaces / newlines → display mode)

$ mat(
    1, 2;
    3, 4;
  ) $                      // matrix — rows separated by ;
```

Math gotchas (full list in `references/math.md`):

- Multi-letter identifiers: `$"NPV"$`, not `$NPV$`.
- No `\` prefix: `alpha`, `beta`, `pi`.
- No `\left` / `\right`: delimiters auto-scale.
- Currency outside math: `\$5,000`, not `$5,000`.

## Tables

```typst
#table(
  columns: (auto, 1fr, 2fr),
  align: (left, center, right),
  inset: 8pt,
  stroke: 0.5pt,
  table.header([*Name*], [*Role*], [*Notes*]),
  [Alice], [Engineer], [Joined 2023],
  [Bob],   [Designer], [Joined 2024],
)
```

Single `fill:` argument only — pass a function for conditional fills:

```typst
#table(
  fill: (x, y) => if y == 0 { rgb("#263238") }
                  else if calc.odd(y) { rgb("#f5f5f5") },
  ...
)
```

`table.header(...)` repeats the header on every page since Typst 0.14.

## Images

```typst
#image("photo.jpg")                              // natural width
#image("logo.svg", width: 40%)                   // sized
#image("chart.pdf")                              // PDF as image (0.14+)
#image("photo.jpg", alt: "Founder portrait, 2025")   // accessibility
```

Always add `alt:` for screen readers — Typst 0.14 emits PDF/UA-1 tagged
PDFs by default.

## Bibliography

```typst
A citation @einstein1905.
Prose form: #cite(<einstein1905>, form: "prose")

#bibliography("references.bib")     // BibTeX
#bibliography("references.yml")     // Hayagriva (YAML, Typst-native)
```

80+ CSL styles are bundled. To pick one: `bibliography("refs.bib", style: "ieee")`.

## Functions you'll reach for in résumé / PDF work

| Function                              | Use                                                |
|---------------------------------------|----------------------------------------------------|
| `image(path, width:, alt:)`           | embed image                                        |
| `link(url, [text])`                   | hyperlink                                          |
| `grid(columns:, gutter:, ..items)`    | layout (preferred over table for non-data)         |
| `block(width:, inset:, fill:, body)`  | a styled container                                 |
| `rect(width:, height:, fill:, stroke:)` | a rectangle (often used for badges, spacers)    |
| `box(...)`                            | inline analog of `rect`/`block`                     |
| `v(1em)` / `h(1fr)`                   | vertical space / flexible horizontal space         |
| `pagebreak(weak: true)`               | new page; `weak: true` skips if already at top     |
| `align(center, body)`                 | alignment wrapper                                  |
| `text(size: 11pt, fill: blue, body)`  | inline text styling                                |
| `datetime.today()`                    | today's date (for résumé date headers)             |
| `lorem(80)`                           | placeholder text                                   |

## Putting it together — a tiny example

```typst
#set page(paper: "a4", margin: 2cm)
#set text(font: "New Computer Modern", size: 10pt)
#set par(leading: 0.65em, justify: true)
#set heading(numbering: "1.")
#set figure(placement: auto)

#show heading.where(level: 1): it => {
  v(0.8em)
  text(size: 16pt, weight: "bold", fill: rgb("#1e3a5f"), it)
  v(0.3em)
}

= Introduction

#lorem(60)

== Background

Typst is an alternative to LaTeX. See @typst-paper for details.

#bibliography("refs.bib")
```
