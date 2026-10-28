# Draft a copy-paste prompt asking an LLM to write a new type detector

Turns a handful of example values for a new data type into a
self-contained prompt: the versioned detector contract (see
\`inst/prompts/detector-contract.md\`) followed by the type's positive
examples and machine-generated hard negatives. Paste or attach the
result into any LLM; feed the function it returns to
\[evaluate_detector()\].

## Usage

``` r
draft_detector_prompt(
  examples,
  type_name,
  n_negatives = 15,
  seed = 514,
  file = NULL,
  contract_path = NULL,
  quiet = FALSE
)
```

## Arguments

- examples:

  A character vector of 10-25 valid example values for the new type.

- type_name:

  A single lower_snake_case type name, e.g. \`"iso_country"\`. The LLM
  is asked to write \`is\_\<type_name\>()\`.

- n_negatives:

  Max hard negatives to include per mutation tier (keeps the prompt
  readable; the file still captures everything you pass).

- seed:

  Integer seed for reproducible test-case generation.

- file:

  Output path for the prompt \`.md\`; \`NULL\` writes to \`tempdir()\`.

- contract_path:

  Optional override for the bundled contract (path or URL).

- quiet:

  If \`TRUE\`, only write the file (no console print).

## Value

The prompt file path, invisibly. The prompt text is printed unless
\`quiet = TRUE\`.

## See also

\[evaluate_detector()\], \[formex::guess_data_type()\]
