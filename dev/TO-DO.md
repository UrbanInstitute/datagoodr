## DONE: Packaging & integration (2026-07-10)

The package now builds, installs, and loads cleanly, and the full
data-in -> DGF -> Research Guide pipeline runs via `library(datagoodr)`
(no more `source()`-ing individual R files).

- [x] Fixed `DESCRIPTION` (correct Title/Description, `Authors@R`, added
      `readxl`, moved render-only deps to Suggests, RoxygenNote 7.3.3)
- [x] `library(datagoodr)` now provides `%>%` and all pipeline functions
      (was the root cause of STEP1 failing when sourced)
- [x] Qualified unexported dplyr/purrr calls that broke under a real install
      (`count`, `tibble`, `select`, `walk`, `pwalk`) - found via codetools on
      the installed namespace
- [x] Rewrote `get_design()` to read layouts from the namespace instead of
      `.GlobalEnv`/`data()`, removing the `all.layouts <<-`/`xx <<-` hack need
- [x] Replaced all 60 placeholder roxygen stubs with real documentation
- [x] Fixed `messaage` typo in `replace_name()`
- [x] `STEP1.R` and `RG.qmd` rewritten to use `library(datagoodr)`
- [x] Added a testthat suite (`tests/testthat/`): create_dgf structure/typing,
      get_design, create_all_sections render, and utility functions - 33 tests
- [x] Verified end-to-end: STEP1 builds the DGF, STEP3 renders RG.html + RG.pdf

## Update create_dgf()

- [ ] align column names and formatting with updated DGF-CORE-CO-2019-V1.xlsx
- [ ] add function to [create dgf rules file](https://github.com/lecy/datagood2/blob/main/R/01-05-write-dgf-rules-file.R) "dgf.R" 
- [x] add rg_hash column

### Re-integrate the six ignored arguments (found 2026-07-15)

`create_dgf()` accepts six arguments that are never read in its body, so they
are silently ignored today. They are documented as such in the roxygen block
(R/01-00-CREATE-DGF.R) rather than removed, because removing them would break
existing calls - `datagoodr()`'s own example and dev/testing-wrapper.R both
pass `guess.dates`. Each needs to be wired up to its intended behaviour, or
dropped deliberately:

- [ ] `vtypes` - explicit per-column type overrides, to take precedence over
      the inferred types (`use.df.types` / `guess.factors` currently decide
      everything).
- [ ] `guess.dates` - detect and recast date/time columns. The original
      implementation called `find_dates()` / `recast_dates()`; neither function
      exists anywhere in the package, so the call was commented out and the
      argument left dangling. Blocked on the date/time data type (see the
      customize-stage list below).
- [ ] `dd` - merge an existing data dictionary into the new DGF (supply
      vdesc/vlabel/etc. from a curated source instead of the `v*` vectors).
- [ ] `keep.dd.cols` - which columns of that data dictionary to carry through.
- [ ] `preview_dd` / `preview_dp` - print the data dictionary / data profile to
      the console as the DGF is built.

Method note: these were found by comparing each exported function's formals
against the symbols actually referenced in its body. Worth re-running after any
signature change - it also surfaced the dead `rg.name` in `datagoodr()`.



## DONE: Create inspect_dgf() function (2026-07-10)

`inspect_dgf()` (R/02-06-inspect-dgf.R) validates a DGF after manual edits.
It is wired into `working-example/STEP2.R` and covered by tests.

- [x] Check to make sure all json cells are still valid json objects
      (`dd_f_level`, `rg_properties`, `rg_stats`, `rg_graphics`; note
      `rg_preview` is ";;"-delimited text, not JSON)
- [x] If functions are referenced in the `vconvert`/`vformat` columns make
      sure they are defined
- [x] Also checks required columns, renderable `vtype_class`, and `rg_hash`
- Also cleaned up: removed stale draft util files (02-01/02-02) whose
  functions referenced dead column names; moved the real format helpers
  (`as_EIN`, `as_mm`, `as_yyyy`, `as_yyyymm`) into R/02-01-format-functions.R
  and exported/documented them.

## Create ingest_raw() function 

Calls inspect_dgf() before, and update_dgf() afterwards. 

### Fix ingest_raw() - currently exported but cannot run (found 2026-07-15)

**Purpose.** `ingest_raw()` takes the raw CSV and the current DGF, applies all
of the data-type conversion and standardization steps the DGF prescribes, and
emits a clean, import-stable version of the data. "Import-stable" is the point:
re-reading the cooked file should reproduce the same types and values every
time, rather than leaving them to `readr`'s inference.

**Possible rename.** `ingest_raw()` describes when it runs, not what it does.
Consider `cook_raw_data()` - or something else more descriptive of the
transform - when it is implemented.

**Current state.** `R/02-00-INGEST-RAW.R` is a stub that errors if called: it
references `dgf` at `apply_name_aliases( df, dgf )`, but `dgf` is never defined
- the line that would load it is commented out (`# dgf <- load excel`). The
remaining pipeline steps are commented-out stubs. It is exported and appears in
the package index, so a user can find it and call it.

- [ ] `dgf` argument: accept the current DGF (a data frame, or a path to the
      DGF `.xlsx`), matching how `update_dgf()` / `create_rg()` take theirs.
      This replaces the `# dgf <- load excel` stub. `load_dgf()` already exists.
- [ ] apply the `vconvert` type-conversion functions per column.
- [ ] apply the standardization rules (`dgf_standardize`); `apply_stdz_rules()`
      is referenced in the stub but does not exist anywhere and needs writing.
      See also "dgf standardization and validation is not yet integrated" below.
- [ ] wire in `apply_raw_convert_fx()`, which already exists and is exported but
      is never called.
- [ ] write the cooked data out; decide whether that is the caller's job or the
      function's (cf. `create_dgf()`'s `dir`/`file` arguments).
