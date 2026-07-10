######################
### Step 01: Create the DGF
######################

# The DGF (Data Governance File) stores the minimum metadata, summary
# statistics, and graphics needed to describe a dataset. Once it exists, the
# raw data is no longer needed to render the Research Guide in Step 3.

library( datagoodr )


## Read the original data frame
df <- readr::read_csv( "data-dev/DEMO-DATA-SMALL.csv" )


## Create the DGF from just the data frame.
## This writes working-example/DGF-V1.csv and working-example/DGF-V1.xlsx.
create_dgf( df,
            file = "working-example/DGF-V1" )

# DGF-V1 is fairly blank - it only contains what can be inferred from the data.
# You can add information manually (in Excel) or iteratively in R. Here we pull
# variable descriptions, type-conversion functions, and formatting rules from a
# previously curated file and pass them in to create a richer DGF-V2.
dgf.blank <- readxl::read_xlsx( "data-dev/DGF-CORE-CO-2019-blank.xlsx" )
create_dgf( df,
            vdesc    = dgf.blank$dd_desc,
            vconvert = dgf.blank$data_type_convert,
            vformat  = dgf.blank$data_type_format,
            file     = "working-example/DGF-V2" )

## DGF-V2 carries much more (though technically optional) information that makes
## the rendered Research Guide more informative and polished.
