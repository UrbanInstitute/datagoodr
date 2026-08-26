##############################
### Deprecated as_* rule names
###############################
## The rule functions that INGEST a written format were renamed `as_* -> read_*`
## so a name states its input format rather than implying it produces one (see
## the read_* / as_* split in R/01-07-read-rules.R). `as_id()` is unchanged --- it
## genuinely names an output type.
##
## These shims forward to the new names with a one-time warning, so DGFs whose
## rule cells still carry the old names keep running for one release. Four of
## them (as_EIN, as_mm, as_yyyy, as_yyyymm) are ALSO exported by formex with
## different behaviour, which is the other reason the rename happened; keeping
## them here as deprecated shims is deliberate and time-limited.
##
## Remove this file at the next minor version.

#' @keywords internal
#' @noRd
.dg_deprecated_env <- new.env(parent = emptyenv())

#' Warn once per session that a rule name is deprecated (internal)
#' @keywords internal
#' @noRd
.dg_deprecate <- function(old, new) {
  if (is.null(.dg_deprecated_env[[old]])) {
    .dg_deprecated_env[[old]] <- TRUE
    warning(old, "() is deprecated and will be removed; use ", new, "(). ",
            "A DGF rule cell naming ", old, " should be updated to ", new, ".",
            call. = FALSE)
  }
  invisible(NULL)
}

#' Deprecated `as_*` rule names
#'
#' Renamed to `read_*` to state the format each one *ingests*. Each shim
#' forwards to its replacement and warns once per session.
#'
#' @param x,format,tz Passed through to the replacement function.
#' @return Whatever the replacement returns.
#' @name datagoodr-deprecated
#' @seealso [read_date()], [read_ein()]
#' @keywords internal
NULL

#' @rdname datagoodr-deprecated
#' @export
as_date <- function(x, format, tz = "UTC") {
  .dg_deprecate("as_date", "read_date"); read_date(x, format, tz)
}
#' @rdname datagoodr-deprecated
#' @export
as_datetime <- function(x, format, tz = "UTC") {
  .dg_deprecate("as_datetime", "read_datetime"); read_datetime(x, format, tz)
}
#' @rdname datagoodr-deprecated
#' @export
as_yyyymmdd <- function(x) { .dg_deprecate("as_yyyymmdd", "read_yyyymmdd"); read_yyyymmdd(x) }
#' @rdname datagoodr-deprecated
#' @export
as_mmddyyyy <- function(x) { .dg_deprecate("as_mmddyyyy", "read_mmddyyyy"); read_mmddyyyy(x) }
#' @rdname datagoodr-deprecated
#' @export
as_ddmmyyyy <- function(x) { .dg_deprecate("as_ddmmyyyy", "read_ddmmyyyy"); read_ddmmyyyy(x) }
#' @rdname datagoodr-deprecated
#' @export
as_mdyyyy <- function(x) { .dg_deprecate("as_mdyyyy", "read_mdyyyy"); read_mdyyyy(x) }
#' @rdname datagoodr-deprecated
#' @export
as_dMyyyy <- function(x) { .dg_deprecate("as_dMyyyy", "read_dMyyyy"); read_dMyyyy(x) }
#' @rdname datagoodr-deprecated
#' @export
as_Mdyyyy <- function(x) { .dg_deprecate("as_Mdyyyy", "read_Mdyyyy"); read_Mdyyyy(x) }
#' @rdname datagoodr-deprecated
#' @export
as_yyyymmddHHiiss <- function(x) {
  .dg_deprecate("as_yyyymmddHHiiss", "read_yyyymmddHHiiss"); read_yyyymmddHHiiss(x)
}
#' @rdname datagoodr-deprecated
#' @export
as_mmddyyyyhhiiA <- function(x) {
  .dg_deprecate("as_mmddyyyyhhiiA", "read_mmddyyyyhhiiA"); read_mmddyyyyhhiiA(x)
}
#' @rdname datagoodr-deprecated
#' @export
as_EIN <- function(x) { .dg_deprecate("as_EIN", "read_ein"); read_ein(x) }
#' @rdname datagoodr-deprecated
#' @export
as_mm <- function(x) { .dg_deprecate("as_mm", "read_mm"); read_mm(x) }
#' @rdname datagoodr-deprecated
#' @export
as_yyyy <- function(x) { .dg_deprecate("as_yyyy", "read_yyyy"); read_yyyy(x) }
#' @rdname datagoodr-deprecated
#' @export
as_yyyymm <- function(x) { .dg_deprecate("as_yyyymm", "read_yyyymm"); read_yyyymm(x) }
