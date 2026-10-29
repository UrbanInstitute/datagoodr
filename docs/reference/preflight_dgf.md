# Check a dataset for degenerate columns before building a DGF

Scans every column and reports the ones that tend to break, or quietly
mislead, a profile: a column with a single value, an all-missing column,
values too long for a date parser, a yes/no flag spelled several ways,
zero-padded codes, duplicate columns, placeholder values, non-finite
numbers, and timestamp columns with too many distinct values to store
whole. It is much faster than [`create_dgf`](create_dgf.md) (about 40
seconds on a file of 568,000 rows and 199 columns, where the build took
about 22 minutes with the formex release before its 2026-10-28
speed-up), and it reports **every** finding at once instead of the first
failure.

## Usage

``` r
preflight_dgf(df, max_chr = 1000L, smoke_n = NULL, seed = 1L)
```

## Arguments

- df:

  A data frame, or the path to a `.csv` file (read with every column as
  text, as [`create_dgf`](create_dgf.md) does).

- max_chr:

  Values of at least this many bytes are reported as `long_values`.
  Defaults to `1000`, the length at which base R's
  [`strptime()`](https://rdrr.io/r/base/strptime.html) gives up.

- smoke_n:

  `NULL` (the default), or a number of rows. If given, also runs
  [`create_dgf`](create_dgf.md) on a random sample of that many rows
  (written to a temporary folder, with the pre-flight off) and reports
  any failure as a `smoke_test_failed` finding that names the variable.
  A sample of a few thousand rows finds most crashes in about a minute,
  even on a file whose full build takes half an hour.

- seed:

  Integer seed for the smoke-test sample. The session's random-number
  state is left as it was.

## Value

A data frame with one row per finding and columns `var_name`, `rule`,
`severity` (`"error"`, `"warn"` or `"info"`), `detail` and `suggestion`;
zero rows for a clean dataset. It has class `dgf_preflight`, with its
own [`print()`](https://rdrr.io/r/base/print.html) method.

## Details

[`create_dgf`](create_dgf.md) runs this itself (see its `preflight`
argument); call it directly to look at a dataset before committing to a
build.

Missing means `NA` or blank (empty or whitespace-only), as in
[`create_dgf`](create_dgf.md). The rules, with their severity:

- `smoke_test_failed` (error):

  the sample build failed (only with `smoke_n`).

- `constant` (warn):

  every row has the same value.

- `single_value_with_blanks` (warn):

  one value plus blanks, e.g. an `X`/blank checkbox.

- `all_missing` (warn):

  no values at all.

- `duplicate_column` (warn):

  identical to an earlier column.

- `mixed_boolean_encoding` (warn):

  a flag written more than two ways (`0`, `1`, `true`, `false`).

- `non_finite` (warn):

  `Inf`, `-Inf` or `NaN`.

- `placeholder_value` (info, warn from 5% of rows):

  `0000000000`, `9999`, `N/A`, ... holding at least 0.1% of the rows.

- `long_values` (info):

  values of `max_chr` bytes or more.

- `leading_zero_code` (info):

  digit strings with leading zeros, which a number would lose.

- `high_cardinality_temporal` (info):

  too many distinct timestamps to store whole; see
  `getOption("datagoodr.temporal.max_values")`.

`create_dgf(preflight = "warn")` reports errors and warnings; `"error"`
stops on either.

## See also

[`create_dgf`](create_dgf.md)

## Examples

``` r
df <- data.frame(
  id    = sprintf("%03d", 1:40),
  year  = rep("2023", 40),                          # one value
  box_x = ifelse(seq_len(40) %% 4 == 0, "X", ""),   # one value plus blanks
  n     = rnorm(40)
)
preflight_dgf(df)
#> preflight_dgf: 4 columns, 40 rows: 0 error(s), 2 warning(s), 1 note(s)
#> 
#> [warn] constant: 1 column(s)
#>   year                               every row is '2023'
#>   -> no information to analyse; drop it, or record the value in the documentation
#> 
#> [warn] single_value_with_blanks: 1 column(s)
#>   box_x                              one value ('X') in 10 of 40 rows (25.0%); the rest are blank
#>   -> if a blank means 'no' this is a checkbox: recode to TRUE/FALSE; if a blank means 'not asked', leave blank; otherwise drop it
#> 
#> [info] leading_zero_code: 1 column(s)
#>   id                                 40 value(s) (100.0%) are digit strings with a leading zero, e.g. '001'
#>   -> keep as text: type it identifier or categorical, never number
```
