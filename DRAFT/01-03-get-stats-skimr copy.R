# library( skimr )
# library( dplyr )
# library( jsonlite )


# x <- 
# '[ 
#   { "stat" : "n_missing",  "bats" : "0" }, 
#   { "stat" : "complete_rate",  "bats" : "1" }, 
#   { "stat" : "ordered",  "bats" : "FALSE" }, 
#   { "stat" : "n_unique",  "bats" : "3" }, 
#   { "stat" : "top_counts",  "bats" : "R :  2895, L :  1303, B :  422"}
# ]'
# 
#  jsonlite::fromJSON(x)



# parts = skimr partitions

#' @title get skimr table 
#'
#' @description some description text  
#'
#' @details some additional details 
#'
#' @export
get_skimr_table <- function( parts, type="numeric" )
{
  # extract numeric variables
  dt <- parts[[ type ]] %>% as.data.frame()

  # transpose so each var is a column
  d <- t( dt ) %>% as.data.frame()

  names(d) <- d[1,] %>% as.vector()
  d$stat <- row.names(d)
  row.names(d) <- NULL
  d<- d[-1,]
  return(d)
}


#' @title jsonify skimr 
#'
#' @description some description text  
#'
#' @details some additional details 
#'
#' @export
jsonify_skimr <- function( df, v )
{
  check <- v %in% names(df)
  if( ! check ){ stop("v not in df") }
  d <- df[c("stat",v)]
  d[[v]] <- trimws( d[[v]] )
  jd <- jsonlite::toJSON( d )
  jd <- gsub( "\\{", "  \\{ ", jd )
  jd <- gsub( ":", " : ", jd )
  jd <- gsub( '","', '",  "', jd )
  jd <- gsub( "\\},", " \\}, \n", jd )
  jd <- gsub( "\\[", "\\[ \n", jd )
  jd <- gsub( "\\]", "\n\\]", jd )
  return(jd)
}

# f.df <- get_skimr_table( df, type="factor" )
# jsonify_skimr( f.df, "bats" )



#' @title extract values from skimr table
#'
#' @description some description text  
#'
#' @details some additional details 
#'
#' @export
get_values <- function( df ) {

  nmz <- names(df)
    
  # https://docs.ropensci.org/skimr/reference/skim_with.html
  #
  # my_skimr <- 
  #   skim_with( 
  #     base = sfl(n_missing = n_missing, complete_rate = complete_rate),
  #     numeric = sfl( median, mad ),
  #     factor = sfl( ... ),
  #     character = sfl( ... ),
  #     logical = sfl( ... ),
  #     append = TRUE )
  #
  #  my_skimr( data )
  #
  #  # Or pass the same as a list, unquoting the input.
  #  my_skimmers <- list(numeric = sfl(mean), character = sfl(length))
  #  my_skim <- skim_with(!!!my_skimmers)
  
  df.skim <- skimr::skim( df )
  skimr.parts <- skimr::partition( df.skim )
  
  results <- list()
  
  for( i in nmz )
  {
    type <- class( df[[i]] )
    if( "POSIXct" %in% type ){ type <- "POSIXct" }
    skim.df <- get_skimr_table( skimr.parts, type )
    json <- jsonify_skimr( skim.df, i )
    results[[i]] <- json
  }
  
  x <- unlist( results )
  return(x)
}

