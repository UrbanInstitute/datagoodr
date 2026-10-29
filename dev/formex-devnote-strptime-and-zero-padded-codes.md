# Dev note to formex — a length crash, silent loss of leading zeros, and warning noise

From: datagoodr · 2026-10-29
Re: formex `main` at `7fcf2f5`, found while building a DGF for the IRS 990 tax-year-2023 e-file
panel (P00 + P01 + P08: 568,214 returns x 196 columns)

**Evidence labels.** **[verified]** = reproduced by running it against formex `7fcf2f5` (installed
from `main`). **[from source]** = read in the code, not executed. Every claim in §1 and §3 is
verified; in §2 the verb behaviour is verified and the end-to-end plan was not run (see there).

**Update, later on 2026-10-29: F1 is fixed in formex; F2 and F3 are still open.** formex `main`
now carries `b06ef9d` (*Guard date parsing against >=1000-byte values*), which is the one-line guard
suggested in §F1 (see `dev/formex-b2-strptime-fix.md`). I re-ran the F1, F2 and F3 checks below
against formex `main` at `ca82926`, loaded read-only with `pkgload::load_all()` **[verified]**:

| check | `7fcf2f5` (this note was written against) | `ca82926` (formex `main` now) |
|---|---|---|
| F1 `is_date(c(<1,500-byte value>, "2020-01-15", NA, "x"))` | ERROR | `FALSE TRUE NA FALSE` |
| F1 `.fx_parse_iso_date(c(<1,500-byte value>, "2020-01-15"))` | ERROR | `NA "2020-01-15"` |
| F1 `guess_data_type()` on long + dates, and on long text only | ERROR, ERROR | OK, OK |
| F2 `as_number` / `as_integer` on `c("0155","0925","00","11")` | `155 925 0 11` | `155 925 0 11` (unchanged) |
| F3 warnings from `guess_data_type()` on 400 large integers | 1 | 2 (same message) |

The installed formex in the personal R library is still `7fcf2f5`, so a datagoodr build there still
needs `.cap_bytes()` until formex is reinstalled. The F1 text below is left as written, as the record
of what was found and how the fix was checked.

Three things belong to formex. They are ordered by how much they cost us. datagoodr works around
the first and guards against the second at its own seam, so none of this is blocking, but each
workaround is code we would like to delete.

| # | Problem | Cost | datagoodr workaround |
|---|---|---|---|
| F1 | `strptime()` aborts on any value over 1000 bytes (3 entry points) — **fixed in formex `b06ef9d`** | `create_dgf()` died minutes into a build, with an error that names no column | `.cap_bytes()` trims values before the call into formex |
| F2 | the numeric verbs turn `"0155"` into `155` with no signal | a group exemption number and a `00`/`11` code were typed `number` and lost their zeros | `.lossy_as_number()` refuses the conversion (branch `fix-zero-padded-codes-typed-number`) |
| F3 | `guess_data_type()` emits `NAs introduced by coercion to integer range` on large integers | one warning per large-number column on a wide frame | muffled by message in `.formex_guess()` |

---

## F1. `strptime()` aborts on values over 1000 bytes — fixed in formex `b06ef9d` (text below is the original finding)

Base R's `strptime()` raises `input string is too long` on any input **longer than 1000 bytes**
(**[verified]**: 1,000 bytes parses, 1,001 fails). formex hands it raw cell values with no length
check. Free-text fields (a reasonable-cause narrative, a mission statement) routinely exceed that:
in this file 1,609 rows hold a value of 1,000 bytes or more, the longest 8,985 bytes.

**[verified]** against `7fcf2f5`, with free text of the stated length:

| call | result |
|---|---|
| `is_date(<1,000-byte value>)` | `FALSE` (no error) |
| `is_date(<1,001-byte value>)` and `is_date(<1,500-byte value>)` | **ERROR: input string is too long** |
| `is_date("2020-01-15 zzz...")`, 1,000 bytes / 1,111 bytes | ok / **ERROR** (a leading date does not help) |
| `guess_data_type(c(<1,500-byte value>, <30 dates>))` | **ERROR** |
| `guess_data_type(<1,500-byte text only>)` | **ERROR** |
| `formex:::.fx_parse_iso_date(<1,500-byte value>)` | **ERROR** |

So a public entry point (`guess_data_type()`) fails on ordinary free text. This is the same result
as the 2026-10-28 check against `3d812d2`; the speed-up and the template commits since did not
change it.

**Where.** Two loops call `strptime()` on the normalised input, and both start from
`.date_norm_input()` (`R/dt-date-flex.R:91`):

* `is_date()` — `R/dt-date-flex.R:134`, reached from `guess_data_type()`;
* `.fx_parse_iso_date()` — `R/20-fx-stabilize.R:75`, the stabilizer's date verb.

**Suggested fix (one line, in the shared helper).** A value that long cannot be a date, so blank it
before parsing:

```r
.date_norm_input <- function(x){
  x <- trimws(as.character(x))
  x[!is.na(x) & nchar(x, type = "bytes") >= 1000L] <- NA_character_   # cannot be a date; never reaches strptime()
  ...
```

(The exact limit is "over 1000", so `>= 1000L` also blanks the 1,000-byte value, which is harmless:
no date is that long. `> 1000L` is the exact form; the patch tested below used `>= 1000L`.)

**[verified]** by patching `.date_norm_input` in a scratch session (formex repo untouched):

