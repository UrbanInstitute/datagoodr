# datagoodr TO-DO

Refreshed 2026-10-27 against the current DGF schema (`dgf_schema_cols()`, 43
columns) and the v7 draft schema (`dgf_schema_cols_v7()`). The stabilization
workflow the v7 columns implement is described in
`dev/stabilization-workflow.md`.

## Priorities (2026-10-27)

1. ~~Profile on the render type.~~ **Done 2026-10-27** (see below).
   Remaining: whenever the guarded type and the semantic guess disagree,
   `create_dgf()` overwrites `desired_semantic_type` with the guarded type
   (`homeworld`: `geographic` -> `text`; a `"$1,234"` column with no ready
   stabilizer -> `text`). The guess survives in `guess_semantic_type`, but the
   user loses the target. Better, once profiling runs on stabilized values
   everywhere: keep the target and flag the row ("awaiting stabilizer" /
   "needs review") instead.
2. **Flip `create_dgf()` to `dgf_schema_cols_v7()`**, once item 1 lands and
   every function in the inventory below reads the v7 columns.
3. **Stabilize step (see `dev/stabilization-workflow.md`, "Gaps"):**
   fragility-based `stabilizer_needed`; `stabilizer_status` written back by
   `stabilize_data()`; bare function names (from `DG.R`) runnable in
   `stabilizer`; `stabilize_data()` reading raw files as text.
4. **Load rules:** propose `load_rule_needed` / `load_rule`; add `as_factor`
   (levels and labels from `dd_f_levels`) and `as_ordered`; apply them in
   `read_stable_csv()`.
5. **`raw_data_mode`:** record what a plain (inferring) read would produce, not
   the all-text read (today `raw_data_type` is always `character`).
6. **Settle `guess_n_sample` (see `dev/performance-notes.md`, §3).** The type
   guess was not reproducible and is now seeded (`guess_seed = 1`), but formex's
   `n_sample = 100` leaves confidence unstable for any column with more than 100
   distinct values — so a column near `route_threshold` is decided by the draw.
   Raising it to 300 fixes `birthState` and `AVG` on `bb.csv` but shifts guessed
   types in every DGF already written, so it needs a decision, not a patch.
   Same note carries the speed work: type guessing was 63% of a build, the
   `rg_*` profiles only 7%.
7. ~~Speed up the formex type guess.~~ **Done 2026-10-28** — shipped as
   `lecy/formex@3d812d2` on `main` (see `dev/performance-notes.md`, §2 and §6).
   `create_dgf()` on `bb.csv` went 9.92s -> 6.86s and type guessing 6.20s ->
   3.59s, with the written DGF byte-identical and both suites green (formex
   883, datagoodr 554, 0 failures). Root cause: 86% of formex's per-call cost
   was the router, most of it input-independent work recomputed on every call.
   Remaining from that work: `guess_n_sample` (item 6 above), and the three
   items formex deliberately left unfixed (§2.3).

### Routing rules (2026-10-27)

- Templates are chosen from `desired_semantic_type` first; the legacy
  `desired_data_type` is used only when the semantic type is blank or unknown.
- `desired_semantic_type` may be a bare leaf (`usd`), a bare data type
  (`number`), or a formex path (`number:currency:usd`, truncated where the route
  stopped). A path's first segment names the data type.
- **Conflicted semantic types route to text for now.** `geographic` is listed
  under both categorical and identifier. A bare `geographic` routes to text
  unless `guess_variant_id` or a path (`identifier:id:geographic`) settles it.
  Longer term: ask formex for distinct names (e.g. `geographic_id`).
- Formex -> template crosswalk: number, categorical, boolean, temporal,
  identifier and text map one to one; structured and unknown fall back to text.
  Known gaps: `tags` (needs split-then-count), `min_max` /
  `confidence_interval` / `lat_lon` (pairs, not single numbers), `date_range`,
  and geometry (no map template).

