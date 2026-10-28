# datagoodr (development version)

## New

### The DGF carries a two-axis guess and a suggested stabilizer (formex v7)

formex v7 models a value's format as `(semantic_type, format_style, unit_type)`
and exposes stabilization as a transform-path search. datagoodr now records and
acts on that:

* **`guess_*` columns** capture formex's route leaf as two axes —
  `guess_format_style` (the written rendering) and `guess_unit_type` (the
  dimensional/categorical unit) — alongside a human `guess_label`
  (`calendar {{ date :: temporal }}`), `guess_match_kind` (the honesty column),
  and `guess_variant_id`/`guess_depth`/`guess_confidence`.
* **`desired_*` gains the matching target form** (`desired_semantic_type`,
  `desired_format_style`, `desired_unit_type`), and `create_dgf()` fills a
  suggested **`stabilizer`** — a `read :: [convert] :: write` plan from
  `formex::fx_plan_transform()` — previewing its effect in **`stable_first5`**.
  A reformat the registry cannot reach is reported `not-transformable`, never
  guessed.
* **`stabilize_data(use_v7 = TRUE)`** executes those plans with
  `formex::fx_apply_plan()` — vectorised and type-preserving. It is opt-in: the
  default is unchanged, and a legacy `raw_to_stable_transform` /
  `desired_data_import_rule`, where set, always takes precedence.

The flip is additive: `desired_data_type`/`desired_data_class` remain the render
engine's dispatch contract.

### `create_dgf()` reads both of formex's predictions

formex returns two answers per column — the v6 `$route` (a four-level ontology
path that truncates gracefully) and the legacy `$guess` (a detector at a pass
rate). They are **complementary**, so datagoodr now reads both:

* The **route wins** when it resolves to a confident leaf. It reaches types no
  detector emits — a bare four-digit year is `temporal/period/year` to the
  router and nothing at all to the detectors, so year columns are now typed
  `temporal` instead of falling through to `text`.
* The **legacy guess wins** where the route truncates, which is every
  zero-padded numeric key (FIPS, ZIP, EIN) and email address.

`desired_data_class` now carries v6 coordinates directly. No translation was
needed: the v4 dotted vocabulary turned out to be a *subset* of v6's
`semantic_family.semantic_type`, so the column already spoke v6.

Two guards keep a wrong prediction from corrupting a column:

* **The storage-safety gate.** A `number/*` route may not re-type a column that
  `.safe_numeric()` refuses to promote. The same rule that stops
  `read_as_text = TRUE` turning `06037` into `6037` now stops the router doing
  it. One predicate, both directions.
* **Confidence is not sufficient.** A column of `rnorm()` doubles routes to
  `text/web/domain` at depth 4 with confidence 1.0, because `-0.6264538` parses
  as a domain name. So the route may refine a coarse `text` base type or supply
  a strong semantic signal, but it may not overturn a type read from storage.

When neither modality is confident the column keeps its base type, and the
route's `depth` is recorded rather than discarded — a truncated path is a valid
partial answer for a reviewer to deepen, not a failure.

### Pre-flight check for degenerate columns

`create_dgf()` profiles every column, which takes minutes on a large file, and a
column the profilers could not handle used to surface as a crash partway through,
with an error that named no column. A new pre-flight step finds those columns
first, and reports all of them at once.

* **`preflight_dgf(df)`** scans each column and returns one row per finding
  (`var_name`, `rule`, `severity`, `detail`, `suggestion`). Rules: `constant`,
  `single_value_with_blanks` (an `X`/blank checkbox), `all_missing`,
  `duplicate_column`, `mixed_boolean_encoding` (`0`/`1`/`true`/`false`),
  `non_finite`, `placeholder_value`, `long_values`, `leading_zero_code` and
  `high_cardinality_temporal`. On a 568,000-row, 199-column file it takes about
  40 seconds; the build took about 22 minutes there (with the formex release before
  its 2026-10-28 speed-up). `smoke_n = 5000` also
  builds a DGF from a random sample and reports a failure by variable.
* **`create_dgf(preflight = )`** runs it automatically: `"warn"` (the default)
  prints a one-line summary and continues, `"error"` stops before any profiling
  if a column is flagged, `"off"` skips it. The findings are kept on the result as
  `attr(dgf, "preflight")`.
* **Errors now name the variable.** A failure while profiling is reported as
  `create_dgf(): statistics (factor) failed for variable 'x': ...`.

## Breaking changes

### Type detection moved to the formex package

