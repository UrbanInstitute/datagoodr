# Replace variable names matching an alias

Given a vector of current names, replaces any that match one of the
aliases in \`x\` with the single replacement name \`y\`. A message
reports what was replaced, and a warning is issued if more than one name
matches.

## Usage

``` r
replace_name(nm, x, y)
```

## Arguments

- nm:

  A character vector of current variable names.

- x:

  A \`";;"\`-delimited string (or vector) of aliases to match against
  \`nm\`.

- y:

  The single replacement name to substitute for matched aliases.

## Value

The \`nm\` vector with matched names replaced by \`y\`.

## See also

\[rename_all()\], \[parse_nm()\]
