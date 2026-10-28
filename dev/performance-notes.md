# Dev notes — DGF build speed and guess quality

From: datagoodr · 2026-10-28
Re: profiling `create_dgf()` on `data-dev/bb.csv` (4,620 rows x 19 columns)

Measured on Windows 11, R 4.4.2, formex 0.0.0.9000, 14 cores.

The short version: **the `rg_*` data profiles are not the bottleneck.** They are
6.8% of a DGF build. Type guessing was 62.7%, effectively all of it inside
`formex::guess_data_type()`. Chasing that number also turned up a correctness
bug — the build was not reproducible — which is the more important finding of
the two.

The root cause in formex has since been found and fixed (§2): ~86% of its
per-call cost was the router, and most of *that* was input-independent work
recomputed on every single call. Net result, verified end to end:

| Frame | Before | After | |
|---|---|---|---|
| 19 cols, `workers = 1` | 9.92s | **5.72s** | 1.7x |
| 95 cols, `workers = 7` | 49.47s | **22.41s** | 2.2x |

**The written DGF is bit-identical before and after** (`identical()` on the
whole 19 x 43 data frame). One consequence to note up front: with the formex
fix in place, `workers` no longer buys anything on a narrow frame — see §3.

## 0. Method, and a warning about noise

Two passes: `Rprof(line.profiling = TRUE)` over a whole `create_dgf()` call, then
explicit `system.time()` per phase with every namespace pre-loaded, so one-time
package loading does not get charged to the phase that happens to trigger it.

**Timing noise on this machine is large.** The same 19-column guessing workload
measured anywhere from 4.88s to 6.31s across runs, and `create_dgf()` with
`workers = 1` came in at 7.54s, 8.48s, and 10.56s in different sessions. A
single-run difference under about 20% is not an effect. Everything claimed below
is either a median over repetitions or a difference large enough to survive that
spread; where a number is a single run, it says so. One hypothesis in §4 died
exactly this way, after a first run suggested a 15% win.

### Phase breakdown (warm namespaces, single run, 9.89s total)

| Phase | Time | Share |
|---|---|---|
| `guess_dgf_types` (formex) | 6.20s | **62.7%** |
| `recast_factors` / `is_factor` | 0.81s | 8.2% |
| `get_stats` | 0.49s | 5.0% |
| `get_graphics` | 0.18s | 1.8% |
| `get_examples` (preview) | 0.11s | 1.1% |
| `write .xlsx` | 0.09s | 0.9% |
| `get_properties` | 0.04s | 0.4% |
| `dgf_v7_stabilizer_columns` | 0.04s | 0.4% |
| column hashing | 0.02s | 0.2% |

The profiles — `get_stats` + `get_graphics` — are **0.67s, 6.8%**.

### A cold-profile trap worth recording

