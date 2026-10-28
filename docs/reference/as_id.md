# Coerce a column to an identifier (character, trimmed)

The import rule for identifier columns: keep the value as text (so
leading zeros and long numeric IDs survive) and trim surrounding
whitespace. This is an \`as\_\*\` — it names the TYPE it produces, and
belongs in \`desired_data_import_rule\`, not
\`raw_to_stable_transform\`.

## Usage

``` r
as_id(x)
```

## Arguments

- x:

  A vector.

## Value

A trimmed character vector.

## See also

\[read_date()\] for the ingest direction.

## Examples

``` r
as_id(c(" 06037 ", "36061"))
#> [1] "06037" "36061"
```
