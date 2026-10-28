# Data stabilization workflow (DRAFT)

Written 2026-10-27. Describes how a variable travels from its raw, possibly
noisy form to a standardized, stable form written to a new governed CSV, and
which DGF columns record each step. Builds on the v7 schema
(`dgf_schema_cols_v7()`, R/01-08-stabilizer-plan.R) and formex's
transform-path API. Where today's code differs from this design, the gap is
listed at the end.

## The journey in one picture

```
 raw CSV                                                     stable CSV
 (as received)                                               (governed)
    |                                                            |
    v                                                            v
 [1 READ] --> [2 GUESS] --> [3 TARGET] --> [4 ASSESS] --> [5 PLAN] --> [6 REVIEW] --> [7 APPLY] --> [8 LOAD]
  raw_data_mode  guess_*      desired_*    stabilizer_   stabilizer    (human, in    stabilizer_   load_rule_
  raw_first5                               needed        stable_first5  the DGF)     status        needed
                                                                                                   load_rule
 ---------------- machine proposes ------------------------------------>|<-- human confirms -->|<-- machine applies -->
```

The program tries hard to guess the semantic type and to draw a road map from
raw to stable, but every proposal is a suggestion the user can correct in the
DGF before anything is written.

## Who owns each column

| column | written by | edited by the user? |
|---|---|---|
| `raw_data_mode`, `raw_first5` | `create_dgf()` | no |
| `guess_*` | formex, via `guess_dgf_types()` | no (it is the record of what was guessed) |
| `desired_semantic_type` / `_format_style` / `_unit_type` | defaulted from the guess | **yes**, the main correction point |
| `stabilizer_needed` | machine assessment | yes (override "no" -> "yes" to force a rule) |
| `stabilizer` | proposed by formex, or a user function | **yes** |
| `stabilizer_status` | `create_dgf()`, then `stabilize_data()` | no |
| `stable_first5` | preview of the stabilizer on `raw_first5` | no |
| `load_rule_needed`, `load_rule` | proposed from the desired type | **yes** |

Machine-owned columns are rewritten on every run. User-owned columns are kept
by `update_dgf()` once the user has changed them.

---

## Step by step

### 1. Read: `raw_data_mode`, `raw_first5`

The raw file is read with every column as character (`read_as_text = TRUE`),
so nothing is lost or reinterpreted on the way in. `raw_data_mode` then reports
the R storage mode the column would get from a plain read: `character`,
`numeric`, `integer`, `logical`, `Date`, `POSIXct`. That records how fragile
the raw file is in the hands of an ordinary reader. `raw_first5` shows the
first five values exactly as written in the file.

### 2. Guess: `guess_semantic_type`, `guess_format_style`, `guess_unit_type`

formex routes the column through its ontology and proposes:

- **`guess_semantic_type`**: what the values *are* (`calendar`, `usd`,
  `geographic` id, `count`, `unordered` category, ...). There are 88 semantic
  types under 8 data types (number, text, categorical, boolean, temporal,
  identifier, structured, unknown). The full list is in "Render routing" below.
- **`guess_format_style`**: how they are *written*. This is the information
  needed to read them correctly, for example:
  - a date's element order (`mmddyyyy` vs `ddmmyyyy` vs ISO `yyyymmdd`);
  - how a geography is represented (`county_fips`, `us_state` name vs
    abbreviation, `iso_country`, `dms` vs decimal coordinates);
  - a time zone or clock convention on a timestamp;
  - a currency's punctuation (`$1,234.50`), a percent as `45%` vs `0.45`, a
    range as `10-20` vs `10 to 20`.
- **`guess_unit_type`**: the unit or code system (`USD`, `EPSG:4326`,
  `GEOID;;FIPS;;ZIP`, `datetime;;timezone`, `percentile 0-100`).

Supporting columns record how much to trust the guess: `guess_label` (a
readable summary), `guess_match_kind`, `guess_confidence`, `guess_depth` (how
far down the ontology the route got) and `guess_variant_id`. A shallow or
low-confidence guess is the main signal that the user should review the row.

### 3. Target: `desired_semantic_type`, `desired_format_style`, `desired_unit_type`

The target form the stabilize step converts *to*. These are defaulted from the
guess, with the style set to the ontology's canonical stable form
(`desired_default_format`, e.g. a calendar date -> ISO `yyyy-mm-dd`, a USD
amount -> a plain number). The user changes these when:

- the guess is wrong (a ZIP code guessed as a count);
- the guess is right but a different target is wanted (keep a fiscal year as a
  fiscal year rather than mapping it to a calendar year);
- a unit conversion is wanted (Fahrenheit -> Celsius, cents -> dollars).

`desired_semantic_type` also decides which Research Guide template the variable
uses (see "Render routing").

