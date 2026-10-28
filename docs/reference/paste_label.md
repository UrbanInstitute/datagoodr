# Print just a section label (no content) into the RG

Used by the standard layout to place a section's label in its own
left-hand cell (e.g. the PREVIEW label beside a full-width data
preview).

## Usage

``` r
paste_label(VNAME, LABEL = "PREVIEW")
```

## Arguments

- VNAME:

  Ignored; present for a uniform layout-function signature.

- LABEL:

  A character string for the label. Defaults to \`"PREVIEW"\`.

## Value

No return value; prints the label to the RG.
