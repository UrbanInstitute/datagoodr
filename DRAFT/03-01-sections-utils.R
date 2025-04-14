library( htmltools )
library( dplyr )
library( pointblank )
library( knitr )
library( gt )          # convert to table 
library( kableExtra )
library( psych )       # skew function 


vname <- "VARNAME"

vlabel <- "Ipsum is simply dummy text of the printing and typesetting industry."

vtype <- "numeric"

vscope <- "PZ"


desc <- "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."

loc <- "SCHED-A-PART-01-LINE-01"


f <- 
structure(list(f_level = c("AR", "ED", "EN", "HE", "HS", "IN", 
"MO", "MR", "PB", "RE", "UN", "ZA", "ZB", "ZC", "ZD", "ZE", "ZF"
), label = c("Arts", "Education", "Environment", "Health", "Human Services", 
"International", "Other", "Pensions and Retirement", "Public Benefit", 
"Religion", "Unknown", "Single Organization Support", "Fundraising Within Group", 
"Private grantmaking foundations", "Public foundations", "General fundraising", 
"Other supporting")), class = "data.frame", row.names = c(NA, 
17L))

quant <- 
structure(list(q1 = c("Q-05", "Q-25", "Q-50", "Q-75", "Q-95"), 
    q2 = c(0, 100, 500, 900, 1234)), class = "data.frame", row.names = c(NA, 
-5L))

stats <- 
structure(list(s1 = c("Min", "Median", "Mean", "Max", "Skew", 
"Kurtosis"), s2 = c("x", "x", "x", "x", "x", "x")), class = "data.frame", row.names = c(NA, 
-6L))




q <- kable( quant )

s <- kable( stats )





#########
#########  SHARED
#########

get_row <- function( vname, dgf ) {

  if( ! any(vname %in% dgf$dgf_vname) )
  { return(NULL) } # add warning
  
  row <- dgf[ dgf$dgf_vname == vname , ]
  row <- as.list(row)
  return(row)
}

design <- 
 c( "div2 ;; vlabel  ;; LABEL",
    "div3 ;; vtype   ;; DATA TYPE",
    "div3 ;; scope   ;; SCOPE",
    "div4 ;; desc    ;; DESCRIPTION",
    "div4 ;; flevel  ;; LEVELS",
    "div4 ;; loc     ;; LOCATION CODE" )
    
    
create_div <- function( div, design, row )
{
  divx <- grep( paste0("^",div), design, value=T )
  purrr::walk( .x=divx, .f=get_txt, row ) 
}


row <- list( vtype="factor", scope="PZ", flevel=flev,
        desc="some description", loc="LOCATION-CODE-01" )



# DIV2

create_div( div="div2", design, row )





create_div1 <- function( x=vname ) {
  cat(  "::: {.div1} \n\n"  )
  cat( paste0(  "#### ",  x,  "\n\n"  ) )
  cat(  "::: \n\n"  )
}

create_div1( x=vname )



create_div2 <- function( 
    x=vlabel, 
    x.lab="LABEL" ) {

  cat( "::: {.div2} \n\n" )
  v_to_txt( x, x.lab )
  cat( "::: \n\n" )
}

create_div2( x2=vlabel )




create_div3 <- function( 
    x3=vtype, 
    x3.lab="DATA TYPE", 
    x4=vscope, 
    x4.lab="SCOPE" ) {

  cat( "::: {.div3} \n\n" )
  v_to_txt( x3, x3.lab )
  v_to_txt( x4, x4.lab )
  cat( "::: \n\n" )
}

create_div3( x3=vtype, x4=vscope )






########
########   NUMERIC
########


# v <- rnorm(1000)


# DESCRIPTION  
create_div4 <- function( 
    x5=desc, x5.lab="DESCRIPTION", 
    x6=k,    x6.lab="LEVELS", 
    x7=loc,  x7.lab="LOCATION CODE" ) {
  cat( "::: {.div4} \n\n" )
  v_to_txt( x5, x5.lab )
  v_to_txt( x6, x6.lab )
  v_to_txt( x7, x7.lab )
  cat( "::: \n\n" )
}

