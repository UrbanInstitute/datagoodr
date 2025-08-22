#### order of operations for testing -----------------------


## TEST 1 --------------------------------
## load data
dd <- readxl::read_xlsx("data-dev/DGF-CORE-CO-2019-V1.xlsx" )
dat <- readr::read_csv("data-dev/DEMO-DATA-SMALL.csv" )

# Get just numeric
dd <- dd[22:27,  ]

#rename variable to make easier to work with
dgf <- dd


## Testing 03-01-create-sections.R
source( "R//03-01-create-sections.R")
source("R//03-05-tables.R")
source("R//01-03-get-stats.R")

#create_div is causeing this warning every time it runs
# Warning: Unknown or uninitialised column: `DIV`.
# Unknown or uninitialised column: `DIV`.
# Unknown or uninitialised column: `DIV`.
# Unknown or uninitialised column: `DIV`.
# Unknown or uninitialised column: `DIV`.
# Unknown or uninitialised column: `DIV`.
# Unknown or uninitialised column: `DIV`.
# Unknown or uninitialised column: `DIV`.


## testing create_all_sections
all.layouts <- get_design()
dgf.content <- dgf_to_list( dgf )
all.vars <- names( dgf.content )



L <- dgf.content
VNAME <- all.vars[1]
# run internal lines of create_section
#same warnings as above
# lets look at create_div

#Works
create_div( div.num="div2", all.layouts, xx )
create_div( div.num="div3", all.layouts, xx )
create_div( div.num="div4", all.layouts, xx )



create_div( div.num="div5", all.layouts, xx )

#error is in get_properties, lets look at that
DATA_TYPE <- xx[["data_type"]]
layout.type <- dplyr::filter( all.layouts, TYPE == DATA_TYPE )

# skip div if not included in design
if( ! any( div.num %in% layout.type$DIV ) ) #there is not column in dd called $DIV, is this supposed to be layouttype?
{ return( NULL ) }

div.fxs <-
  layout.type %>%
  dplyr::filter( DIV == div.num ) %>%
  select( FUNCTION, VNAME, LABEL )
div.fxs

args <- as.list(div.fxs[-1])
stats <- args

#run get_properties line by line

#error happening in get_stats
varname <- VNAME
get_stats(VNAME)
#fixed

#back to get_properties
get_properties(get_stats(VNAME))

# Good
#now back to div.fxs in create_div. I think this is where the error is comming from
# i don't think it is currently reading get_stats correctly


get_properties(VNAME)

## TEST 2- ------------------------------------
### I think that fixed some things lets start again from the top
# Sweep envrionment
## load data
dd <- readxl::read_xlsx("data-dev/DGF-CORE-CO-2019-V1.xlsx" )
dat <- readr::read_csv("data-dev/DEMO-DATA-SMALL.csv" )

# Get just numeric
# dd <- dd[22:27,  ]

#rename variable to make easier to work with
dgf <- dd


## Testing 03-01-create-sections.R
source( "R//03-01-create-sections.R")
source("R//03-05-tables.R")
source("R//01-03-get-stats.R")



## testing create_all_sections
all.layouts <- get_design()
dgf.content <- dgf_to_list( dgf )
all.vars <- names( dgf.content )


#internal content of create_all_sections
L <- dgf.content
VNAME <- all.vars[10]
# run internal lines of create_section
xx <<- L[[ VNAME ]] #make this a global variable?
DATA_TYPE <- xx[["data_type"]]
layout.type <- dplyr::filter( all.layouts, TYPE == DATA_TYPE )
all.divs <- unique( layout.type$DIV )
all.divs <- all.divs[ ! all.divs == "div1" ]
#same warnings as above
# lets look at create_div

#Works
create_div( div.num="div2", all.layouts, xx )
create_div( div.num="div3", all.layouts, xx )
create_div( div.num="div4", all.layouts, xx )

# fixed by adding xx[vname]
create_div( div.num="div8", all.layouts, xx )

