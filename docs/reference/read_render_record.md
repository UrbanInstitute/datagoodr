# Recover the render record from a rendered report

Reads back the provenance record \[render_record()\] embedded in a
rendered \`.html\`, so you can ask which DGF produced a report you were
handed.

## Usage

``` r
read_render_record(path)
```

## Arguments

- path:

  Path to a rendered \`.html\` file.

## Value

The record as a named list, or \`NULL\` when the file carries none (e.g.
it was produced before the record chunk existed).

## See also

\[render_record()\]

## Examples

``` r
if (FALSE) { # \dontrun{
rec <- read_render_record( "research-guide.html" )
rec$dgf_hash
} # }
```