datagoodr no longer contains the data-type detection library. It now lives in
**[formex](https://lecy.github.io/formex/)**, which datagoodr imports.

The two packages split along a clean line: **formex is the engine** (one column
at a time, stateless — the type ontology, the detectors, `guess_data_type()`,
`fx_stabilize()`), and **datagoodr is the workflow** (a whole data frame,
human-in-the-loop — profiling, the Data Governance File, review and override,
applying stabilization, writing outputs).

**104 functions were removed from datagoodr's namespace**, including all 80
`is_*` detectors, `guess_data_type()`, `score_data_type()`, and the AutoType
test-case helpers. Code that called them needs one of:

```r
library(formex)          # attach it, and existing calls keep working
formex::is_ein(x)        # or qualify each call
```

`is_factor()` and `is_factor_df()` are **not** affected — those are datagoodr's
own cardinality helpers, not detectors, and remain exported.

Also moved to formex: the `data_type_tests` dataset, the `data-types/` ontology
tree, the internal geography/code lookups in `sysdata.rda`, and the four
detection vignettes (*Data-Type Detectors*, *The Data-Type Ontology*, *Guessing
a Data Type*, *Formex*). Their current versions are on formex's documentation
site.

Install formex with:

```r
remotes::install_github("lecy/formex")
```

### Rule functions renamed: `as_*` -> `read_*`

A rule that *ingests* a written format now says so in its name. `as_mmddyyyy()`
never produced `mm/dd/yyyy` — it consumed it and returned a `Date`. The name
said the opposite of the function.

The convention is now:

* **`read_<format>()`** ingests a value written in that format. The name states
  the **input**. These belong in `raw_to_stable_transform`.
* **`as_<type>()`** coerces a value into a target type. The name states the
  **output**. These belong in `desired_data_import_rule`.

This makes the DGF's two bridge columns distinguishable on sight — a rule
sitting in the wrong column is now visible without running it.

| old | new |
|---|---|
| `as_date(x, format)` | `read_date(x, format)` |
| `as_datetime(x, format)` | `read_datetime(x, format)` |
| `as_yyyymmdd()` | `read_yyyymmdd()` |
| `as_mmddyyyy()` | `read_mmddyyyy()` |
| `as_ddmmyyyy()` | `read_ddmmyyyy()` |
| `as_mdyyyy()` | `read_mdyyyy()` |
| `as_dMyyyy()` | `read_dMyyyy()` |
| `as_Mdyyyy()` | `read_Mdyyyy()` |
| `as_yyyymmddHHiiss()` | `read_yyyymmddHHiiss()` |
| `as_mmddyyyyhhiiA()` | `read_mmddyyyyhhiiA()` |
| `as_yyyymm()` | `read_yyyymm()` |
| `as_yyyy()` | `read_yyyy()` |
| `as_mm()` | `read_mm()` |
| `as_EIN()` | `read_ein()` |
| `as_id()` | `as_id()` (unchanged — it names a type) |

The old names still work as deprecated shims that warn once per session, so a
DGF whose rule cells carry them keeps running. **They will be removed in the
next minor version.** Update rule cells in your DGF `.xlsx`/`.csv` files.

### `read_ein()` returns the canonical hyphenated form

`as_EIN("12345678")` returned `"012345678"`; `read_ein("12345678")` returns
`"01-2345678"`. This matches the stable form the type ontology declares for
`identifier / id / administrative (ein)`, so a datagoodr-stabilized EIN and a
formex-stabilized EIN are now the same string.

## Bug fixes

* **A compact date label now reads the run-together form.**
  `as_yyyymmdd("20190315")` returned `NA` — the exact case the compact label
  exists for. A label names the element *order*, not the punctuation, so
  `read_date()` now compiles both a delimited and a run-together pattern and
  picks per value. `read_yyyymmdd("20190315")` and `read_yyyymmdd("2019-03-15")`
  both parse.

* **`read_yyyy()` accepts a fiscal-year prefix.** `read_yyyy("FY2019")` returns
  `"2019"`.

* **`read_yyyymm()` validates its input** rather than silently slicing any
  string, and accepts an already-hyphenated value.

* **A column with one distinct value no longer aborts `create_dgf()`.** A constant
  column, or one value plus blanks (an `X`/blank checkbox, which datagoodr reads as
  one level), failed with `'names' attribute [2] must be the same length as the
  vector [1]` (or `replacement has 0 rows, data has 1`). Subsetting a one-element
  table dropped it to a bare vector, so the frequency table lost its `Freq` column.
  The factor statistics, the treemap data and the word-cloud words now keep the
  table intact; output for every other column is unchanged.

* **Free text of 1,000 bytes or more no longer aborts type detection.** base R's
  `strptime()` refuses such input, and both datagoodr's temporal detector and the
  call into formex's date detector passed raw cell values to it. Whether a build
  crashed depended on whether a long value fell in the first 50 rows (or in
  formex's random sample of 100), so it could pass or fail on the same file.

* **An all-missing column no longer aborts the build.** Its character statistics
  failed with `invalid number of 'breaks'`, and its preview was `"NA"`. It now
  profiles as empty and renders.

* **`retype_dgf()` reads a `.csv` as text.** It used `readr`'s type inference, which
  turned `"00"` into 0 and `"06037"` into 6037 before profiling the type you had
  just chosen to protect them.

* **`retype_dgf()` refreshes `dd_f_levels`.** After retyping a variable to
  categorical or boolean the level dictionary kept the old spellings
  (`0`/`1`/`false`/`true`) or stayed empty, so the guide printed stale or missing
  category labels. Labels already edited for a level that still exists are kept;
  a type with no levels is left untouched.

* **A timestamp column no longer stores one graphic row per distinct value.** On a
  568,000-row file two timestamp variables each stored a 39.7-million-character
  cell, past Excel's cell limit. Above `getOption("datagoodr.temporal.max_values",
  10000)` distinct values, ISO timestamps are stored at the finest of minute, hour
  or day that fits. A column under the cap is stored exactly as before.

* **`create_rg()` bakes a DGF path the render can resolve.** A DGF outside the
  report's folder is now written relative to it (`../dgf/DGF.xlsx`); Quarto resolves
  the path from the `.qmd`, so the old as-given path failed with `path does not
  exist`.

## Internal

* `.safe_numeric()` — the rule deciding which character columns
  `create_dgf(read_as_text = TRUE)` may promote to numeric, and therefore what
  keeps `06037` from becoming `6037` — moved from the (now formex-owned)
  detector helpers into datagoodr's own utilities, where it belongs.

* `R/01-06-guess-dgf-types.R` is now the documented **formex seam**. It reads
  only formex's public return value and touches no internals.