#moving on
create_div( div.num="div6", all.layouts, xx )
# #div 6 function doesn't exist yet
# div.num="div6"
# DATA_TYPE <- xx[["data_type"]]
# layout.type <- dplyr::filter( all.layouts, TYPE == DATA_TYPE )
# div.fxs <-
#   layout.type %>%
#   dplyr::filter( DIV == div.num ) %>%
#   select( FUNCTION, VNAME, LABEL )
# div.fxs

### Div6 works now

## Creating Div 7
create_div( div.num="div9", all.layouts, xx )



### FACTOR TESTING ___---------------------------------
dd <- readxl::read_xlsx("data-dev/DGF-CORE-CO-2019-V1.xlsx" )
dat <- readr::read_csv("data-dev/DEMO-DATA-SMALL.csv" )

# Get just numeric
dd <- dd[6:15,  ]

#rename variable to make easier to work with
dgf <- dd


## Testing 03-01-create-sections.R
source( "R//03-01-create-sections.R")
source("R//03-05-tables.R")
source("R//01-03-get-stats.R")
source("R//03-00-utils.R")


## testing create_all_sections
all.layouts <- get_design()
dgf.content <- dgf_to_list( dgf )
all.vars <- names( dgf.content )


L <- dgf.content
VNAME <- all.vars[7]

### TESTING HTML TABLES FOR get_properties ------------------
## Set up
dd <- readxl::read_xlsx("data-dev/DGF-CORE-CO-2019-V1.xlsx" )
dat <- readr::read_csv("data-dev/DEMO-DATA-SMALL.csv" )

# Get just numeric
dd <- dd[c(14:15),  ]

#rename variable to make easier to work with
dgf <- dd


## Testing 03-01-create-sections.R
source( "R//03-01-create-sections.R")
source("R//03-05-tables.R")
source("R//01-03-get-stats.R")
source("R//03-00-utils.R")


## testing create_all_sections
all.layouts <- get_design()
dgf.content <- dgf_to_list( dgf )
all.vars <- names( dgf.content )


L <- dgf.content
VNAME <- all.vars[1]

all.layouts <- get_design()
dgf.content <- dgf_to_list( dgf )

xx <<- L[[ VNAME ]] #make this a global variable?
DATA_TYPE <- xx[["data_type"]]
layout.type <- dplyr::filter( all.layouts, TYPE == DATA_TYPE )
all.divs <- unique( layout.type$DIV )
all.divs <- all.divs[ ! all.divs == "div1" ]


DATA_TYPE <- xx[["data_type"]]
layout.type <- dplyr::filter( all.layouts, TYPE == DATA_TYPE )

# get_properties 1 ---
stats <- get_stats(VNAME)

f <- function(x){ format(x,big.mark=",") }
stats <- sapply( stats, f )

VAL <-
  c( stats[["N"]],
     stats[["distinct.n"]], stats[["distinct.p"]],
     stats[["duplicated.p"]],
     stats[["most.common.v"]], stats[["most.common.p"]],
     stats[["zero.n"]], stats[["zero.p"]],
     stats[["missing.n"]],
     stats[["na.n"]], stats[["na.p"]],
     stats[["inf.n"]] )

STAT <-
  c( "Rows (N)",
     "Distinct (N)", "Distinct (%)", "Duplicates (%)",
     "Most Common Value", "Most Common Val (%)",
     "Zero (N)", "Zero (%)",
     "All Empty (N)",
     "Missing/NA (N)", "Missing/NA (%)",
     "Infinite (N)")

t <- data.frame( STAT, VAL )
k <- knitr::kable( t, align=c("l","r"))
cat( paste0( k, " \n" ) )


######## Logical Teseting
### TESTING HTML TABLES FOR get_properties ------------------

#### CHARACTER TESTING
## Set up
dd <- readxl::read_xlsx("data-dev/DGF-CORE-CO-2019-V1.xlsx" )
dat <- readr::read_csv("data-dev/DEMO-DATA-SMALL.csv" )