create_div4( x5=desc, x6=k, x7=loc )



build_proptable_numeric <- 
  function( x ) {

  dist        <- length( unique( x ) )
  dist.p      <- dist/length( x )
  miss        <- sum( is.na( x ) )
  miss.p      <- miss/length( x )
  zero        <- sum( x == 0, na.rm=T )
  zero.p      <- zero/length(x)
  neg         <- sum( x < 0, na.rm=T )
  neg.p       <- neg / length(x)

  prop.value  <- 
    c( dist, dist.p, 
       miss, miss.p,
       zero, zero.p,
       neg, neg.p )

  prop.labels <- 
    c( "Distinct (n)", 
       "Distinct (%)", 
       "Missing  (n)", 
       "Missing  (%)",
       "Zeroes  (n)",
       "Zeroes  (p)",
       "Negative (n)",
       "Negative (p)" )

  properties  <- 
    data.frame( 
       prop.labels, 
       prop.value )

  colnames(properties) <- NULL

  cat( paste0( kable( properties ), " \n" ), sep="" )
  cat( "\n\n" )

}


# PROPERTIES
create_div5 <- function( x ) {
  cat( "::: {.div5} \n\n" )
  cat( "##### Properties \n\n" )
  build_proptable_numeric( x )
  cat( "::: \n\n" )
}

create_div5( v )



# QUANTILES 

build_quanttable_numeric <- function( x ) {

  quant.value <- 
    quantile( 
      x, 
      c( 0.05, 0.25, 
         0.50, 0.75, 0.95 ) )

  quant.labels <- 
    c( "Q-05", "Q-25", 
       "Q-50", "Q-75", "Q-95" )

  quant <- 
    data.frame( 
      quant.labels, 
      quant.value )

  colnames(quant) <- NULL
  rownames(quant) <- NULL

  cat( paste0( knitr::kable( quant ), " \n" ) )
  cat( "\n\n" )
}



create_div6 <- function( x ) {
  cat( "::: {.div6} \n\n" )
  cat( "##### Quantiles \n\n" )
  build_quanttable_numeric( x )
  cat( "::: \n\n" )
}

create_div6( v )




# SUMMARY STATS 

build_stattable_numeric <- 
  function( x ) {

  min          <- min( x, na.rm=T )
  median       <- median( x, na.rm=T )
  mean         <- mean( x, na.rm=T )
  max          <- max( x, na.rm=T )
  skew         <- skew( x, na.rm=T )
  kurt         <- kurtosi( x, na.rm=T )
  stat.value   <- c( min, median, mean, max, skew, kurt)
  stat.labels  <- c( "Min", "Median", "Mean", "Max", "Skew", "Kurt" )
  stat         <- data.frame( stat.labels, stat.value )
  
  # print a kable table 
  colnames(stat) <- NULL
  cat( paste0( kable( stat ), " \n" ), sep="" )
  cat( "\n\n" )
  
}



create_div7 <- function( x ) {
  cat( "::: {.div7} \n\n" )
  cat( "#### Summary Stats \n\n" )
  build_stattable_numeric( x )
  cat( "::: \n\n" )
}

create_div7( v )



# HISTOGRAM 

hg <- function( x ) {
  t <- table( cut( x, 10 ) )
  par( mar=c(0,0,0,0) )
  barplot( 
    t, col="steelblue", 
    axisnames = FALSE )
}



create_div8 <- function( x ) {
  cat( "::: {.div8} \n\n" )
  cat( "##### Histogram \n\n" )
  hg( x )
  cat( "\n::: \n\n" )
}

create_div8( v )





# TABLE 

# Example values
vals <- round( rnorm(25,100000,100000), 0 )

# convert to table

