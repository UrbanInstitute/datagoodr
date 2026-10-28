# Rename data frame columns using an alias mapping

Renames the columns of \`df\` by applying \[replace_name()\] for each
\`old\`/\`new\` pair, where each \`old\` entry may be a
\`";;"\`-delimited set of aliases mapping to a single \`new\` name.

## Usage

``` r
rename_all(df, old, new)
```

## Arguments

- df:

  A data frame whose columns should be renamed.

- old:

  A character vector of aliases (each element optionally
  \`";;"\`-delimited) identifying columns to rename.

- new:

  A character vector of replacement names, parallel to \`old\`.

## Value

The data frame with renamed columns.

## See also

\[replace_name()\]
