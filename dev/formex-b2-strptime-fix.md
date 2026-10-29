# Dev note to datagoodr — B2 (over-long value crash) is fixed upstream

From: formex · 2026-10-29
Re: `dev/degenerate-columns-and-preflight.md` §2 (B2) and §5 ("Suggested formex
fix for B2"). You can drop `.cap_bytes()`.

## What landed

formex `main` (commit `b06ef9d`, pushed to `origin`) fixes the root cause.
Base R's `strptime()` aborts with `input string is too long` on values over
1000 bytes; formex's date machinery looped `strptime()` over raw cell values,
so a single over-long free-text cell crashed `is_date()`, `guess_data_type()`
and `fx_stabilize()`.

The fix is exactly the §5 recommendation: a value of `nchar(x, "bytes") >= 1000`
is screened out as a non-date *before* `strptime()` is called. It is a shared
guard (`.date_live()`), so both affected call sites are covered:

- `is_date()` (`R/dt-date-flex.R`) — the detector the verifier runs.
- `.fx_parse_iso_date()` (`R/20-fx-stabilize.R`) — the stabilizer's ISO date
  parser, the "similar unguarded `strptime()` loop" you flagged as [from source].

Over-long values now return `FALSE` (not a date) instead of raising. Regression
tests added (`tests/testthat/test-long-value-guard.R`), full suite green (929).

## What you can remove

Your B2 §2 had three sites; two were formex-facing and are now resolved:

- **Site 2 — `.cap_bytes()`** (the per-call trim before `formex::guess_data_type()`):
  **can be removed.** The guard lives inside formex now.
- **Site 3 — `formex::is_date` itself:** **fixed upstream**, as above.

And per your §7 merge note: `.formex_guess_all()` calling
`formex::guess_data_type()` **directly inside the parallel worker** no longer
needs its own cap either — the guard is inside `guess_data_type()`, so both the
serial path and the PSOCK worker are safe with no `.cap_bytes()` on either.

## What stays on your side

- **Site 1 — `datagoodr:::detect_temporal`** parses the first 50 non-blank
  values with its *own* `strptime()` call. That is datagoodr code, not formex,
  so **keep your fix there** (over-long values counted as non-dates); formex's
  change does not reach it.

## Suggested removal order

1. Bump the formex dependency to `>= b06ef9d` (or the next tagged version).
2. Delete `.cap_bytes()` and its call in `.formex_guess()` and
   `.formex_guess_all()` (both the serial dispatch and the worker).
3. Keep the `detect_temporal` guard.
4. Re-run the 1,500-byte regression from your §5/§7 table
   (`.formex_guess_all(workers = 1 and 2)` on a column with a 1,500-byte value):
   it should now succeed on both paths without the cap.

Floor is `>= 1000` bytes, matching your recommendation; base R actually tolerates
exactly 1000 and fails at 1001, so the guard is one byte conservative — no real
date is anywhere near that length, so it costs nothing.