- [ ] call `inspect_dgf()` before and `update_dgf()` after, per the note above.
- [ ] until it works, consider un-exporting it so it stays out of the public
      index - it currently errors on any call.

## DONE: Create update_dgf() function (2026-07-10)

`update_dgf()` (R/04-00-REFRESH-DGF.R) refreshes a DGF against updated data.

- [x] check rg_hash column, update rg fields if data has changed
- Unchanged variables keep their curated DGF row verbatim; changed/added
  variables get refreshed data summaries; removed variables are reported.
- Curated fields (vdesc/vname_alias/vscope/vloc/vconvert/vformat) are
  preserved, and hand-edited factor level labels are carried across a data
  change for levels that still exist.
- Returns the updated DGF with `status` (unchanged/changed/added per variable)
  and `removed` attributes. Demoed in working-example/STEP4.R; covered by tests.
- NOTE (future optimization): update_dgf currently rebuilds the DGF from the
  new data via create_dgf(), then keeps old rows for unchanged variables. It is
  correct and preserves curation, but recomputes summaries for unchanged
  variables. A future version could extract create_dgf's per-variable
  derivation so unchanged variables are skipped entirely.

## DONE: Wire missing dictionary/summary sections into the RG (2026-07-10)

The factor level dictionary and several planned sections were captured in the
DGF (or captured-able) but never rendered. Now wired in:

- [x] LEVELS - `dd_f_level` now stores a two-column level/label dictionary
      (label seeded to the code, editable in Excel); new `paste_levels()`
      renderer; added to factor & logical layouts.
- [x] QUANTILES - new `paste_quantiles()` reads the quantile rows from
      `rg_stats`; `paste_stats_num()` now shows the remaining stats; added to
      the numeric layout (own grid slot so it no longer collides with STATS).
- [x] SCOPE / LENGTH / LOCATION CODE - new DGF columns (`vscope`, `vloc`
      user-supplied; `vlength` = max field width, auto-computed); wired into
      all four layouts, grouped like the demo (DATA TYPE+SCOPE+LENGTH and
      DESCRIPTION+LEVELS+LOCATION CODE).
- [x] Fixed a latent bug: `dd_f_level` used `df[, vname]`, which returns a
      1-col tibble (levels() == NULL) for readr-loaded data, so levels were
      only captured when `vconvert` happened to coerce to a base data.frame.
      Now uses `df[[vname]]`.
- [x] `v_to_txt()` renders blank (not "NA") for empty metadata fields.
- Verified end-to-end: STEP3 renders LEVELS (13), QUANTILES (8), and
  SCOPE/LENGTH/LOCATION CODE (27) into RG.html.

## DONE: Step 5 customization backbone (2026-07-10)

See dev/05-customization-design.md for the full plan.

- [x] `create_rg()` / `create_dd()` scaffold a project (.qmd pointed at the DGF
      + starter DG.R); `use_datagoodr_template()` copies a template.
- [x] Two flavors: RG (full profile) and DD (descriptors only). DD =
      `get_design(style = "dd")` filtered to v_to_txt / paste_levels.
- [x] `create_all_sections(dgf, style =, layouts =)` and `get_design(style =,
      layouts =)` support the DD/RG switch and layout overrides.
- [x] Layout override: a `layout.*` defined in DG.R / the QMD global env wins
      over the package default; an explicit `layouts` arg wins over both.
- [x] Templates ship in inst/templates/ (RG.qmd, DD.qmd, DG.R); the .qmd
      sources DG.R at render if present. Demoed in working-example/STEP5.R.
- Removed stale draft scaffolding (build_rg/build_dd/customize_template,
  inst/qmd-templates/).

Done since:
- [x] Granular per-variable API (2026-07-10): the render engine no longer uses
      the bare `xx`/`all.layouts` globals - the current variable's row is held
      in a package-internal context env (get_xx/set_xx). Exposed dg_section(),
      dg_stats(), dg_quantiles(), dg_properties(), dg_preview(), dg_levels(),
      dg_graphic(), dg_field() for inline narrative use. R/03-03-granular.R.

Still to do at the customize stage (see design doc):
- Aesthetic pass (CSS + gt color tables, ydata-inspired).
- standardize() / format() / create_vr(); date/time data type.

## Update create_rg() function (superseded - see above)


## Notes on things that should be updated in the future

