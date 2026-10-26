# Dev note to datagoodr — the v7 formex API

From: formex · 2026-10-26
Re: reply to `formex-devnote-schema-simplification.md`; the surface datagoodr's
flat, format-first DGF can build on.

We read your note and it converged with our own review — several of your asks
were already on our gap list. Here is what has landed and what is in flight,
keyed to your seven asks.

## Landed now

### Recipe bug fixes (your §2)
- `as_yyyy()` / the `as_yyyy` verb strip a fiscal-year prefix: `"FY2019"` →
  `"2019"` (was returning the raw string / `NA`).
- `as_EIN()` / the `as_ein` verb emit canonical `"NN-NNNNNNN"` and restore a
  leading zero lost to numeric coercion: `"12345678"` → `"01-2345678"`.
- Your working `read_yyyymm` / `read_ein` / `read_yyyy` are still welcome as the
  `read_*` half — see composition below.

### Stale duplicate removed (your §7)
`data-types/research_data_type_ontology_v6.csv` is gone; `fx_ontology()` reads
`inst/extdata/` (the 96-row, `match_kind`-bearing authority). Resolve any path
you had pointing at the old copy.

### Two-axis leaf + unit rename (your §3, §4)
The ontology now carries, next to `format_label`:

- **`format_style`** — the *written* rendering (field order + separators,
  suffix-scaling, abbreviated-vs-full). This is what `read_*`/`write_*` key on.
- **`unit_type`** — RENAMED from `dd_data_unit`, moved beside `format_style`.
  The dimensional/categorical unit that carries meaning (`USD`, `C`/`F`,
  fiscal/calendar). Settled design point: date field-order lives in
  `format_style`, not here — `unit_type` is reserved for true units, so
  "resolve the unit" means one thing in every family.
- **`desired_default_format`** — the `write_*` target to pre-fill when the human
  states no preference (`yyyymmdd` for calendar, `numeric` for a USD amount).

This is **additive and non-breaking**: `format_label` is kept (derived) for one
release, so anything you read today keeps working while you migrate to the two
axes. `$route` still exposes the unit as `dd_unit`, now sourced from `unit_type`.

## The transform model (your §2: `read_` / `write_`)

Stabilization is three composable operations, not one:

```
read_<style>        written form      -> canonical value
write_<style>       canonical value   -> written form        (NEW half)
convert_<u1>_<u2>   canonical (unit1) -> canonical (unit2)    (unit change)
```

`write_*` normalizes first, then renders — internally `write_X(v) =
render_X(as_*(v))` — so `read_src :: write_dst` is safe on half-cleaned input,
which answers your "output format should be user-controllable" directly.

### Transformability is a search (shipped, experimental)

Whether a given input format can reach a desired one is answered, not assumed:

```r
library(formex)
fx_plan_transform(
  fx_format("temperature", "celsius", "C"),
  fx_format("temperature", "fahrenheit", "F"))
#> <fx_plan: read_celsius :: convert_C_F :: write_fahrenheit>

fx_plan_transform(
  fx_format("year", "FYyyyy", "fiscal"),
  fx_format("year", "bare", "calendar"))
#> <fx_plan: NOT transformable -- no path ...>   # convert_fiscal_calendar not defined
```

API: `fx_format(semantic_type, format_style, unit_type)` builds a format
descriptor; `fx_plan_transform(from, to)` returns an `fx_plan`
(`$transformable`, `$path`, `$reason`); `fx_transformable()` is the boolean;
`fx_apply_plan(x, plan)` runs it. This is the library search you sketched:
input `(unit_type, format_style)` → desired `(unit_type, format_style)`, with a
`convert_*` required for any unit change. A missing converter is reported as
unreachable rather than guessed.

## In flight (next)

- `fx_stabilize(x, semantic_type, format_label, target_format=)` — render the
  stabilized column to a chosen `format_style` via the planner, falling back to
  the canonical form (and reporting `target_reachable = FALSE`) when no
  `write_*`/`convert_*` path exists yet. **This is step 3, landing now.**
- Growing the `read_*`/`write_*` registry from each ontology row's
  `format_style` + `desired_default_format`, and `convert_*` per `unit_type`
  pair (temperature first, then fiscal/calendar year once you give us the
  fiscal-year-end convention).
- Executability (your §1): we are prioritizing the high-frequency recipes
  (`usd`, `year`, `quarter`, `yyyymm`, `ein`, `us_state`, `zip`).

## Still on us, not yet done (your §5, §6)

- The two `format_label` collisions (`mixed`; `geographic`) — we will add a
  `disambiguator` note or rename; for now resolve on your side by cardinality as
  you described.
- Format-DSL prefix discipline (`fx:` / `strp:` / `re:`, `::` reserved for
  compose). We will emit `fx:` for lexicon tokens when we start writing into
  your `data_format` field.
- `fx_dgf_fields()` depth-scale reconciliation.

Full engine-side detail: `formex/ONTOLOGY-V7-PLAN.md`.
