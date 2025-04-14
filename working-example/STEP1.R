######################
### Step 01 Create the DGF
######################

## Load all R/01*.R functions
source("R/01-02-data-type-factors.R")
source("R/00-utils.R")
source("R/02-02-ingest-utils.R")
source("R/01-03-get-stats.R")
source("R/01-03-get-graphics.R")
source("R/01-04-save-to-excel.R")
source("R/01-00-create-DGF.R")


## Read original data frame
df <- readr::read_csv("data-dev/DEMO-DATA-SMALL.csv" )


## create the DGF from just the data frame
# this creates DGF-V1.csv and DGF-V1.xlsx
create_dgf(df,
           file = "working-example/DGF-V1")

# This file looks quite blank!!
# if you have any information you would like to add manually, you can do so here
# You can also do this in an iterative process,
# I know the vdesc (variable descriptions) and the vname_alias and some validation functions
# from a previous file (data-dev/DGF-CORE-CO-2019-blank.xlsx)
# so i'm going to add them here
dgf.blank <- readxl::read_xlsx("data-dev/DGF-CORE-CO-2019-blank.xlsx" )
create_dgf(df,
           vdesc = dgf.blank$dd_desc,
           vconvert = dgf.blank$data_type_convert,
           vformat = dgf.blank$data_type_format,
           file = "working-example/DGF-V2"
           )


## This file has much more (but technically not necessary info) to make the RG pretty!