### Done 2026-10-27

- [x] `dgf_schema_cols_v7()` keeps `dd_f_levels` and documents the six dropped
      legacy columns.
- [x] `dg_render_type()` (exported): picks each variable's Research Guide
      template. Order: legacy `desired_data_type` -> ontology data type of
      `desired_semantic_type` (via `formex::fx_ontology()`) -> `text` fallback
      for structured / unknown / blank / unrecognised types. Used by
      `create_section()`, `create_div()`, the `dg_*()` helpers, and the RG/DD
      templates. `inspect_dgf()` checks `desired_semantic_type` on a v7 DGF.
- [x] `create_dgf()` seeds a blank `desired_semantic_type` with the base type
      (`number`, `text`, ...) where formex found no route, so plain numeric
      columns still route to the number template.
- [x] `create_dgf()` collapses list columns (`starwars$films`) to `a|b|c`
      instead of deparsed R code (`c("A New Hope", ...`).
- [x] `create_dgf()`: honours `dd_vlabel`; rule-prefix check now strips
      `as_`/`read_` (it assumed 3-char `as_`); removed the dead
      `if(is.null(format))` line.
- [x] `dplyr::starwars |> create_dgf() |> create_rg(render = TRUE)` runs end to
      end and renders all 14 variables.
- [x] **Profile type = render type.** `create_dgf()` profiles each variable on
      the first type its values can carry: the enriched legacy guess (it keeps
      the storage gate, cardinality tie-break and identifier/temporal
      detectors) -> the v7 target (`dg_render_type()` of
      `desired_semantic_type`) -> the storage type. The target goes first when
      its `ready` stabilizer actually converts the values to numbers. The chosen
      type is written to `desired_data_type`, and to `desired_semantic_type`
      wherever the two would route differently, so legacy and v7 routing agree
      with the stored profile. `dd_f_levels` is now built for every
      categorical / boolean variable from the profiled values.
      `retype_dgf()` also updates `desired_semantic_type`. Verified: starwars
      renders all 14 variables both with and without the legacy columns.
      Trade-off: a semantic guess that disagrees with the guarded type is
      overwritten in `desired_semantic_type` (starwars `homeworld`:
      `geographic` -> `text`); it is kept in `guess_semantic_type`.

---

## DGF schema (current, 43 columns) and v7 status

`keep` = in the v7 draft schema; `drop` = legacy, replaced in v7; `rename` =
v7 name differs.

```
1. DATA DICTIONARY & FIELD DOCUMENTATION
  var_name                   keep
  dd_vname_alias             keep
  dd_vlabel                  keep
  dd_vdesc                   keep
  dd_data_unit               drop     (unit moves to desired_unit_type)
  dd_f_levels                keep     (level/label table; feeds as_factor)
  dd_is_join_key             keep
2. RAW INGEST
  raw_data_type              rename -> raw_data_mode
  raw_data_format            drop     (format moves to guess_format_style)
  raw_first5                 keep
  raw_duplicated             keep
3. DATA TYPE STANDARDIZATION
  guess_label .. guess_confidence (8)        keep
  raw_to_stable_transform    drop  -> stabilizer
  stable_data_type           drop
  stable_data_format         drop
  desired_data_import_rule   drop  -> load_rule
  desired_data_type          drop  -> dg_render_type(desired_semantic_type)
  desired_data_class         drop  -> desired_semantic_type / desired_format_style
  desired_semantic_type / _format_style / _unit_type   keep
  stabilizer_needed, stabilizer, stabilizer_status, stable_first5   keep
  load_rule_needed, load_rule                          keep
4. DESCRIBE
  rg_properties, rg_preview, rg_stats, rg_graphics, rg_max_chr     keep
5. VALIDATE
  validate_rules, validate_format                                  keep (never filled)
6. VERSION CONTROL / MISC
  prov_start_hash (never filled), prov_current_hash                keep
```

