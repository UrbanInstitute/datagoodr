# Print Graphics of a character Variable into RG

Read rg_graphics column of DGF and print word cloud in the RG

## Usage

``` r
v_to_wordcloud(VNAME, LABEL = "WORD CLOUD")
```

## Arguments

- VNAME:

  A character string specifying the name of the variable whose
  properties are to be displayed.

- LABEL:

  A character string (from layout.TYPE object) for the section title.
  Defaults to \`"Word Cloud"\`.

## Value

This function does not return a value; it prints the formatted word
cloud to the RG

## Details

The function is an internal function of \`create_div\` in
R/03-01-create-sections.R.
