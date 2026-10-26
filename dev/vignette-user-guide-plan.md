# datagoodr user guide — proposed vignette set

Written 2026-10-26. A proposal (not yet written) for a full user guide, built
from the outline you gave, ordered as a reading path and grounded in what the
package actually does today. Two vignettes already exist and fold into the set;
the rest are new. Notes at the end flag the few places the outline and the
current code don't yet line up.

## The set, in reading order

The pkgdown "Articles" menu would list these top to bottom — a newcomer reads 1→7.

| # | vignette (file) | status |
|---|---|---|
| 1 | Getting Started (`getting-started.Rmd`) | **new** |
| 2 | The datagoodr Workflow (`workflow-overview.Rmd`) | **new** |
| 3 | Rule-Based Data Governance (`data-governance.Rmd`) | revise existing `data-governance-workflow.Rmd` |
| 4 | Stabilizing Datasets (`stabilizing-datasets.Rmd`) | **new** |
| 5 | Data Profiling (`data-profiling.Rmd`) | **new** |
| 6 | Profiles & Research Guides (`research-guides.Rmd`) | **new** (absorbs `guessing-data-types.Rmd`'s typing bridge) |
| 7 | Documentation & the DGF (`documenting-data.Rmd`) | **new** |

Plus the existing **Guessing Data Types** (`guessing-data-types.Rmd`) kept as a
focused reference behind #6, for readers who want the typing detail.

---

## 1. Getting Started

**Purpose.** What datagoodr is and why it exists, in one sitting. The elevator
version: a CSV has no schema, so every tool that opens it guesses the types
differently; datagoodr pairs a dataset with a **Data Governance File (DGF)** that
records how each column is stored, how it should be read, and what it means — and
turns that into a stable dataset and a readable Research Guide.

**Covers**
- The problem: CSV is the lingua franca of analysis, and it carries no type
  information.
- The three things datagoodr produces: the **DGF** (a governed data dictionary),
  a **stabilized dataset** (a governed CSV that imports correctly), and a
  **Research Guide** (a rendered data profile).
- The shortest possible end-to-end: `create_dgf()` → review → `stabilize_data()`
  / `create_rg()`. One screenshot of each output.
- Install (datagoodr + its formex dependency) and where to go next.

**Shows.** A single small dataset carried through all three outputs at a glance —
the hook the later vignettes unpack.

---

## 2. The datagoodr Workflow (high level)

**Purpose.** The mental model, no code mechanics. How one artifact — the DGF —
is the spine: it is a *fancy data dictionary* that also drives everything
downstream.

**Covers**
- The DGF as a table with **one row per variable** and columns grouped by stage
  (`dd_` dictionary, `raw_` as-received, `guess_`/`desired_` type, `stabilizer`,
  `rg_` profile). It is both documentation *and* the control surface.
- How managing **data types** is the hinge: once a column's type is settled, the
  right stabilization rule and the right **data profile** follow from it.
- The loop: guess → review in a spreadsheet → stabilize → profile → render,
  iterating as the data improves.

**Shows (the outline's "glimpse")**
- A trimmed DGF for ~4 columns — a date, a ZIP, a factor, a number — so the
  reader sees the `guess_label`, `desired_*`, and `rg_*` cells side by side.
- **Two data-profile examples** rendered from it: a numeric column (histogram +
  quantile table) and a categorical column (treemap + frequency table) — a
  preview of #5/#6, no detail yet.

---

## 3. Rule-Based Data Governance

*(Revises the current `data-governance-workflow.Rmd`, which already covers the
two-bridge mechanics; this reframes it around the governance argument you gave.)*

**Purpose.** The DGF as the **command center** for protecting, refining, and
sharing data assets — and why datagoodr's take on governance is deliberately
low-barrier.

**Covers**
- **Data governance** = protecting data assets, refining them, and making them
  available to the organization or outside stakeholders. A long-standing concern
  in information systems, now acute in statistics and the social sciences: the
  creation and sharing of new data sources has grown exponentially while
  governance practice has not kept pace.
- **Meet analysts where they are.** Governance frameworks that demand complex
  schemas and unfamiliar data-type ontologies fail most analysts and academics.
  datagoodr is organized around **familiar data types and CSV files** — the
  default currency of the scientific world and organizational analysts.
- **Rule-based governance.** You write the *name* of a rule in a DGF cell and the
  package applies it; governance is declarative, portable, and reproducible, and
  a rule in the wrong place is visible on sight.
- The DGF travels *with* the data (embedded in the governed CSV), so the contract
  and its lineage are not a detachable sidecar.

**Shows.** The DGF as a spreadsheet a non-programmer edits; the rule columns and
their guards; the portability payoff (a governed CSV another tool can read).

---

## 4. Stabilizing Datasets

**Purpose.** How noisy, non-standard source formats become a **stable** version
that behaves — importing to the correct type where possible, and **safely** (no
data loss) where not.

**Covers**
- The two outcomes, stated plainly:
  - **Stabilized to type** — calendar dates (`03/15/2019` → ISO `2019-03-15`),
    booleans (`Y`/`yes`/`1` → logical), currency and compact numbers. These parse
    to the right R type on reload.
  - **Stabilized safely** — things a CSV cannot losslessly type (factors,
    identifiers) **default to text but are protected**: leading zeros preserved
    (`06037` stays `06037`, never `6037`), long IDs not cast to lossy doubles.
    "Safe" means the governed file never imports in a way that loses information.
- The **storage-safety gate**: why a confident "this is a number" guess is
  refused on a zero-padded key — the single rule that protects every FIPS, ZIP,
  EIN, NAICS column.
- Stabilization as the v7 `read :: [convert] :: write` plan, previewed before it
  runs (`stable_first5`) so a mis-parsed date is caught on sight.

**Shows.** A before/after table: raw messy values on the left, the stabilized
column and its reload type on the right, for a date, a boolean, a factor, and a
zero-padded code.

---

## 5. Data Profiling

**Purpose.** Profiling as what makes data **transparent and auditable** — every
column gets a measured description, stored in the DGF, not a human's say-so.

**Covers**
- **Universal quality metrics**, captured for every column: **Distinct** count,
  **Missing/NA** and **Missing/Empty**, **Zero**, **Infinite**, and
  **Duplicated** — each as a count and a percentage, reported only when it occurs
  so the profile stays honest about what is actually present.
- **Type-specific indicators**: numeric columns add the quantile ladder
  (min, Q05/Q25/median/Q75/Q95, max) plus mean, skew, and kurtosis; categorical
  columns get level frequencies; temporal columns get grain and coverage.
- **How the DGF logs and stores profiles.** The `rg_*` columns
  (`rg_properties`, `rg_preview`, `rg_stats`, `rg_graphics`, `rg_max_chr`) hold
  each column's profile as JSON, so a profile travels in the DGF and survives the
  `.xlsx` round trip. Re-profiling (`update_dgf()`) recomputes them against the
  current data.

**Shows.** A single column's full profile record, and how the same five `rg_`
cells are read back to render the guide in #6.

---

## 6. Data Profiles & Research Guides

**Purpose.** How datagoodr gets from a brand-new dataset to **stable
documentation as fast as possible** — formex types the columns, default guide
templates render them, and the analyst is left only the meaning to add.

**Covers**
- The fast path: `create_dgf()` types every column via **formex** and attaches a
  default profile, so a first, publishable Research Guide exists before any hand
  curation.
- **One guide, many reporting styles — chosen by type.** The renderer dispatches
  on the column's type:
  - number → **histogram** + quantile table
  - categorical → **treemap** + frequency table
  - temporal (calendar) → **calendar heat-map**
  - boolean → **boolean bar**
  - text → **word cloud** + length/sample
- How typing quality drives guide quality (links to **Guessing Data Types** for
  the detail).

**Shows.** The same dataset rendered as a guide, with each column type showing
its distinct visual — a gallery of the reporting styles.

---

## 7. Documenting Data with the DGF

**Purpose.** How the DGF turns documentation into a **fill-in-the-blanks
spreadsheet task**, and how those entries become the published guide.

**Covers**
- The DGF pre-creates **template fields** the analyst completes: variable labels
  and descriptions (`dd_vlabel`, `dd_vdesc`), and — the key convenience — a
  **per-level template for factors** (`dd_f_levels`), so a coded `1`–`5` gets a
  row per level waiting for a human-readable label and definition, edited in
  Excel.
- Why this is the right division of labor: the machine measures and types; the
  human supplies meaning the data cannot carry.
- **How the entries translate downstream** *(completing the outline's cut-off
  sentence — confirm this is what you meant)*: the curated `dd_*` text flows into
  the rendered **Research Guide**, and the portable `dd_`/`stable_`/`validate_`
  families are **embedded in the governed CSV**, so labels and definitions travel
  with the data to the next tool or repository (and map toward archival standards
  like DDI).

**Shows.** A factor before and after labeling — the blank `dd_f_levels` template,
the filled-in version, and the labeled result in the rendered guide.

---

## Notes where the outline meets the current code

1. **Entropy is not computed today.** The outline lists entropy as a universal
   metric; datagoodr currently captures Distinct / Missing / Zero / Infinite /
   Duplicated, not entropy. Options: drop it from #5, or add an `entropy` (and
   perhaps a categorical-balance) metric to `get_stats()` first and then document
   it. Recommend deciding before #5 is written.
2. **Your last sentence was cut off** ("how those get translated to…"). I
   completed #7 as *translated to the rendered Research Guide and the portable
   metadata embedded in the governed CSV* — correct me if you meant something
   else (e.g. a specific export format).
3. **Two existing vignettes fold in.** `data-governance-workflow.Rmd` becomes #3
   (reframed), and `guessing-data-types.Rmd` sits behind #6 as the typing
   reference. If you'd rather keep #3 as-is and add the governance argument as a
   preface, say so.
4. **pkgdown ordering** is set in `_pkgdown.yml` under `articles:`; I'd add an
   explicit article index so the menu reads 1→7 rather than alphabetically.
5. **Scope of examples.** #2's "glimpse" and #6's "gallery" need a small, vivid
   demo dataset that has one column of each type. `data-dev/` has demo data we can
   reuse or trim so every vignette tells the story on the same table.

## Suggested build order

#1 and #2 first (they frame everything and need only screenshots of existing
output), then #4 and #5 (concrete, code-light), then #6 and #7 (which depend on
the profiling and documentation vocabulary the earlier ones establish), and #3
last as a revision. One shared demo dataset throughout.