build_table <- function(x){

  tab <- 
    sample( x, 25 ) %>% 
    matrix( nrow=5 ) %>%
    as.data.frame()

  e <- gt::gt( tab )

  e <- 
    gt::tab_options( 
      e, 
      column_labels.hidden = T )

  pal <- 
    scales::col_numeric( 
      c( "white", "aquamarine3" ),
      domain=NULL )

  e <- 
    gt::data_color( 
      e,
      palette = pal  )

  return( as_raw_html(e) )
}

create_div9 <- function( x ) {
  cat( "::: {.div9} \n\n" )
  cat( "##### Example Values \n\n" )
  cat( paste0( build_table( x ), " \n\n"  ) )
  cat( "::: \n\n" )
}

create_div9( v )






#########
#########  FACTORS 
#########

# DEMO FACTOR
#   v <- 
#   c( sample( LETTERS, 250, replace=T ), 
#      sample( LETTERS[8:15], 250, replace=T ) )
#   v <- factor( v, levels=LETTERS )


v <- 
structure(c(12L, 21L, 5L, 13L, 18L, 11L, 26L, 7L, 23L, 9L, 27L, 
20L, 21L, 17L, 25L, 27L, 17L, 7L, 10L, 15L, 26L, 12L, 27L, 23L, 
NA, 8L, 22L, 19L, 11L, 26L, 21L, 22L, 10L, 2L, 25L, 15L, 17L, 
6L, 9L, 26L, 23L, 5L, 3L, 18L, 18L, 14L, 2L, 17L, 22L, 1L, 1L, 
1L, 1L, 1L, 1L, 13L, 17L, 11L, 10L, 3L, 25L, 25L, 8L, 25L, 23L, 
11L, 9L, 16L, 5L, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 
19L, 26L, 24L, 14L, 19L, 6L, 11L, 25L, 11L, 27L, 16L, 16L, 17L, 
13L, 10L, 25L, 27L, 13L, 3L, 27L, 23L, 22L, 17L, 26L, 2L, 23L, 
21L, 12L, 22L, 9L, 8L, 26L, 27L, 16L, 6L, 4L, 16L, 25L, 13L, 
21L, 9L, 14L, 9L, 25L, 2L, 5L, 6L, 9L, 17L, 8L, 9L, 16L, 6L, 
10L, 23L, 25L, 8L, 23L, 2L, 24L, 6L, 8L, 24L, 17L, 7L, 23L, 7L, 
25L, 18L, 12L, 19L, 18L, 27L, 23L, 20L, 24L, 7L, 5L, 16L, 18L, 
18L, 19L, 16L, 22L, 23L, 22L, 6L, 27L, 8L, 6L, 24L, 25L, 11L, 
18L, 5L, 9L, 16L, 24L, 27L, 5L, 21L, 14L, 7L, 3L, 4L, 17L, 15L, 
18L, 2L, 8L, 27L, 12L, 19L, 18L, 2L, 14L, 10L, 26L, 21L, 24L, 
7L, 4L, 18L, 23L, 16L, 26L, 27L, 15L, 25L, 27L, 27L, 14L, 4L, 
27L, 15L, 10L, 21L, 3L, 14L, 18L, 20L, 20L, 9L, 25L, 9L, 26L, 
16L, 17L, 8L, 18L, 25L, 23L, 10L, 3L, 21L, 5L, 19L, 2L, 9L, 15L, 
21L, 7L, 25L, 21L, 7L, 3L, 24L, 6L, 12L, 7L, 14L, 16L, 14L, 11L, 
9L, 13L, 14L, 9L, 10L, 11L, 13L, 10L, 9L, 10L, 12L, 9L, 13L, 
13L, 12L, 14L, 10L, 14L, 15L, 15L, 9L, 10L, 15L, 11L, 16L, 15L, 
11L, 14L, 10L, 15L, 10L, 14L, 13L, 10L, 12L, 16L, 9L, 10L, 9L, 
11L, 11L, 10L, 11L, 11L, 11L, 11L, 12L, 12L, 10L, 16L, 15L, 13L, 
11L, 9L, 14L, 16L, 11L, 14L, 15L, 12L, 13L, 13L, 14L, 16L, 16L, 
10L, 11L, 11L, 12L, 14L, 12L, 13L, 14L, 14L, 12L, 14L, 14L, 10L, 
11L, 14L, 16L, 15L, 12L, 16L, 12L, 12L, 14L, 9L, 9L, 10L, 15L, 
9L, 15L, 14L, 9L, 15L, 11L, 10L, 12L, 9L, 16L, 11L, 13L, 15L, 
15L, 13L, 15L, 14L, 16L, 10L, 16L, 9L, 16L, 15L, 16L, 13L, 16L, 
9L, 9L, 13L, 13L, 9L, 9L, 14L, 12L, 12L, 9L, 9L, 9L, 14L, 14L, 
10L, 15L, 16L, 15L, 15L, 16L, 9L, 12L, 12L, 10L, 16L, 16L, 12L, 
16L, 14L, 12L, 14L, 15L, 16L, 10L, 10L, 16L, 9L, 13L, 11L, 14L, 
16L, 14L, 10L, 10L, 14L, 9L, 16L, 10L, 9L, 14L, 9L, 15L, 12L, 
14L, 9L, 10L, 16L, 9L, 15L, 14L, 14L, 16L, 13L, 16L, 13L, 16L, 
11L, 9L, 13L, 10L, 10L, 13L, 10L, 14L, 15L, 11L, 9L, 12L, 13L, 
11L, 13L, 14L, 12L, 15L, 10L, 12L, 12L, 12L, 11L, 16L, 13L, 10L, 
16L, 10L, 16L, 13L, 10L, 13L, 12L, 16L, 13L, 9L, 16L, 13L, 9L, 
15L, 9L, 12L, 9L, 11L, 12L, 14L, 11L, 12L, 11L, 12L, 9L, 9L, 
11L, 13L, 14L, 9L, 11L, 9L, 14L, 12L, 9L, 15L, 9L), levels = c("", 
"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
), class = "factor")


