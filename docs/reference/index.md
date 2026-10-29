# Package index

## All functions

- [`abbrev_num()`](abbrev_num.md) : Abbreviate numbers for compact,
  uniform axis/graphic labels
- [`align_dec()`](align_dec.md) : Pad a column of formatted numbers so
  their decimal points align
- [`apply_name_aliases()`](apply_name_aliases.md) : Rename raw columns
  to their DGF variable names
- [`apply_raw_convert_fx()`](apply_raw_convert_fx.md) : Apply DGF
  type-conversion functions to raw columns
- [`as_id()`](as_id.md) : Coerce a column to an identifier (character,
  trimmed)
- [`boolebar()`](boolebar.md) : Draw a boolean variable as one divided
  bar
- [`booleplot()`](booleplot.md) : Draw a compact horizontal bar plot
  with consistent bar geometry
- [`check_dgf_rules()`](check_dgf_rules.md) : Check that a DGF's rules
  still fit the data
- [`check_length()`](check_length.md) : Check and standardize design
  element length
- [`create_all_sections()`](create_all_sections.md) : Create sections
  for all variables in a DGF
- [`create_dd()`](create_dd.md) : Create a data dictionary project from
  a DGF
- [`create_dgf()`](create_dgf.md) : create DGF file
- [`create_dgf_skeleton()`](create_dgf_skeleton.md) : Create an empty v2
  DGF skeleton
- [`create_div()`](create_div.md) : Create all non-level-1 div section
  in markdown
- [`create_div1()`](create_div1.md) : Create a level-1 div section in
  markdown
- [`create_rg()`](create_rg.md) : Create a research guide project from a
  DGF
- [`create_section()`](create_section.md) : Create a section for a
  variable
- [`datagoodr()`](datagoodr.md) : Generate DGF and RG
- [`datagoodr_css()`](datagoodr_css.md) : Return the datagoodr report
  stylesheet
- [`dgf_from_stable()`](dgf_from_stable.md) : Rebuild a DGF from a
  stable CSV read
- [`dg_baseball`](dg_baseball.md) : Baseball players: a messy test
  dataset
- [`dg_baseball_dictionary`](dg_baseball_dictionary.md) : Data
  dictionary for the baseball test dataset
- [`dg_demo`](dg_demo.md) : Demo dataset for the datagoodr vignettes
- [`dg_stats()`](dg_element.md) [`dg_properties()`](dg_element.md)
  [`dg_quantiles()`](dg_element.md) [`dg_preview()`](dg_element.md)
  [`dg_levels()`](dg_element.md) [`dg_graphic()`](dg_element.md)
  [`dg_field()`](dg_element.md) : Render one element of a variable's
  profile
- [`dg_render_type()`](dg_render_type.md) : Pick the Research Guide
  template for each variable
- [`dg_section()`](dg_section.md) : Render one variable's full profile
  section
- [`dollarize()`](dollarize.md) : Format Numeric Values as Dollar
  Amounts
- [`draft_detector_prompt()`](draft_detector_prompt.md) : Draft a
  copy-paste prompt asking an LLM to write a new type detector
- [`draft_factor_labels_prompt()`](draft_factor_labels_prompt.md) :
  Draft a copy-paste prompt asking an LLM to label factor levels
- [`evaluate_detector()`](evaluate_detector.md) : Score a candidate
  detector against generated test cases
- [`first_n()`](first_n.md) : Extract and Format the First N Unique
  Values from a Vector
- [`get_class_df()`](get_class_df.md) : Summarise the class and an
  example value for each column
- [`get_design()`](get_design.md) : Compile the section design for each
  variable type
- [`get_dupes()`](get_dupes.md) : Identify and Print Duplicate Variables
  in a Data Frame
- [`get_graphics()`](get_graphics.md) : Generate Graphics Based on
  Variable Type
- [`get_json_error()`](get_json_error.md) : Return the parse error for
  an invalid JSON string
- [`get_levels()`](get_levels.md) : Return a factor's levels as a single
  delimited string
- [`get_properties()`](get_properties.md) : Generate Table of Properties
- [`get_stats()`](get_stats.md) : Generate Statistics Based on Variable
  Type
- [`ingest_raw()`](ingest_raw.md) : Ingest a raw dataset using DGF rules
  (Step 2, work in progress)
- [`inspect_dgf()`](inspect_dgf.md) : Validate a DGF before rendering
  (Step 2)
- [`is_factor()`](is_factor.md) : Guess whether a vector should be
  treated as a factor
- [`is_factor_df()`](is_factor_df.md) : Guess factor columns across a
  data frame
- [`jsonify_f()`](jsonify_f.md) : Convert a factor's levels to a
  formatted JSON string
- [`load_dgf()`](load_dgf.md) : Load DGF from DGF Excel Sheet
- [`log_message()`](log_message.md) : Write a message to a log file (and
  optionally the console)
- [`parse_design()`](parse_design.md) : Parse design strings into a data
  frame
- [`parse_functions()`](parse_functions.md) : Collect and check the
  conversion functions named in a DGF
- [`parse_nm()`](parse_nm.md) : Split a delimited alias string into
  unique names
- [`paste_boolebar()`](paste_boolebar.md) : Print a boolean variable's
  divided bar into the RG
