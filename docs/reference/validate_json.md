# Check whether each element of a vector is valid JSON

Vectorised wrapper around \[jsonlite::validate()\] used to verify that
the JSON-encoded cells of a DGF are well formed.

## Usage

``` r
validate_json(v)
```

## Arguments

- v:

  A character vector of JSON strings.

## Value

A logical vector, one element per input, \`TRUE\` where the string is
valid JSON.

## See also

\[get_json_error()\], \[show_invalid()\],
[`validate`](https://jeroen.r-universe.dev/jsonlite/reference/validate.html)