# label dictionary 
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







# x can be string
# or x can be data.frame
# with factor levels and labels 
# imported from the DGF 



get_field <- function( field, ls ) 
{
  fd <- ls[[field]]

  if( is.null(fd) )
  { return(NULL) }

  if( jsonlite::validate( fd ) )
  {
    x <- jsonlite::fromJSON( fd )
  } else {
    x <- ls[[field]] |> as.character()
  }
  return( x )
}


get_txt <- function( x, ls ) 
{
  x <- 
   x %>% 
   strsplit( ";;" ) %>% 
   unlist() %>%
   trimws()
  
  # x[2] = field name
  # x[3] = field label 

  x.val <- get_field( x[2], ls )
  x.lab <- x[3]

  x_to_txt( x=x.val, x.lab=x.lab )
}

get_txt( x, ls )



x_to_txt <- function( x, x.lab ) 
{

  if( class(x) == "character" ) 
  { 
    string_to_txt( x, x.lab ) 
  }

  if( class(x) == "data.frame" ) 
  {    
    f_to_txt( f=x, f.lab=x.lab ) 
  }
  
}


string_to_txt <- function( x, x.lab=NULL ) 
{
  txt <- 
    paste0( "**",  x.lab,  "**", 
            ": ",  x,      "\n\n"  )
  cat( txt )
}



f_to_txt <- function( f, f.lab ) {
  fkable <- knitr::kable(f)
  cat( paste0( "##### ", f.lab, "\n\n" ) )
  cat( paste0( fkable, " \n" ), sep="" )
  cat( "\n\n" )
}



#  purrr::walk( .x=div3, .f=get_txt, ls ) 



create_div3 <- function( design, ls )
{
  div3 <- grep( "^div3", design, value=T )
  purrr::walk( .x=div3, .f=get_txt, ls ) 
}