Never filled by any code today: `dd_data_unit`, `raw_data_format`,
`raw_to_stable_transform`, `validate_rules`, `validate_format`,
`prov_start_hash`, `load_rule_needed`, `load_rule`.

---

## Port off the legacy columns: function inventory

Every function that reads or writes a column the v7 schema drops. Each must
read the v7 columns (3a `guess_*` / 3c `desired_*`, `stabilizer`, `load_rule`)
before `create_dgf()` can flip to `dgf_schema_cols_v7()`.

| function (file) | legacy columns used | v7 replacement | status |
|---|---|---|---|
| `create_dgf()` (01-00) | writes all six; `desired_data_import_rule` / `stable_data_format` / `stable_data_type` are also arguments | write the v7 set; replace the rule arguments with `desired_semantic_type` overrides (see "Arguments" below) | open |
| `dgf_schema_cols()` (01-01) | defines them | becomes `dgf_schema_cols_v7()` | open (the flip) |
| `dg_render_type()` (01-01) | reads `desired_semantic_type` first; legacy `desired_data_type` only when the semantic type is blank or unknown | drop the legacy branch after the flip | done (bridge) |
| `retype_dgf()`, `.dgf_vclass_of()` (01-05) | writes `desired_data_type` / `desired_data_class`; units into class | write `desired_semantic_type` / `desired_unit_type`; profile via `dg_render_type()` | done (types and units write `desired_semantic_type`; legacy columns kept in step when present) |
| `guess_dgf_types()` (01-06) | returns `desired_data_type` / `desired_data_class` | return only `guess_*` + `dd_is_join_key`; desired_* defaulted in 01-08 | open |
| `inspect_dgf()` (02-06) | validates `desired_data_type`; checks functions in `desired_data_import_rule` / `stable_data_format` | validates `desired_semantic_type` (added); check functions in `stabilizer` / `load_rule` | partial |
| `check_dgf_rules()` (02-07) | runs `raw_to_stable_transform` / `desired_data_import_rule` | run `stabilizer` / `load_rule` | open |
| `default_layouts()` (03-01) | displayed `desired_data_type`, `desired_data_class`, `dd_data_unit` in the attributes block | DATA TYPE = template type, SEMANTIC TYPE = `desired_semantic_type` (done); UNIT still reads `dd_data_unit` -> `desired_unit_type` | partial |
| `create_section()`, `create_div()` (03-01) | routed on `desired_data_type` | `dg_render_type()` | done |
| `set_dg_context()` (03-03) | returned `desired_data_type` | `dg_render_type()` | done |
| `paste_temporal_graphic()` (03-02) | reads the grain from `desired_data_class` (`period.month`, ...) | derive the grain from `desired_semantic_type` (`year`, `month`, `day_of_week`, ...) via `.temporal_grain()` | done (semantic type first; legacy class only for pre-v7 DGFs) |
| `update_dgf()` (04-00) | carries `desired_data_import_rule` / `stable_data_format` across; keys level carry-over on `desired_data_type` | carry `desired_*`, `stabilizer`, `load_rule`; key on `dg_render_type()` | open |
| `stabilize_data()` (09) | runs `desired_data_import_rule` then `raw_to_stable_transform`; v7 plan opt-in | `stabilizer` only (formex plan or a bare `DG.R` function); then drop `use_v7` | open |
| RG.qmd / DD.qmd templates | routed on `desired_data_type` | `dg_render_type()` | done |
| DG.R template | example layout row names `desired_data_type` | update the example | open |

Also to update after the flip: tests (`test-check-rules`, `test-create-dgf`,
`test-customize`, `test-formex-seam`, `test-guess-dgf-types`,
`test-identifier`, `test-inspect-dgf`, `test-render`, `test-retype-dgf`,
`test-stabilize-data`, `test-temporal`, `test-v7-stabilizer`) and vignettes
(`data-governance-workflow`, `guessing-data-types`, `workflow-overview`).

