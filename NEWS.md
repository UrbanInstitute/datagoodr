# datagoodr (development version)

## New

### Versioned data projects with a provenance manifest

A dataset can now live in a **project directory** that keeps its whole history
in one place and never loses the original. `create_project(raw)` scaffolds a
folder with `data/raw/` holding the input file --- written once and never
touched again --- and a seeded `data/manifest.json`. `create_project_dgf()`
then builds the DGF at the project root and stabilizes it into the first
governed data version, `data/v01.csv`.

Every time the data is stabilized or cleaned, `create_version()` writes the next
numbered governed CSV (`v02`, `v03`, …), each built from the version below it, so
the raw floor is never overwritten. A new version is written automatically
whenever stabilizing changes the data **or** the DGF carries a new conversion.

The **manifest** logs, per version and per variable, what changed: the
`stabilizer`, target type and target format, the first five values at read vs
after the transform, and the start/end content hash of each variable. The first
version records every variable; later versions record only the ones that
changed. Because each version is built on the one below it, a variable whose
read-hash no longer matches the end-hash recorded for the version below it is
flagged as **changed outside the workflow** (`external_change_detected`).

`read_data(project)` opens a project's data and defaults to the latest version;
`update_dgf()` accepts a project directory and refreshes against the latest
version; `create_rg()`/`create_dd()` take a `project` argument that points them
at the project's DGF. Reuses the existing governed-CSV provenance
(`write_stable_csv()`/`read_stable_csv()`) and per-variable hashing, so versions
also carry their lineage inside the file. See `?create_project`.

## Fixes

### A uniform factor no longer grows a huge "other" treemap box

A categorical variable whose levels each held exactly 2% of the rows --- an
all-distinct key such as the 50 US states --- drew every level as its own tile
*and* a second `"other"` box as large as the whole dataset. The treemap kept
levels at `>= 2%` but lumped them at `<= 2%`, so a level sitting on the 2.0%
line counted both ways and was double-counted into `"other"`. The two tests now
agree (`< 2` to lump), and `get_graphics_fact()` no longer seeds the bucket by
appending an empty `"other"` row when a factor has no sub-2% tail.

## New

### The contents list glimpses the data

Every row of a research guide's contents list now carries example values under
the variable's label, so the opening page says what the data looks like and not
just what the columns are called. The values come from `stable_first5` --- the
first values as the stabilizer will write them --- and fall back to the
`rg_preview` sample for a variable the stabilizer leaves alone, which is most
of them.

Whole values only: the glimpse packs values until the next one would break its
character budget rather than trimming one to fill it, because one complete
value tells a reader more than five cut off mid-word. A single value longer
than the whole budget is the one exception, trimmed with an ellipsis rather
than left out. `rail_contents(glimpse = )` sets the budget, or `0` leaves the
data out.

### A boolean reads as one divided bar

`boolebar()` draws a boolean variable as a single full-width bar split into its
TRUE / FALSE / NA parts --- counts and shares printed on the bar in the report's
accent orange, categories named above in a light grey, and a tenths scale
beneath. The scale is the point: without one a divided bar says only "these are
the parts", and with one it says where each part sits in the whole.

**It is now every style's boolean graphic**, not just the compact one. A part
too narrow to hold its own count carries it above the bar instead, with a
leader back to the part, so a 0.1% missing category still says what it is.
Both boolean graphics also name their categories by the curated labels in
`dd_f_levels` where a DGF has them, so a bar reads `0 (V-shaped)` rather
than `0`.

`booleplot()`, the stack of one bar per category, is still exported and still
works --- a project that prefers it can put it back from `DG.R`:

```r
# in DG.R
layout.logical <- sub( "paste_boolebar", "paste_booleplot",
                       datagoodr:::default_layouts()$logical )
```

### A compact research guide, for documentation

`create_rg(dgf, style = "compact")` scaffolds the same guide as the default
`"rail"` style, condensed so a reader can scan several variables per screen
instead of one. Nothing is left out --- the same blocks appear in the same
order, for the same types:

* **PROPERTIES is transposed** into a one-row strip at the top of each
  variable's body (`paste_properties_horizontal()`), instead of a five-to-six
  row table in the rail. In the rail that table is what set a unit's height, so
  condensing anything else first would have shortened nothing.
* **The long tables and the preview are kept short.** A block function that
  declares `size`, `max.lines` or `max.rows` is handed the active style's
  values at render time, so one layout row lists 8 factor levels over 2 preview
  lines in a compact guide and 50 over 4 in the default one. Length is a
  property of the style, not of the layout.
* **The numeric DISTRIBUTION SHAPE block is dropped** --- skew and kurtosis are
  already drawn above the histogram.
* **Smaller graphics and roughly half the whitespace**, via `RG-compact.qmd`
  and `datagoodr-compact.css`.