The first `Rprof` run blamed `00-utils.R#36` (`need_pkg()`'s `requireNamespace`)
for 22.7% and the `kableExtra::spec_hist` line in `get_stats_chr()` for 13.3%.
Both are **one-time namespace and graphics-stack loading**, not per-column work.
Warm, `need_pkg()` costs 0.000s and `spec_hist()` about 0.01s per call. Neither
is worth optimizing; a profile of a DGF build must warm the namespaces first or
it will send you after the wrong thing.

## 1. datagoodr fixes

### 1.1 Done

**Reproducibility: fixed seed for the type guess.** `formex::guess_data_type()`
draws its sample from the session RNG. Left alone, the same data produced
different types on different runs. Measured over four runs of bb.csv:

| Column | Run 1 | Run 2 | Run 3 | Run 4 |
|---|---|---|---|---|
| `weight` | number, 0.448 | number, 0.399 | number, 0.357 | number:quantity:measurement, 0.550 |
| `AVG` | number:quantity:measurement, 0.736 | …, 0.765 | **text:web:domain, 1.000** | …, 0.664 |
| `AB` | identifier, 0.253 | number, 0.290 | number, 0.281 | number, 0.368 |

These reached `desired_data_type` in the written DGF: across three builds
`nameLast` moved text → categorical and `AB` categorical → text. `create_dgf()`
now takes `guess_seed`, defaulting to `1`; `guess_seed = NULL` restores the old
behaviour. Verified: two builds under different session RNG states produce an
identical data frame and an identical CSV md5.

**Hoisted the formex calls out of the decision loop** into `.formex_guess_all()`
(`R/01-06-guess-dgf-types.R`). The per-column decision logic was already pure
bookkeeping; only the guess itself is worth distributing. `create_dgf(workers =)`
spreads it over a PSOCK pool. Medians:

| Frame | `workers = 1` | parallel | Speed-up |
|---|---|---|---|
| 19 cols | 10.56s | 5.48s (`workers = 7`) | 1.9x |
| 95 cols | 47.01s | 21.04s (`workers = 7`) | 2.2x |

Sub-linear because each worker re-pays formex's ~0.81s first-call warm-up, so
the pool only pays off once there are enough columns to amortise it. Default is
`workers = 1`; behaviour is unchanged unless asked for. With `guess_seed` fixed,
parallel and serial results are **identical** — verified column by column and on
the whole assembled DGF.

> **Superseded for narrow frames.** These numbers are against the *old* formex.
> Once the §2 fix ships, `workers` is a wash at 19 columns and worth only ~1.4x
> at 95 — the single-process build is already as fast as the old parallel one.
> See §3, "The formex fix largely supersedes `workers`". The plumbing is still
> worth keeping for wide frames.

**`is_factor(verbose =)`.** `is_factor()` built `paste0`/`table` diagnostic
strings for every column, and `is_factor_df()` then discarded them through
`capture.output()`. Shadowing `cat` with a no-op leaves those arguments as
unforced promises, so on the quiet path the strings are never built. Also
de-duplicated a `table(x)` that ran twice over the full column (0.25s → 0.11s
across 19 columns). Worth ~0.2s of the 1.0s — smaller than first estimated, and
the comment in the source was corrected to say so. Decision output verified
identical to the verbose path.

### 1.2 Remaining, in priority order

1. **`hablar::retype()` is 0.59s of the 0.66s left in `is_factor_df()`** — called
   once per column on the full vector, to reach the "only test integers" branch.
   The integer/variance/sequence tests below it depend on exactly what it
   returns, so replacing it with a cheap base-R numeric probe risks silently
   changing typing decisions. Needs a deliberate decision plus a before/after
   type comparison over several datasets, not a perf patch.
2. **Decide the `guess_n_sample` default** (see §3). Currently left at formex's
   100, which is knowingly unstable for any column with more than 100 distinct
   values.
3. **Cache the guess across rebuilds.** formex has no internal memoisation — the
   same column guessed twice costs 0.380s both times. `refresh_dgf()` /
   `update_dgf()` re-guess columns whose values have not changed, and
   `prov_current_hash` is already computed per column in `create_dgf()`. Keying a
   guess cache on that hash plus `n_sample` and the formex version would make
   rebuilds near-free. Only sound now that the guess is deterministic.
4. **Pre-load the suggested namespaces once** at the top of `create_dgf()` rather
   than discovering them through `need_pkg()` mid-profile. Costs nothing at
   runtime; it just stops the first profile anyone runs from blaming the wrong
   function (see §0).

## 2. formex fixes

Root cause found and fixed in the formex **source checkout**
(`00-GITHUB/formex`, 5 files, +123/-11). Not committed, and the **installed copy
is untouched** — see §6 before expecting any of this in a normal session.

### 2.0 Where the per-call floor actually went

A 10-value input cost ~130ms. Broken down on `as.character(1:10)`:

| Component | ms | Share |
|---|---|---|
| **verifier leak loop over `.FX_FOIL`** (24 constant strings) | **50** | **38%** |
| **verifier confirm loop** (21 ontology rows / 16 distinct recipes) | **34** | **26%** |
| **router `.fx_shortlist`** | **28** | **21%** |
| …`fx_extract_features` | 25 | 19% |
| ……`.finalize` → `as.data.frame()` on a 477-element list | 15 | 11% |
| …`xgboost::predict` | 2.7 | 2% |
| `score_data_type` (88 detectors) | 19 | 14% |
| …of which `is_date` | ~9 | 7% |
| `fx_ontology()` re-reading the 43 KB CSV | 3 | 2% |

`route = TRUE` is **86%** of the floor — the earlier 75% estimate, re-measured
at the floor rather than on real columns.

**Why `strptime` was so hot.** `.DATE_FORMATS` holds **730** formats (146 genome
cores x 5 time suffixes), built once at load — that part was fine. The problem
was the loops: `is_date()` and `.fx_parse_iso_date()` iterate formats and only
stop once *every* value has parsed, so a column that is **not** a date pays all
730 `strptime` calls. And that ran **three times per call**: once in `is_date`,
then twice more over the 24-value foil. `.fx_parse_iso_date(.FX_FOIL)` alone was
14ms, and nothing in the foil is a date.

**The headline insight:** the two verifier loops — 64% of the floor — were
largely recomputing *input-independent* values. The leak rate is
`.fx_confirm_rate(.FX_FOIL, expr)`: a pure function of a constant and a recipe
string, recomputed ~20 times per call, forever.

### 2.1 Fixes made

| # | File | Change |
|---|---|---|
| a | `dt-date-flex.R`, `20-fx-stabilize.R` | **Date-format pre-filter.** Two *necessary* conditions drop formats that cannot parse any value: a format with a literal `":"` needs a `":"` in the value; one with `%b`/`%B`/`%p` needs an ASCII letter. 730 → 146 formats for a colon-free column, → **48** with neither colons nor letters. Survivors keep their original order, so *which* format wins a value is unchanged. |
| b | `02-01-guess-data-type.R` | **Foil-leak memo + confirm de-duplication.** Leak rate cached per recipe string in a namespace env; the column confirm runs once per *distinct* recipe (`{{ none }}` alone covered 4 rows). Leak loop **50ms → 0ms** after the first call of a session. |
| c | `10-fx-features.R` | **`.finalize()` fast one-row data frame.** Builds it directly when the names are already syntactic and unique — which they always are, being generated internally — falling back to `as.data.frame()` otherwise. 25ms → 15ms. |
| d | `12-fx-testcase.R` | **Cache the ontology's own example signatures.** `shortlist_candidates()` recomputed `fx_type_signature()` for ~95 ontology `examples` on every call. Keyed on the `examples` column, so an edited ontology recomputes. This is what made the model-free signature router unusable as a fallback. |

Delimiters are deliberately **not** filtered in (a): a literal `" "` in a format
matches *zero* whitespace — `strptime("20200315", "%Y %m %d")` parses — so a
delimiter filter would have been wrong. Verified directly.

### 2.2 Verification (re-run independently, not taken on trust)

Against a pristine `git archive HEAD` tree in a separate process:

| Workload | Before | After | |
|---|---|---|---|
| 19 bb columns | 7.28s [7.06-7.64] | 3.26s [3.23-3.30] | **2.2x** |
| per-call floor | 199ms [192-229] | 69ms [66-75] | **2.9x** |
| `router = "signature"`, warm | 1.66s | 0.18s | 9.2x |

Rep ranges do not overlap, so these survive the §0 noise bound.

- **`identical()` on all 19 bb columns under both `router = "auto"` and
  `router = "signature"`: TRUE.** Field-level pass over all route fields plus
  `guess`: 0 diffs. End-to-end `create_dgf()` DGF: identical.
- **The pre-filter, exhaustively**: 0 of 584 colon-bearing formats parse any of
  16 colon-free values; 0 of 586 alpha-requiring formats parse any of 15
  letter-free values (including `13:45`, `1:2:3`, `2020-03-15 13:45:30`); and
  4,123 random probes compared filtered vs unfiltered gave **0 mismatches**.
- **formex's own suite: 883 pass, 0 fail, 0 skip** (before and after).

**One real behavioural side effect.** formex's suite went from 38 warnings to 2.
These are all `"NAs introduced by coercion to integer range"` from the
`as_integer` verb. Because the leak is now cached and the confirm de-duplicated,
that recipe runs **once per session** instead of once per candidate row per call
— same text, same returned values, just emitted far less. datagoodr muffles this
warning by message in `.formex_guess()` anyway, but anything that *counts* these
warnings will see fewer.

### 2.3 Found but not fixed

1. **`fx_ontology()` re-reads and parses the 43 KB CSV per call** (~3ms, 2%).
   Caching it is trivial but **changes semantics** — editing
   `research_data_type_ontology_v6.csv` mid-session would stop being picked up,
   which matters for the ontology-authoring workflow. A cache keyed on the
   file's `mtime` + size would preserve that; worth doing, needs a decision.
2. **`fx_extract_features` is now ~15ms of genuine block work** and is the
   largest remaining slice. `fx_blocks_for_features()` already exists to compute
   only the blocks a model references, but the artifact's `medians` were fitted
   with all blocks present, so skipping blocks would silently substitute medians
   for real values and **could change predictions**. Needs a retrain or a
   verified feature-to-block audit. Not a safe win.
3. **The ~18ms confirm loop is genuinely input-dependent** — recipes must run on
   the actual column. Could be cut further with per-recipe applicability gates
   (skip the date genome when a column has no digits at all), but that is
   detection *logic*, not caching.
4. **The three new caches are session-scoped with no invalidation hook**, except
   the ontology one (keyed on its input). The leak cache is keyed on the recipe
   string, so hot-patching a verb in `.fx_verbs()` mid-session would leave stale
   leak rates. Low risk, worth knowing.
5. **Still no cross-call memoisation of the guess itself** (§1.2 item 3). The
   same column guessed twice still costs the same twice; only the
   input-independent *internals* are now cached.

### 2.4 `n_sample = 100` is too small, and makes confidence a coin flip

**Not addressed by the speed work** — this is a quality issue and is still open.

The sample is drawn from the **distinct** values, so the rule is exact:

> **confidence is stable if and only if `n_sample >= n_distinct`.**

Standard deviation of confidence over 5-6 seeds:

| Column | distinct | `n_sample = 100` | `n_sample = n_distinct` |
|---|---|---|---|
| `bats` | 3 | 0.0000 stable | 0.0000 stable |
| `height` | 18 | 0.0000 stable | 0.0000 stable |
| `weight` | 111 | 0.0544 | 0.0000 stable |
| `birthState` | 210 | 0.1631 | 0.0000 stable |
| `AB` | 581 | 0.0780 | 0.0000 stable |

Below that line the reported confidence is a sample statistic, so **any column
sitting near `route_threshold` is decided by the draw.** `birthState` spans
0.631-0.905 at 100, straddling the 0.8 acceptance threshold; at 300 it is a flat
0.813 and correctly resolves to `mutually_exclusive.geographic` instead of
falling back to `text`. Raising it also clears `AVG`'s spurious `web.domain`
class.

**Ask:** (a) treat confidence as an estimate and report its sample size, or (b)
default `n_sample` to something adaptive like `min(n_distinct, cap)` so a column
is either exhaustively checked or honestly flagged as sampled. A fixed 100 is
the worst of both.


## 3. Better default settings

| Setting | Current default | Recommendation | Evidence | Risk if changed |
|---|---|---|---|---|
| `guess_seed` | `1` (**changed**) | keep `1` | builds were not reproducible; §1.1 | shifts guessed types vs. whatever the last unseeded run happened to roll |
| `guess_n_sample` | `NULL` → formex's 100 | **raise, probably to 300** | confidence unstable whenever `n_sample < n_distinct`; §2.4 | changes guessed types in every existing DGF; +1.2s on bb.csv, more on high-cardinality columns |
| `workers` | `1` | **keep `1`** once the formex fix ships; raise only for wide frames | see table below | none — results are identical with a fixed seed |
| `route_threshold` | `0.8` | leave until §2.4 is settled | the threshold is fine; the *confidence* feeding it is the unstable part | — |
| `is_factor(verbose)` | `TRUE` | `TRUE` (public API unchanged) | `is_factor_df()` passes `FALSE`; §1.1 | none |

All three new knobs also read options, so a project can set them once:
`options(datagoodr.workers = 7, datagoodr.guess_n_sample = 300)`.

### The formex fix largely supersedes `workers`

This is the one recommendation that changed once §2 landed. Medians over 3 reps:

| Frame | formex | `workers = 1` | `workers = 7` | parallel still worth it? |
|---|---|---|---|---|
| 19 cols | before | 9.92s | 5.82s | yes, 1.7x |
| 19 cols | **after** | **5.72s** | 5.79s | **no — a wash** |
| 95 cols | before | 49.47s | 22.27s | yes, 2.2x |
| 95 cols | **after** | 30.33s | **22.41s** | yes, but only 1.4x |

Once guessing is ~2.2x cheaper, a 19-column build is dominated by the phases
that were never the problem (profiles, factor recasting, IO ~3.7s), and the
pool's start-up cost cancels the remaining gain. Keep `workers = 1` as the
default; it is now only worth raising on genuinely wide frames, and even there
the margin has shrunk. **Do not drop the `workers` plumbing** — it is what makes
a 200-column frame tolerable, and it cost nothing to keep.

**On `guess_n_sample`, the recommendation is to raise it but the call is not
mine to make**: it is a quality-for-time trade that shifts types in every DGF
already written. 300 covers the great majority of real columns exhaustively
(bb.csv: 15 of 19), and the two columns it changes here both change for the
better. The adaptive form — `min(n_distinct, cap)` — is better still but belongs
in formex (§2.4). Note the formex speedup buys headroom for exactly this: the
time it frees is roughly what raising `n_sample` to 300 costs.

## 4. Measured and rejected

Recording these so nobody re-runs them.

**Hoisting `detectors = data_type_detectors()` out of the default argument.** A
first paired run showed 6.00s → 5.12s, "15% faster", with identical results. It
is **noise**. Over 5 paired reps the sign reverses: default median 4.97s
(4.88–5.39), hoisted median 5.50s (5.25–6.00). There is also no mechanism —
`data_type_detectors()` costs 0.0004s and is called once per `guess_data_type()`.
Dropped.

**Row subsampling before the guess.** Pointless: cost is flat in row count
(§2.1), because formex reduces to `n_sample` distinct values before doing
anything expensive.

**Pre-processing columns into capped unique-value samples before calling
formex.** Worth recording in full, because the reasoning is sound and the
conclusion is still no — formex already does this internally:

```r
u <- unique(x)
uniq <- if (length(x)) length(u)/length(x) else NA_real_   # computed BEFORE sampling
if (length(u) > n_sample) { if (!is.null(seed)) set.seed(seed); u <- sample(u, n_sample) }
```

- **It is lossless.** Passing `unique(x)` instead of the full column gave
  identical results on all 19 bb.csv columns (`n_sample` set high so no sampling
  occurred). formex only ever sees distinct values.
- **It does give determinism without a seed.** `head(unique(x), 300)` with
  `n_sample = 300` makes `length(u) > n_sample` false, so `sample()` never runs —
  identical across 4 RNG states. Note the cap must *equal* `n_sample`: capping at
  300 while leaving `n_sample = 100` still samples, and is still nondeterministic.
- **But it saves no time.** 19 columns: full column 5.04s vs capped-unique 5.57s
  (within noise, if anything slower). `unique()` for all 19 columns costs ~0.000s.
  There is nothing to save, because the expensive work happens *after* formex's
  own reduction. Raising `n_sample` to 300 doubles the time (5.04s → 10.03s) —
  more distinct values means more detector work, whoever does the de-duplicating.
- **And `head()` introduces order bias.** It changed the answer on 6 of 19
  columns versus using all distinct values. bb.csv is sorted by player name, so
  the first 300 distinct surnames all begin with "A": `nameLast` became *more
  confidently* geographic (0.53 → 0.82), which is more confidently wrong.
  `SLUG` dropped 0.74 → 0.66. Two changed for the better (`nameFirst` gained
  `name/person`, `AB` lost a bogus `icd9_code` guess), which is the point —
  the effect is arbitrary.

**Conclusion:** a fixed `seed` is the better determinism lever than capping,
because it keeps the sample random (hence unbiased) while making it repeatable.
Keep the preprocessing idea only as the fallback if formex ever stops accepting
a seed. The one genuinely useful variant is **raising `n_sample` above
`n_distinct`**, which is §2.4 — and that is a formex default, not a
preprocessing step.

One caveat for whoever revisits this: `uniq` (the distinct ratio, computed from
the **full** column before sampling) is passed on to the router, so
de-duplicating does discard a signal. Measured, it barely matters today — across
the 19 bb.csv columns and four synthetic cardinality-sensitive cases (state
codes, small integer codes, yes/no, years), de-duplicating never changed the
resolved route, and changed confidence only once (`small_ints`, 0.9857 →
0.9889). But the signal is wired in, so this is a contract question for formex
rather than something to rely on.

## 5. Reproducing

```r
pkgload::load_all(".")
bb <- read.csv("data-dev/bb.csv", colClasses = "character", check.names = FALSE)

# phase timing — warm the namespaces first, or see §0
invisible(lapply(c("psych","htmltools","kableExtra","hablar","formex","openxlsx","DescTools"),
                 requireNamespace, quietly = TRUE))
system.time(create_dgf(bb, dir = tempdir(), file = "bench", open = FALSE))
system.time(guess_dgf_types(bb, rep("text", ncol(bb))))

# the per-call floor
system.time(for (i in 1:20) formex::guess_data_type(as.character(1:10), name = "v"))

# the n_sample stability rule
v <- as.character(bb$birthState)                    # 210 distinct
sd(sapply(1:6, function(k) { set.seed(k * 37)
  formex::guess_data_type(v, name = "s", n_sample = 100)$route$confidence }))   # ~0.16
sd(sapply(1:6, function(k) { set.seed(k * 37)
  formex::guess_data_type(v, name = "s", n_sample = 300)$route$confidence }))   # 0
```

The working scripts for every measurement above are in this session's scratchpad
rather than the repo; the snippets here are enough to re-derive each number.

## 6. Deployment state

**Installed 2026-10-28.** `devtools::install()` from the formex checkout; the
library copy now carries all four fixes, so an ordinary `library(formex)` /
`create_dgf()` run gets them with no `load_all()` needed. Confirmed against the
installed namespace: `.date_formats_for`, `.fx_foil_leak`, `.fx_rate_by_recipe`,
`.fx_example_sigs`, `.DATE_FORMAT_SUBSETS` all present, and the pre-filter cuts
730 formats to 48 for a digits-only column.

**Shipped 2026-10-28.** Commit `3d812d2`, 5 files, +123/-11
(`R/02-01-guess-data-type.R`, `R/10-fx-features.R`, `R/12-fx-testcase.R`,
`R/20-fx-stabilize.R`, `R/dt-date-flex.R`), fast-forward merged to `main` and
pushed to `lecy/formex`. `main` == `origin/main` == `3d812d2`, tree clean, and
the installed build is that same source — so a fresh
`devtools::install_github("lecy/formex")` now gets the speedup, and reinstalling
here no longer reverts it.

### Post-install, measured through the ordinary library path

| | Old formex | Installed |
|---|---|---|
| `create_dgf()`, 19 cols, `workers = 1` | 9.92s | **6.86s** [6.28-7.06] |
| `create_dgf()`, 19 cols, `workers = 7` | 5.82s | 6.07s |
| `guess_dgf_types()` alone | 6.20s | **3.59s** |
| formex per-call floor | ~130ms | **71ms** |

- **The baseball DGF is byte-identical** to the one built against the old
  formex (same CSV md5, `ac70c471…`), and still reproducible across RNG states.
- **datagoodr's suite: 554 pass, 0 fail, same 4 CRAN-gated skips** before and
  after — including `test-formex-seam.R`, which asserts directly on formex
  behaviour.
- `workers = 7` is again no better than `workers = 1` here, confirming §3.

To A/B against a different formex without installing, `pkgload::load_all()` the
checkout *before* loading datagoodr — `formex::` then resolves to that tree:

```r
pkgload::load_all("C:/Users/jdlec/Dropbox/00 - URBAN/00-GITHUB/formex")
pkgload::load_all(".")   # datagoodr
```

A pristine `git archive HEAD` tree plus the before/after snapshots used for the
§2.2 equivalence checks are in this session's scratchpad, not the repo.

### Suggested order of work

1. ~~Install the formex fix.~~ **Done 2026-10-28** (§6). Still to do:
   **commit the five formex files** — the installed build is ahead of formex's
   git HEAD, so a clean reinstall would silently revert the speedup.
2. **Decide `guess_n_sample`** (§2.4, §3). The quality question, now affordable.
3. **Guess cache keyed on `prov_current_hash`** (§1.2 item 3) — makes
   `refresh_dgf()` / `update_dgf()` near-free. Only sound because the guess is
   now deterministic.
4. **`fx_ontology()` mtime-keyed cache** (§2.3 item 1) — small, needs the
   semantics decision.
5. **`hablar::retype()` in `is_factor()`** (§1.2 item 1) — the last real
   datagoodr-side cost, but it can change typing, so it needs a type-diff
   harness across several datasets first.
