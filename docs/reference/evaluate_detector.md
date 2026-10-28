# Score a candidate detector against generated test cases

Runs the (LLM-produced) detector over the positives and freshly
generated negatives and returns the same recall/precision report used to
build the package's own fixtures — so you can see how well the suggested
function works before adopting it.

## Usage

``` r
evaluate_detector(detector, examples, type_name = "candidate", seed = 514)
```

## Arguments

- detector:

  A function taking a character vector and returning a logical vector
  (the function the LLM wrote).

- examples:

  The same positive examples passed to \[draft_detector_prompt()\].

- type_name:

  Optional label for the report header.

- seed:

  Integer seed (match the drafting call for identical negatives).

## Value

The results table from \[formex::build_autotype_results()\], invisibly,
after printing the error report via
\[formex::generate_autotype_report()\].

## See also

\[draft_detector_prompt()\]
