# `@preview` packages — the useful ones

Typst packages live at https://typst.app/universe/. They auto-download and
cache on first compile — no separate install. Always **pin** a version; the
namespace is experimental and APIs can break between minors.

Listed here: the packages this skill actually uses (résumé, slides, doc
writing). For exotic stuff (data viz, diagrams, sequence charts), browse the
universe directly.

---

## Résumé / cover letter

| Package           | Version  | Purpose                                                                  |
|-------------------|----------|--------------------------------------------------------------------------|
| `modern-cv`       | `0.10.0` | Default résumé template (Awesome-CV port). Needs Roboto / Source Sans / FontAwesome. |
| `neat-cv`         | `1.0.0`  | Alt: sidebar layouts, accent colours, skill bars, Hayagriva publications.|
| `basic-resume`    | `0.2.9`  | Minimal ATS-friendly fallback.                                           |
| `brilliant-cv`    | `4.0.1`  | Feature-rich CV — older Awesome-CV style.                                |
| `fontawesome`     | latest   | Icon font (transitive dep of modern-cv & neat-cv).                       |

Detailed usage: `references/resume.md`.

---

## Presentations

| Package    | Version  | Purpose                                                |
|------------|----------|--------------------------------------------------------|
| `touying`  | `0.6.1`  | Active presentation framework. Use 0.6.x API only.     |

Detailed usage: `references/touying.md`.

---

## Callouts / boxes (for documents)

| Package         | Version | Purpose                                       |
|-----------------|---------|-----------------------------------------------|
| `gentle-clues`  | `1.3.0` | Tip / warning / note / example admonitions    |
| `showybox`      | `2.0.4` | Customisable bordered boxes                   |

```typst
#import "@preview/gentle-clues:1.3.0": tip, warning, example

#tip[Shrinkage estimators are best when T < N.]
#warning[The `path` function is deprecated. Use `curve`.]
#example[A 60/40 portfolio averaged Sharpe 0.8 over 2010-2020.]
```

```typst
#import "@preview/showybox:2.0.4": showybox

#showybox(
  title: "Key Insight",
  frame: (border-color: blue, title-color: blue.lighten(80%)),
)[Diversification reduces unsystematic risk, not systematic risk.]
```

---

## Code blocks

| Package  | Version | Purpose                                  |
|----------|---------|------------------------------------------|
| `codly`  | `1.3.0` | Code blocks with line numbers, language labels |
| `zebraw` | `0.6.1` | Zebra-striped code, line highlighting    |

```typst
#import "@preview/codly:1.3.0": *
#show: codly-init.with()

```rust
fn main() {
    println!("Hello, world!");
}
```
```

```typst
#import "@preview/zebraw:0.6.1": *
#show: zebraw.with(
  background-color: luma(250),
  highlight-color: rgb("#e3f2fd"),
)
```

---

## Tables / lists

| Package      | Version | Purpose                                  |
|--------------|---------|------------------------------------------|
| `tablem`     | `0.3.0` | Markdown-style table syntax              |
| `glossarium` | `0.5.10`| Glossaries with cross-referencing        |

```typst
#import "@preview/tablem:0.3.0": tablem

#tablem[
  | Name  | Role     | Department |
  | ----- | -------- | ---------- |
  | Alice | Engineer | Platform   |
  | Bob   | Designer | Product    |
]
```

```typst
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary, gls, print-glossary

#show: make-glossary
#register-glossary((
  (key: "capm", short: "CAPM", long: "Capital Asset Pricing Model",
   desc: "Equilibrium asset-pricing model relating return to systematic risk."),
))

The #gls("capm") is widely taught.

#print-glossary()
```

---

## Pseudocode / algorithms

| Package    | Version | Purpose                       |
|------------|---------|-------------------------------|
| `lovelace` | `0.3.0` | Pseudocode (algorithms style) |

```typst
#import "@preview/lovelace:0.3.0": pseudocode-list

#pseudocode-list[
  + *Input:* views $q$, uncertainty $tau$
  + Compute equilibrium $Pi = delta Sigma w_"mkt"$
  + Blend views with prior
  + *Output:* posterior expected returns $mu$
]
```

---

## Markdown bridge

| Package  | Version | Purpose                              |
|----------|---------|--------------------------------------|
| `cmarker`| `0.1.0` | Render Markdown content inside Typst |

```typst
#import "@preview/cmarker:0.1.0": render

#render(read("notes.md"))
```

Handy when migrating Markdown content into a Typst doc — keep the body in
Markdown and use Typst for page styling.

---

## Article templates

| Package         | Version | Purpose                  |
|-----------------|---------|--------------------------|
| `charged-ieee`  | `0.1.0` | IEEE article template    |

```typst
#import "@preview/charged-ieee:0.1.0": ieee

#show: ieee.with(
  title: "Towards Improved Modelling",
  authors: ((name: "Alice", affiliation: "Artos Institute"),),
  abstract: "We propose ...",
)
```

Browse https://typst.app/universe/ for: ACM, Springer, dissertation
templates, journal styles, etc.

---

## Network gotchas

Packages download from `https://packages.typst.org`. If you see "package
not found" on a fresh machine:

```bash
# Check connectivity
curl -sI https://packages.typst.org | head -1

# Cache location (where packages land after first download)
ls "${XDG_DATA_HOME:-$HOME/Library/Application Support}/typst/packages/preview/"
```

If the user is offline, the bundled templates in `references/templates.md`
work without `@preview` — they're plain Typst.
