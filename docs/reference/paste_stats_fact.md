# Print Statistic of a Factor Variable into RG

Read rg_stats column of DGF and print statistics in a table in the RG

## Usage

``` r
paste_stats_fact(VNAME, LABEL = "STATS")
```

## Arguments

- VNAME:

  A character string specifying the name of the variable whose
  properties are to be displayed.

- LABEL:

  A character string (from layout.TYPE object) for the section title.
  Defaults to \`"STATS"\`.

## Value

This function does not return a value; it prints the formatted table to
the RG as html code

## Details

The function is an internal function of \`create_div\` in
R/03-01-create-sections.R.
