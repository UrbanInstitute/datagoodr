# Changelog

## datagoodr (development version)

### New

#### The DGF carries a two-axis guess and a suggested stabilizer (formex v7)

formex v7 models a value’s format as
`(semantic_type, format_style, unit_type)` and exposes stabilization as
a transform-path search. datagoodr now records and acts on that:

- **`guess_*` columns** capture formex’s route leaf as two axes —
  `guess_format_style` (the written rendering) and `guess_unit_type`
  (the dimensional/categorical unit) — alongside a human `guess_label`
  (`calendar {{ date :: temporal }}`), `guess_match_kind` (the honesty
  column), and `guess_variant_id`/`guess_depth`/`guess_confidence`.
- **`desired_*` gains the matching target form**
  (`desired_semantic_type`, `desired_format_style`,
  `desired_unit_type`), and [`create_dgf()`](../reference/create_dgf.md)
  fills a suggested **`stabilizer`** — a `read :: [convert] :: write`
  plan from
  [`formex::fx_plan_transform()`](https://rdrr.io/pkg/formex/man/fx_plan_transform.html)
  — previewing its effect in **`stable_first5`**. A reformat the
  registry cannot reach is reported `not-transformable`, never guessed.
- **`stabilize_data(use_v7 = TRUE)`** executes those plans with
  [`formex::fx_apply_plan()`](https://rdrr.io/pkg/formex/man/fx_apply_plan.html)
  — vectorised and type-preserving. It is opt-in: the default is
  unchanged, and a legacy `raw_to_stable_transform` /
  `desired_data_import_rule`, where set, always takes precedence.

The flip is additive: `desired_data_type`/`desired_data_class` remain
the render engine’s dispatch contract.

#### `create_dgf()` reads both of formex’s predictions

formex returns two answers per column — the v6 `$route` (a four-level
ontology path that truncates gracefully) and the legacy `$guess` (a
detector at a pass rate). They are **complementary**, so datagoodr now
reads both:

- The **route wins** when it resolves to a confident leaf. It reaches
  types no detector emits — a bare four-digit year is
  `temporal/period/year` to the router and nothing at all to the
  detectors, so year columns are now typed `temporal` instead of falling
  through to `text`.
- The **legacy guess wins** where the route truncates, which is every
  zero-padded numeric key (FIPS, ZIP, EIN) and email address.

`desired_data_class` now carries v6 coordinates directly. No translation
was needed: the v4 dotted vocabulary turned out to be a *subset* of v6’s
`semantic_family.semantic_type`, so the column already spoke v6.

Two guards keep a wrong prediction from corrupting a column:

- **The storage-safety gate.** A `number/*` route may not re-type a
  column that `.safe_numeric()` refuses to promote. The same rule that
  stops `read_as_text = TRUE` turning `06037` into `6037` now stops the
  router doing it. One predicate, both directions.
- **Confidence is not sufficient.** A column of
  [`rnorm()`](https://rdrr.io/r/stats/Normal.html) doubles routes to
  `text/web/domain` at depth 4 with confidence 1.0, because `-0.6264538`
  parses as a domain name. So the route may refine a coarse `text` base
  type or supply a strong semantic signal, but it may not overturn a
  type read from storage.

When neither modality is confident the column keeps its base type, and
the route’s `depth` is recorded rather than discarded — a truncated path
is a valid partial answer for a reviewer to deepen, not a failure.

### Breaking changes

#### Type detection moved to the formex package

datagoodr no longer contains the data-type detection library. It now
lives in **[formex](https://lecy.github.io/formex/)**, which datagoodr
imports.

The two packages split along a clean line: **formex is the engine** (one
column at a time, stateless — the type ontology, the detectors,
[`guess_data_type()`](https://rdrr.io/pkg/formex/man/guess_data_type.html),
[`fx_stabilize()`](https://rdrr.io/pkg/formex/man/fx_stabilize.html)),
and **datagoodr is the workflow** (a whole data frame, human-in-the-loop
— profiling, the Data Governance File, review and override, applying
stabilization, writing outputs).

**104 functions were removed from datagoodr’s namespace**, including all
80 `is_*` detectors,
[`guess_data_type()`](https://rdrr.io/pkg/formex/man/guess_data_type.html),
[`score_data_type()`](https://rdrr.io/pkg/formex/man/score_data_type.html),
and the AutoType test-case helpers. Code that called them needs one of:

``` r
library(formex)          # attach it, and existing calls keep working
formex::is_ein(x)        # or qualify each call
```

[`is_factor()`](../reference/is_factor.md) and
[`is_factor_df()`](../reference/is_factor_df.md) are **not** affected —
those are datagoodr’s own cardinality helpers, not detectors, and remain
exported.

Also moved to formex: the `data_type_tests` dataset, the `data-types/`
ontology tree, the internal geography/code lookups in `sysdata.rda`, and
the four detection vignettes (*Data-Type Detectors*, *The Data-Type
Ontology*, *Guessing a Data Type*, *Formex*). Their current versions are
on formex’s documentation site.

Install formex with:

``` r
remotes::install_github("lecy/formex")
```

#### Rule functions renamed: `as_*` -\> `read_*`

A rule that *ingests* a written format now says so in its name.
[`as_mmddyyyy()`](../reference/datagoodr-deprecated.md) never produced
`mm/dd/yyyy` — it consumed it and returned a `Date`. The name said the
opposite of the function.

The convention is now:

- **`read_<format>()`** ingests a value written in that format. The name
  states the **input**. These belong in `raw_to_stable_transform`.
- **`as_<type>()`** coerces a value into a target type. The name states
  the **output**. These belong in `desired_data_import_rule`.

This makes the DGF’s two bridge columns distinguishable on sight — a
rule sitting in the wrong column is now visible without running it.

| old | new |
|----|----|
| `as_date(x, format)` | `read_date(x, format)` |
| `as_datetime(x, format)` | `read_datetime(x, format)` |
| [`as_yyyymmdd()`](../reference/datagoodr-deprecated.md) | [`read_yyyymmdd()`](../reference/read_date.md) |
| [`as_mmddyyyy()`](../reference/datagoodr-deprecated.md) | [`read_mmddyyyy()`](../reference/read_date.md) |
| [`as_ddmmyyyy()`](../reference/datagoodr-deprecated.md) | [`read_ddmmyyyy()`](../reference/read_date.md) |
| [`as_mdyyyy()`](../reference/datagoodr-deprecated.md) | [`read_mdyyyy()`](../reference/read_date.md) |
| [`as_dMyyyy()`](../reference/datagoodr-deprecated.md) | [`read_dMyyyy()`](../reference/read_date.md) |
| [`as_Mdyyyy()`](../reference/datagoodr-deprecated.md) | [`read_Mdyyyy()`](../reference/read_date.md) |
| [`as_yyyymmddHHiiss()`](../reference/datagoodr-deprecated.md) | [`read_yyyymmddHHiiss()`](../reference/read_date.md) |
| [`as_mmddyyyyhhiiA()`](../reference/datagoodr-deprecated.md) | [`read_mmddyyyyhhiiA()`](../reference/read_date.md) |
| [`as_yyyymm()`](../reference/datagoodr-deprecated.md) | [`read_yyyymm()`](../reference/read_yyyymm.md) |
| [`as_yyyy()`](../reference/datagoodr-deprecated.md) | [`read_yyyy()`](../reference/read_yyyy.md) |
| [`as_mm()`](../reference/datagoodr-deprecated.md) | [`read_mm()`](../reference/read_mm.md) |
| [`as_EIN()`](../reference/datagoodr-deprecated.md) | [`read_ein()`](../reference/read_ein.md) |
| [`as_id()`](../reference/as_id.md) | [`as_id()`](../reference/as_id.md) (unchanged — it names a type) |

The old names still work as deprecated shims that warn once per session,
so a DGF whose rule cells carry them keeps running. **They will be
removed in the next minor version.** Update rule cells in your DGF
`.xlsx`/`.csv` files.

#### `read_ein()` returns the canonical hyphenated form

`as_EIN("12345678")` returned `"012345678"`; `read_ein("12345678")`
returns `"01-2345678"`. This matches the stable form the type ontology
declares for `identifier / id / administrative (ein)`, so a
datagoodr-stabilized EIN and a formex-stabilized EIN are now the same
string.

### Bug fixes

- **A compact date label now reads the run-together form.**
  `as_yyyymmdd("20190315")` returned `NA` — the exact case the compact
  label exists for. A label names the element *order*, not the
  punctuation, so [`read_date()`](../reference/read_date.md) now
  compiles both a delimited and a run-together pattern and picks per
  value. `read_yyyymmdd("20190315")` and `read_yyyymmdd("2019-03-15")`
  both parse.

- **[`read_yyyy()`](../reference/read_yyyy.md) accepts a fiscal-year
  prefix.** `read_yyyy("FY2019")` returns `"2019"`.

- **[`read_yyyymm()`](../reference/read_yyyymm.md) validates its input**
  rather than silently slicing any string, and accepts an
  already-hyphenated value.

### Internal

- `.safe_numeric()` — the rule deciding which character columns
  `create_dgf(read_as_text = TRUE)` may promote to numeric, and
  therefore what keeps `06037` from becoming `6037` — moved from the
  (now formex-owned) detector helpers into datagoodr’s own utilities,
  where it belongs.

- `R/01-06-guess-dgf-types.R` is now the documented **formex seam**. It
  reads only formex’s public return value and touches no internals.