### `create_dgf()` arguments against the schema

| argument | today | plan |
|---|---|---|
| `df`, `read_as_text`, `use.df.types`, `guess.factors`, `max_factor_levels`, `dir`, `file`, `open` | working | keep |
| `dd_vlabel`, `dd_vdesc`, `dd_vname_alias` | working (`dd_vlabel` fixed 2026-10-27) | keep |
| `var_name` | ignored; always `names(df)` | remove (documented as ignored) |
| `stable_data_type` | ignored; computed | remove (column dropped in v7) |
| `desired_data_import_rule` | applied before profiling | replace with a `desired` override (named vector of semantic types) |
| `stable_data_format` | display transform for previews | replace with `desired_format_style` / the stabilizer preview |
| `vtypes` | ignored | becomes the `desired` override above |
| `guess.dates` | ignored | remove: formex detects temporal types |
| `dd`, `keep.dd.cols` | ignored | keep the idea: merge an existing data dictionary into the `dd_*` columns |
| `preview_dd`, `preview_dp` | ignored | remove, or print the DGF summary already shown |

---

## Older items, status updated 2026-10-27

### DONE: Packaging & integration (2026-07-10)

Builds, installs, and loads cleanly; the full pipeline runs via
`library(datagoodr)`. testthat suite added (since grown to ~490 tests).

### Read raw as text + guarded numeric promotion: DONE

- [x] `create_dgf(read_as_text = TRUE)` is the default; `.safe_numeric()`
      promotes only columns safe to store as numbers (no leading zeros, within
      2^53). The temp write->read round-trip is gone.
- [x] readr is called with `lazy = FALSE` (avoids the vroom ALTREP path).
- [ ] `stabilize_data()` and the RG template's optional `data_file` still read
      with readr's inference; switch them to the all-text read.
- [ ] (later) big-file mode: reservoir sampling + chunked streaming.

### Heuristics to separate IDs from quantities (idea 2026-07-26): open

Among all-integer columns, flag likely identifiers rather than quantities. Now
best done in formex (the detector), with datagoodr surfacing the result:

