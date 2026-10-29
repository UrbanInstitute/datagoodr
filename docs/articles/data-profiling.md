# Data Profiling

## Profiling makes data transparent and auditable

A governed dataset should not ask you to take its quality on faith.
**Profiling** is the measured description of every column — how complete
it is, how it is distributed, where the surprises are — computed from
the values themselves and stored in the DGF. Because the profile travels
with the governance file, anyone can audit what the data actually looked
like, without re-reading the raw file.

[`create_dgf()`](https://urbaninstitute.github.io/datagoodr/reference/create_dgf.md)
profiles every column as it builds the DGF;
[`update_dgf()`](https://urbaninstitute.github.io/datagoodr/reference/update_dgf.md)
recomputes the profile for any column whose data has changed.

## Universal quality metrics — measured for every column

Regardless of type, each column reports a small set of integrity counts,
each as a count and a percentage, and — importantly — **only when it
occurs**, so the profile never pads itself with zeros that would bury
the real signal:

- **Distinct** — how many unique values (the first clue to whether a
  column is an identifier, a category, or a measurement).
- **Missing / NA** and **Missing / Empty** — absent values, separating
  true `NA` from empty strings, because the distinction often matters.
- **Zero** — exact zeros (meaningful for counts, rates, and money).
- **Infinite** — non-finite values that signal a computation or import
  problem.
- **Duplicated** — repeated rows/values, surfaced rather than hidden.

Read together these are a quick integrity check: a column that is 40%
missing, or one that is all distinct, tells you something before you
plot anything.

## Type-specific indicators

On top of the universal counts, each type adds the indicators that are
meaningful for it:

- **Numeric** — the quantile ladder (minimum, Q05, Q25, median, Q75,
  Q95, maximum) plus mean, **skew**, and **kurtosis**, so a skewed or
  heavy-tailed distribution is visible as a number, not just a picture.
- **Categorical** — the level frequencies, ranked, with the long tail
  capped so the table stays legible.
- **Temporal** — the grain (year, month, day, …) and coverage of the
  range.
- **Text** — length and sampled values.

The point of type-specific profiling is that a quality problem looks
different for each type: for a number it is an outlier or a skew; for a
category it is a rare level or a near-constant column; for a date it is
a gap in coverage.

## A profile, measured

Build a DGF from the demo dataset and read two real profiles back out —
the universal quality counts for any column, and the numeric statistics
table:

``` r

library(datagoodr)
dgf <- create_dgf(dg_demo, file = tempfile("dgf"), open = FALSE)
```

``` r

dg_properties(dgf, "revenue")   # universal: distinct, missing, zeros, ...
```

**PROPERTIES**:

| STAT     | VAL |      PER |
|:---------|----:|---------:|
| Rows     |  60 |          |
| Distinct |  60 | (100.0%) |

``` r

dg_stats(dgf, "revenue")        # type-specific: the numeric statistics
```

**STATS**:

| STAT     |      VAL |
|:---------|---------:|
| Minimum  |    55.91 |
| Median   |    338.8 |
| Mean     |   534.83 |
| Maximum  | 2,100.88 |
| Skew     |     1.44 |
| Kurtosis |     1.58 |

These tables are exactly what the Research Guide renders, read straight
from the DGF’s stored profile — no re-reading of the raw data.

## How the DGF logs and stores profiles

Each column’s profile is written into the DGF’s `rg_*` columns and kept
as **JSON text**:

- `rg_properties` — the universal counts and type indicators;
- `rg_stats` — the statistics tables (quantiles, frequencies);
- `rg_preview` — a sample of values;
- `rg_graphics` — the data a type’s visual is drawn from;
- `rg_max_chr` — the widest value, for layout.

Storing them as JSON (not nested R objects) is deliberate: it survives
the `.xlsx` round trip that a nested column would not, so the profile is
portable and the raw data is no longer needed to render the guide. When
you re-profile with
[`update_dgf()`](https://urbaninstitute.github.io/datagoodr/reference/update_dgf.md),
only the changed columns’ `rg_*` cells are rewritten; curated dictionary
text is left untouched.

> **Note.** Today’s universal metrics are the integrity counts above.
> Richer summaries of spread and balance — such as an entropy or
> concentration measure for categoricals — are under consideration as
> additional universal indicators.

## Next

- **Profiles & Research Guides** — how these stored profiles become a
  rendered report, with a different visual for each type.
