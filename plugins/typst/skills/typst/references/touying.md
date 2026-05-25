# Touying 0.6.x — Typst presentations

Touying is the active presentation framework for Typst 0.14. Polylux is dead
(its 0.3.x is incompatible with 0.14). The 0.6.x API differs **completely**
from 0.3.x / 0.4.x — do not use `register()`, `utils.methods()`, or
`utils.slides()` (those are the old API).

The shape is always: `#import "@preview/touying:0.6.1": *` → import a theme →
`#show: theme-name.with(...)` → write slides using `=` for sections and `==`
for slides.

---

## Quick-start (Metropolis theme — the safe default)

```typst
#import "@preview/touying:0.6.1": *
#import themes.metropolis: *

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Presentation Title],
    subtitle: [Subtitle],
    author: [Author Name],
    date: datetime.today(),
    institution: [Institution],
  ),
)

#title-slide()

= First Section

== Slide Title

Content here.

#pause

This appears after one click.

#focus-slide[Questions?]
```

---

## Theme matrix

| Theme       | Import line                       | Show rule                         | Best for                                |
|-------------|-----------------------------------|-----------------------------------|-----------------------------------------|
| metropolis  | `#import themes.metropolis: *`    | `metropolis-theme.with(...)`      | technical talks, seminars               |
| university  | `#import themes.university: *`    | `university-theme.with(...)`      | academic lectures, institution branding |
| stargazer   | `#import themes.stargazer: *`     | `stargazer-theme.with(...)`       | polished conferences                    |
| dewdrop     | `#import themes.dewdrop: *`       | `dewdrop-theme.with(...)`         | light aesthetic, top navigation         |
| simple      | `#import themes.simple: *`        | `simple-theme.with(...)`          | minimal, distraction-free               |
| aqua        | `#import themes.aqua: *`          | `aqua-theme.with(...)`            | colourful, modern                       |

Theme-specific parameters:

```typst
#show: stargazer-theme.with(
  aspect-ratio: "16-9",
  progress-bar: true,              // bottom progress indicator
  config-info(...),
)

#show: dewdrop-theme.with(
  aspect-ratio: "16-9",
  navigation: "mini-slides",       // top navigation bar
  config-info(...),
)
```

---

## `config-info` — always populate

```typst
config-info(
  title: [Title],
  subtitle: [Subtitle],
  author: [Author],
  date: datetime.today(),
  institution: [Institution],
  logo: emoji.school,              // or image("logo.png", height: 1.5em)
)
```

## `config-common` — global behaviour

```typst
config-common(
  show-notes-on-second-screen: right,   // enable speaker-notes display
  datetime-format: auto,
)
```

---

## Slide types

```typst
= Section Title         // section divider slide (automatic)
== Slide Title           // regular slide with title
---                      // untitled slide (content only)

#title-slide()                                    // title page
#title-slide(authors: ([Alice], [Bob]))           // university theme
#focus-slide[Wake up!]                            // full-screen emphasis
#matrix-slide[Left][Right]                        // 2-column
#matrix-slide(columns: 3)[A][B][C]                // 3-column
#matrix-slide(columns: (1fr, 2fr))[Narrow][Wide]  // proportional
#outline-slide()                                  // table of contents
```

---

## Reveals / animation

```typst
== Key Concepts

First point — always visible.

#pause

Second point — appears on click.

#pause

Third point — on next click.
```

**Cap pauses at 2-3 per slide.** Overuse makes a deck feel sluggish.

`#meanwhile` synchronises content across columns (useful in `matrix-slide`):

```typst
First left line.
#pause
More left.
#meanwhile
Right column (appears with "First left line", not after the pause).
```

`components.progressive-show` reveals list items one by one:

```typst
#components.progressive-show(
  [- First],
  [- Second],
  [- Third],
)
```

---

## Speaker notes

```typst
== Slide Title

Visible content.

#speaker-note[
  - Talking points
  - Hidden in normal view
]
```

Enable display with `config-common(show-notes-on-second-screen: right)`.

---

## Appendix

```typst
#show: appendix

= Backup Slides

== Extra Detail
```

Slides after `#show: appendix` are excluded from totals and outlines.

---

## Common pitfalls

| Pitfall                          | Symptom / Cause                              | Fix                                    |
|----------------------------------|----------------------------------------------|----------------------------------------|
| Using 0.3.x / 0.4.x API          | `register()` / `utils.methods()` not found  | use `#show: theme.with(...)`           |
| Missing theme import             | `themes.metropolis` not found               | `#import themes.metropolis: *`         |
| Empty title slide                | no metadata shown                            | populate `config-info(...)`            |
| Polylux import                   | incompatible with touying                    | use touying only, don't mix            |
| Too many `#pause`                | sluggish feel                                | max 2-3 per slide                      |
| Custom fonts not found           | theme defaults assumed                       | pass `font:` and `header-font:` overrides into the theme |

---

## Compiling slides

```bash
# 16:9 PDF
typst compile slides.typ

# PNG export — one per slide
typst compile slides.typ /tmp/slide-{0p}.png --ppi 150

# Quick preview of slide 5
typst compile slides.typ /tmp/slide.png --pages 5
```

---

## Version note

Pin `@preview/touying:0.6.1`. Newer versions (0.6.2+) may add features but
break minor things. Stable on Typst 0.14.x.
