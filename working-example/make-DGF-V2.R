###############################################################################
### Build a curated DGF-V2 for the demo data
###############################################################################
# create_dgf() produces the rough first pass; a human then curates it. This
# script fills in variable labels, descriptions, the ontology coordinates
# (subtype / class / format), and meaningful factor-level labels, so the
# rendered Research Guide shows what a *semi-complete* DGF looks like. Run from
# the package root:  Rscript working-example/make-DGF-V2.R

library(datagoodr)

raw <- "data-dev/DEMO-DATA-SMALL.csv"
dgf <- create_dgf(raw, dir = "working-example", file = "DGF-V2-tmp", open = FALSE)

## --- type corrections that change the render (re-profile) --------------------
# an 11-digit Census tract is a geographic identifier, not a quantity
dgf <- retype_dgf(dgf, raw, types = c(CEO_CENSUSTRACT = "identifier"))

## --- per-variable metadata ---------------------------------------------------
# each entry: label, description, and the ontology coordinates (blank = omit)
meta <- list(
  F9_00_ORG_NAME_L1 = list("Organization name",
    "Legal name of the filing organization (Form 990, header).",
    "phrase","organization_name","plain"),
  F0_00_ORG_CONTACT = list("Contact person",
    "Name of the organization's principal officer or contact.",
    "phrase","person_name","plain"),
  F9_00_ORG_ADDR_L1 = list("Street address",
    "Mailing street address of the organization.",
    "line","address","plain"),
  F9_00_ORG_ADDR_CITY = list("City",
    "City of the organization's mailing address.",
    "phrase","place_name","plain"),
  EIN = list("Employer Identification Number",
    "IRS-assigned 9-digit taxpayer ID; the unique key for the organization.",
    "numeric_id","administrative_id","plain"),
  SUBSECCD = list("IRS subsection code",
    "501(c) subsection under which the organization is tax-exempt.",
    "nominal","administrative_code","code"),
  BMF_ACTIV1 = list("BMF activity code",
    "Primary IRS Business Master File activity code (legacy numeric code).",
    "","",""),
  NTMAJ12 = list("NTEE major group (12-category)",
    "NCCS 12-category summary of the organization's NTEE classification.",
    "nominal","classification_code","code"),
  NTEE1 = list("NTEE major group",
    "First letter of the National Taxonomy of Exempt Entities code - the broad activity area.",
    "nominal","classification_code","code"),
  NTEEFINAL = list("NTEE code",
    "Full National Taxonomy of Exempt Entities code assigned to the organization.",
    "token","classification_code","code"),
  NTEESRC = list("NTEE source",
    "Method or source by which the NTEE code was assigned.",
    "nominal","category","code"),
  DEDUCTCD = list("Deductibility code",
    "Whether contributions to the organization are tax-deductible.",
    "nominal","administrative_code","code"),
  OUTREAS = list("Out-of-scope reason",
    "Reason the organization is excluded from the NCCS core file.",
    "nominal","category","code"),
  F9_05_UBIZ_IMCOME_OVER_LIMIT_X = list("UBI over filing threshold",
    "Whether unrelated business income exceeded the $1,000 filing threshold.",
    "","",""),
  OUTNCCS = list("In / out of NCCS core",
    "Whether the organization is included in the NCCS core file.",
    "","",""),
  COUNTY_FIPS = list("County (FIPS)",
    "5-digit Census county FIPS code of the organization's location.",
    "numeric_id","geographic_id","plain"),
  CEO_CENSUSTRACT = list("Census tract (GEOID)",
    "11-digit Census tract identifier of the organization's location.",
    "numeric_id","geographic_id","plain"),
  F9_00_TAX_PERIOD_END_DATE = list("Tax period end",
    "Year and month (YYYYMM) the reporting tax period ended.",
    "nominal","reporting_period","code"),
  F9_00_TAX_PERIOD_END_DATE_PY = list("Tax period end (prior year)",
    "Year and month the prior-year tax period ended.",
    "nominal","reporting_period","code"),
  F9_00_TAX_PERIOD_BEGIN_DATE = list("Tax period begin",
    "Fiscal-period start code for the reporting year.",
    "nominal","reporting_period","code"),
  F9_00_TAX_ACCPER = list("Accounting period",
    "Month in which the organization's fiscal year ends.",
    "ordinal","month_of_year","code"),
  F9_08_REV_TOT_TOT = list("Total revenue",
    "Total revenue for the year (Form 990, Part VIII).",
    "continuous","currency","currency"),
  F9_10_ASSET_TOT_BOY = list("Total assets (BOY)",
    "Total assets at the beginning of the year (Form 990, Part X).",
    "continuous","currency","currency"),
  F9_10_ASSET_TOT_EOY = list("Total assets (EOY)",
    "Total assets at the end of the year (Form 990, Part X).",
    "continuous","currency","currency"),
  F9_10_NAFB_TOT_BOY = list("Net assets (BOY)",
    "Net assets or fund balances at the beginning of the year.",
    "continuous","currency","currency"),
  F9_09_EXP_TOT_TOT = list("Total expenses",
    "Total functional expenses for the year (Form 990, Part IX).",
    "continuous","currency","currency"),
  F9_01_EXP_TOT_PY = list("Total expenses (prior year)",
    "Total expenses reported for the prior year.",
    "continuous","currency","currency")
)

