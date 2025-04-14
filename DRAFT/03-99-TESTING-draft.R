library( jsonlite )
library( dplyr )
library( knitr )



dgf <- openxlsx::read.xlsx( "../data-dev/DGF-CORE-CO-2019-V1.xlsx" )
df <-  readr::read_csv( "../data-dev/DEMO-DATA-SMALL.csv" )


fdict <-
'[
  {  "f_level" :  "AR"  ,  "label" :  "Arts"  },
  {  "f_level" :  "ED"  ,  "label" :  "Education"  },
  {  "f_level" :  "EN"  ,  "label" :  "Environment"  },
  {  "f_level" :  "HE"  ,  "label" :  "Health"  },
  {  "f_level" :  "HS"  ,  "label" :  "Human Services"  },
  {  "f_level" :  "IN"  ,  "label" :  "International"  },
  {  "f_level" :  "MO"  ,  "label" :  "Other"  },
  {  "f_level" :  "MR"  ,  "label" :  "Pensions and Retirement"  },
  {  "f_level" :  "PB"  ,  "label" :  "Public Benefit"  },
  {  "f_level" :  "RE"  ,  "label" :  "Religion"  },
  {  "f_level" :  "UN"  ,  "label" :  "Unknown"  },
  {  "f_level" :  "ZA"  ,  "label" :  "Single Organization Support"  },
  {  "f_level" :  "ZB"  ,  "label" :  "Fundraising Within Group"  },
  {  "f_level" :  "ZC"  ,  "label" :  "Private grantmaking foundations"  },
  {  "f_level" :  "ZD"  ,  "label" :  "Public foundations"  },
  {  "f_level" :  "ZE"  ,  "label" :  "General fundraising"  },
  {  "f_level" :  "ZF"  ,  "label" :  "Other supporting"  }
]'

# read json table from dgf
f <- fromJSON( fdict )


fromJSON(fdict) |> knitr::kable()





  DATA_TYPE <- xx[["data_type"]]
  layout.type <- dplyr::filter( all.layouts, TYPE == DATA_TYPE )

  # skip div if not included in design
  if( ! any( div.num %in% dd$DIV ) )
  { return( NULL ) }

  div.fxs <-
    layout.type %>%
    dplyr::filter( DIV == div.num ) %>%
    select( FUNCTION, VNAME, LABEL )

  cat( paste0( "::: {.", div.num, "} \n\n" ) )

  pwalk( div.fxs,
     function( FUNCTION, ... ) {
       args <- list(...)
       txt <- do.call( FUNCTION, args )
       cat( txt )
     } )

  cat( "::: \n\n" )



  v <- "NTMAJ12"

  xx <- L[[ v ]]
  DATA_TYPE <- xx[["data_type"]]
  layout.type <- dplyr::filter( all.layouts, TYPE == DATA_TYPE )
  all.divs <- unique( layout.type$DIV )
  all.divs <- all.divs[ ! all.divs == "div1" ]

  cat( "{{< pagebreak >}} \n\n")
  cat( "::::: {.parent} \n\n" )

  create_div1( v )
  # create_div( div="div2", layout.type, xx )
  # create_div( div="div3", layout.type, xx )
  # create_div( div="div4", layout.type, xx )
  walk( all.divs, create_div, layout.type, xx )
  cat( ":::::  \n\n\n\n\n\n" )