- `R/paste-wordcloud.R` is not scaled correctly. Some are too big and some are too small. Investigate how to make this more uniform. 

- The div arrangements in the current qmd-templates/RG.qmd is probably not the best arrangement for things. We went with a "clean" enough arrangement where you can clearly see everything that is supposed to be there. But this can probably look better in a future update. 

- [x] Sometimes the "most common value" in the `[get/paste]_properties` table is NA and so the percentage also turns to NA. `most_common_val()` was rewritten in base R to handle numeric, character, NA, and empty inputs cleanly (2026-07-10). The percentage handling in `paste_properties` may still warrant a look.

- [x] `create_dgf()` edge case fixed (2026-07-10): a `vformat` that changes a
  numeric column's type (e.g. `dollarize`) no longer crashes `get_stats_num`.
  vformat is now treated as a display transform - preview/properties use the
  formatted values, while numeric/logical stats & graphics are computed on the
  underlying values. Verified byte-identical output for the DGF-V2 example.
- the `vformat` column of the DGF isn't really integrated into the RG when pasting values in specific formats. Future versions should allow for this customization. 

- dgf standardization and validation is not yet integrated. 

- [ ] `.xlsx` cell 32767-char limit (found 2026-07-16): `save_to_excel()` (and
  the v1->v2 migration) write the DGF via `openxlsx::writeData`, which silently
  truncates any cell over 32767 characters - Excel's hard limit. A variable
  with a very large `rg_graphics`/`rg_stats` JSON blob (e.g. a factor with
  hundreds of levels) loses the tail. The `.csv` mirror has no such limit, so
  the two sidecars can disagree. Not introduced by the schema rename - it
  affects any DGF with a big JSON cell - but worth a real fix: either chunk the
  cell (as the governed-CSV writer already does) or treat the `.csv` as the
  authoritative store for the `rg_*` payloads. The render is unaffected today
  because the truncated cells were not on any rendered variable, but that is
  luck, not design.

- [ ] `get_dupes()` cleanup (found 2026-07-15): the `df` argument is vestigial -
  it is never read. The body is `hh <- vhash  # sapply( df, rlang::hash )`, i.e.
  the hashing moved out to the caller and `vhash` is now passed in ready-made,
  but the signature kept `df`. The roxygen still documents `@param df` and the
  example still passes it. Either drop `df` from the signature and the docs, or
  restore it as the fallback (`if (missing(vhash)) vhash <- sapply(df, rlang::hash)`),
  which would make the documented `get_dupes(df, vhash)` example honest. The
  function is exported but never called inside the package or tests, so either
  change is low-risk.

## Two readers disagree about a DGF (found 2026-07-15)

The package loads a DGF two different ways, and they do not produce the same
object from the same file:

- `load_dgf()` (R/00-utils.R) uses `openxlsx::read.xlsx()` -> a `data.frame`.
  Used by `inspect_dgf()`, `update_dgf()`, and anything taking a DGF by path.
- The RG/DD templates use `readxl::read_excel()` -> a `tibble`.

The difference is not just the container. **`readxl` infers an all-empty column
as logical `NA`; `openxlsx` reads it as character.** Verified on a freshly built
DGF for all eight columns a user has not filled in yet - `vdesc`, `vname_alias`,
`vscope`, `vloc`, `vconvert`, `vformat`, `dgf_standardize`, `dgf_validate`.
Some populated character columns (`rg_stats`, `rg_graphics`, `dd_f_level`,
`raw_first5`) also differ when compared as strings; coercing everything to
character does **not** make the two converge, so the discrepancy is in the
values, not only the types.

Nothing is visibly broken today, but it means `inspect_dgf()` validates a
subtly different object than the one the report renders from, and any code that
tests a column's type (`is.character(dgf$vdesc)`) can behave differently
depending on which path reached it. It also makes `render_record()`'s
`dgf_hash` reader-dependent - see the note in `hash_dgf()` (R/07-render-record.R)
and the test pinning that behaviour in tests/testthat/test-render-record.R.

- [ ] Pick one reader and use it everywhere. `load_dgf()` is the natural
      candidate since it is the package's own documented loader; the templates
      would call `load_dgf(params$dgf_file)` instead of `readxl::read_excel()`.
- [ ] Whichever wins, force the DGF's known-character columns to character on
      load, so an empty `vdesc` is `""` and not `NA` / `logical`. That is what
      actually removes the class of bug rather than just picking a side.
- [ ] Careful: switching readers changes column *types*, which is a real
      behaviour change even when the report looks the same. Verify with the
      byte-identical render check used in Stage 1 (render working-example
      DGF-V2 before and after, compare the HTML md5 and every figure hash;
      see the git history for the method).
      Checked and *not* a concern: tibble and data.frame handle an `NA` in the
      `dgf[dgf$vtype_class == "x", ]` logical index the same way, and
      `vtype_class` carries no `NA` in a generated DGF anyway.
- [ ] Once the loader is canonical, `render_record()`'s hash could reasonably
      claim to identify the *file*, and the note in `hash_dgf()` can be relaxed.



