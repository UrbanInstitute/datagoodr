#' Example IRS990 Data Set
#'
#' A toy example of IRS990 data to be documented with datagoodr
#' @name example.df
#' @format A data frame with 25,000 rows and 27 variables:
#' \describe{
#'   \item{F9_00_ORG_NAME_L1}{Organization name line 1}
#'   \item{F0_00_ORG_CONTACT}{Contact person (from IRS files)}
#'   \item{F9_00_ORG_ADDR_L1}{Organization street address line 1}
#'   \item{F9_00_ORG_ADDR_CITY}{Organization city}
#'   \item{EIN}{EIN}
#'   \item{SUBSECCD}{IRS subsection code}
#'   \item{BMF_ACTIV1}{IRS Activity Code 1}
#'   \item{NTMAJ12}{NTEE major group (12)}
#'   \item{NTEE1}{NTEE major group}
#'   \item{NTEEFINAL}{NA}
#'   \item{NTEESRC}{NA}
#'   \item{DEDUCTCD}{IRS Deductibility code}
#'   \item{OUTREAS}{Reason why out of scope}
#'   \item{F9_05_UBIZ_IMCOME_OVER_LIMIT_X}{Had unrelated business gross income of \$1,000 or more}
#'   \item{OUTNCCS}{Out of Scope flag}
#'   \item{COUNTY_FIPS}{State + County FIPS code}
#'   \item{CEO_CENSUSTRACT}{Census tract}
#'   \item{F9_00_TAX_PERIOD_END_DATE}{Tax period end date}
#'   \item{F9_00_TAX_PERIOD_END_DATE_PY}{Tax period end date - prior year}
#'   \item{F9_00_TAX_PERIOD_BEGIN_DATE}{Tax period begin date}
#'   \item{F9_00_TAX_ACCPER}{Tax period end date}
#'   \item{F9_08_REV_TOT_TOT}{Total revenue - total}
#'   \item{F9_10_ASSET_TOT_BOY}{Total assets - beginning of year}
#'   \item{F9_10_ASSET_TOT_EOY}{Total assets - end of year}
#'   \item{F9_10_NAFB_TOT_BOY}{Net assets or fund balances - beginning of year}
#'   \item{F9_09_EXP_TOT_TOT}{Total functional expenses - total expenses}
#'   \item{F9_01_EXP_TOT_PY}{Total expenses - prior year}
#' }
#'
#' @details See \url{https://nonprofit-open-data-collective.github.io/irs990efile/data-dictionary/data-dictionary.html} for full data dictionary.
NULL


#' DGF Default
#'
#' An example of a generated DGF with all default options.
#' @name dgf
#' @format Result of \link{create_dgf} with \link{example.df} data.
#' @details This data set was generated using the code in the example section of this help file.
#' @examples
#' \dontrun{
#' data(df)
#' create_dgf(df, file = "dgf")
#' }
NULL


#' DGF Detailed
#'
#' An example of a generated DGF with formatting options.
#' @name dgf.detailed
#' @format Result of \link{create_dgf} with \link{example.df} data using formatting options.
#' @details This data set was generated using the code in the example section of this help file.
#' See datagoodr/working-example/README.md for more details on how this dgf was created.
#' See datagoodr/R/02-02-ingest-utils.R for the non base R functions in `info$data_type_format` in the example below.
#' @examples
#' \dontrun{
#' data(df)
#'
#' # Add additional info for formatting
#' info <- "vname,dd_desc,data_type_convert,data_type_format\n
#'   F9_00_ORG_NAME_L1,Organization name line 1,NA,NA\n
#'   F0_00_ORG_CONTACT,Contact person (from IRS files),NA,NA\n
#'   F9_00_ORG_ADDR_L1,Organization street address line 1,NA,NA\n
#'   F9_00_ORG_ADDR_CITY,Organization city,NA,NA\n
#'   EIN,EIN,as.character,as_EIN\n
#'   SUBSECCD,IRS subsection code,NA,NA\n
#'   BMF_ACTIV1,IRS Activity Code 1,as.factor,NA\n
#'   NTMAJ12,NTEE major group (12),NA,NA\n
#'   NTEE1,NTEE major group,NA,NA\n
#'   NTEEFINAL,NA,as.factor,NA\n
#'   NTEESRC,NA,NA,NA\n
#'   DEDUCTCD,IRS Deductibility code,NA,NA\n
#'   OUTREAS,Reason why out of scope,as.factor,NA\n
#'   F9_05_UBIZ_IMCOME_OVER_LIMIT_X,\"Had unrelated business gross income of $1,000 or more\",as.factor,NA\n
#'   OUTNCCS,Out of Scope flag,as.factor,NA\n
#'   COUNTY_FIPS,State + County FIPS code,NA,NA\n
#'   CEO_CENSUSTRACT,Census tract,NA,NA\n
#'   F9_00_TAX_PERIOD_END_DATE,Tax period end date,NA,as_yyyymm\n
#'   F9_00_TAX_PERIOD_END_DATE_PY,Tax period end date - prior year,NA,as_yyyymm\n
#'   F9_00_TAX_PERIOD_BEGIN_DATE,Tax period begin date,as.character,as_yyyymm\n
#'   F9_00_TAX_ACCPER,Tax period end date,NA,as_mm\n
#'   F9_08_REV_TOT_TOT,Total revenue - total,NA,NA\n
#'   F9_10_ASSET_TOT_BOY,Total assets - beginning of year,NA,NA\n
#'   F9_10_ASSET_TOT_EOY,Total assets - end of year,NA,NA\n
#'   F9_10_NAFB_TOT_BOY,Net assets or fund balances - beginning of year,NA,NA\n
#'   F9_09_EXP_TOT_TOT,Total functional expenses - total expenses,NA,NA\n
#'   F9_01_EXP_TOT_PY,Total expenses - prior year,NA,NA\n"
#'
#' cat(info)
#' info <- readr::read_csv(info)
#'
#' create_dgf(df,
#'            vdesc = info$dd_desc,
#'            vconvert = info$data_type_convert,
#'            vformat = info$data_type_format,
#'            file = "dgf-detailed")
#' }
NULL






