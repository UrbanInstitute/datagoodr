# Contract: build a data-type detector

You are writing one R function that detects whether values belong to a specific
data type. Your function will be dropped into the `datagoodr` package as a
"detector" and registered so the package can guess column types automatically.
Follow this contract exactly. A concrete type, its positive examples, and its
generated test cases are given **below this contract**.

## What a detector is

A detector is a **boolean predicate**: it answers "is each value an X?" It does
**not** guess among types, transform values, or judge data quality. The guessing
happens in a separate layer that aggregates detectors.

## Function contract (must hold exactly)

1. **Name:** `is_<type>` where `<type>` is the type name given below
   (e.g. `is_currency_code`). Lower snake_case.
2. **Input:** a single argument `x`, a character vector. Begin by coercing:
   `x <- as.character(x)`.
3. **Output:** a **logical vector the same length as `x`** — `TRUE` where the
   value matches the type, `FALSE` where it does not.
4. **`NA`-safe:** where `x[i]` is `NA`, the result must be `NA`. Never error on
   `NA`, empty strings, or unexpected input.
5. **Vectorized and pure:** no loops that change length, no printing, no file or
   network access, no global state.
6. **Dependencies:** prefer base R (regex, `%in%`, lookup tables). If a value
   requires a checksum or a code list, inline the reference data in the
   function or as a sibling constant. Do not call other packages unless you
   state which one and why.

## How to use the test cases below

You are given, below this contract:

- **Positives** — real valid values. Your detector must return `TRUE` for
  **all** of them (recall = 1). This is non-negotiable.
- **Hard negatives** — machine-generated near-misses your detector should
  reject (return `FALSE`). They come from three mutation strategies:
  - **S2** (preserve-alphabet): characters swapped within the observed alphabet.
  - **S3** (random): characters swapped for arbitrary printable characters.
  - **SP** (scramble-structure): punctuation/delimiter positions permuted while
    digits/letters keep their identity — this tests whether you check that
    structural characters are in the *right place*, not merely present.

**Important — do not over-fit.** A fourth strategy, S1, mutates only the
alphanumeric payload while preserving structure. For loosely-structured types
(e.g. a currency amount like `$12.30`) an S1 mutant such as `$47.99` is still a
**valid** value. You are **not** shown S1 negatives, and you must **not** try to
reject valid-looking variants. Match the type's real definition, not the
specific example set.

## Stop rules

Your detector is done when, against the cases below:

- it returns `TRUE` for **100%** of positives, **and**
- it returns `FALSE` for **at least 85%** of the S3 and SP negatives, **and**
- it is the **narrowest** rule that still accepts all positives (do not widen
  the pattern to also accept things that are not the type).

If you cannot reject some negatives without also rejecting a real positive,
stop and keep recall = 1 — explain the residual ambiguity in one line.

## Deliverable format (return exactly this, nothing more)

1. One fenced ` ```r ` code block containing **only** the `is_<type>` function.
2. One sentence stating the rule you implemented and any residual ambiguity.
3. One fenced ` ```r ` line giving the registry entry, of the form:
   `<type> = list(detector = "is_<type>", label = "<short human label>")`

Do not restate the contract, the examples, or the test data.

## Worked example

For the type `currency_code` (positives `"USD"`, `"eur"`, `"JPY"`; hard
negatives `"US1"`, `"U$D"`, `"ZZZ"`), a correct answer is:

```r
is_currency_code <- function(x) {
  x <- as.character(x)
  iso4217 <- c("USD","EUR","JPY","GBP","CAD","AUD")  # inline the full list
  out <- toupper(x) %in% iso4217
  out[is.na(x)] <- NA
  out
}
```

The rule: a value is a currency code iff, upper-cased, it is a member of the
ISO 4217 code list (a lookup, not a shape check — `"ZZZ"` has the right shape
but is not a real code).

```r
currency_code = list(detector = "is_currency_code", label = "currency code (ISO 4217)")
```

---

The type you must write a detector for, with its positives and hard negatives,
follows below.
