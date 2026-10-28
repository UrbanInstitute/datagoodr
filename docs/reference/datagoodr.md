# Generate DGF and RG

Run the entire datagoodr workflow

## Usage

``` r
datagoodr(
  wd = getwd(),
  folder.name = NULL,
  path.raw.data,
  create.dgf.params = NULL,
  rg.name = "research-guide"
)
```

## Arguments

- wd:

  charterer string of project output location. Default is the current
  working directory.

- folder.name:

  character string of folder project output will be put into. Defaut is
  "datagoodr-TODAYSDATE".

- path.raw.data:

  character string of absolute path to raw dataset that is to be
  documented. File extension can be .csv or .xlsx. See
  data-dev/demo-data-small.csv for an example.

- create.dgf.params:

  list of function arguments for creating the dgf. See
  [create_dgf](create_dgf.md) for available function arguments (df
  argument is not needed). Defaul is NULL which uses the default
  arguments for [create_dgf](create_dgf.md).

- rg.name:

  character string to name the final research guide output. Default is
  "research-guide".

## Value

This function outputs entire datagoodr workflow into the \`wd\`
directory.

## Details

Run the entire datagoodr workflow.....

## Examples

``` r
if (FALSE) { # \dontrun{
## Testing datagoor funciton
library(datagoodr )
datagoodr(
  wd = "~/Desktop",
  folder.name = NULL,
  location.data.raw <- paste0(getwd(), "/data-dev/DEMO-DATA-SMALL.csv"),
  create.dgf.params = list(use.df.types = FALSE,
                           guess.factors = TRUE,
                           guess.dates = FALSE),
  rg.name = "test-research-guide"
)
} # }
```
