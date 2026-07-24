##############################
### Guess-based DGF type enrichment
###############################
## Runs guess_data_type() over each column of the raw data and refines the
## coarse R-storage typing that create_dgf() starts from:
##   * fills the (blank) desired_data_subtype / desired_data_class with ontology
##     coordinates when a detector confidently matches;
##   * refines desired_data_type for coarse ("text") columns and for strong
##     semantic guesses (temporal / identifier);
##   * promotes a geographic CATEGORICAL to an IDENTIFIER when the column is
##     near-unique (a key, not a grouping var), and flags dd_is_join_key.
##
## It is intentionally conservative: it never overrides a number/categorical/
## boolean base type from a loose detector, so a count column that happens to
## look like a Unix timestamp stays a number. Columns with no confident match
## are left exactly as create_dgf() typed them.


## ontology data_type -> the DGF's desired_data_type vocabulary. structured and
## unknown fall back to text, which the render engine handles via the character
## path (dg_type_of / .dgf_vclass_of).
#' @keywords internal
#' @noRd
.ontology_to_dgf_type <- function(t) {
  switch(t,
    number      = "number",
    categorical = "categorical",
    boolean     = "boolean",
    temporal    = "temporal",
    identifier  = "identifier",
    text        = "text",
    structured  = "text",
    unknown     = "text",
    "text")
}

## temporal ontology class -> the DGF stable_data_unit that selects the render
## graphic. The detector library is the single source of truth for a temporal
## column's unit; create_dgf() falls back to a storage-class default (date/hour)
## only for a temporal the guess left unmapped.
#' @keywords internal
#' @noRd
.temporal_unit <- function(cls) {
  switch(cls,
    calendar_date = "date", timestamp = "date", date_range = "date",
    time_of_day = "hour", hour_of_day = "hour",
    year = "year", quarter = "quarter", semester = "semester",
    season = "season", season_of_year = "season",
    month = "month", month_of_year = "month",
    reporting_period = "period",
    day_of_week = "dow", week_of_year = "week",
    "date")
}

#' Refine DGF types from the detector library
#'
#' @param df The raw data frame (columns to profile).
#' @param base_type Character vector of the create_dgf base `desired_data_type`
#'   per column (ontology vocabulary), same length/order as `names(df)`.
#' @param distinct_threshold Share of distinct non-missing values above which a
#'   geographic categorical is promoted to an identifier (a key).
#'
#' @return A data frame, one row per column, with `desired_data_type`,
#'   `desired_data_subtype`, `desired_data_class`, `stable_data_unit`, and
#'   `dd_is_join_key` --- the refined values create_dgf() should use. Columns
#'   with no confident guess carry the base type and blank subtype/class/unit.
#' @keywords internal
#' @noRd
guess_dgf_types <- function(df, base_type, distinct_threshold = 0.9) {
  vars <- names(df)
  out <- data.frame(
    desired_data_type    = base_type,
    desired_data_subtype = rep("", length(vars)),
    desired_data_class   = rep("", length(vars)),
    stable_data_unit     = rep("", length(vars)),
    dd_is_join_key      = rep("", length(vars)),
    stringsAsFactors = FALSE
  )

  for (i in seq_along(vars)) {
    vals <- as.character(df[[i]])
    g <- guess_data_type(vals, name = vars[i])
    if (is.na(g$guess)) next

    o     <- g$ontology
    otype <- o[["data_type"]]
    gtype <- .ontology_to_dgf_type(otype)
    sub   <- o[["data_subtype"]]
    cls   <- o[["data_class"]]

    nn  <- vals[!is.na(vals) & nzchar(trimws(vals))]
    pct <- if (length(nn)) length(unique(nn)) / length(nn) else 0

    ## cardinality promotion: a near-unique geographic categorical is a key
    if (otype == "categorical" && cls == "geography" && pct >= distinct_threshold) {
      gtype <- "identifier"
      sub   <- if (all(grepl("^[0-9]+$", unique(nn)))) "numeric_id" else "text_id"
      cls   <- "geographic_id"
    }

    ## only OVERRIDE the base type when it is coarse ("text") or the guess is
    ## a strong semantic signal (temporal/identifier) from a NON-loose detector
    loose <- g$guess %in% .loose_detectors
    override <- (base_type[i] == "text") ||
                (gtype %in% c("temporal", "identifier") && !loose)

    if (override) {
      out$desired_data_type[i] <- gtype
    } else if (gtype != base_type[i]) {
      ## base kept but guess disagrees -> don't stamp an inconsistent class
      next
    }
    out$desired_data_subtype[i] <- sub
    out$desired_data_class[i]   <- cls
    ## the detector library owns the temporal unit (its class knows the grain)
    if (out$desired_data_type[i] == "temporal")
      out$stable_data_unit[i] <- .temporal_unit(cls)
    ## flag a join key when the column is an identifier AND near-unique
    if (out$desired_data_type[i] == "identifier" && pct >= distinct_threshold) {
      out$dd_is_join_key[i] <- "TRUE"
    }
  }
  out
}
