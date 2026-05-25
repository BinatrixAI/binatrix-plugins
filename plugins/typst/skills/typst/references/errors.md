# Typst compile errors — catalogue & fixes

Compilation success (exit code 0) does **not** guarantee correct output —
always render a preview PNG and look at it. But these are the errors that
prevent compilation entirely, ordered by how often they bite real users.

---

## Top 5 errors

| Error                                | Cause                                              | Fix                                                |
|--------------------------------------|----------------------------------------------------|----------------------------------------------------|
| `unclosed delimiter`                 | bare `$`, `_`, or `*` in body text                 | escape: `\$`, `\_`, `\*` (or `......` for blanks)  |
| `unknown variable: <name>`           | multi-letter math identifier OR missing `#` prefix | `$"NPV"$` (quote), or add `#`                      |
| `unclosed label`                     | `<text>` parsed as `<label>` reference             | `\<` `\>`, or words, or fullwidth `＜＞`            |
| `unknown variable: True` (or None)   | expression chain — `#func()(…)` parsed as call     | insert `~` between `)` and `(`                     |
| `module emoji does not contain X`    | `emoji.*` has gaps                                 | use `sym.*` equivalent — sym module is complete    |

## Full table (top 12)

| #  | Error                                 | Cause                                              | Fix                                                  |
|----|---------------------------------------|----------------------------------------------------|------------------------------------------------------|
| 1  | `unclosed delimiter`                  | `$5,000` opens math mode                           | `\$5,000` — escape all `$` in body                   |
| 2  | `unclosed delimiter`                  | `_word_` or `*word*` triggers emphasis             | `\_`, `\*`, or rephrase                              |
| 3  | `unknown variable: NPV`               | adjacent letters = one variable name in math       | `$"NPV"$` (quoted string, upright)                   |
| 4  | `unknown variable: <name>`            | function called without `#` in markup mode         | `#func()` not `func()`                               |
| 5  | `unknown variable: True` / `None`     | `#h(1em)("text")` parsed as call                   | `#h(1em)~("text")` — `~` breaks the chain            |
| 6  | `unclosed label`                      | `<text>` is `<label-ref>` syntax                   | `\<` `\>`, or rephrase, or fullwidth `＜＞`           |
| 7  | `duplicate argument`                  | same parameter passed twice (e.g. `fill:` × 2)     | merge into a single `fill: (x, y) => ...` function   |
| 8  | `unexpected token`                    | unescaped `#`, `@`, or `$` in body                 | escape: `\#`, `\@`, `\$`                             |
| 9  | `context is known`                    | `counter()` called outside `context`               | wrap in `#context [...]`                             |
| 10 | `module emoji does not contain X`     | not all emoji exist                                | use `sym.star.filled` instead of `emoji.target`      |
| 11 | `font not found: Roboto`              | modern-cv requires Roboto / Source Sans / FontAwesome | run font preflight; install via brew or override font: |
| 12 | `element functions ... no longer have a register method` | old polylux / pre-0.6 touying API          | upgrade to touying 0.6.x — use `#show: theme.with(...)` |

---

## Math-mode pitfalls (deep)

### Currency in math mode

```typst
// WRONG — "unclosed delimiter" / "unknown variable"
$ P = $548.33 $        // inner $ breaks delimiter
$ V_0 = £80.00 $       // £ is unknown in math

// CORRECT — numbers in math, currency outside
$ P = 548.33 $
The price is \$548.33.

$ V_0 = 80.00 $
The value is £80.00.
```

### Angle brackets parsed as labels (including CJK)

`<text>` is always interpreted as `<label-reference>` — this includes Chinese
or Japanese text containing bare `<` `>`:

```typst
// WRONG
[Premium (>100)]
#cn[当收益率 < 5% 时]

// FIX 1 — words
[Premium (above 100)]
#cn[当收益率小于 5% 时]

// FIX 2 — fullwidth (invisible to reader)
[Premium (＞100)]
#cn[当收益率 ＜ 5% 时]

// FIX 3 — escape
[Premium (\>100)]
```

