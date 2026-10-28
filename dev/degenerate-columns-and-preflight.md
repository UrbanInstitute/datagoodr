# Dev notes — degenerate columns, a pre-flight check, and what changed

From: datagoodr · 2026-10-28
Branch: `preflight-and-degenerate-column-fixes`, cut from `origin/main` (`f5cd312`)
Re: building a DGF and Research Guide for the IRS 990 tax-year-2023 e-file panel
(P00 + P01 + P08: 568,214 returns x 199 columns), with a clean install of
datagoodr (0.1.0), formex (`8978cc0`), panel990 and concordance990 (2.0.3).

**Evidence labels.** **[verified]** = reproduced by running it. **[from source]** =
read in the code, not executed. **[inferred]** = a conclusion from the above, not
traced. Nothing here was pushed; the branch is local.

---

## 0. Summary

A degenerate column (single-valued, all-missing, over-long text) made
`create_dgf()` abort **after 10-20 minutes of profiling**, with an error that named no
column. On this file that cost three full-length runs before the cause was found. This
branch fixes the crashes, makes errors name the variable, and adds a pre-flight check that
finds such columns before profiling starts.

| # | Problem | Status on this branch |
|---|---|---|
| B1 | one-level factor crashes `get_stats_fact` / `get_graphics_fact` / word cloud | **fixed** |
| B2 | `strptime()` aborts on values >= 1000 bytes (3 call sites) | **fixed in datagoodr**; root cause in formex **not** fixed upstream (see §5) |
| B3 | `create_dgf(vtypes=)` accepted and ignored | unchanged (design decision) |
| B4 | `retype_dgf(data = <path>)` infers types with `readr` | **fixed** |
| B5 | a timestamp column stores a 39.7M-character profile | **fixed** (option `datagoodr.temporal.max_values`) |
| B6 | duplicate columns are reported but profiled twice | **reported** by pre-flight; not de-duplicated |
| B7 | `retype_dgf()` leaves `dd_f_levels` stale | **fixed**; the `level` / `f_level` key mismatch is **not** unified |
| B8 | `create_rg()` bakes a DGF path Quarto cannot resolve | **fixed** (`rel_to_dir()` extended) |
| B9 | all-missing column crashes the character stats; preview is "NA" | **fixed** |
| B10 | zero-padded two-value code typed as `number` | **not changed**; flagged by pre-flight (§3) |
| B11 | `%\|\|%` used without import | **not changed** (§2) |
| — | no pre-flight check; errors name no column | **new**: `preflight_dgf()`, `create_dgf(preflight=)`, named errors |

Tests: baseline on clean `main` was **204 passing, 0 failing, 4 skipped**. On this branch:
**234 passing, 0 failing, 0 errors, 4 skipped** (the 204 existing + 30 new), with formex `8978cc0`
and again, identically, with formex `3d812d2` (§5). On a 30,000-row sample, the DGF the branch
builds is **identical to the one unmodified `main` builds in every cell except** the two
intended (`rg_graphics` of the two timestamp variables, B5).

---

## 1. Why the failures were so expensive