create_div4 <- function( design, ls )
{
  div4 <- grep( "^div4", design, value=T )
  purrr::walk( .x=div4, .f=get_txt, ls ) 
}




# Descriptions 
create_div4_f <- function( 
    desc,  fdict, loc ) {
  cat( "::: {.div4} \n\n" )
  v_to_txt( desc,  "DESCRIPTION" )
  v_to_txt( fdict, "CATEGORIES" )
  v_to_txt( loc,   "LOCATION CODES" )
  cat( "::: \n\n" )
}

create_div4_f( desc=vdesc, fdict=x, loc=loc )



build_proptable_factor <- function( x ) {

  dist        <- length( unique( x ) )
  dist.p      <- dist/length( x )
  miss        <- sum( is.na( x ) )
  miss.p      <- miss/length( x )
  empty       <- sum( levels(x)=="" )
  empty.p     <- empty/length(x)

  prop.value  <- 
    c( dist, dist.p, 
       miss, miss.p,
       empty, empty.p )

  prop.labels <- 
    c( "Distinct (n)", 
       "Distinct (%)", 
       "Missing  (n)", 
       "Missing  (%)",
       "Empty Labels (n)",
       "Empty Labels (p)" )

  properties  <- 
    data.frame( 
       prop.labels, 
       prop.value )

  colnames(properties) <- NULL

  cat( paste0( knitr::kable( properties ), " \n" ), sep="" )
  cat( "\n\n" )
}


create_div5_f <- function( x ) {
  cat( "::: {.div5} \n\n" )
  cat( paste0( "##### ", "PROPERTIES", "\n\n" ) )
  build_proptable_factor( x )
  cat( "::: \n\n" )
}

create_div5_f( v )






f_table <- function( f, format="html") {
  t <- 
    table(f) %>%
    sort( decreasing=T )
  pt <- 
    prop.table(t) %>%
    round(3)
  d <- data.frame( 
    F=names(t),
    N=as.numeric(t),
    Prop=as.numeric(pt) )
  k <- knitr::kable( d, format )
  return(k)
}

# f_table( f=v )

create_div6_f <- function( f ) {
  cat( "::: {.div6} \n\n" )
  cat( paste0( "##### ", "Factor Levels", "\n\n" ) )
  f_table( f )
  cat( "::: \n\n" )
}

# create_div6_f( v )

f_table( v )


bp <- function( f, show=10 ) {
  t <- 
    table(f) %>%
    sort( decreasing=F )

  par( mar=c(4,0,0,1) )
  barplot( 
    t[1:show]/sum(t), col="firebrick4",
    horiz=T, 
    axisnames = FALSE )
}

# bp( v, show=20 )


create_div7_f <- function( f, n=10 ) {
  cat( "::: {.div7} \n\n" )
  cat( paste0( "##### ", "Top ", n, " Levels", "\n\n" ) )
  bp( f, show=n )
  cat( "::: \n\n" )
}

# create_div7_f( f=v )



#########
#########  CHARACTERS 
#########



# Descriptions 
create_div4_t <- function( 
    desc, loc ) {
  cat( "::: {.div4} \n\n" )
  v_to_txt( desc, "DESCRIPTION" )
  v_to_txt( loc,  "LOCATION CODES" )
  cat( "::: \n\n" )
}

create_div4_t( desc=vdesc,loc=loc )



