# Working Example

A CSV has no schema. Whether `201912` is a date, `36081001900` a geography ID, or
`27244` a dollar amount is invisible to whoever opens the file next — every tool
guesses, and they guess differently. `datagoodr` fixes this by pairing the data
with a **Data Governance File (DGF)**: one row per variable recording how the
data is stored, how it should be read, and what it means.

This folder contains two runnable examples.

## The main walkthrough — `walkthrough.R`

One script, end to end, on a real (slightly messy) IRS nonprofit extract
(`data-dev/DEMO-DATA-SMALL.csv`). Run it from the package root:

```r
Rscript working-example/walkthrough.R
```

It moves through the rule-based workflow — three stages (`raw_` → `stable_` →
`desired_`) joined by two rule bridges:

1. **Create the DGF.** `create_dgf()` profiles every column, runs the detector
   library over it, and writes `DGF.csv` / `DGF.xlsx` with a first guess at each
   variable's type, subtype, class, key flags, and the `rg_` render profile.
2. **Correct the guesses R can't make from data alone.** `retype_dgf()` fixes
   the semantic calls the bytes don't reveal — the `YYYYMM` tax-period columns
   are monthly **dates**, not categories; the 11-digit census tract is an
   **identifier**, not a number — and re-profiles just those variables so the
   stored graphic matches the corrected type.
3. **Add semantic context.** Set the `desired_*` fields (subtype / class) to say
   what each column *is*, independent of storage.
4. **Reformat to a governed CSV.** Drop `as_*` rule names in
   `raw_to_stable_transform`; `stabilize_data()` applies them (each guarded by
   its `is_*` detector) and `write_stable_csv()` writes a self-describing CSV
   with an embedded, portable copy of the DGF.
5. **Validate & render.** `inspect_dgf()` checks the DGF is well formed, then
   `create_rg()` scaffolds a Quarto project and renders the Research Guide (it
   also drops a `DG.R` you can edit to customize formatting and layouts).
6. **Refresh when the data changes.** `update_dgf()` compares a new extract to
   the DGF by content hash — unchanged variables keep their curated row, changed
   ones are re-profiled — and re-runs the rule guards, flagging any that no
   longer fit the cleaned data.

Outputs land in this folder: `DGF.csv`/`DGF.xlsx` (the governance file),
`DGF-governed.csv` (the stabilized data), and `research-guide.*` (the report).

## The temporal showcase — `STEP-temporal-demo.R`

A compact second example focused on the date/time detectors and units. It builds
a synthetic dataset (`make-temporal-demo-data.R`) spanning the messy temporal
formats a real extract throws at you — abbreviated month/weekday names, `m-d-Y`
vs `d-m-y`, `YYYY-MM`, am/pm clock times, a full timestamp, bare years — then
shows the `create_dgf()` → `retype_dgf()` (type + unit) → `create_rg()` loop.
The graphic for each temporal is chosen at render from `stable_data_unit`
(calendar heatmap, month bars, day-of-week, year histogram, …).

## Learn more

The **"Rule-Based Data Governance"** vignette explains the three-stage model and
the `as_*` / `is_*` rule-and-guard system; the **"Data-Type Detector Guide"**
vignette catalogs the detectors that power both `guess_data_type()` and the
rule guards.