`create_dgf()` profiles every column. On the 568,214 x 199 file the build took ~22 minutes
(with formex `8978cc0`; formex's 2026-10-28 speed-up shortens it, see §5). Each crash arrived
late and as a bare R error (`'names' attribute [2] must be the same length as the vector [1]`)
with no variable name. B1 was misdiagnosed once and cost three full runs; B2 was found only
because a 30,000-row smoke test failed in under a minute, since the full file had passed type
detection by luck of row order.

---

## 2. Bugs

### B1. One-level factors [verified]

`sort(table(x), decreasing = TRUE)` followed by a subset collapses a one-element table to a
bare named integer, so `data.frame()` / `as.data.frame()` lose the `Freq` column:
`get_stats_fact` -> `'names' attribute [2] must be ...`; `get_graphics_fact` -> `replacement has
0 rows, data has 1`; and the word-cloud `simplify_char()` returned the *count* as the word for a
column with one distinct word.

Not only constants trigger it: datagoodr treats blanks as missing, so **one value plus blanks**
(an `X`/blank checkbox) is also a one-level factor. In this file: 2 constants, 19 checkboxes and
1 code column (`FAL1`). "Constant" must be measured *after* missing-value normalisation.

Fix: `.freq_table()` (`R/00-utils.R`) orders with `drop = FALSE` and preserves the dimension
name. Output for every input that worked is identical (regression tests pin the pre-fix strings
captured from unmodified `main`). `get_graphics_fact` still appends an `"other"` row with count
**0** when every level is >= 2% — verified, kept byte-for-byte.

### B2. `strptime()` aborts on values >= 1000 bytes [verified]

`Error in strptime(...): input string is too long`. Base R refuses such input, and three places
hand it raw cell values:

1. `datagoodr:::detect_temporal` — parses the **first 50 non-blank values**, so it fails only if a
   long value falls in that window (a latent, row-order-dependent bug). **Fixed**: over-long values
   count as non-dates and are never parsed.
2. The call into formex (`.formex_guess()` -> `formex::guess_data_type()` -> `is_date`). **Worked
   around** in datagoodr: `.cap_bytes()` trims over-long values *for that one call only*
   (multi-byte safe); the data, the profile and the storage-safety gate still see the originals.
3. `formex::is_date` itself, which loops formats over every value it is given. **Not fixed
   upstream.** Verified against formex HEAD `3d812d2`: `is_date()` and `guess_data_type()` still
   raise the same error on a 1,500-byte value (§5). The root fix belongs in formex; `.cap_bytes()`
   can be removed once it lands.

Triggers here: `F9_00_REASONABLE_CAUSE_TXT` (max 8,985 bytes) and `F9_01_ACT_GVRN_ACT_MISSION`
(max 1,063), ordinary free-text fields. formex's own `R/20-fx-stabilize.R` has a similar
`strptime(x0[todo], ...)` call that looks unguarded [from source, not run].

### B3. `vtypes` is accepted and ignored [verified from docs and signature]

So there is no way to say "treat this column as text / skip it" before profiling. Unchanged: it is
a design question. The pre-flight findings give a user the information to decide.

### B4. `retype_dgf(data = <path>)` infers types [from source, then verified by test]

It called `readr::read_csv(data)` with default inference, which turns `"00"` into 0 and
`"06037"` into 6037 — the columns a user retypes to protect. Now reads as text (as `create_dgf`
does) and casts only the retyped columns.

### B5. Timestamp profiles can be enormous [verified]

The temporal profile is a value -> count table with one row per distinct value. For
`RETURN_TIME_STAMP` (531,118 distinct) that was a **39.7M-character cell**, twice, making
`DGF.csv` 88 MB and exceeding Excel's cell limit. The profile is deliberately unit-independent (a
user can change the grain and re-render), so it cannot simply be aggregated. Fix: above
`getOption("datagoodr.temporal.max_values", 10000)` distinct values, ISO timestamps are stored at
the finest of minute / hour / day that fits. `parse_hour()` reads *leading* digits, so it already
cannot read an hour from an ISO timestamp; date, week, month and year grains lose nothing. A
column under the cap, or not ISO-like, is stored exactly as before.

### B6. Redundant columns [verified]

`create_dgf()` prints `raw_duplicated` and then profiles both columns. The merge log suggests
`panelize()` keeps both the unprefixed key and its `F9_00_` copy [inferred]. Pre-flight now reports
them (`duplicate_column`); de-duplication is not implemented.

### B7. `retype_dgf()` leaves `dd_f_levels` stale [verified]

