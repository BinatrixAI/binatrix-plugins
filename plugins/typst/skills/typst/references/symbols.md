# Symbols cheatsheet

Rule of thumb: **default to `sym.*`**. The `sym` module is complete and
stable. The `emoji` module has gaps and will error on names that seem
natural but don't exist (`emoji.target`, `emoji.fire`).

---

## Safe vs unsafe

```typst
// Safe
#emoji.clock                   // 🕐
#emoji.pencil                  // ✏️
#emoji.checkmark               // ✅

// Unsafe — DOES NOT EXIST, will error at compile
#emoji.target                  // ❌ "module emoji does not contain target"
```

When in doubt, use a `sym.*` equivalent:

| Emoji you wanted        | Use `sym.*` instead    |
|-------------------------|------------------------|
| 🎯 (target)             | `sym.circle.filled` ●  |
| ⭐ (star)               | `sym.star.filled` ★    |
| ◇ (diamond)             | `sym.diamond.filled` ◆ |
| △ (triangle)            | `sym.triangle.stroked.t` △ |
| ☑ (check)               | `sym.checkmark` ✓      |

---

## Arrows

```typst
#sym.arrow.r        // →
#sym.arrow.l        // ←
#sym.arrow.t        // ↑
#sym.arrow.b        // ↓
#sym.arrow.l.r      // ↔
#sym.arrow.t.b      // ↕
#sym.arrow.r.long   // ⟶
#sym.arrow.r.double // ⇒
#sym.arrow.r.curve  // ⤴
```

## Bullets & marks

```typst
#sym.square         // □
#sym.checkmark      // ✓
#sym.dot            // ·
#sym.bullet         // •
#sym.dash.em        // —
#sym.dash.en        // –
#sym.dash.hyph      // -
#sym.star.filled    // ★
#sym.diamond.filled // ◆
#sym.circle.filled  // ●
#sym.heart          // ♡
```

## Math & logic

```typst
#sym.times          // ×
#sym.div            // ÷
#sym.lt.eq          // ≤
#sym.gt.eq          // ≥
#sym.approx         // ≈
#sym.percent        // %
#sym.plus.minus     // ±
#sym.infinity       // ∞
#sym.partial        // ∂
#sym.integral       // ∫
#sym.sum            // ∑
#sym.prod           // ∏
#sym.in             // ∈
#sym.subset         // ⊂
#sym.union          // ∪
#sym.intersect      // ∩
#sym.forall         // ∀
#sym.exists         // ∃
```

## Currency

```typst
#sym.dollar         // $   (use \$ in text instead — math-mode triggers otherwise)
#sym.euro           // €
#sym.pound          // £
#sym.yen            // ¥
```

## Punctuation that needs escaping in body

```typst
\#                  // # (would be code prefix)
\@                  // @ (would be reference)
\$                  // $ (would be math)
\<                  // <
\>                  // >
\_                  // _ (would be italic)
\*                  // * (would be bold)
```

---

## Inline symbol usage

In markup mode, `sym.*` works the same:

```typst
Status: #sym.checkmark Complete

Click #sym.arrow.r to proceed.

Score: 9.5 #sym.dot 10 (rounded)
```

In math mode, the `sym.` prefix is implicit — write the bare name:

```typst
$ AA x in RR ":" x^2 >= 0 $    // forall (AA), in, geq inferred
$ pi r^2 $                      // pi, no #sym needed
```