Batch-find bare angle brackets:

```bash
grep -n '[^\\]<\|[^\\]>' document.typ
```

### Adjacent letters in math

Typst parses adjacent letters as a single variable. Almost every finance /
science abbreviation breaks this rule.

| You write          | Typst sees             | Fix                                  |
|--------------------|------------------------|--------------------------------------|
| `$NPV = 0$`        | variable `NPV` → error | `$"NPV" = 0$`                        |
| `$tD$`             | variable `tD`          | `$t D$` or `$t times D$`             |
| `$WACC$`           | variable `WACC`        | `$"WACC"$`                           |
| `$V_L = V_U + tD$` | `tD` is one variable   | `$V_L = V_U + t D$`                  |

Same trap with: IRR, FCFF, FCFE, EPS, ROE, DDM, CAPM, CFA, etc.

### Commas break lines in math

```typst
// WRONG — displays "1, 471, 429" with breaks
$ "PV" = 1,471,429 / 1.6105 $

// CORRECT — no separators inside math
$ "PV" = 1471429 / 1.6105 $

// For formatted display, drop to text mode
The PV is £1,471,429.
```

### Asterisk inside content block

```typst
// ERROR — `*` opens bold
[The value is \$1,859,375*]

// FIX
[The value is \$1,859,375\*]
```

---

## Special character cheatsheet

| Char    | Problem                                | Solution                                |
|---------|----------------------------------------|------------------------------------------|
| `#`     | command prefix                         | `\#` in content                          |
| `_`     | triggers italic                        | `\_`, or `......` for blanks             |
| `*`     | triggers bold                          | `\*` or rephrase                         |
| `@`     | reference / citation                   | `\@` in plain text                       |
| `$`     | math delimiter                         | `\$` for currency; never inside `$ $`    |
| `<` `>` | label reference (in ALL content)       | `\<` `\>`, or fullwidth `＜＞`            |
| `£` `€` | unknown in math mode                   | keep outside `$ $`                       |

---

## Font-not-found errors

The most common compile error for new users on macOS, especially with
modern-cv:

```
error: font not found: Roboto
```

Diagnostic:

```bash
typst fonts 2>/dev/null | grep -iE "roboto|source sans|font ?awesome"
```

Fix path A — install:

```bash
brew install --cask font-roboto font-source-sans-3 font-fontawesome
```

Fix path B — override in the .typ:

```typst
#show: resume.with(
  ...,
  font: "New Computer Modern",
  header-font: "New Computer Modern",
)
```

See `references/resume.md` §6 for the full font preflight workflow.

---

## Package version mismatches

The `@preview` namespace is experimental — APIs can break between minor
versions. Symptoms:

- `function not found: register` → old polylux/touying API. Upgrade.
- `unexpected argument` after pinning a newer version → consult the
  package's own README on https://typst.app/universe/.

Always **pin** versions: `@preview/modern-cv:0.10.0`, not bare
`@preview/modern-cv`.

---

## When the file just won't compile

If you can't isolate the error:

1. **Bisect with comments.** Wrap halves of the document in `/* ... */` and
   compile incrementally to find the broken region.
2. **Strip imports.** Comment out all `#import` lines except essentials,
   then re-add one by one.
3. **Compile a minimal repro.** Copy the broken section into a fresh
   `repro.typ` with only the relevant `#set` rules.
4. **Check Typst version.** `typst --version`. If < 0.14, several features
   in `references/*` won't work — bump the binary first.

---

## Useful one-liners

```bash
# Find bare $ in body (likely currency that needs escaping)
grep -n '[^\\]\$' document.typ | grep -v '^.*\$.*\$.*$'

# Find bare angle brackets
grep -n '[^\\]<\|[^\\]>' document.typ

# Find unescaped # in markup
grep -n '[^\\]#[a-z]' document.typ | head -20

# List headings to verify structure
typst query document.typ "heading" --field "body"
```