After retyping three checkboxes that mix `0/1/true/false` to boolean, the guide still printed
"CATEGORY LABELS: 0 1 FALSE TRUE"; variables made newly categorical got no levels. Fixed: the
dictionary is rebuilt by the same helper `create_dgf()` now uses (`.levels_json()`), keeping labels
already edited for surviving levels, and left untouched when the new type has no levels.

**Still open:** the stored JSON uses the key `"level"`, but the exported `jsonify_f()` writes
`"f_level"`. They cannot be interchanged. Not unified (public API).

### B8. `create_rg()` path [verified; documented behaviour]

`rel_to_dir()` documented that a DGF outside the report's folder is "left as given (the caller's
responsibility)". Quarto resolves the path from the `.qmd`, so `create_rg(dgf = "dgf/DGF.xlsx",
dir = "guide")` failed at render. Extended: a path that exists is baked relative to `dir`
(`../dgf/DGF.xlsx`); the same-folder case and unresolvable paths behave as before.

### B9. All-missing column [verified]

The character stats failed with `invalid number of 'breaks'` (aborting the build), and the preview
was `"NA"`. The stats now return the same shape with explicit `"NA"` cells, an empty `HIST` and an
empty `COMMON`; the renderer already accepts an empty `HIST` (the identifier profile uses it). The
preview is `""`.

### B10. A zero-padded code can still be typed `number` [verified; mechanism inferred]

On a fixture, `create_dgf()` typed a column of `"00"` / `"11"` as **number** (and
`F9_00_IRS_TRUST_OOB_VERIFIED_X` in the real file), although `.safe_numeric(c("00","11"))` is
`FALSE`. The likely route is `.align_profile_types()`: when formex's stabilizer is "ready" and
converts the values, the result is accepted as numeric without re-checking `.safe_numeric()`
[inferred, not traced]. A suggested guard is to require `.safe_numeric()` there. **Not changed**:
it alters how existing DGFs are typed, in code under active development. Pre-flight reports it
as `leading_zero_code`.

### B11. `%||%` without an import [from source]

`R/01-08-stabilizer-plan.R` uses `%||%`, which is in base R only from 4.4.0, while DESCRIPTION
says `R (>= 4.1)`. Not run on 4.1-4.3. The new code avoids it.

---

## 3. `preflight_dgf()` and `create_dgf(preflight = )`

```r
preflight_dgf(df, max_chr = 1000L, smoke_n = NULL, seed = 1L)   # exported; returns a findings table
create_dgf(df, preflight = c("warn", "error", "off"))           # default "warn"
```

One row per finding (`var_name`, `rule`, `severity`, `detail`, `suggestion`); class
`dgf_preflight` with a `print()` method. Missing means `NA`, empty or whitespace-only. It works on
each column's **distinct values and their counts** (`match` + `tabulate`), not on every row.

| rule | severity | found on the real file |
|---|---|---|
| `constant` | warn | 2 (`TAX_YEAR`, `F9_00_TAX_YEAR`) |
| `single_value_with_blanks` | warn | 20 (19 `X`/blank checkboxes + the `FAL1` column) |
| `all_missing` | warn | 0 |
| `duplicate_column` | warn | 8 pairs |
| `mixed_boolean_encoding` | warn | 3 (`0/1/true/false`) |
| `non_finite` | warn | 0 |
| `placeholder_value` | info; warn from 5% | 2 (`ORG_WEBSITE` `N/A` 25.3%; `ORG_PHONE` `0000000000` 0.4%) |
| `leading_zero_code` | info | 5 (EIN x2, phone, group exemption number, `..._OOB_VERIFIED_X`) |
| `high_cardinality_temporal` | info | 2 (531,118 distinct timestamps) |
| `long_values` | info | 2 (493 and 1,074 values >= 1000 bytes) |
| `smoke_test_failed` | error | only with `smoke_n` |

On the real file it finds, in one pass, what took hours to find by hand: **34 warnings, 10 notes,
0 errors**.

**Speed [verified].** 100.7 s -> **35.9 s** (2.8x) after moving the rules from all rows to distinct
values; a profile showed ~70% of the time was `grepl` and `tolower` over every distinct value of
high-cardinality columns. Documented as "about 40 seconds", not "seconds".

**Noise [verified].** The first placeholder rule flagged 73 columns; 71 touched under 200 rows (one
organisation really is called "None"). A floor of 0.1% of rows keeps the two that matter.

**`smoke_n`.** Builds a DGF from a random sample (in a temp folder, pre-flight off) and reports a
failure as `smoke_test_failed`, naming the variable. It found B2 in under a minute. The session's
random-number state is preserved (the build draws random numbers too).

**Named errors.** The per-variable steps in `create_dgf()` (temporal and identifier detection,
preview, properties, statistics, graphic) are wrapped so a failure reads
`create_dgf(): statistics (factor) failed for variable 'x': ...`. This is how B9 was found.

**Deliberately not implemented:** an automatic `"fix"` policy (it would rewrite data silently), a
`vtypes` override (B3), de-duplication (B6), and a fallback profile for a column that still fails.

---

## 4. Two type-detection passes — a correction

An earlier version of these notes called datagoodr's own `detect_temporal()` /
`detect_identifier()` an "unfinished migration" to formex. **That was wrong.** formex's
`INTEGRATION-NOTES.md` says they "stay in datagoodr ... base-pass pre-checks in the stats/DGF
layer. They are NOT in formex", and `.align_profile_types()` documents why the legacy guess comes
first (it carries the storage-safety gate, the cardinality tie-break and the identifier / temporal
detectors that a raw semantic route lacks). The datagoodr README separately lists porting the
renderer off the legacy `desired_data_*` columns as "in progress", which is a different, narrower
migration.

The cost of the design is real but small: B2 had to be fixed in three places. A shared
"is this value even parseable" guard would remove that.

---

## 5. Checked against formex HEAD (`3d812d2`, 2026-10-28)

formex `main` is one commit ahead of the version these notes were built on (`8978cc0`), shipped and
pushed: *Speed up guess_data_type ~2.2x by caching input-independent work* (date-format pre-filter,
foil-leak memo, cached ontology signatures; 5 files). Installed into a separate library and tested.

formex was installed from a clean `git archive` of its `HEAD` into a separate library; the
library used for everything above was left alone, and each run printed which formex it loaded.

| Check | Result |
|---|---|
| **B2 — does the new formex fix the long-text crash?** | **No** [verified]. `formex::is_date()` and `formex::guess_data_type()` raise `input string is too long` on a 1,500-byte value in both formex versions, including when the value contains a colon (which the new pre-filter looks at). So `.cap_bytes()` is still required. |
| **Branch test suite, formex `3d812d2`** | **234 tests, 0 failed, 0 errored, 4 skipped** [verified] — the same result as with formex `8978cc0`. |
| **Does the new formex change any DGF?** | **No** on this data [verified]. A 30,000-row x 194-column sample of the 990 file, same seeds, branch code: the DGF built under `8978cc0` and under `3d812d2` match in **all 194 x 43 cells** (every type, guess, stabilizer and profile). One dataset, so this supports the commit's "no detection verdict changes" claim; it does not prove it. |
| **Is the build faster?** | **Not measured here.** My `3d812d2` run shared the CPU with the full test suite (8.5 min against 2.6 min), so the timings are contention, not a result. The 1.7x-2.2x in `dev/performance-notes.md` is that note's measurement, not re-measured. |

What this means for the work above:

* **The 22-minute build time** quoted in §1 and in the NEWS entry was measured with `8978cc0` and
  is now an overestimate; the pre-flight's advantage over a build is smaller with the new formex.
  The docs say "before its 2026-10-28 speed-up".
* **Suggested formex fix for B2:** in `is_date()`, treat a value of `nchar(x, "bytes") >= 1000` as
  "not a date" before `strptime()` (and the same in the `R/20-fx-stabilize.R` loop). Then
  `.cap_bytes()` can go.
* **`dev/performance-notes.md` §2.3.3** floats "per-recipe applicability gates (skip the date genome
  when a column has no digits at all)". That would avoid `strptime` on most free text, but it is a
  detection-logic change, not a length guard: a long value that contains digits would still reach it.
* **`guess_seed` (your `v7-stabilization-workflow` commits)** makes the guess deterministic. It does not interact with
  this branch: the equivalence runs fixed the seed themselves, and the pre-flight smoke test only
  needs the session's RNG state restored, which `.with_seed()` does.
* **Not tested:** the parallel `workers` path (it is in your `v7-stabilization-workflow` commits; see §7), and formex's
  own test suite (its notes report 883 passing; not re-run here).

---

## 6. Upstream data packages (panel990 / ef2 / concordance990)

* 7 columns have no concordance entry (`EIN2`, `OBJECTID`, `RETURN_PARTIAL_X`, `RETURN_TAXPER_DAYS`,
  `URL`, `VERSION`, `F9_00_ORG_EXEMPT_TYPE`); they were labelled by hand and marked as such.
* `TAX_YEAR` is constant 2023, but period end dates run into late 2024 (289 distinct).
* 9,095 organisations filed more than once for 2023 (568,214 returns, 558,700 distinct EINs).
* In concordance990, `_X` does not always mean checkbox (`..._FED_ASSURANCE_X` holds `FAL1`,
  `..._AUTENTICATED_X` `AAL1/AAL2`, `..._OOB_VERIFIED_X` `00/11`, `..._CUSTOMER_X` 0-3).
  `F9_00_GROUP_EXEMPT_NUM` is typed numeric but is a zero-padded code.
* `data_dictionary("F990")` has 18 repeated `variable_name`s (identical rows): `unique()` it first.
* For full-990-only (scope `PC`) variables a blank on a 990-EZ return means "not asked", even where
  `blank_meaning = implicit_false`. Recoding blanks to FALSE without checking scope would assert
  answers 208,863 filers never gave.

---

## 7. Merging this branch

This branch is cut from `origin/main` (`f5cd312`), so it fast-forwards onto `origin/main` cleanly
[verified with `git merge-tree`]. Nothing was pushed, and this branch lives in its own worktree, so
the working copy of `v7-stabilization-workflow` was not touched.

`v7-stabilization-workflow` has since gained four commits (`c3e11cf` .. `e7d936b`: reproducible and
parallel type guessing, `guess_n_sample = 300`, `is_factor()` arguments, the performance notes).
Merging this branch into it **conflicts in four files** [verified with `git merge-tree`, which
writes nothing]; each is a mechanical, additive conflict:

* `R/01-00-CREATE-DGF.R` — your `workers` / `guess_seed` / `guess_n_sample` arguments and this
  branch's `preflight` argument both extend the signature and the `@param` block.
* `R/01-06-guess-dgf-types.R` — this branch adds `.cap_bytes()` and calls it at the top of
  `.formex_guess()`. In your version, `.formex_guess_all()` (line ~138) calls
  `formex::guess_data_type` **directly inside the parallel worker**, bypassing `.formex_guess()`, so
  with `workers > 1` the long-text crash (B2) would return. Apply `.cap_bytes()` to the values once,
  in `.formex_guess_all()`, before they are dispatched to either path. (Not tested: the parallel path
  was not run.)
* `NEWS.md`, `man/create_dgf.Rd` — both sides add text in the same places.

`NAMESPACE`, `R/00-utils.R`, `R/01-03-*.R`, `R/01-05-retype-dgf.R`, `R/05-build-functions.R` and the
new files merge without conflict.

`.with_seed()` in the smoke test is independent of `guess_seed`. Files in this repo use CRLF in the
working tree (`core.autocrlf = true`); the diffs are small and clean.