# Get just numeric
# dd <- dd[c(1:),  ]

#rename variable to make easier to work with
dgf <- dd


## Testing 03-01-create-sections.R
source("R//03-01-create-sections.R")
source("R//03-05-tables.R")
source("R//01-03-get-stats.R")
source("R//03-00-utils.R")
source("R//03-06-barplot.R")
source("R//03-04-wordcloud.R")


## testing create_all_sections
all.layouts <- get_design()
dgf.content <- dgf_to_list( dgf )
all.vars <- names( dgf.content )


L <- dgf.content
VNAME <- all.vars[10]


xx <<- L[[ VNAME ]] #make this a global variable?
DATA_TYPE <- xx[["data_type"]]
layout.type <- dplyr::filter( all.layouts, TYPE == DATA_TYPE )
all.divs <- unique( layout.type$DIV )
all.divs <- all.divs[ ! all.divs == "div1" ]



###############################
### Separating Steps
###############################
source("R/01-02-data-type-factors.R")
source("R/00-utils.R")
source("R/02-02-ingest-utils.R")
source("R/01-03-get-stats.R")
source("R/01-03-get-graphics.R")
source("R/01-04-save-to-excel.R")
source("R/01-00-create-DGF.R")

dgf.blank <- readxl::read_xlsx("data-dev/DGF-CORE-CO-2019-blank.xlsx" )
dgf <- dgf.blank
df <- readr::read_csv("data-dev/DEMO-DATA-SMALL.csv" )

create_dgf(df,
           vdesc = dgf.blank$dd_desc,
           vconvert = dgf.blank$data_type_convert,
           vformat = dgf.blank$data_type_format,
           )


vtypes=NULL
use.df.types=FALSE
guess.factors=TRUE
guess.dates=FALSE
dd=NULL
vname=NULL
vlabel=NULL
vdesc=NULL
vtype=NULL
vconvert = dgf$data_type_convert
vformat = dgf$data_type_format
vname_alias = NULL
keep.dd.cols=NULL
preview_dd=F
preview_dp= F



####### Testing to get set 03 functions to read from generated dgf ------
source("R/00-utils.R")
# source("R/01-00-create-DGF.R")
# source("R/01-02-data-type-factors.R")
# source("R/01-03-get-stats.R")
# source("R/01-03-get-graphics.R")
# source("R/01-04-save-to-excel.R")
source("R/02-02-ingest-utils.R")
source("R/03-00-BUILD-RG-DICT.R")
source("R/03-01-create-sections.R")
source("R/03-04-wordcloud.R")
source("R/03-02-treemap.R")

dgf <- readxl::read_excel("DGF.xlsx")

# DGF is in data-dev/DGF-DRAFT.xlsx
all.layouts <- get_design()



## Let's start with character
dgf <- dgf[dgf$vtype_class == "logical", ]

dgf.content <- datagoodr:::dgf_to_list( dgf )
all.vars <- names( dgf.content )

#walk( all.vars, create_section, all.layouts, dgf.content )
VNAME <- all.vars[1]
L <- dgf.content

xx <<- L[[ VNAME ]] #make this a global variable?
DATA_TYPE <- xx[["vtype_class"]] # change data_type to vtype_class
layout.type <- dplyr::filter( all.layouts, TYPE == DATA_TYPE )
all.divs <- unique( layout.type$DIV )
all.divs <- all.divs[ ! all.divs == "div1" ]

cat( "{{< pagebreak >}} \n\n")
cat( "::::: {.parent} \n\n" )

create_div1( VNAME )
# walk( all.divs, create_div, layout.type, xx )
# cat( ":::::  \n\n\n\n\n\n" )

## walking along divs
div = "div2"
create_div(div = "div2", layout.type, xx)
create_div(div = "div3", layout.type, xx)
create_div(div = "div4", layout.type, xx)
create_div(div = "div17", layout.type, xx)
create_div(div = "div18", layout.type, xx)
create_div(div = "div19", layout.type, xx)