build_proptable_text <- function( x ) {

  dist        <- length( unique( x ) )
  dist.p      <- dist/length( x )
  miss        <- sum( is.na( x ) )
  miss.p      <- miss/length( x )
  empty       <- sum( x=="", na.rm=T )
  empty.p     <- empty/length(x)
  min.char    <- min( nchar(x), na.rm=T ) 
  ave.char    <- median( nchar(x), na.rm=T )
  max.char    <- max( nchar(x), na.rm=T )

  prop.value  <- 
    c( dist, dist.p, 
       miss, miss.p,
       empty, empty.p,
       min.char, ave.char, max.char )

  prop.labels <- 
    c( "Distinct (n)", 
       "Distinct (%)", 
       "Missing  (n)", 
       "Missing  (%)",
       "Empty Labels (n)",
       "Empty Labels (p)",
       "Min Num of Chars (n)",
       "Median Num of Chars (n)",
       "Max Num of Chars (n)" )

  properties  <- 
    data.frame( 
       prop.labels, 
       prop.value )

  colnames(properties) <- NULL

  cat( paste0( knitr::kable( properties ), " \n" ), sep="" )
  cat( "\n\n" )
}


create_div5_t <- function( x ) {
  cat( "::: {.div5} \n\n" )
  cat( paste0( "##### ", "PROPERTIES", "\n\n" ) )
  build_proptable_text( x )
  cat( "::: \n\n" )
}

create_div5_t( x )



# 40 characters per line



tx <-
c("ELDER PAWS SENIOR DOG FOUNDATION", "ROYAL MUSIC SOCIETY", 
"DACAR INSTITUTE FOUNDATION INC", "ANCHOR OF HOPE", "COLOMBIAN CULTURAL CMTE OF MV", 
"CHILDRENS LEGAL AID SOCIETY INC", "ICEBREAKER PRAYER CENTER", 
"HINDU TEMPLE OF FRESNO", "PRECIOUS STONES ACADEMY INC", "SEQUATCHIE HAVEN INC", 
"PORTLAND COLLECTIVE HOUSING SYNDICATE", "Building Utah Youth", 
"THE BONAZZI FOUNDATION FOR THE", "THE POINT IS DBA THE POINT", 
"NATIONAL TRADITIONAL COUNTRY MUSIC ASSN", "HEALING WITH HAPPINESS FOUNDATION", 
"OWL HOUSE INC", "ELBA COMMUNITY OUTREACH", "FIRST CITY COUNCIL ON CANCER", 
"PEKIN MEMORIAL HOSPITAL AUXILIARY", "WOODSTOCK COMMUNITY FOOD SHELF", 
"Brooklyn Park Seniors Incorporated", "EVELYNS BFF BREAST FRIENDS FOREVERINC"
)


tx2 <- paste0( "{{", tx, "}}", collapse=" " )
tx2 <- paste0( tx, collapse=" ;; " )  
tx2 <- paste0( " :: ", tx, collapse=" " )  
nchar(tx2)

size <- 80
tx3 <- NULL
while( nchar(tx2) > size )
{
  x <- substr( tx2, 1, size )
  tx2 <- substring( tx2, first=size )
  tx3 <- c( tx3, x )
}
tx3 <- c( tx3, tx2 )


t(tx3) %>% kable()





f_table <- function( f, format="html") {
  t <- 
    table(f) %>%
    sort( decreasing=T )
  pt <- 
    prop.table(t) %>%
    round(3)
  d <- data.frame( 
    F=names(t),
    N=as.numeric(t),
    Prop=as.numeric(pt) )
  k <- knitr::kable( d, format )
  return(k)
}

# f_table( f=v )

create_div6_f <- function( f ) {
  cat( "::: {.div6} \n\n" )
  cat( paste0( "##### ", "Factor Levels", "\n\n" ) )
  f_table( f )
  cat( "::: \n\n" )
}

# create_div6_f( v )

f_table( v )


bp <- function( f, show=10 ) {
  t <- 
    table(f) %>%
    sort( decreasing=F )

  par( mar=c(4,0,0,1) )
  barplot( 
    t[1:show]/sum(t), col="firebrick4",
    horiz=T, 
    axisnames = FALSE )
}

# bp( v, show=20 )


create_div7_f <- function( f, n=10 ) {
  cat( "::: {.div7} \n\n" )
  cat( paste0( "##### ", "Top ", n, " Levels", "\n\n" ) )
  bp( f, show=n )
  cat( "::: \n\n" )
}

