# Contract: suggest human-readable factor labels

You are given one or more categorical (factor) variables from a dataset's Data
Governance File (DGF). Each variable's levels are currently stored with the raw
**code** as both the level and its label. Your job is to fill in a concise,
human-readable **label** for each level, using the variable's name, label, and
description as context. The variables and their levels are given **below this
contract**.

## What to produce

For each variable, return the **same list of levels, in the same order**, with
the `label` field replaced by a readable description of what that code means.

## Rules (must hold exactly)

1. **Never change a `level` value.** The level codes are keys back into the
   data; preserve them character-for-character (including leading zeros and
   case). Only the `label` field may change.
2. **Never add, remove, or reorder levels.** Return exactly the levels you were
   given, one label per level.
3. **Use the context.** The variable name, label, and description often reveal
   the coding scheme. Decode recognizable standard code systems from your own
   knowledge — for example ISO 4217 currency codes, ISO 3166 country codes,
   US Census FIPS codes, NTEE/NCCS nonprofit codes, ICD diagnosis codes,
   Likert scales, US state abbreviations.
4. **Keep labels short.** A noun phrase in Title Case, no trailing period
   (e.g. `"Arts, Culture & Humanities"`, not `"This code means arts..."`).
5. **Flag uncertainty; do not invent.** If you cannot determine a level's
   meaning with reasonable confidence, set its label to the original code
   followed by ` (uncertain)`. Never fabricate a plausible-sounding meaning.

## Deliverable format (return exactly this)

For **each** variable, one fenced ` ```json ` block, preceded by a line naming
the variable, e.g. `## SUBSECCD`. The JSON is an array of
`{"level": ..., "label": ...}` objects — the same structure you were given,
paste-ready back into the DGF's `dd_f_levels` cell. After all blocks, add a
short bullet list of any variables where you flagged levels as uncertain.

Do not restate the contract or the input.

## Worked example

Given:

> **Variable:** `region`
> **Label:** Census region
> **Description:** US Census Bureau region of the respondent
> ```json
> [{"level":"1","label":"1"},{"level":"2","label":"2"},
>  {"level":"3","label":"3"},{"level":"4","label":"4"}]
> ```

A correct answer:

## region
```json
[{"level":"1","label":"Northeast"},{"level":"2","label":"Midwest"},
 {"level":"3","label":"South"},{"level":"4","label":"West"}]
```

---

The variables to label follow below.
