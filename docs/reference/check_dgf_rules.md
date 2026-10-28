# Check that a DGF's rules still fit the data

For every variable carrying a \`raw_to_stable_transform\` or
\`desired_data_import_rule\`, applies the rule to the matching column of
\`data\` and measures the share of \*present\* values it turns into
\`NA\` — the same signal the rule's \`is\_\*\` guard would give. A high
miss rate means the rule no longer matches the data (e.g. you cleaned a
date column, so the old \`read_mmddyyyy\` no longer applies).

## Usage

``` r
check_dgf_rules(dgf, data, threshold = 0.2)
```

## Arguments

- dgf:

  A DGF data frame, or a path to a DGF \`.xlsx\`.

- data:

  The data to test against: a data frame, or a path to a \`.csv\`.

- threshold:

  Miss rate above which a rule is flagged as not fitting. Defaults to
  \`0.2\`.

## Value

A data frame with one row per (variable, rule): \`var_name\`, \`stage\`
(\`"reformat"\` or \`"import"\`), \`rule\`, \`miss_rate\`, and \`fits\`
(logical). Empty when the DGF has no rules. Rows with \`fits == FALSE\`
are the ones to review.

## See also

\[stabilize_data()\], \[update_dgf()\]

## Examples

``` r
if (FALSE) { # \dontrun{
bad <- subset(check_dgf_rules(dgf, raw_data), !fits)
} # }
```
