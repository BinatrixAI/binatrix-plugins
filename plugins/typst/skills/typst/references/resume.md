# Résumé / Cover Letter — full reference

This is the headline workflow. The skill defaults to **`@preview/modern-cv`**
(the Awesome-CV design ported to Typst). `@preview/neat-cv` is the alternative
when the user wants sidebar layouts, accent colours, or skill-level bars.

---

## 1. Pick the template

| User said…                                                       | Pick           |
|------------------------------------------------------------------|----------------|
| Default, or "professional", or "classic", or "Awesome-CV"        | **modern-cv**  |
| "Modern with sidebar", "colourful", "with skill bars", "show publications" | **neat-cv** |
| "Academic CV with publications and grants"                       | **neat-cv** (Hayagriva bibliography) |
| "ATS-friendly, plain"                                            | **basic-resume** (`@preview/basic-resume:0.2.9`) |

If unsure → modern-cv. The user can swap later.

---

## 2. modern-cv (default)

- Package: `@preview/modern-cv:0.10.0` (April 2026)
- License: MIT
- Min Typst: 0.12.0 (current 0.14.2 is fine)
- Required fonts: **Roboto, Source Sans Pro, FontAwesome** — see §6 preflight.
- Modes: `resume.with(...)` for CVs, `letter.with(...)` for cover letters.

### Full résumé example (paste-runnable)

```typst
#import "@preview/modern-cv:0.10.0": *

#show: resume.with(
  author: (
    firstname: "John",
    lastname: "Smith",
    email: "js@example.com",
    phone: "(+1) 111-111-1111",
    github: "ptsouchlos",
    linkedin: "Example",
    address: "111 Example St. Example City, EX 11111",
    positions: (
      "Software Engineer",
      "Software Architect",
    ),
  ),
  profile-picture: none,
  date: datetime.today().display(),
  paper-size: "us-letter",
  accent-color: rgb("#26428b"),
)

= Education

#resume-entry(
  title: "Example University",
  location: "B.S. in Computer Science",
  date: "August 2014 - May 2019",
  description: "Cum laude",
)

#resume-item[
  - Relevant coursework: Distributed Systems, Compilers, Cryptography
  - Senior thesis: lock-free queue benchmarking under contention
]

= Experience

#resume-entry(
  title: "Senior Engineer",
  location: "Acme Corp — Remote",
  date: "June 2019 - Present",
  description: "Platform team",
)

#resume-item[
  - Led platform migration to edge-first architecture; cut p99 latency 47%
  - Mentored 4 engineers across two timezones; ran weekly architecture reviews
  - Shipped 11 consecutive months with zero production rollbacks
]

#resume-entry(
  title: "Software Engineer",
  location: "Startup Inc. — Remote",
  date: "June 2019 - June 2021",
  description: "Founding engineer",
)

#resume-item[
  - Designed and shipped real-time collaboration backend (WebSocket + CRDT)
  - Wrote the deployment pipeline; built CI from scratch
]

= Projects

#resume-entry(
  title: "open-source-lib",
  location: "github.com/janedoe/open-source-lib",
  date: "2023",
  description: "Rust crate, 800+ stars",
)

#resume-item[
  - High-performance JSON streaming parser; published to crates.io
  - Used by 4 production projects including notable-company
]

= Skills

#resume-item[
  - *Languages:* Rust, Go, TypeScript, Python, SQL
  - *Infrastructure:* Cloudflare Workers, AWS, Kubernetes, Postgres, Redis
  - *Tools:* Git, Linux, Docker, Terraform
]
```

### Cover letter

modern-cv exports the cover-letter mode as **`coverletter`** (not `letter`),
and the recipient block + salutation are **separate function calls** in the
body, not parameters of `coverletter.with(...)`. Always use
`datetime.today().display()` for the date — don't hard-code a string.