# meta carries the legacy (subtype, class, format) coordinates; translate them
# to the v4 ontology's dotted `class.subclass` for desired_data_class.
for (v in names(meta)) {
  i <- match(v, dgf$var_name); if (is.na(i)) next
  m <- meta[[v]]
  dgf$dd_vlabel[i] <- m[[1]]
  dgf$dd_vdesc[i]  <- m[[2]]
  cs <- datagoodr:::.to_class_subclass(m[[3]], m[[4]], m[[5]])
  if (nzchar(cs)) dgf$desired_data_class[i] <- cs
}

## --- meaningful factor-level labels ------------------------------------------
labs <- list(
  SUBSECCD = c(
    "2"="501(c)(2) Title-holding corporation","4"="501(c)(4) Social welfare organization",
    "5"="501(c)(5) Labor / agricultural org","6"="501(c)(6) Business league",
    "7"="501(c)(7) Social & recreational club","8"="501(c)(8) Fraternal beneficiary society",
    "9"="501(c)(9) Voluntary employees' beneficiary assoc.","10"="501(c)(10) Domestic fraternal society",
    "11"="501(c)(11) Teachers' retirement fund","12"="501(c)(12) Benevolent life insurance / utility co-op",
    "13"="501(c)(13) Cemetery company","14"="501(c)(14) State-chartered credit union",
    "15"="501(c)(15) Mutual insurance company","16"="501(c)(16) Crop-financing corporation",
    "17"="501(c)(17) Supplemental unemployment benefit trust","18"="501(c)(18) Employee-funded pension trust",
    "19"="501(c)(19) Veterans' organization","23"="501(c)(23) Veterans' association",
    "24"="501(c)(24) Section 4049 ERISA trust","25"="501(c)(25) Title-holding corp (multiple parents)",
    "26"="501(c)(26) State high-risk health coverage org","27"="501(c)(27) State workers' comp reinsurance org",
    "29"="501(c)(29) Qualified nonprofit health insurer (CO-OP)"),
  NTMAJ12 = c(
    "AR"="Arts, culture & humanities","BH"="Higher education","ED"="Education (excl. higher ed)",
    "EH"="Hospitals & primary care","EN"="Environment & animals","HE"="Health (excl. hospitals)",
    "HU"="Human services","IN"="International & foreign affairs","MU"="Mutual / membership benefit",
    "PU"="Public & societal benefit","RE"="Religion-related","UN"="Unknown / unclassified"),
  NTEE1 = c(
    "A"="Arts, Culture & Humanities","B"="Education","C"="Environmental Quality","D"="Animal-Related",
    "E"="Health Care","F"="Mental Health & Crisis Intervention","G"="Voluntary Health Associations",
    "H"="Medical Research","I"="Crime & Legal-Related","J"="Employment","K"="Food, Agriculture & Nutrition",
    "L"="Housing & Shelter","M"="Public Safety & Disaster Relief","N"="Recreation & Sports",
    "O"="Youth Development","P"="Human Services","Q"="International & Foreign Affairs",
    "R"="Civil Rights & Advocacy","S"="Community Improvement","T"="Philanthropy & Grantmaking",
    "U"="Science & Technology","V"="Social Science","W"="Public & Societal Benefit",
    "X"="Religion-Related","Y"="Mutual & Membership Benefit","Z"="Unknown"),
  NTEESRC = c(
    "ACT1"="Assigned from activity code","BEST"="Best available assignment","END2"="End-of-process assignment",
    "HIED"="Higher-education override","IRS"="IRS-assigned","NEW"="Newly assigned","ntCO"="NCCS core assignment",
    "SOI"="IRS Statistics of Income","SUB"="Subsector reassignment","SUB2"="Subsector reassignment (2nd pass)",
    "SUB3"="Subsector reassignment (3rd pass)","thp"="Third-party source","VER"="Manually verified",
    "WORD"="Keyword / text-based","ZZ"="Unassigned"),
  DEDUCTCD = c("0"="Not specified","1"="Contributions are tax-deductible",
    "2"="Contributions are not tax-deductible","4"="Deductible by treaty (foreign org)"),
  OUTREAS = c("F"="Foreign / non-US","N"="Not a reporting public charity",
    "S"="Small (below filing threshold)","T"="Terminated / defunct"),
  F9_05_UBIZ_IMCOME_OVER_LIMIT_X = c("N"="No","Y"="Yes"),
  OUTNCCS = c("IN"="In NCCS core file","OUT"="Out of NCCS core file"),
  F9_00_TAX_ACCPER = c("1"="January","2"="February","3"="March","4"="April","5"="May","6"="June",
    "7"="July","8"="August","9"="September","10"="October","11"="November","12"="December")
)

for (v in names(labs)) {
  i <- match(v, dgf$var_name); if (is.na(i)) next
  lv <- dgf$dd_f_levels[i]; if (is.na(lv) || !nzchar(lv)) next
  codes <- as.character(jsonlite::fromJSON(lv)$level)
  m <- labs[[v]]
  lab <- ifelse(codes %in% names(m), unname(m[codes]), codes)
  dgf$dd_f_levels[i] <- datagoodr:::jsonify_df(
    data.frame(level = codes, label = lab, stringsAsFactors = FALSE))
}

## --- save + validate ---------------------------------------------------------
utils::write.csv(dgf, "working-example/DGF-V2.csv", row.names = FALSE)
save_to_excel(dgf, "working-example/DGF-V2.xlsx", open = FALSE)
file.remove(list.files("working-example", "^DGF-V2-tmp", full.names = TRUE))
rep <- inspect_dgf(dgf)
cat("DGF-V2 written | valid:", rep$valid, "| rows:", nrow(dgf), "\n")
