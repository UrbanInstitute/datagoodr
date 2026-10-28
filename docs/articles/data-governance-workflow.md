# Rule-Based Data Governance

## What data governance is, and why it is hard

**Data governance** is the work of protecting data assets, refining
them, and making them available — to an organization, or to outside
stakeholders. It has been a core concern of information systems for
decades. But it has become acute in statistics and the social sciences,
where the creation and sharing of new data sources has grown
exponentially while governance *practice* has not kept pace.

The usual answer is an enterprise data-governance system: a platform
built around complex schemas and unfamiliar data-type ontologies, with a
cost and staffing model that put it out of reach for most labs,
analysts, and academics. Governance that demands all of that fails to
meet the majority of researchers where they are. The result is
predictable — most datasets are shared with little or no governance at
all.

datagoodr takes the opposite approach. It is organized around **familiar
data types and CSV files** — the default currency of much of the
scientific world and of organizational analysts — and around a single
artifact anyone can edit in a spreadsheet. The command center for all of
it is the **DGF**.

## The problem it solves: a CSV has no schema

A CSV is just text. Whether `47401` is a ZIP code, a county FIPS, or a
count is invisible to the reader — every program that opens the file has
to *guess*, and they guess differently. `datagoodr` fixes this by
pairing the data with a **Data Governance File (DGF)**: a small table,
one row per variable, that records how the data is stored, how it should
be read, and what it means. The DGF is a **rule-based** artifact — you
write the *name* of a rule in a cell, and the package applies it — so
governance is declarative, portable, and reproducible.

## Three stages, two bridges

A variable’s type lives on a short journey from the raw file to how you
actually want to analyze it. The DGF columns are grouped to mirror that
journey:

    RAW CSV ──raw_to_stable_transform──▶ GOVERNED CSV ──desired_data_import_rule──▶ ANALYSIS
       │            (reformat: lossless)        │           (coerce into type)          │
     raw_*                              stable_*                               desired_*
     how R reads the raw file           the canonical current state           what it should BE
     (type, format)                     (type, format)                        (type, class)

- **`raw_`** — the raw file as received: `raw_data_type` (how R reads
  it), `raw_data_format`, and profiling (`raw_first5`,
  `raw_duplicated`).
- **`stable_`** — the **governed CSV** after cleanup: `stable_data_type`
  and `stable_data_format` (the unit is recorded in `dd_data_unit`).
  These describe the data *as it currently is*.
- **`desired_`** — the **intended interpretation**, which does not
  change across file versions: `desired_data_type` and
  `desired_data_class` (a dotted `family.type` coordinate such as
  `period.year` or `id.geographic`).

Between the stages sit two **rule** columns, and each takes its own
family of rule name:

- **`raw_to_stable_transform`** — the lossless **reformat** (standardize
  weird dates to ISO, strip thousands separators, restore a dropped
  leading zero). Its job is to produce a *canonical* governed CSV that
  every tool reads correctly. Takes a **`read_*`** rule:
  `read_mmddyyyy`, `read_ein`, `read_yyyymm`.
- **`desired_data_import_rule`** — the **coercion** that reads the
  governed column into the desired R type. Takes an **`as_*`** rule:
  `as_id`.

## Which bridge closes the gap? A mechanical rule

The storage a reader produces can be one of only four base types
(`text`, `number`, `boolean`, `temporal`); the *desired* type may also
be a semantic type a CSV cannot express (`categorical`, `identifier`,
`list`). That tells you which bridge to use:

| the desired type is… | example | close the gap with |
|----|----|----|
| **reader-achievable** (base) | a date read as text | **reformat** (`raw_to_stable_transform`) — make the reader hit it |
| **not expressible in a CSV** (semantic) | a ZIP that is a `categorical`, an ID that is an `identifier` | **import rule** (`desired_data_import_rule`) — only metadata can say it |

The design goal is to push as much as possible into the *reformat* (it
is lossless and every downstream tool benefits), leaving import rules
only for the genuinely schema-dependent distinctions.

## `read_*` and `as_*` rules, and their `is_*` guards

A rule name tells you which stage it belongs to:

- **`read_<format>()`** *ingests* a value written in that format — the
  name states the **input**. These go in `raw_to_stable_transform`.
- **`as_<type>()`** *coerces* a value into a target type — the name
  states the **output**. These go in `desired_data_import_rule`.

So [`read_ddmmyyyy()`](../reference/read_date.md) reads `15/03/2019` and
returns a `Date`; it does not *produce* `dd/mm/yyyy`. A rule sitting in
the wrong column is visible without running it.