On the package's demo dataset that is a 35% shorter page, and a median variable
of 380px against 610px. The compact guide is the rail renderer at a higher
density, so everything that customizes a rail guide --- `DG.R` overrides, a
`layout.*` shadow, a local stylesheet --- works on it unchanged. `get_design(compact
= TRUE)` returns its design, and `rail_sections(style = "compact")` draws it,
which also lets one document mix densities group by group.

`vignette("report-styles")` compares the three styles and shows how to switch,
and the documentation site carries the baseball guide in both the default and
the compact style for comparison.

### A truncated FACTOR LEVELS table now says what it left out

The table has always listed at most 50 levels and simply stopped. It now closes
with the tally it was hiding (`+ 10 more levels`), counted against the
variable's DISTINCT property rather than against the levels in hand --- the DGF
itself stores only the 50 most frequent, so counting those would under-report.
This is the one output change to an existing guide.

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

### `create_dgf()` is reproducible, and guesses from a larger sample

`formex::guess_data_type()` draws its sample from the session RNG, so the same
data produced different types on different runs — across three builds of the
baseball dataset `nameLast` moved text -> categorical and `AB` categorical ->
text. `create_dgf()` now seeds it (`guess_seed`, default `1`), so repeated
builds of the same data produce an identical DGF.

Seeding makes the draw repeatable, not correct. formex samples from a column's
**distinct** values and its confidence is stable only when the sample covers
them all, so `create_dgf()` also raises `guess_n_sample` to **300** (formex's
own default is 100). On the baseball dataset that fixes `birthState`, which now
resolves to `mutually_exclusive.geographic` instead of falling back to `text`,
and clears a spurious `text:web:domain` class on `AVG`.

* Both are arguments and options: `guess_seed = NULL` restores the old
  session-RNG behaviour, and `guess_n_sample = NULL` hands the sample size back
  to formex. `options(datagoodr.guess_seed = )` /
  `options(datagoodr.guess_n_sample = )` set them project-wide.
* **Guessed types can differ from a DGF built before this change** — that is the
  point, but re-check any curated DGF you regenerate.
* The larger sample costs roughly what the formex speedup above saves, so a
  build is about level on time while being reproducible and better typed.

`create_dgf(workers = )` additionally spreads the per-column guess over a
process pool. It defaults to `1`; with the formex fix in place it is only worth
raising on wide frames.

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

* **A zero-padded code is no longer typed `number`.** A group exemption number (`0155`), a
  `00`/`11` code and a zero-padded key (`000123`) were typed `number` and lost their leading
  zeros. `create_dgf()` accepts a formex stabilizer's conversion to numbers whenever every value
  converts without an `NA`, and `as.numeric("0155")` does. It now refuses the conversion when every
  value is a plain number that `.safe_numeric()` rejects (a leading-zero integer, or one past
  2^53), the same rule `read_as_text` uses. A column that needs real cleaning to become a number
  (`"$1,234"`) is unaffected. A two-state code that is not a flag now falls back to `categorical`
  instead of `text`, so such a code is typed the same whether it is read from a data frame
  or a `.csv` path.

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

* **`booleplot()` no longer fails on a short figure.** It snapshotted the whole
  graphics parameter list and put it back on exit; restoring the device-derived
  `"pin"` it had captured errored with `invalid value specified for graphical
  parameter` whenever the chunk's `fig.height` was small — which every compact
  guide's boolean section is. It now saves and restores only the margin it sets.

## Internal

* `.safe_numeric()` — the rule deciding which character columns
  `create_dgf(read_as_text = TRUE)` may promote to numeric, and therefore what
  keeps `06037` from becoming `6037` — moved from the (now formex-owned)
  detector helpers into datagoodr's own utilities, where it belongs.

* `R/01-06-guess-dgf-types.R` is now the documented **formex seam**. It reads
  only formex's public return value and touches no internals.

* **DGF builds are roughly a third faster, via formex.** Profiling
  `create_dgf()` showed type guessing was 63% of a build and the `rg_*` data
  profiles under 7% — so the work went into `formex::guess_data_type()`, which
  cost ~130ms per column even for a ten-value input. Most of that floor was
  input-independent work recomputed on every call (the verifier's foil-leak
  loop, the ontology's own example signatures) plus a 730-format `strptime`
  sweep that non-date columns paid in full. Fixed upstream in
  `lecy/formex@3d812d2`; with it installed, `create_dgf()` on the 4,620 x 19
  baseball dataset goes 9.92s -> 6.86s and the guess itself 6.20s -> 3.59s.
  **The written DGF is byte-identical** — this is purely caching and
  short-circuiting, with no change to any detection verdict. One visible side
  effect: formex's `as_integer` "NAs introduced by coercion" warning now fires
  about once per session instead of once per candidate per column (datagoodr
  already muffled it). Requires the updated formex; older versions still work,
  just slower. Full measurements and method in `dev/performance-notes.md`.
