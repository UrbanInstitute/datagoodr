# Return the parse error for an invalid JSON string

Validates a single JSON string and returns the error message produced by
\[jsonlite::validate()\], or \`NULL\` when the string is valid.

## Usage

``` r
get_json_error(x)
```

## Arguments

- x:

  A single JSON string.

## Value

A character string describing the JSON parse error, or \`NULL\` if \`x\`
is valid JSON.

## See also

\[validate_json()\],
[`validate`](https://jeroen.r-universe.dev/jsonlite/reference/validate.html)
