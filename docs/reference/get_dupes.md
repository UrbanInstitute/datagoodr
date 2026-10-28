# Identify and Print Duplicate Variables in a Data Frame

This function checks for duplicate variables in a data frame based on a
provided hash vector. It prints out the names of duplicate variables and
returns a logical vector indicating which rows are raw_duplicated.

## Usage

``` r
get_dupes(df, vhash)
```

## Arguments

- df:

  A data frame containing the variables to be checked for
  raw_duplicated.

- vhash:

  A vector of hash values corresponding to each variable in the data
  frame. This is typically computed using a hashing function like
  \`rlang::hash()\`.

## Value

A logical vector indicating which variables are raw_duplicated.

## Examples

``` r
if (FALSE) { # \dontrun{
vhash <- sapply(df, rlang::hash)  # Generate hash values for variables
get_dupes(df, vhash)  # Identify and print duplicate variables
} # }
```