### 4. Assess: `stabilizer_needed`

Reports whether the **current** form of the values is *fragile*: prone to
corruption when the file is read, opened in a spreadsheet, or auto-recast by a
stats program. Values: `yes` / `no` / `unknown`.

Fragility is about the raw values, not only about whether guess and target
differ. Typical fragile cases:

| fragility | example | what goes wrong |
|---|---|---|
| ambiguous dates | `03/04/2021` | read as March 4 or April 3 depending on locale; Excel silently converts |
| non-ISO dates | `20190315`, `FY2019`, `Mar-19` | read as a number or a string, never as a date |
| leading zeros in numeric codes | FIPS `06037`, ZIP `02139`, EIN `012345678` | numeric read drops the zero -> `6037` |
| long numeric IDs | 16-19 digit account or record IDs | above 2^53 a double cannot hold them exactly -> last digits change; Excel shows `1.23457E+18` |
| text that looks like a date or number | gene `SEPT2`, part `1-2`, `1E5` | spreadsheet converts to a date or scientific notation |
| formatted numbers | `$1,234.50`, `45%`, `(1,200)` | read as text, or as the wrong magnitude |
| character encoding | `CafÃ©` for `Café`, a stray BOM | mojibake from a Latin-1 / UTF-8 mismatch |
| coded missing values | `-99`, `N/A`, `.` | averaged as real values, or force a numeric column to text |
| coded booleans | `Y`/`N`, `1`/`2`, `Yes`/`No` | read as text or as numbers, not logical |

A column already in a robust form (plain integers, ISO dates, clean UTF-8 text)
gets `no`. `unknown` means the guess was too shallow to judge.

### 5. Plan: `stabilizer`, `stable_first5`

**`stabilizer`** names how the raw values become the stable form. It holds one of:

- **a formex plan** from the internal library, written
  `{{ read_<style> :: [convert_<unit>_<unit>] :: write_<style> }}`, found by
  formex's transform-path search from the guess to the target (108 edges today:
  101 `read_*`, 5 `write_*`, 2 `convert_*`);
- **a datagoodr rule** such as `read_mmddyyyy` or `read_ein`
  (R/01-07-read-rules.R, R/02-01-read-formats.R);
- **a user function** defined in the project's `DG.R`, named by its bare function
  name. The user writes a function that takes the raw vector and returns the
  stable vector, and puts its name in the cell.

It is left blank when `stabilizer_needed` is `no`.

**`stable_first5`** runs the stabilizer over the first five raw values, so the
reviewer sees `raw_first5` and `stable_first5` side by side. A wrong rule is
obvious on sight: a mis-ordered date reader produces `1987-17-03` or `NA`.

### 6. Review (human)

The user opens the DGF in Excel and works down the rows that need attention:
low `guess_confidence` or shallow `guess_depth`, `stabilizer_needed = unknown`,
`stabilizer_status` not `ready`, or a `stable_first5` that looks wrong. They
correct `desired_*`, swap in a different `stabilizer`, or write their own in
`DG.R`, then re-run so the previews refresh.

### 7. Apply: `stabilize_data()`, `stabilizer_status`

`stabilize_data()` reads the raw file as text, runs each column's stabilizer
over the full column, and writes the stable CSV (`write_stable_csv()`).
`stabilizer_status` reports what happened for that column in the current data
file:

| status | meaning |
|---|---|
| `not needed` | `stabilizer_needed = no`; values pass through unchanged |
| `ready` | a stabilizer is set and its preview worked; not yet applied |
| `applied` | run on the full column with no losses |
| `applied (k failed)` | run, but k non-missing raw values became `NA`; the values that failed should be listed in a log |
| `not-transformable: <reason>` | no path from guess to target exists in the library; the user must supply a rule |
| `missing function: <name>` | the cell names a function that is not defined (e.g. a `DG.R` that was not sourced) |
| `needs review` | `stabilizer_needed = unknown` and no rule is set |

