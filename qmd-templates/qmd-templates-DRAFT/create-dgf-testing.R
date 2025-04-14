library( htmltools )
library( dplyr )
library( purrr )
library( pointblank )
library( knitr )
library( gt )
library( kableExtra )
library( psych )
library( data.table )
library( gt)
library( treemap )
library( plotly )
library( wordcloud )
library( wordcloud2 )
library( tm )
library( stringr)


source("R/01-02-data-type-factors.R")
source("R/00-utils.R")
source("R/02-02-ingest-utils.R")
source("R/01-03-get-stats.R")
source("R/01-03-get-graphics.R")
source("R/01-04-save-to-excel.R")
source("R/01-00-create-DGF.R")

dgf.blank <- readxl::read_xlsx("data-dev/DGF-CORE-CO-2019-blank.xlsx" )
df <- readr::read_csv("data-dev/DEMO-DATA-SMALL.csv" )

create_dgf(df,
           vdesc = dgf.blank$dd_desc,
           vconvert = dgf.blank$data_type_convert,
           vformat = dgf.blank$data_type_format,
           file = "data-dev/DGF-DRAFT")