Every rule has a matching **`is_*` guard** from the detector library,
which lives in the [formex](https://lecy.github.io/formex/) package.
Before `read_ddmmyyyy` runs,
[`formex::is_date()`](https://rdrr.io/pkg/formex/man/is_date.html)
checks that the column actually looks like a date; if it does not, the
rule does not match the data and you get a warning instead of silent
corruption. That single idea ties the system together:

- **governance** — drop a rule name in a cell and it is applied;
- **safety** — its `is_*` guard validates the precondition;
- **iteration** — [`update_dgf()`](../reference/update_dgf.md) re-runs
  the guards against the *current* data and flags rules that no longer
  fit (because you cleaned the file).

## The workflow

``` r
library(datagoodr)

# 1. create_dgf() launches the guessers and populates the pipeline.
#    It profiles each column, runs formex over it (formex::guess_data_type
#    with the variable name as a hint), and fills in a first pass at every column
#    of the DGF -- storage, a semantic desired_data_type/subtype/class, factor
#    levels, near-unique key flags, and the rg_ profile used to render.
dgf <- create_dgf(raw_data, file = "DGF", open = FALSE)
```

[`create_dgf()`](../reference/create_dgf.md) does the heavy first guess;
**your job is to curate two things**:

**(a) Move the data from raw to canonical** — add reformat rules to
`raw_to_stable_transform` so the governed CSV is clean and
self-describing (standardize dates, declutter grouped numbers, preserve
leading zeros). This is representation only: no information is lost, the
values just get written in a form every tool reads.

**(b) Add semantic context** — set the `desired_*` fields to say what
each column should *be*, independent of how it happens to be stored. A
grade coded `1`–`12` is `categorical`, not a number; a FIPS code is an
`identifier` with class `id.geographic` when it is a key, and
`categorical` with class `mutually_exclusive.geographic` when it is a
grouping variable. This is where you encode meaning the CSV alone cannot
carry.

``` r
# Edit the DGF in Excel, or programmatically:
dgf$raw_to_stable_transform[dgf$var_name == "founded"] <- "read_mmddyyyy"  # raw -> ISO
dgf$desired_data_type[dgf$var_name == "grade_level"]   <- "categorical"    # a grade is not a number
dgf$desired_data_class[dgf$var_name == "county_fips"]  <- "id.geographic"  # dotted family.type

# 2. Apply the reformat rules to a raw extract -> a canonical, governed CSV.
stable <- stabilize_data(raw_data, dgf)
write_stable_csv(stable, "data-governed.csv", dgf = dgf)

# 3. Re-profile after you have changed a type or cleaned the data.
dgf <- update_dgf(dgf, raw_data)   # re-runs guards, recomputes rg_* for changed vars
```

## A suggested stabilizer you can preview (formex v7)

[`create_dgf()`](../reference/create_dgf.md) does not only guess the
type — it proposes *how to standardize* the column and shows you the
result before you commit. Each variable carries a machine guess in
`guess_*` (the detected leaf as two axes, `guess_format_style` and
`guess_unit_type`, with a readable `guess_label` like
`calendar {{ date :: temporal }}`), a `desired_*` target form you can
edit, and a suggested **`stabilizer`** — a `read :: [convert] :: write`
plan resolved by formex’s transform-path search. Its effect on the first
few values is previewed in **`stable_first5`**, so a mis-detected date
order is visible on sight. A reformat formex cannot reach (say a
fiscal-to-calendar year, with no registered converter) is reported
`not-transformable` rather than guessed.

Executing those plans is opt-in, so the suggestion only runs when you
ask:

``` r
# Apply the suggested v7 stabilizer plans (read :: [convert] :: write) to a raw
# extract. A column with a legacy raw_to_stable_transform rule keeps using it;
# the default (use_v7 = FALSE) leaves behaviour unchanged.
stable <- stabilize_data(raw_data, dgf, use_v7 = TRUE)
```

## Why the split pays off

- **Iterative improvement.** Governance is not one-shot. You clean a
  column, and [`update_dgf()`](../reference/update_dgf.md) reconciles
  the DGF with the new state — the `desired_` interpretation is stable,
  while the `raw_`/`stable_` storage and the rules needed to bridge to
  it evolve as the data improves.
- **Portability.** Because `stable_data_unit`/`stable_data_format`
  describe the data as it is, and the `desired_` fields describe intent,
  the governed CSV carries enough to be understood by non-R tools — and
  maps cleanly onto archival standards (DDI) for deposit in a repository
  like Dataverse.
- **No hidden magic.** Every transformation is a named rule you can
  read, and every rule has a guard that refuses to run on data it does
  not fit.

## Where detection lives

Type detection is not part of datagoodr. It lives in the
[formex](https://lecy.github.io/formex/) package, which owns the type
ontology, the `is_*` detector library, `guess_data_type()`, and
`fx_stabilize()`. datagoodr calls it once per column and turns the
answer into DGF coordinates.

For the vocabulary and the detectors, see formex’s own vignettes — *The
Data-Type Ontology*, *Data-Type Detectors*, *Guessing a Data Type*, and
*Formex* — at <https://lecy.github.io/formex/>.