# create_div7_f( f=v )




create_div8 <- function( 
    x11, x11.lab="Histogram" ) {
  cat( "::: {.div8} \n\n" )
  cat( paste0( "##### ", x11.lab, "\n\n" ) )
  hg( x=x11 )
  cat( "\n::: \n\n" )
}

create_div8( x11=x )



create_div9 <- function( 
    x12=e, x12.lab="Example values" ) {
  cat( "::: {.div9} \n\n" )
  cat( paste0( "##### ", x12.lab, "\n\n" ) )
  cat( as_raw_html( x12 ) )
  cat( "::: \n\n" )
}

create_div9( x12=e )



create_section <- function( 
    x1=vname,
    x2=vlabel,  x2.lab="LABEL",
    x3=vtype,   x3.lab="DATA TYPE", 
    x4=vscope,  x4.lab="SCOPE",
    x5=desc,    x5.lab="DESCRIPTION", 
    x6=k,       x6.lab="LEVELS", 
    x7=loc,     x7.lab="LOCATION CODE",
    x8=x,       x8.lab="Properties",
    x9=x,       x9.lab="Quantiles",
    x10=x,      x10.lab="Statistics",
    x11=x,      x11.lab="Histogram",
    x12=e,      x12.lab="Example values" ) {

  cat( "{{< pagebreak >}} \n\n")  # add page break between variables?
  cat( "::::: {.parent} \n\n" )
  create_div1( x1=vname )
  create_div2( x2=vlabel )
  create_div3( x3=vtype, x4=vscope )
  create_div4( x5=desc, x6=k, x7=loc )
  create_div5( x8=x  )
  create_div6( x9=x  )
  create_div7( x10=x )
  create_div8( x11=x )
  create_div9( x12=e )
  cat( "::::: \n\n" )
}


vname <- "name"
vtype <- "type"
v <- df[["vname"]]

vscope <- "PC"
vdesc <- "some long description"

loc, loc.lab


