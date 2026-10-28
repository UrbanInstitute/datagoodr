# Print the invalid JSON cells in a vector

Identifies the elements of \`v\` that are not valid JSON and prints, for
each, its parse error message followed by the offending string. Useful
for debugging a DGF after manual edits.

## Usage

``` r
show_invalid(v)
```

## Arguments

- v:

  A character vector of JSON strings.

## Value

Invisibly returns \`NULL\`; called for its printed side effects.

## See also

\[validate_json()\], \[get_json_error()\]
