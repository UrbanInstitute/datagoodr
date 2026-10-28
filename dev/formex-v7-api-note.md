# Dev note to datagoodr — the v7 formex API

From: formex · 2026-10-26
Re: reply to `formex-devnote-schema-simplification.md`; the surface datagoodr's
flat, format-first DGF can build on.

> **Update 2026-10-26 — v7 is complete and on `main`.** The migration and the
> whole API surface below are shipped and green (100 tests): the two-axis leaf
> (`format_style` + `unit_type`) with `desired_default_format`, the transform
> planner, `fx_stabilize(..., target_format=)`, `format_style` on `$route`, and a
> registry generated from the ontology recipes. The recipe bugs and the stale
> CSV are gone. Five test-backed detectors were wired — `day_of_week`,
> `month_of_year` (new selective `as_dow`/`as_moy` recipes), and `first_name`,
> `quarter`, `domain` (flag reconciled) — taking implemented coverage to 41/96.
> `implemented` is pure metadata (not used in detection), so your §1 gating on
> it is safe. **Deferred, each its own effort:** the router retrain (not needed
> yet — `format_label` is retained), broad `write_*` renderers (today's set is a
> seed, so `target_format` resolves for temporal/temperature and the generated
> read side; elsewhere it returns canonical with `target_reachable = FALSE`),
> and true multi-style detection. Pull `main`; `ONTOLOGY-V7-PLAN.md` has the
> status section.
>
> **Update 2 — currency-amount landed.** `is_currency_amount()` (a symbol-marked
> amount: `$`, `€`, `£`, `¥`, prefix or suffix, with sign/grouping/decimals)
> makes the `as_usd` recipe selective, so a `$`-column now resolves to `usd` at
> depth 4 (42/96 implemented). `usd` answers your §1 priority. `euro`'s verb is
> ready but unflagged until the library has euro columns. Note the design line:
> a **bare** amount (`1,234`, `-45.10`) is the symbol-less `balance` type and is
> not value-detectable — it stays metadata-gated, as your flat schema expects.
> Still open: `convert_fiscal_calendar` (needs your fiscal-year-end convention).
>
> **Update 3 — detector coverage now 46/96.** Further test-backed detectors are
> wired: `day_of_week`, `month_of_year`, `first_name`, `quarter`, `domain`,
> `usd`, `place`, `min_max` range, and geometry `point`/`polygon`. Two engine
> bugs fixed in passing (the transform-DSL `verb[arg]` parser dropped a trailing
> `]`; `as_range` no longer claims nested arrays as ranges). One finding that
> affects your §1 gating: a selective recipe is **necessary but not sufficient**
> to route — the learned router never shortlists very rare `mask` leaves
> (`array`, `version`, `reporting_period` confirm in isolation but never reach
> the verifier), so they stay `implemented = no` on purpose. Known tie-break
> still open: a city column routes to the `geographic` leaf rather than `place`
> (your §5 collision); the `disambiguator` work is next.
>
> **Update 4 — §5 collisions resolved.** The ontology now has a `disambiguator`
> column (and `fx_validate_ontology()` fails on an undeclared collision). Both of
> your §5 cases are handled, wired live into the verifier via the column's
> uniqueness ratio: (1) `geographic` as a categorical grouping vs. an identifier
> key — repeating → `categorical/geographic`, unique-per-row → `identifier/id/
> geographic`; and (2) the cross-type place↔geographic case — a city column of
> repeating values → the geographic grouping, mostly-unique → `text/name/place`.
> The `mixed` collision is gone (the `unknown` leaf was renamed `heterogeneous`;
> the boolean `mixed` keeps its name). So you can default to `format_label` for
> the user-facing label without a leaf-only tie-break of your own, except where
> you still prefer your cardinality call. `convert_fiscal_calendar` remains the
> one open item (needs your fiscal-year-end convention).

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

> **Update 5 — 2026-10-27 — your v7-dgf-integration-plan gating items have shipped, and the starwars report is addressed.**
>
> Re `dev/v7-dgf-integration-plan.md` "Not landed yet (our testing gate)":
> all three are now on formex `main`, so you can unfreeze that integration:
> 1. The `format_style` + `unit_type` split is built (ONTOLOGY-V7-PLAN §5 steps 1–4).
> 2. `guess_data_type()$route` now carries `format_style` (resolved from the variant).
> 3. `fx_transforms()` is generated from the ontology recipes (a `read_<style>`
>    edge per row), not just the seed — plus `write_numeric` for number types.
>
> Your `dplyr::starwars` detection-quality report, item by item:
> - `name` → now `text/person` (was `organization`).
> - `hair_color` / `eye_color` → now `text/color/color_name` (new `is_color_name()`
>   + a curated color-word lexicon; the words "brown"/"auburn"/"orange" are also
>   US places, which was the leak). No longer `geographic`.
> - `mass` (`measurement` → `numeric`) → now reachable: a plain number has a
>   `write_numeric` edge, so `fx_plan_transform(fx_format("measurement"),
>   fx_format("measurement","numeric"))` returns a plan instead of "no path".
> - list columns `a|b|c` → still unrecognized; a flat-delimited set is best modeled
>   as `categorical/multiselect/tags` (not `structured`, which is for bracketed
>   JSON/arrays). A delimiter-split `tags` detector is the recommended next step —
>   not built yet.
>
> Also new and relevant to your audit / raw-stats TO-DO: `fx_stabilize()` now
> returns a **`conversion_log`** (n present / stabilized / dropped / rate / reason
> / examples) and **warns** when present values become NA, so a column losing
> values is surfaced, not silent. Wire this into the governance file so a reviewer
> sees drops before the cleaned CSV is written.
>
> Still open on our side: `convert_fiscal_calendar` (needs your fiscal-year-end
> convention) and the `tags` detector above. Coverage is now 47/97 variants
> implemented; 91 detectors.
