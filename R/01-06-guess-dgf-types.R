##############################
### Guess-based DGF type enrichment
###############################
## Runs guess_data_type() over each column of the raw data and refines the
## coarse R-storage typing that create_dgf() starts from:
##   * fills the (blank) desired_data_class with the ontology role, written as
##     `class.subclass` (dotted), when a detector confidently matches;
##   * refines desired_data_type for coarse ("text") columns and for strong
##     semantic guesses (temporal / identifier);
##   * promotes a geographic CATEGORICAL to an IDENTIFIER when the column is
##     near-unique (a key, not a grouping var), and flags dd_is_join_key.
##
## The detector-library crosswalk (.data_type_ontology) still speaks the legacy
## (type, subtype, class, format) vocabulary; .to_class_subclass() translates a
## detector's (subtype, class, format) into the v4 ontology's `class.subclass`
## so the DGF carries the new coordinates without re-authoring the crosswalk.
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

## Legacy crosswalk (subtype, class, format) -> v4 `class.subclass`. Keyed on the
## legacy data_class, with data_subtype disambiguating hash IDs and data_format
## naming the color model. Returns "" for a class with no v4 mapping (e.g. a
## bare number, whose default class is left blank).
#' @keywords internal
#' @noRd
.to_class_subclass <- function(subtype, cls, fmt) {
  switch(cls,
    category            = "mutually_exclusive.unordered",
    group               = "mutually_exclusive.unordered",
    geography           = "mutually_exclusive.geographic",
    classification_code = "mutually_exclusive.classification_code",
    administrative_code = "mutually_exclusive.classification_code",
    ordered_category    = "mutually_exclusive.ordered",
    missingness_reason  = "mutually_exclusive.missingness_reason",
    email               = "contact.email",
    phone               = "contact.phone",
    url                 = "web.url",
    network_address     = "web.ip",
    color               = paste0("color.", if (nzchar(fmt)) fmt else "hex"),
    address             = "postal.full",
    person_name         = "name.person",
    organization_name   = "name.organization",
    place_name          = "name.place",
    label               = "text.label",
    title               = "text.title",
    text                = "text.long",
    long_text           = "text.long",
    record_id           = if (identical(subtype, "hash_id")) "id.hash" else "id.record",
    entity_id           = "id.entity",
    administrative_id   = "id.administrative",
    geographic_id       = "id.geographic",
    version_id          = "id.version",
    calendar_date       = "date.calendar",
    timestamp           = "date.timestamp",
    time_of_day         = "time.clock",
    year                = "period.year",
    quarter             = "period.quarter",
    month               = "period.month",
    semester            = "period.semester",
    season              = "period.season",
    reporting_period    = "period.reporting_period",
    hour_of_day         = "phase.hour_of_day",
    day_of_week         = "phase.day_of_week",
    week_of_year        = "phase.week_of_year",
    month_of_year       = "phase.month_of_year",
    season_of_year      = "phase.season_of_year",
    date_range          = "interval.date_range",
    currency            = "currency.usd",
    "")
}

## v4 temporal `class.subclass` -> the render grain that selects the graphic.
## Replaces the old stable_data_unit lookup: the render engine now derives the
## grain from desired_data_class, so the grain travels with the type, not a
## separate unit column.
#' @keywords internal
#' @noRd
.temporal_grain <- function(class_subclass) {
  sub <- sub("^[^.]*\\.?", "", as.character(class_subclass))  # drop the class part
  switch(sub,
    calendar = "date", timestamp = "date", date_range = "date",
    clock = "hour", hour_of_day = "hour",
    year = "year", quarter = "quarter",
    month = "month", month_of_year = "month",
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
#'   `desired_data_class` (dotted `class.subclass`), and `dd_is_join_key` --- the
#'   refined values create_dgf() should use. Columns with no confident guess
#'   carry the base type and a blank class.
#' @keywords internal
#' @noRd
guess_dgf_types <- function(df, base_type, distinct_threshold = 0.9) {
  vars <- names(df)
  out <- data.frame(
    desired_data_type  = base_type,
    desired_data_class = rep("", length(vars)),
    dd_is_join_key     = rep("", length(vars)),
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
    fmt   <- o[["data_format"]]
    cs    <- .to_class_subclass(sub, cls, fmt)

    nn  <- vals[!is.na(vals) & nzchar(trimws(vals))]
    pct <- if (length(nn)) length(unique(nn)) / length(nn) else 0

    ## cardinality promotion: a near-unique geographic categorical is a key
    if (otype == "categorical" && cls == "geography" && pct >= distinct_threshold) {
      gtype <- "identifier"
      cs    <- "id.geographic"
    }

    ## a column already typed identifier (by detect_identifier) that the
    ## detectors recognize as a geography is a geographic KEY.
    if (base_type[i] == "identifier" && otype == "categorical" && cls == "geography") {
      gtype <- "identifier"
      cs    <- "id.geographic"
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
    out$desired_data_class[i] <- cs
    ## flag a join key when the column is an identifier AND near-unique
    if (out$desired_data_type[i] == "identifier" && pct >= distinct_threshold) {
      out$dd_is_join_key[i] <- "TRUE"
    }
  }
  out
}
