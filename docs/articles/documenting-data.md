# Documenting Data with the DGF

## Documentation as filling in the blanks

Machines can measure and type a column, but they cannot know that
`grade` is coded `1 = Freshman … 4 = Senior`, or that `rev` means net
revenue in thousands of dollars. That meaning has to come from a person.
datagoodr’s approach is to make supplying it as light as possible:
[`create_dgf()`](https://urbaninstitute.github.io/datagoodr/reference/create_dgf.md)
pre-builds the **template fields** for documentation, and you fill them
in — in a spreadsheet.

The division of labor is clean: the machine measures and types; the
human supplies the meaning the data cannot carry on its own.

## The dictionary fields

Every variable’s row carries data-dictionary cells waiting for text:

- `dd_vlabel` — a short human label,
- `dd_vdesc` — a longer description,
- `dd_vname_alias` — an alternate name, if the source uses one.

You edit them where the DGF lives — in Excel, or programmatically — and
they belong to the variable from then on.

## The factor template: the real time-saver

The field that saves the most work is the one for **factors**. When a
column is categorical,
[`create_dgf()`](https://urbaninstitute.github.io/datagoodr/reference/create_dgf.md)
does not just note “categorical” — it enumerates the levels into
`dd_f_levels` as a template, one entry per level, each waiting for a
human-readable label and definition. A coded column arrives in the DGF
already expanded into the rows you need to annotate:

    # dd_f_levels for `grade`, as created — a template to fill in:
      level   label        definition
      1       ___          ___
      2       ___          ___
      3       ___          ___
      4       ___          ___

    # after you edit it in the spreadsheet:
      level   label        definition
      1       Freshman     first-year undergraduate
      2       Sophomore    second-year undergraduate
      3       Junior       third-year undergraduate
      4       Senior       fourth-year undergraduate

You never have to discover the levels yourself or build the table — you
only supply the words.

## How the entries become documentation

The text you add in these fields is not inert; it flows into both
outputs:

- **The rendered Research Guide.** The labels and descriptions become
  the headings and prose of the profile, and the factor level labels
  replace the raw codes in the category table and treemap — so
  `1`/`2`/`3`/`4` reads as `Freshman`/`Sophomore`/`Junior`/`Senior` in
  the published guide.
- **The governed CSV.** The portable families of the DGF — the `dd_`
  dictionary, the `stable_` descriptors, and the `validate_` rules — are
  **embedded in the governed CSV** written by
  [`write_stable_csv()`](https://urbaninstitute.github.io/datagoodr/reference/write_stable_csv.md).
  So the labels and definitions travel *with the data* to the next tool
  or repository, not as a detachable sidecar, and map cleanly toward
  archival standards (such as DDI) for deposit.

## Why edit in a spreadsheet

Keeping documentation in the DGF — a table you open in Excel — is
deliberate. It is where analysts already work, it needs no new tool or
query language, and a colleague who does not use R can still read,
review, and contribute. That is the whole premise: governance and
documentation that meet people where they are.

Re-profiling with
[`update_dgf()`](https://urbaninstitute.github.io/datagoodr/reference/update_dgf.md)
preserves every hand-edited label and definition, so documentation
accumulates as the data evolves rather than being redone each cycle.

## Where this fits

This closes the loop the guide has walked through: **Getting Started**
and **The datagoodr Workflow** for the shape of it; **Rule-Based Data
Governance** for the why; **Stabilizing Datasets**, **Data Profiling**,
and **Profiles & Research Guides** for the machine-produced half; and
this vignette for the human half that turns a profiled dataset into
finished, shareable documentation.
