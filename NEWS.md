# datagoodr (development version)

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

## Internal

* `.safe_numeric()` — the rule deciding which character columns
  `create_dgf(read_as_text = TRUE)` may promote to numeric, and therefore what
  keeps `06037` from becoming `6037` — moved from the (now formex-owned)
  detector helpers into datagoodr's own utilities, where it belongs.

* `R/01-06-guess-dgf-types.R` is now the documented **formex seam**. It reads
  only formex's public return value and touches no internals.