Values that fail to convert are never dropped silently. They show up in the
status and in a conversion log (formex's `fx_stabilize()` already returns one).

### 8. Load: `load_rule_needed`, `load_rule`

The stable CSV is meant to be robust, but CSV still has no types.
`load_rule_needed` reports whether the stable values will load correctly
**by default** in Excel, R, Stata or Python, and `load_rule` says how to load
those that won't.

| stable form | loads correctly by default? | `load_rule` |
|---|---|---|
| ISO date `2024-10-25` | yes (readr, pandas, Excel) | blank |
| plain number, ISO timestamp in UTC | yes | blank |
| `TRUE` / `FALSE` | yes | blank |
| factor / category `AR`, `ED`, `HE` | no: loads as text | `as_factor` (levels and labels from `dd_f_levels`) |
| ordered category, Likert scale | no: loads as text or a number | `as_ordered` (level order from `dd_f_levels`) |
| zero-padded ID `06037` | no: loads as a number and drops the zero | `as_id` (keep as character) |
| long numeric ID | no: loads as a double and loses digits | `as_id` |
| timestamp with a local time zone | partly: the zone is lost | `as_datetime` with its `tz` |

`load_rule` is blank when `load_rule_needed` is `no`. It names a function such
as `as_factor`, `as_id` or a user function from `DG.R`. `read_stable_csv()`
applies the load rules, so a user of the stable data gets the right types in
one call, and the DGF documents the same rules for anyone using another program.

`as_factor` should build the factor from the `dd_f_levels` dictionary, so the
curated level order and labels are applied on load rather than re-derived from
the data.

---

## Render routing: `desired_semantic_type` -> template

The Research Guide groups variables into the six data types it has templates
for. The routing key is the ontology `data_type` of `desired_semantic_type`,
looked up in `formex::fx_ontology()`:

| ontology data_type | semantic types (desired_semantic_type) | RG template |
|---|---|---|
| number | measurement, count, rate, ratio, duration, score, index, rank, balance, usd, euro, probability, odds, percent, percentile, min_max, confidence_interval, lat_lon, lon_lat, lat, lon | number |
| categorical | unordered, ordered, geographic, classification_code, missingness_reason, tags, likert, rating, ranking, grade_level | categorical |
| boolean | indicator, presence, status, response, mixed | boolean |
| temporal | calendar, timestamp, clock, year, quarter, month, reporting_period, hour_of_day, day_of_week, month_of_year, week_of_year, date_range | temporal |
| identifier | record, entity, administrative, geographic, hash, version | identifier |
| text | literal, label, title, long, serialized, person, organization, place, handle, street, po_box, full, url, domain, ip, mac, email, phone, hex, rgb, hsl, cmyk | text |
| structured | list, array, object, key_value, point, polygon | **fallback -> text** |
| unknown | heterogeneous, malformed, unclassified | **fallback -> text** |
| blank / not in ontology | (a user-typed value formex does not know) | **fallback -> text**, flagged by `inspect_dgf()` |

`geographic` appears under both categorical and identifier. The ontology row
for the column's `variant_id` decides which one applies, and when the user types
a bare semantic type, the cardinality tie-break `guess_dgf_types()` already uses
decides. A user-typed data type (`number`, `text`, ...) in `desired_semantic_type`
should also be accepted and routed directly.

---

## Gaps between this design and today's code

1. **`stabilizer_needed` is not a fragility check yet.** `plan_stabilizer()` sets
   `yes` only when the planned path is non-empty (guess style != target style).
   A zero-padded FIPS whose guess and target agree gets `no`, though it is
   fragile. Needs a fragility assessment (leading zeros, > 15 digits, non-ISO
   dates, formatted numbers, encoding) that reads `raw_first5` / the column.
2. **`stabilizer_status` uses a smaller vocabulary** (`ready`, `identity`,
   `not-transformable: <reason>`) and is set only at `create_dgf()` time.
   `stabilize_data()` does not write back `applied` / `applied (k failed)`.
3. **Bare function names in `stabilizer` are not run.** `stabilize_data()` runs
   the formex `{{ ... }}` path (`use_v7 = TRUE`, opt-in) or the legacy
   `raw_to_stable_transform` / `desired_data_import_rule` cells. A `DG.R`
   function named in `stabilizer` needs a resolver: a bare name found in the
   environment -> call it; `{{ ... }}` -> formex.
4. **`stabilize_data()` reads a raw file path with readr's type inference**
   (R/09-stabilize-data.R:100), so a raw `06037` can be damaged before the
   stabilizer sees it. It should read as text, as `create_dgf()` does.
5. **`load_rule_needed` / `load_rule` are always blank.** Nothing proposes them,
   and `as_factor` / `as_ordered` do not exist yet (`as_id` does). Note that
   `forcats::as_factor` exists, so a datagoodr `as_factor` will mask it when both
   are attached; `dg_as_factor` or a `load_` prefix would avoid that.
6. **`read_stable_csv()` does not apply load rules** yet.
7. **`raw_data_mode` is not in the live schema.** The live DGF has
   `raw_data_type`, recorded *after* the all-text read, so it is always
   `character`. Per step 1 it should record what a plain read would produce.
8. **Naming.** The schema column is `stable_first5` (not `stage_first5`), and
   level labels live in `dd_f_levels` (a level/label table), not a separate
   `dd_f_labels` column.
9. **The render engine still routes on `desired_data_type`**, a legacy column the
   v7 schema drops. It needs the `desired_semantic_type` -> data_type lookup
   above, with the text fallback.