* `is_date(c(long, "2020-01-15", NA, "x"))` -> `FALSE TRUE NA FALSE` (long is `FALSE`; `NA` stays `NA`);
* `.fx_parse_iso_date(c(long, "2020-01-15"))` -> `NA "2020-01-15"`;
* `guess_data_type()` on long + dates and on long text only both return a result;
* `is_date()` on a mixed ordinary vector (ISO, `05/Mar/2016`, `March 5, 2016 2:00 PM`, `20160305T14:00:00Z`,
  `"banana"`, `"12345"`, `NA`) is **identical** with and without the patch.

Please add a regression test: `is_date()`, `guess_data_type()` and the date verb each on a vector
containing a 1,500-byte string. Once this lands, datagoodr deletes `.cap_bytes()` (the "Remove once
formex guards the length itself" comment in `R/01-06-guess-dgf-types.R`).

*Not covered by the one-liner:* any other `strptime`/`as.Date(x, format=)` call that does not go
through `.date_norm_input()`. `R/22-fx-transform-path.R:135` calls `as.Date(x)` without a format and
was **not** tested [from source].

---

## F2. The numeric verbs drop leading zeros silently

`as_number` and `as_integer` (`R/20-fx-stabilize.R`, `.fx_verbs()`) read a value with `.fx_num()`
and write it back with `as.character(...)`. For a zero-padded code the round trip succeeds and the
zeros are gone, and nothing marks the result as lossy.

**[verified]**: `as_number` and `as_integer` on `c("0155", "0925", "00", "11")` both return
`155 925 0 11`.

**What this did in a real build.** In this file `F9_00_GROUP_EXEMPT_NUM` is a four-digit code with
leading zeros (`0155`, `0237`; 643 of the 1,348 non-blank values in a 30,000-row sample start with
a zero) and `F9_00_IRS_TRUST_OOB_VERIFIED_X` holds only `00` and `11`. formex routes both to
`quantity`:

| column | route (`guess_data_type`, seed 1) | depth | confidence |
|---|---|---|---|
| `F9_00_GROUP_EXEMPT_NUM` | quantity / measurement | 3 | 0.51 |
| `F9_00_IRS_TRUST_OOB_VERIFIED_X` | quantity / count | 3 | 0.63 |

datagoodr then planned a stabilizer to a number, the verb converted every value without an `NA`, and
datagoodr's "everything converted" check accepted it. Both columns came out typed `number`. (The
check was datagoodr's bug, fixed on the branch named above. The verb is formex's.)

Which build did what **[verified from the 2026-10-28 `type_audit.csv` and logs]**:
`F9_00_IRS_TRUST_OOB_VERIFIED_X` was already typed `number` then (stabilizer `ready`; this is B10 in
`dev/degenerate-columns-and-preflight.md`). `F9_00_GROUP_EXEMPT_NUM` was `text` with stabilizer
`identity`, and became `number` only with the updated packages — so that one is a regression, and
the cause is somewhere in the route/stabilizer-planning change between formex `8978cc0` and
`7fcf2f5` **[inferred, not bisected]**.

Two asks, in order of value:

1. **Make the verbs lossy-aware.** `as_number` / `as_integer` should return `NA` (or flag the plan as
   not `applied`) for a value that is a plain digit string with a leading zero, or an integer past
   2^53. datagoodr already has the predicate (`.safe_numeric()`): a plain number is unsafe if it is
   a leading-zero integer (`^-?0[0-9]`) or has more than 15 integer digits. A single shared rule on
   both sides would keep them from disagreeing. The datagoodr comment on the storage-safety gate
   (`R/01-06-guess-dgf-types.R`, "formex's v6 router misroutes zero-padded numeric keys") records
   the same failure in the router, measured on 2026-08-22 for county/state FIPS and ZIP codes; this
   is the stabilizer-side twin of it.
2. **Route a zero-padded code away from `quantity`.** The two columns above sit at depth 3 with
   confidence 0.51-0.63, below datagoodr's 0.8 bar, so the route itself was not adopted as the
   column's type; the stabilizer was planned from that lower-confidence guess regardless. Worth
   checking why a plan is built from a guess the router does not trust.

**Not verified.** I tried to run the full plan (`fx_plan_transform()` -> `fx_apply_plan()`) on the
real column in isolation; my call used the wrong argument type (`inherits(from, "fx_format")` failed)
and I did not retry, so the plan-level behaviour is inferred from the verb result plus the type the
build produced, not run directly.

---

## F3. Coercion warning on large integers

`guess_data_type()` on 400 integers around 5e9 emits one warning (two on formex `ca82926`), `NAs introduced by
coercion to integer range` **[verified]**. The likely source is the `as_integer` verb
(`R/20-fx-stabilize.R:86`: `as.character(as.integer(round(v)))`), a probe that is *supposed* to fail
for a non-integer candidate **[from source; I did not trace the call]**. Profiling a wide frame emits it once per large-number column.
datagoodr muffles it by message in `.formex_guess()`.

Suggested: test the range before coercing (`abs(v) > .Machine$integer.max` -> `NA`), which also makes
the probe's intent explicit and removes the need for the muffle.

---

## What we did not check

* formex's own test suite (not re-run here).
* Whether the F1 patch changes the **speed** of `guess_data_type()` — it adds one `nchar()` per call.
  Not measured.
* The parallel `workers` path in datagoodr, which calls `formex::guess_data_type()` directly. It
  reaches the same crash unless the values are capped first (datagoodr caps once in
  `.formex_guess_all()`).

## Where the datagoodr side lives

* `R/01-06-guess-dgf-types.R` — `.cap_bytes()` (F1), `.formex_guess()` message muffle (F3)
* `R/00-utils.R` — `.safe_numeric()`, `.lossy_as_number()` (F2)
* `R/01-00-CREATE-DGF.R` — `.align_profile_types()`, where the F2 guard sits
* `dev/degenerate-columns-and-preflight.md` §5 — the earlier F1 check against `3d812d2`
