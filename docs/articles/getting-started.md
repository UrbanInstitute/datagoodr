# Getting Started with datagoodr

## What datagoodr is for

A CSV is just text. Whether `47401` is a ZIP code, a county FIPS, or a
count is invisible to the file — so every program that opens it has to
*guess*, and they guess differently. A leading zero disappears (`06037`
becomes `6037`), a date is read in the wrong order, a column of codes is
averaged as if it were a quantity. These small, silent errors are how
ungoverned data quietly corrupts analysis.

`datagoodr` fixes this by pairing a dataset with a **Data Governance
File (DGF)** — a small table, one row per variable, that records how
each column is stored, how it should be read, and what it means. From
that one artifact it produces a clean, self-describing dataset and a
readable profile of it. It is built for the CSV world and meant to be
edited in a spreadsheet, so governance does not require adopting a
heavyweight platform. (For the bigger picture, see *Rule-Based Data
Governance*.)

## The three things datagoodr produces

``` r
# datagoodr uses the formex package as its type-detection engine
remotes::install_github("lecy/formex")
remotes::install_github("UrbanInstitute/datagoodr")
library(datagoodr)
```

**1. The DGF — a governed data dictionary.**
[`create_dgf()`](../reference/create_dgf.md) reads your data, profiles
every column, and types it with the help of
[formex](https://lecy.github.io/formex/). The result is a table you can
open in Excel and curate.

``` r
dgf <- create_dgf(raw_data, file = "DGF", open = FALSE)
# writes DGF.csv and DGF.xlsx, and returns the DGF data frame
```

**2. A stabilized dataset — a governed CSV.**
[`stabilize_data()`](../reference/stabilize_data.md) applies the DGF’s
rules to a raw extract, producing a version that imports to the correct
type where possible and *safely* (without data loss) where not — a date
becomes ISO `2019-03-15`, a ZIP keeps its leading zero.

``` r
stable <- stabilize_data(raw_data, dgf, use_v7 = TRUE)
write_stable_csv(stable, "data-governed.csv", dgf = dgf)
```

**3. A Research Guide — a rendered data profile.**
[`create_rg()`](../reference/create_rg.md) scaffolds a self-contained
report that shows each variable with a visual tuned to its type (a
histogram for a number, a treemap for a category, a calendar heat-map
for a date).

``` r
create_rg(dgf, file = "research-guide")
```

## The shape of the workflow

    raw CSV ──create_dgf()──▶ DGF ──┬── stabilize_data() ──▶ governed CSV
                     (profile + type)│
         you curate labels & types ──┘── create_rg() ───────▶ Research Guide

[`create_dgf()`](../reference/create_dgf.md) does the heavy first pass.
Your job is to curate — add labels and definitions, confirm or correct
the guessed types — in the spreadsheet. Then the same DGF drives both
outputs, and [`update_dgf()`](../reference/update_dgf.md) re-profiles
the data when it changes while keeping everything you curated.

## Where to go next

- **The datagoodr Workflow** — the mental model, with a look at a real
  DGF and sample data profiles.
- **Rule-Based Data Governance** — why the DGF is the command center,
  and what “rule-based governance” means.
- **Stabilizing Datasets** — how messy formats become stable,
  type-correct, and loss-free.
- **Data Profiling** and **Profiles & Research Guides** — what is
  measured, and how it is rendered.
- **Documenting Data with the DGF** — turning the DGF’s template fields
  into published documentation.

Type detection itself lives in the companion package
[formex](https://lecy.github.io/formex/); datagoodr is the workflow
around it.