- [`paste_booleplot()`](paste_booleplot.md) : Print the bar plot of a
  logical variable into the RG
- [`paste_distribution_shape()`](paste_distribution_shape.md) : Print
  the DISTRIBUTION SHAPE table (skew / kurtosis) into the RG
- [`paste_histogram()`](paste_histogram.md) : Print the histogram of a
  numeric variable into the RG
- [`paste_label()`](paste_label.md) : Print just a section label (no
  content) into the RG
- [`paste_levels()`](paste_levels.md) : Print the level dictionary of a
  factor/logical variable into the RG
- [`paste_levels_freq()`](paste_levels_freq.md) : Print the combined
  FACTOR LEVELS table into the RG
- [`paste_levels_horizontal()`](paste_levels_horizontal.md) : Print the
  logical CATEGORY LABELS transposed across a full-width row
- [`paste_preview_chr()`](paste_preview_chr.md) : Print Preview of a
  Character Variable into RG
- [`paste_preview_num()`](paste_preview_num.md) : Print Preview of a
  Numeric Variable into RG
- [`paste_properties()`](paste_properties.md) : Print Properties of a
  Variable into RG
- [`paste_properties_horizontal()`](paste_properties_horizontal.md) :
  Print the PROPERTIES table transposed across one row
- [`paste_quantiles()`](paste_quantiles.md) : Print the quantiles of a
  numeric variable into the RG
- [`paste_stats_chr()`](paste_stats_chr.md) : Print Statistic of a
  Character Variable into RG
- [`paste_stats_chr_common()`](paste_stats_chr_common.md) : Print the
  most common strings of a character variable into the RG
- [`paste_stats_combined()`](paste_stats_combined.md) : Print the
  combined STATS table (summary + quantiles) into the RG
- [`paste_stats_fact()`](paste_stats_fact.md) : Print Statistic of a
  Factor Variable into RG
- [`paste_stats_horizontal()`](paste_stats_horizontal.md) : Print the
  numeric STATS transposed across a full-width row
- [`paste_stats_log()`](paste_stats_log.md) : Print Statistic of a
  Logical Variable into RG
- [`paste_stats_num()`](paste_stats_num.md) : Print Statistic of a
  Numeric Variable into RG
- [`paste_treemap()`](paste_treemap.md) : Print Graphics of a Factor
  Variable into RG
- [`preflight_dgf()`](preflight_dgf.md) : Check a dataset for degenerate
  columns before building a DGF
- [`rail_contents()`](rail_contents.md) : Print the research guide's top
  bar and contents list
- [`rail_groups()`](rail_groups.md) : Split a DGF into the research
  guide's data-type groups
- [`rail_sections()`](rail_sections.md) : Print one data-type group of
  the research guide
- [`read_date()`](read_date.md) [`read_datetime()`](read_date.md)
  [`read_yyyymmdd()`](read_date.md) [`read_mmddyyyy()`](read_date.md)
  [`read_ddmmyyyy()`](read_date.md) [`read_mdyyyy()`](read_date.md)
  [`read_dMyyyy()`](read_date.md) [`read_Mdyyyy()`](read_date.md)
  [`read_yyyymmddHHiiss()`](read_date.md)
  [`read_mmddyyyyhhiiA()`](read_date.md) : Read dates/datetimes written
  in a compact format
- [`read_ein()`](read_ein.md) : Read an EIN written in any common form
- [`read_mm()`](read_mm.md) : Read a month number written at any width
- [`read_render_record()`](read_render_record.md) : Recover the render
  record from a rendered report
- [`read_stable_csv()`](read_stable_csv.md) : Read a stable CSV,
  recovering data and embedded provenance
- [`read_yyyy()`](read_yyyy.md) : Read a year, plain or fiscal-year
  labelled
- [`read_yyyymm()`](read_yyyymm.md) : Read a compact YYYYMM value
- [`recast_factors()`](recast_factors.md) : Convert guessed factor
  columns to factors
- [`rename_all()`](rename_all.md) : Rename data frame columns using an
  alias mapping
- [`render_record()`](render_record.md) : Record what produced this
  report
- [`replace_name()`](replace_name.md) : Replace variable names matching
  an alias
- [`retype_dgf()`](retype_dgf.md) : Correct a variable's type in a DGF
  and re-profile it
- [`save_to_excel()`](save_to_excel.md) : Saves DGF to excel
- [`show_invalid()`](show_invalid.md) : Print the invalid JSON cells in
  a vector
- [`stabilize_data()`](stabilize_data.md) : Standardize a raw dataset
  with a DGF's rules
- [`update_dgf()`](update_dgf.md) : Refresh a DGF against updated data
  (Step 4)
- [`update_rg()`](update_rg.md) : Re-render an existing report against a
  different DGF or dataset
- [`use_datagoodr_template()`](use_datagoodr_template.md) : Copy a
  datagoodr report template into a project
- [`validate_json()`](validate_json.md) : Check whether each element of
  a vector is valid JSON
- [`v_to_wordcloud()`](v_to_wordcloud.md) : Print Graphics of a
  character Variable into RG
- [`wrap_preview()`](wrap_preview.md) : Wrap preview values into a text
  block
- [`write_stable_csv()`](write_stable_csv.md) : Write a data frame to a
  stable CSV with embedded provenance