if( vtype == "numeric" )
{ # call create_section_n }

if( vtype == "factor" )
{ # call create_section_n }

if( vtype == "logical" )
{ # call create_section_n }

if( vtype == "character" )
{ # call create_section_n }

if( vtype == "date" )
{ # call create_section_n }


create_section <- function( 
    vname,
    vlabel,  x2.lab="LABEL",
    vtype,   x3.lab="DATA TYPE", 
    x4=vscope,  x4.lab="SCOPE",
    x5=desc,    x5.lab="DESCRIPTION", 
    x6=k,       x6.lab="LEVELS", 
    x7=loc,     x7.lab="LOCATION CODE",
    x8=x,       x8.lab="Properties",
    x9=x,       x9.lab="Quantiles",
    x10=x,      x10.lab="Statistics",
    x11=x,      x11.lab="Histogram",
    x12=e,      x12.lab="Example values" ) {

  cat( "{{< pagebreak >}} \n\n")  # add page break between variables?
  cat( "::::: {.parent} \n\n" )
  create_div1( vname )  # deparse(substitute( x1 ))
  create_div2( x2=vlabel )
  create_div3( x3=vtype, x4=vscope )
  create_div4( x5=desc, x6=k, x7=loc )
  create_div5( x8=x  )
  create_div6( x9=x  )
  create_div7( x10=x )
  create_div8( x11=x )
  create_div9( x12=e )
  cat( "::::: \n\n" )
}




#############
#############  DATES
#############


start_date <- as.Date('2015-01-01')  
end_date <- as.Date('2017-01-01') 

dt <- 
  sample( 
  seq(
   as.Date('2015-01-01'), 
   as.Date('2018-06-01'), 
   by = "day" ), 
   1000 ) 

format( head(dt), "%Y" )
format( head(dt), "%b" )
format( head(dt), "%d" )


d_table_y <- function( x, format="html" ) {
  y <- format( x, "%Y" )
  n <- length(unique(y))
  if( n > 12 ){ n=12 }
  t <- 
    table(y)[1:n] %>%
    as.data.frame()
  names(t) <- c("Year","N")
  knitr::kable( t, format )
}



d_table_y( dt, "markdown" )


d_table_m <- function( x, format="html" ) {
  m <- format( x, "%b" )
  mo <- 
  c( "Jan", "Feb", "Mar", 
     "Apr", "May", "Jul", 
     "Jun", "Oct", "Aug",  
     "Dec", "Sep", "Nov" )
  m <- factor( m, levels=mo )
  t <- table(m) %>% as.data.frame()
  names(t) <- c("Month","N")
  knitr::kable( t, format )
}


d_table_m( dt, "markdown" )



d_table_d <- function( x, format="html" ) {
  d <- format( x, "%d" )
  days <- 
    c( "01", "02", "03", "04", 
       "05", "06", "07", "08", 
       "09", "10", "11", "12", 
       "13", "14", "15", "16", 
       "17", "18", "19", "20", 
       "21", "22", "23", "24", 
       "25", "26", "27", "28", 
       "29", "30", "31" )
  d <- factor( d, levels=days )
  t <- table(d) %>% as.data.frame()
  names(t) <- c("Day","N")
  knitr::kable( t, format )
}


d_table_d( dt, "markdown" )




#############
#############  NUMERIC
#############

vname <- "name"
vtype <- "type"
v <- df[["vname"]]

vscope <- "PC"
desc <- "description"

loc, loc.label


create_section_n <- function( 
    vname,
    vlabel,  x2.lab="LABEL",
    vtype,   x3.lab="DATA TYPE", 
    x4=vscope,  x4.lab="SCOPE",
    x5=desc,    x5.lab="DESCRIPTION", 
    x6=k,       x6.lab="LEVELS", 
    x7=loc,     x7.lab="LOCATION CODE",
    x8=x,       x8.lab="Properties",
    x9=x,       x9.lab="Quantiles",
    x10=x,      x10.lab="Statistics",
    x11=x,      x11.lab="Histogram",
    x12=e,      x12.lab="Example values" ) {

  cat( "{{< pagebreak >}} \n\n")  # add page break between variables?
  cat( "::::: {.parent} \n\n" )
  create_div1( vname )  # deparse(substitute( x1 ))
  create_div2( x2=vlabel )
  create_div3( x3=vtype, x4=vscope )
  create_div4( x5=desc, x6=k, x7=loc )
  create_div5( x8=x  )
  create_div6( x9=x  )
  create_div7( x10=x )
  create_div8( x11=x )
  create_div9( x12=e )
  cat( "::::: \n\n" )
}


create_section_f <- function( 
    vname,
    vlabel,  x2.lab="LABEL",
    vtype,   x3.lab="DATA TYPE", 
    x4=vscope,  x4.lab="SCOPE",
    x5=desc,    x5.lab="DESCRIPTION", 
    x6=k,       x6.lab="LEVELS", 
    x7=loc,     x7.lab="LOCATION CODE",
    x8=x,       x8.lab="Properties",
    x9=x,       x9.lab="Quantiles",
    x10=x,      x10.lab="Statistics",
    x11=x,      x11.lab="Histogram",
    x12=e,      x12.lab="Example values" ) {

  cat( "{{< pagebreak >}} \n\n")  # add page break between variables?
  cat( "::::: {.parent} \n\n" )
  create_div1( vname )  # deparse(substitute( x1 ))
  create_div2( x2=vlabel )
  create_div3( x3=vtype, x4=vscope )
  create_div4_f( x5=desc, x6=k, x7=loc )
  create_div5( x8=x  )
  create_div6( x9=x  )
  create_div7( x10=x )
  create_div8( x11=x )
  create_div9( x12=e )
  cat( "::::: \n\n" )
}
