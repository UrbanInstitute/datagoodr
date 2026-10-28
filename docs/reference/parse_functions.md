# Collect and check the conversion functions named in a DGF

Takes the unique function names listed in a DGF's \`raw_convert\` column
and verifies that each is a defined function, erroring if any are
missing.

## Usage

``` r
parse_functions(raw_convert)
```

## Arguments

- raw_convert:

  A character vector of function names (typically the \`raw_convert\`
  column of a DGF).

## Value

A character vector of the unique function names.

## Details

Part of the not-yet-operational Step 2 pipeline. Note: the current
existence check has known defects (missing \`vapply\` template, inverted
condition) and is not yet wired into the tested workflow.
