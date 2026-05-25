# Math mode — pitfalls and patterns

Most résumé / cover-letter work won't need this, but document generation in
Typst routinely involves a formula or two and the math mode has sharp edges.

---

## The mental model

- `$ ... $` (no spaces around delimiters) = **inline** math
- `$ ... $` with spaces or newlines around the inner content = **display** math
- Inside math: **no `\` prefix** for symbols; `alpha`, `beta`, `pi` work bare
- Inside math: delimiters auto-scale, no `\left` / `\right`
- Functions don't need `#` inside math; regular content (and code) does

```typst
The sum from $1$ to $n$ is $sum_(k=1)^n k = (n(n+1)) / 2$.

$ f(x) = (x + 1) / x $                    // display

$ f(x, y) := cases(
    1 "if" (x dot y)/2 <= 0,
    2 "if" x "is even",
    3 "if" x in NN,
    4 "else",
  ) $

$ mat(
    1, 2;
    3, 4;
  ) $                                      // matrix; rows separated by ;
```

To inject code mode into math, use `#`:

```typst
$ (a + b)^2 = a^2 + text(fill: #maroon, 2 a b) + b^2 $
```

---

## Currency in math mode → don't

```typst
// WRONG — inner $ closes math mode
$ P = $548.33 $

// WRONG — £ is unknown in math
$ V_0 = £80.00 $

// CORRECT — numbers in math, currency in text
$ P = 548.33 $
The price is \$548.33.

$ V_0 = 80.00 $
The value is £80.00.
```

---

## Multi-letter identifiers

Adjacent letters in math become a single variable name. Almost every finance
or science abbreviation breaks this.

| You write          | Typst sees             | Fix                                       |
|--------------------|------------------------|-------------------------------------------|
| `$NPV = 0$`        | variable `NPV` → error | `$"NPV" = 0$`                             |
| `$tD$`             | variable `tD`          | `$t D$` or `$t times D$`                  |
| `$WACC$`           | variable `WACC`        | `$"WACC"$`                                |
| `$V_L = V_U + tD$` | `tD` is one variable   | `$V_L = V_U + t D$`                       |

Same with IRR, FCFF, FCFE, EPS, ROE, DDM, CAPM, CFA, IRR, WACC, ROIC.

Quoted strings inside math render **upright** (no italics) — appropriate for
abbreviations:

```typst
$ "NPV"_t = sum_(k=0)^n ("CF"_k) / (1 + r)^k $
```

---

## Angle brackets and CJK

`<text>` is `<label-reference>` syntax — this includes CJK text containing
bare `<` `>`. See `references/errors.md` for the cross-cutting catalogue;
the math-specific bit is that you'll also hit this inside math comments and
text functions:

```typst
$ x = cases(
    "if" x < 5 ":" 1,        // OK — < inside string
    "if" x > 5 ":" 2,        // OK
  ) $

// Outside the string in math text — escape:
The condition $x \< 5$ holds when ...
```

---

## Commas break number lines

```typst
// WRONG — displays "1, 471, 429" with line breaks
$ "PV" = 1,471,429 / 1.6105 $

// CORRECT — no thousand separators inside math
$ "PV" = 1471429 / 1.6105 $

// For formatted display, drop to text mode
The PV is £1,471,429.
```

---

## Subscripts and superscripts

```typst
$ x^2 $              // single-token superscript
$ x_2 $              // single-token subscript
$ x^(2n) $           // multi-token superscript — needs parens
$ x_(a -> epsilon) $ // multi-token subscript
$ x^2_3 $            // both at once
```

---

## Common symbols (without the `\` prefix)

```typst
alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu
nu xi omicron pi rho sigma tau upsilon phi chi psi omega

Alpha Beta Gamma Delta ... (capitals)

partial nabla infinity emptyset
NN ZZ QQ RR CC                   // blackboard bold for number sets

sum prod integral                 // big operators
arrow.r arrow.l arrow.t arrow.b   // arrows (see references/symbols.md)
times div dot                     // operators
in subset supset notin            // set membership
leq geq neq approx equiv          // comparisons

forall exists exists.not          // quantifiers
```

`#sym.*` form works outside math too, e.g. `#sym.sum` in prose.

---

## Function call patterns

```typst
$ sin(x) $                     // common functions — pre-defined as upright
$ log(x) $
$ exp(x) $
$ op("MyOp")(x) $              // your own upright operator
$ "MyFunc"(x) $                // string ⇒ upright

$ E[R_p] = sum_(i=1)^n w_i E[R_i] $
$ "Var"(X) = E[(X - mu)^2] $
$ "Cov"(X, Y) = rho_(X Y) sigma_X sigma_Y $
```

---

## Numbering and labels

```typst
#set math.equation(numbering: "(1)")

$
  E = m c^2
$ <einstein>

As shown in @einstein, mass and energy are equivalent.

// Skip numbering for one equation:
$ a^2 + b^2 = c^2 $    // no label, no number
```

---

## Putting it together — résumé sidebar with one formula

If a CV needs a single formula (rare, but happens for researcher CVs), keep
the math block compact:

```typst
= Research

#resume-entry(
  title: "Modelling Sharpe-Maximising Portfolios",
  location: "Submitted to JFinE 2025",
  date: "Mar 2025",
  description: "Lead author",
)

The maximum-Sharpe portfolio under no short-sale constraints satisfies

$ w^* = (Sigma^(-1) (mu - r_f bb(1))) / (bb(1)^T Sigma^(-1) (mu - r_f bb(1))) $

where $Sigma$ is the covariance matrix and $r_f$ the risk-free rate.
```
