# Stabilizing Datasets

## From noisy to stable

Real data arrives in whatever form it was entered: dates as `03/15/2019`
or `15-Mar-2019`, booleans as `Y`/`yes`/`TRUE`/`1`, dollars as `$1,200`,
ZIP codes that a spreadsheet already mangled into `6037`. A
**stabilized** dataset is the same data rewritten into a canonical form
that behaves — one that the next program reads correctly instead of
guessing.

[`stabilize_data()`](../reference/stabilize_data.md) applies the DGF’s
rules to a raw extract and returns that clean version, which
[`write_stable_csv()`](../reference/write_stable_csv.md) writes as a
*governed CSV* carrying its own DGF and provenance.

``` r

stable <- stabilize_data(raw_data, dgf, use_v7 = TRUE)
write_stable_csv(stable, "data-governed.csv", dgf = dgf)
```

## Two outcomes: stabilized *to type*, or stabilized *safely*

Not every column can be losslessly typed in a CSV — and datagoodr is
careful about the difference.

### Stabilized to type

Columns whose meaning a reader *can* recover are converted to a
canonical form that imports to the right type:

| kind          | raw                         | stabilized   | imports as |
|---------------|-----------------------------|--------------|------------|
| calendar date | `03/15/2019`, `15-Mar-2019` | `2019-03-15` | a date     |
| boolean       | `Y`, `yes`, `1`             | `TRUE`       | logical    |
| currency      | `$1,200.00`                 | `1200.00`    | a number   |
| compact month | `201903`                    | `2019-03`    | a month    |

These are the satisfying cases: the stabilized column reloads as exactly
the type it should be, in every tool, without further instruction.

### Stabilized safely

Some distinctions a plain CSV simply cannot carry — a factor’s levels,
an identifier’s identity. Forcing them would lose information, so
datagoodr **protects** the column instead of converting it. The guiding
rule is: never import in a way that loses data.

- **Factors default to text.** A categorical column is kept as its
  written values rather than silently re-coded to integers, so the
  labels survive. You add the *meaning* (levels, definitions) in the
  DGF; see *Documenting Data*.
- **Identifiers are protected, not parsed.** A ZIP or FIPS or EIN keeps
  its exact written form — `06037` stays `06037`, never `6037`; a long
  ID is not cast to a lossy double.

“Safe” means that even when datagoodr cannot promote a column to a
richer type, the governed CSV never imports it in a way that corrupts or
drops information.

## The guard that makes “safe” real

The danger is a *confident but wrong* conversion. A column of ZIP codes
looks exactly like a number, and a naive reader would type it as one —
turning `06037` into `6037`. datagoodr’s **storage-safety gate** refuses
to let any numeric stabilization re-type a column whose values carry
leading zeros or exceed the range integers can represent exactly. One
rule protects every FIPS, ZIP, EIN, and NAICS column at once, in both
directions: if a column cannot safely become a number, nothing may make
it one.

## See the effect before you commit

A stabilization rule is only as good as its fit to the data. When the
DGF proposes a `stabilizer`, it previews the result on the first few
values in `stable_first5`, so a mis-detected date order (parsing
`03/04/2019` as April 3 instead of March 4) is visible on sight rather
than discovered downstream. A reformat the system cannot perform — say
converting a fiscal year to a calendar year with no conversion defined —
is reported as *not transformable* rather than guessed. (The rule
machinery is the `read :: [convert] :: write` plan from the companion
package formex; see *Guessing Data Types* for how the pieces are
chosen.)

## Next

- **Data Profiling** — what gets measured once a column is typed.
- **Documenting Data with the DGF** — supplying the meaning that
  protected columns (factors, identifiers) still need.