```typst
#import "@preview/modern-cv:0.10.0": *

#show: coverletter.with(
  author: (
    firstname: "John",
    lastname: "Smith",
    email: "js@example.com",
    phone: "(+1) 111-111-1111",
    address: "111 Example St., Example City, EX",
    positions: ("Senior Engineer",),
  ),
  date: datetime.today().display(),
  paper-size: "us-letter",
  // Font overrides if Roboto / Source Sans Pro are not installed:
  font: "New Computer Modern",
  header-font: "New Computer Modern",
  // Hide icon-backed contact glyphs when FontAwesome is missing:
  show-address-icon: false,
)

// Recipient block (replaces the old `recipient:` param).
#hiring-entity-info(
  entity-info: (
    target: "Hiring Team",        // first line — usually a team or role
    name: "Acme Corp",            // company name
    street-address: "1 Acme Way", // optional; "" if unknown
    city: "Springfield, IL",
  ),
)

// Letter heading — job position + salutation. Replaces the old
// `subject:` parameter. `addressee:` becomes "Dear <addressee>,".
#letter-heading(
  job-position: "Senior Engineer",
  addressee: "Hiring Team",
)

= About Me

I am writing to apply for the Senior Engineer role at Acme Corp. Over the
past five years I have led platform-level work at scale, including the
migration that you describe in the job posting.

= Why Acme?

Your platform team's recent move to edge-first architecture maps directly
to the work I have been doing — and the parts of the role I am most
excited about are the same ones that originally pulled me into this
field.

= Why Me?

In my current role at Startup Inc. I designed and shipped a real-time
collaboration backend used by 50k weekly active users. The system uses
CRDTs over WebSocket and recovers cleanly from network partitions. I
would be glad to walk through the design during the interview.

Thank you for considering my application.
```

**Body convention**: `= About Me` → `= Why <Company>?` → `= Why Me?`. Three
top-level sections, one short paragraph each. The canonical modern-cv
template uses this exact pattern.

**Missing fields**: if the user didn't give a street address, pass `""` —
never invent one. The `target:` line in `hiring-entity-info` is required
and is usually the team / role / committee, not an individual.

### Knobs reference

| `resume.with(...)` param | Type           | Default                       | Notes                                            |
|--------------------------|----------------|-------------------------------|--------------------------------------------------|
| `author`                 | dict           | required                      | firstname, lastname, email, phone, github, linkedin, address, positions |
| `profile-picture`        | image \| none  | `none`                        | `image("photo.jpg")` for headshot                |
| `date`                   | str            | `datetime.today().display()`  | Footer/header date                               |
| `paper-size`             | str            | `"us-letter"`                 | or `"a4"`                                        |
| `accent-color`           | color          | package default               | e.g. `rgb("#26428b")` or `rgb("#c5a247")`        |
| `font`                   | str            | `"Source Sans Pro"`           | Override if not installed                        |
| `header-font`            | str            | `"Roboto"`                    | Override if not installed                        |

`resume-entry(title:, location:, date:, description:)` — one role / one degree / one project.
`resume-item[...]` — the bullet-list body that follows an entry (or stands alone in a `Skills` section).

Section convention (top-level `=`):
- `= Education`
- `= Experience`
- `= Projects`
- `= Skills`
- `= Certifications`
- `= Languages`
- `= Awards` / `= Publications` / `= Service`

Order them by the role: backend engineer → Experience first; new grad → Education first.

---

## 3. neat-cv (alternative)

When to pick: user wants colourful sidebar, skill-level bars, or has a
publications list.

- Package: `@preview/neat-cv:1.0.0`
- License: MIT
- Min Typst: 0.13.0

```typst
#import "@preview/neat-cv:1.0.0": cv, cv-with-side, entry, item-with-level, contact-info

#show: cv-with-side.with(
  name: "John Smith",
  position: "Software Engineer",
  contact: contact-info(
    email: "js@example.com",
    phone: "(+1) 555-0100",
    location: "Example City, EX",
    links: (
      (icon: "github", text: "ptsouchlos"),
      (icon: "linkedin", text: "Example"),
    ),
  ),
  accent: rgb("#26428b"),
)

== Experience

#entry(
  title: "Senior Engineer",
  org: "Acme Corp",
  date: "Jun 2019 - Present",
)[
  - Led platform migration to edge-first architecture
  - Mentored a team of 4
]

== Skills

#item-with-level("Rust",       level: 5)
#item-with-level("Go",         level: 4)
#item-with-level("TypeScript", level: 4)
#item-with-level("Python",     level: 3)

== Publications

#publications(yaml("publications.yml"), highlight-authors: ("John Smith",))
```

Layout variants (pass via `cv.with(...)` instead of `cv-with-side`):

- `cv-with-side` — sidebar with contact + skills.
- `cv-with-thin-side` — narrower sidebar, content gets more room.
- `cv` — full-width, no sidebar.

---

## 4. End-to-end workflow

When the user wants a CV PDF, do exactly this:

1. **Receive content.** Read what the user pasted, or read the file path they
   gave, or ask once for the minimum: name, role, 2-3 jobs with dates and
   one-line achievements, education, key skills.
2. **Pick the template.** modern-cv unless the user signalled neat-cv cues
   (sidebar / colourful / skill bars / publications).
3. **Pick the output path.** User-supplied path wins. Otherwise `./cv.typ` +
   `./cv.pdf`. Note the absolute path for the final report.
