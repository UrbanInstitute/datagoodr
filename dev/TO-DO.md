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

## Create update_dgf() function

- [ ] check rg_hash column, update rg fields if data has changed 

## Update create_rg() function


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