- [ ] **Fixed width** (constant `nchar`: EIN = 9, ZIP = 5, FIPS = 5/11).
- [ ] **Benford fit** (measurements follow it; manufactured numbers don't).
- [ ] **Uniqueness x entropy** (near-unique + sequential -> row key).
- [ ] Surface as a confidence flag the user confirms, not a hard cast.

### Confirm-before-profile workflow (idea 2026-07-26): now priority 1

Target flow: read as text -> guess (type + suggested stabilizer) -> user
confirms -> stabilize -> profile once on the stabilized values. The v7 schema
now has the pieces: `guess_*` (the guess), `desired_*` (the confirmation),
`stabilizer` + `stable_first5` (the suggested rule and its effect).

- [ ] Profile on the stabilized values, with the profile type taken from
      `dg_render_type()` (priority 1 above).
- [x] Suggested-rule source: formex's `desired_default_format` gives the target
      style, and `fx_plan_transform()` gives the rule.
- [ ] Two kinds of correction must stay distinct: (a) relabel only (values
      already fine, e.g. a number that is really a category) and (b) a type that
      needs a transform (`"201912"` -> a month). (b) needs a `stabilizer`.
- [ ] Confirmation UX: the editable DGF in Excel stays the main review step.

### `ingest_raw()`: still broken, now superseded

`R/02-00-INGEST-RAW.R` is still a stub that errors on any call (`dgf` is never
defined) and is still exported. Its job, raw -> import-stable data, is now
`stabilize_data()`.

- [ ] Un-export or delete `ingest_raw()`. Move `apply_name_aliases()` (the one
      working step) into `stabilize_data()`.
- [ ] `apply_raw_convert_fx()` is exported but never called; delete it or fold it
      into `stabilize_data()`.

### DONE: `inspect_dgf()`, `update_dgf()`, RG sections, Step 5 customization (2026-07-10)

See git history. Open follow-ups:

- [ ] `update_dgf()` rebuilds the whole DGF via `create_dgf()` and keeps old rows
      for unchanged variables; could skip unchanged variables entirely.
- [ ] Aesthetic pass (CSS + gt color tables).
- [ ] `R/paste-wordcloud.R` scaling is uneven.

### Two readers disagree about a DGF (found 2026-07-15): open

`load_dgf()` uses `openxlsx` (data.frame, empty columns as character); the
RG/DD templates use `readxl::read_excel()` (tibble, empty columns as logical
`NA`), so `inspect_dgf()` checks a different object than the report renders.

- [ ] Use `load_dgf()` in the templates.
- [ ] Force known-character DGF columns to character on load.
- [ ] Verify with a byte-identical render (HTML md5 + figure hashes).
- [ ] Then relax the note in `hash_dgf()` (R/07-render-record.R).

### Small fixes: open

- [x] `.xlsx` 32,767-character cell limit (fixed 2026-10-27, found on the
      baseball data: `birthDate` / `debut` / `finalGame` graphics data ran
      118k-210k characters). `save_to_excel()` moves any cell over the limit
      (measured after XML escaping, which openxlsx counts) to a
      `DGF_overflow` sheet in parts, leaving a `<<DGF_overflow>>` pointer;
      `load_dgf()` joins them back (and warns if parts are missing). The RG/DD
      templates now read through `load_dgf(reader = "readxl")`. Reports
      scaffolded before this read with `readxl::read_excel()` directly and will
      not join oversized cells: re-scaffold, or swap that line.
- [ ] `get_dupes()`: the `df` argument is never read. Drop it or restore
      `if (missing(vhash)) vhash <- sapply(df, rlang::hash)`.
- [ ] The `vformat` display formatting (now `stable_data_format`) is not used
      when pasting values into the report. Decide whether `desired_format_style`
      should drive display formatting.

### Data-type detectors: moved to formex

The detector library, its rebuild orchestration, and the deferred
protocol/scientific message formats (SWIFT, FIX, NMEA, FASTA, SMILES, ...) now
live in formex. Track them there.

### Baseball test dataset (`data-dev/bb.csv`, checked 2026-10-27)

4,620 players x 19 columns plus `data-dev/bb-data-dictionary.csv` (label,
description, source, category, verified). Good stabilization test: written
dates (`"Dec 27, 1981"`), ISO dates, `"$851,950"` salaries, `R`/`L`/`B` codes,
non-US places in `birthState` (`"La Romana"`). Read with
`colClasses = "character"`, labels and descriptions passed through `dd_vlabel` /
`dd_vdesc`. Renders all 19 variables with and without the legacy columns.

Fixed while testing:
- [x] `salary` (`usd`, `{{ read_usd :: write_numeric }}` ready) was profiled as
      text: formex's `write_numeric` returns number-like strings, not numbers.
      `create_dgf()` now accepts those; `salary` profiles as a number and keeps
      `usd` as its target.
- [x] `paste_temporal_graphic()` read `desired_data_class` unconditionally, so a
      v7-only DGF errored on the first temporal variable. It now falls back to
      `desired_semantic_type` for the grain.

Open:
- [ ] Date stabilizers: `birthDate` (`"Dec 27, 1981"`), `debut` / `finalGame`
      (already ISO `yyyy-mm-dd`) and `birthYear` all report
      `not-transformable: no path from [w|calendar|...]`. An ISO date should be
      `identity`. Report to formex.
- [ ] `SLUG` (`ratio`): `not-transformable`, though `AVG` (`measurement`) gets
      `write_numeric`. Same family of formex gap as `mass` was.
- [ ] `birthState` / `birthCity` guessed `geographic` but profiled as text
      (too many levels); the semantic guess is overwritten in
      `desired_semantic_type` (priority 1 follow-up).
- [ ] `throws` (`R`/`L`) becomes boolean because it has 2 levels; `bats`
      (`R`/`L`/`B`) is categorical. A 2-level code is not a yes/no flag; the
      boolean rule should require boolean-like values (`TRUE`/`FALSE`, `Y`/`N`,
      `0`/`1`), not just 2 levels.
- [x] Dictionary file corrected (2026-10-27): removed `birthDay` (not in the
      data); `finalGame` no longer repeats `debut`'s description or claims
      blanks it doesn't have; `birthMonth` documented as `Mon` abbreviations,
      not `MM`; blanks documented for `birthState`, `birthCity`, `AB`, `AVG`,
      `SLUG`; date and salary formats stated; placeholder `weight` source
      replaced; leading spaces trimmed.
- [ ] Use the dictionary file directly: this is the `dd` / `keep.dd.cols`
      argument of `create_dgf()`. Dictionary checks `inspect_dgf()` could run:
      documented-but-missing / undocumented variables, duplicate descriptions,
      and `verified = 0` rows flagged in the Research Guide.

### Detection quality seen on `dplyr::starwars` (report to formex)

Re-checked 2026-10-27 against formex `1a1334e`:

- [x] `mass` -> fixed in formex `ff20e2b`: now `{{ write_numeric }}`, status
      `ready`, preview correct.
- [ ] `hair_color`, `eye_color` still guessed `geographic` (depth 3). formex
      `7803a35` added `is_color_name()` and a `color_name` leaf, and the detector
      passes 93% of `eye_color` and 50% of `hair_color` values, but the route
      still lands on `geographic`. Likely causes: compound values
      (`"brown, grey"`, `"blue-gray"`) and non-color fillers (`"none"`,
      `"unknown"`) keep the pass rate below the router's threshold.
- [ ] `name` guessed `organization` (person names).
- [ ] `height`, `birth_year`, `skin_color`, `species`: no route at all.
- [ ] List columns, now collapsed to `a|b|c`, are not recognised as `tags`
      (formex lists a tags detector as its next item).

---

## Ideas for the governance / audit layer (2026-08-02)

### Raw-stage summary statistics for audit-by-inspection

Capture per-variable statistics on the **raw (pre-stabilization)** values and
keep them in the DGF, so a reviewer can see whether cleaning, transformation or
joins changed a variable. This is audit by inspection, not reproduction, aimed
at reviewers without CS expertise (journal reviewers checking an archived
data + code deposit).

- [ ] Shannon entropy (distributional collapse, mass duplication).
- [ ] Missingness count/rate (rows dropped, `NA` injected by a bad join or a
      failed coercion).
- [ ] Boolean and factor level count tables (lost / merged / renamed levels).
- [ ] Distinct count; numeric min/max/range; text length stats.
- [ ] (later) a raw-vs-stable "delta" view listing only the variables whose
      distribution changed beyond a threshold.

Storage: a `raw_*` stat family in the DGF, or computed on demand from a retained
raw glimpse. Pairs with ID hardening: a hardened ID carried with its raw numeric
twin allows a row-level check
(`all.equal(as_id_numeric(id_hardened), as.numeric(id_raw))`) that survives
filtering and joins, where a column hash cannot.

### Dataset-source prefixes in variable names

When joining several sources, prefix each variable with its source
(`census_var1`, `bls_var3`, `irs_var5`) so lineage is legible from the schema.
Future: an opt-in `source_prefix=` on the ingest/join step, with the prefix ->
source + vintage mapping recorded in the DGF.

### Guessed vs desired format as a cleaning audit trail

In v7 terms: wherever `guess_format_style` differs from `desired_format_style`
(or `stabilizer_needed` is `yes`), the values were changed by stabilization, and
the `stabilizer` cell says how. A reviewer can filter on that to get the exact
list of columns the wrangling touched. Surface it as a "what changed on import"
section in the Research Guide.