4. **Run the font preflight.** See §6. For modern-cv, you must know up front
   whether Roboto / Source Sans Pro / FontAwesome are present.
5. **Write `cv.typ`** with the right imports and `#show: resume.with(...)`.
   Fill `author: (...)` and section bodies from user content. Never invent
   employers, dates, or quantified results. If something is missing, ask
   once — bunched into one question.
6. **Compile**:
   ```bash
   typst compile cv.typ
   ```
   On compile error → consult `references/errors.md`. Common one with
   modern-cv on macOS: "font not found: Roboto" → font preflight wasn't done.
7. **Render a preview**:
   ```bash
   typst compile cv.typ /tmp/cv-preview.png --pages 1
   ```
   For two-page CVs also render page 2.
8. **Read the PNG** and visually check: name appears, no fallback squares
   (missing fonts), contact line not cut off the right edge, dates aligned,
   no overflow, headings visible, photo (if any) not stretched.
9. **Report back** with: absolute PDF path, the preview PNG inline, and a
   one-line summary mentioning any font fallbacks or substitutions applied.

---

## 5. Output conventions

- Always write a `.typ` source next to the PDF — the user will iterate on it.
- Always print the absolute output path on a line by itself, e.g.
  `→ /Users/dima/Documents/cv.pdf`. The user can `open` it from another
  cmux pane.
- Never overwrite an unrelated `.typ` file. If `./cv.typ` exists and is not
  recognisably the in-progress draft, ask before clobbering.
- Per-section content goes inside the `=` heading body — don't pile
  everything into one section.

---

## 6. Font preflight (macOS-specific friction point)

modern-cv ships with three font dependencies that macOS does not have
installed by default: **Roboto**, **Source Sans Pro**, **FontAwesome**.

### Diagnostic

```bash
typst fonts 2>/dev/null | grep -iE "roboto|source sans|font ?awesome" | sort -u
```

Expected output if everything is in place:

```
FontAwesome
Roboto
Source Sans Pro
```

(Names vary slightly across versions — "Source Sans 3" is also acceptable.)

If output is empty or missing items, choose a remediation:

### Path A — install via Homebrew (preferred, one-time)

```bash
# First time only — tap the fonts cask:
brew tap homebrew/cask-fonts 2>/dev/null || true

brew install --cask font-roboto font-source-sans-3 font-fontawesome
```

After installation, re-run the diagnostic to confirm.

### Path B — override to bundled fonts (no install, ~30 second fix)

`New Computer Modern` ships with Typst and renders cleanly. Pass overrides
into `resume.with(...)`:

```typst
#show: resume.with(
  ...,
  font: "New Computer Modern",
  header-font: "New Computer Modern",
)
```

FontAwesome substitution: without the icon font, the contact-line icons
(github, linkedin, phone) render as fallback rectangles. Two options:

- Install just the icon font (`brew install --cask font-fontawesome`).
- Drop icon-backed fields from `author: (...)` and add a plain `= Contact`
  section with text links.

### Default behaviour when no user preference is stated

Try Path A. If `brew install` errors (no homebrew, no network, denied), fall
back to Path B and **say so in the final summary** so the user knows the look
is slightly different from the modern-cv canonical screenshots.

---

## 7. Iteration tips

The user will usually want a second pass. Common edits:

- **Add a job** → new `#resume-entry(...)` + `#resume-item[...]` block
  inside the `= Experience` section, in reverse-chronological order.
- **Tighten bullets** → 1-2 lines each, action verb first, quantified where
  possible. Numbers > adjectives.
- **Brand colour** → `accent-color: rgb("#xxxxxx")` in `resume.with(...)`.
- **Photo** → `profile-picture: image("photo.jpg")` (file relative to .typ).
- **Two columns / sidebar look** → switch to neat-cv (§3); modern-cv is
  single-column by design.
- **Page-2 overflow** → tighten bullet wording, or accept a 2-page CV. Do
  not shrink the font below 10pt; modern-cv looks bad below that.

---

## 8. Why this template, why this default

modern-cv is the Typst port of `posquit0/Awesome-CV` (27.6k-star LaTeX
project). It's recognisable to recruiters as "the serious-engineer CV
template" and renders consistently across paper sizes. It's actively
maintained, MIT-licensed, and works with Typst 0.12+.

neat-cv is more visually distinctive (sidebar variants, skill bars). Choose
it when the user wants their CV to stand out visually rather than blend
into the Awesome-CV pile.

Both are stable. Switching between them is just changing the import line +
adjusting field names — no other code changes.
