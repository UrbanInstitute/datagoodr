# Print the PROPERTIES table transposed across one row

The compact research guide's PROPERTIES block: the same properties
[paste_properties](https://urbaninstitute.github.io/datagoodr/reference/paste_properties.md)
stacks in a vertical table — rows, distinct values, missing, zeros,
infinities — laid out horizontally instead, one column per property
holding its count and share (\`3 (5.0 is two lines tall rather than five
or six.

## Usage

``` r
paste_properties_horizontal(VNAME, LABEL = "PROPERTIES")
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"rg_properties"\`).

- LABEL:

  A character string for the section title. Defaults to
  \`"PROPERTIES"\`.

## Value

No return value; prints the table to the RG. Nothing is printed when the
variable has no properties payload.

## Details

Like
[paste_properties](https://urbaninstitute.github.io/datagoodr/reference/paste_properties.md),
the rows shown in their own blocks (Most Common, Skew, Kurtosis) are
filtered out, so a DGF built before they moved renders without them.

## See also

\[paste_properties()\], the vertical form the default guide uses.
