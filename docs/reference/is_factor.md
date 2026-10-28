# Guess whether a vector should be treated as a factor

Applies a series of heuristics to decide whether a vector represents a
categorical (factor) variable rather than free text, an identifier, a
continuous number, a date, or a logical. Character and integer vectors
are flagged as factors when they have few unique values relative to
their length, use fixed-width standardized codes, are dominated by their
most common levels, or form an approximate integer sequence. Diagnostic
details about the decision are printed to the console.

## Usage

``` r
is_factor(
  x,
  unique.p = 0.05,
  unique.n = 100,
  top.n = 25,
  max.variance = 2,
  b.to.f = FALSE
)
```

## Arguments

- x:

  A vector of any type to evaluate.

- unique.p:

  Maximum proportion of unique values for \`x\` to be considered a
  factor. Default \`0.05\`.

- unique.n:

  Maximum count of unique values for \`x\` to be considered a factor.
  The more conservative of \`unique.p\`/\`unique.n\` is used. Default
  \`100\`.

- top.n:

  Number of most-common levels used when testing whether a few levels
  account for the bulk of the data. Default \`25\`.

- max.variance:

  Variance threshold below which an integer vector is treated as
  categorical. Default \`2\`.

- b.to.f:

  Logical; if \`TRUE\`, binary (0/1 or single-value) vectors are
  converted to factors. Default \`FALSE\`.

## Value

A single logical value: \`TRUE\` if \`x\` should be treated as a factor,
otherwise \`FALSE\`.

## See also

[`IsDate`](https://andrisignorell.github.io/DescTools/reference/IsDate.html),
[`retype`](https://rdrr.io/pkg/hablar/man/retype.html)
