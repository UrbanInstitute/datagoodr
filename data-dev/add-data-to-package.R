### Adding data to package


## Small 990 dataset for example purposes
example.df <- readr::read_csv("data-dev/DEMO-DATA-SMALL.csv" )

usethis::use_data(
  example.df,
  overwrite = TRUE
)


## DGF with all default options
dgf <- readxl::read_xlsx("working-example/DGF-V1.xlsx")
usethis::use_data(
  dgf,
  overwrite = TRUE
)

## DGF with formatting options
dgf.detailed <- readxl::read_xlsx("working-example/DGF-V2.xlsx")
usethis::use_data(
  dgf.detailed,
  overwrite = TRUE
)

## how dgf.detailed was created.
# dgf.blank <- readxl::read_xlsx("data-dev/DGF-CORE-CO-2019-blank.xlsx" )
# keep <- dgf.blank[, c("vname", "dd_desc", "data_type_convert", "data_type_format") ]
#
# info <- readr::format_csv(keep)
# info
# cat(info)
# readr::read_csv(info)


# create_dgf(df,
#            vdesc = dgf.blank$dd_desc,
#            vconvert = dgf.blank$data_type_convert,
#            vformat = dgf.blank$data_type_format,
#            file = "working-example/DGF-V2"
# )

#
# info <- "vname,dd_desc,data_type_convert,data_type_format\n
# F9_00_ORG_NAME_L1,Organization name line 1,NA,NA\n
# F0_00_ORG_CONTACT,Contact person (from IRS files),NA,NA\n
# F9_00_ORG_ADDR_L1,Organization street address line 1,NA,NA\n
# F9_00_ORG_ADDR_CITY,Organization city,NA,NA\n
# EIN,EIN,as.character,as_EIN\n
# SUBSECCD,IRS subsection code,NA,NA\n
# BMF_ACTIV1,IRS Activity Code 1,as.factor,NA\n
# NTMAJ12,NTEE major group (12),NA,NA\n
# NTEE1,NTEE major group,NA,NA\n
# NTEEFINAL,NA,as.factor,NA\n
# NTEESRC,NA,NA,NA\n
# DEDUCTCD,IRS Deductibility code,NA,NA\n
# OUTREAS,Reason why out of scope,as.factor,NA\n
# F9_05_UBIZ_IMCOME_OVER_LIMIT_X,\"Had unrelated business gross income of $1,000 or more\",as.factor,NA\n
# OUTNCCS,Out of Scope flag,as.factor,NA\n
# COUNTY_FIPS,State + County FIPS code,NA,NA\n
# CEO_CENSUSTRACT,Census tract,NA,NA\n
# F9_00_TAX_PERIOD_END_DATE,Tax period end date,NA,as_yyyymm\n
# F9_00_TAX_PERIOD_END_DATE_PY,Tax period end date - prior year,NA,as_yyyymm\n
# F9_00_TAX_PERIOD_BEGIN_DATE,Tax period begin date,as.character,as_yyyymm\n
# F9_00_TAX_ACCPER,Tax period end date,NA,as_mm\n
# F9_08_REV_TOT_TOT,Total revenue - total,NA,NA\n
# F9_10_ASSET_TOT_BOY,Total assets - beginning of year,NA,NA\n
# F9_10_ASSET_TOT_EOY,Total assets - end of year,NA,NA\n
# F9_10_NAFB_TOT_BOY,Net assets or fund balances - beginning of year,NA,NA\n
# F9_09_EXP_TOT_TOT,Total functional expenses - total expenses,NA,NA\n
# F9_01_EXP_TOT_PY,Total expenses - prior year,NA,NA\n"
#
# cat(info)
# info <- readr::read_csv(info)
#
# create_dgf(df,
#            vdesc = info$dd_desc,
#            vconvert = info$data_type_convert,
#            vformat = info$data_type_format,
#            file = "dgf-detailed"
# )




