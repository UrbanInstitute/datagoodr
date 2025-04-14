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


k <- kable( f )

q <- kable( quant )

s <- kable( stats )

# Example values
vals <- round( rnorm(25,100000,100000), 0 )

# convert to table

e <- 
  gt::gt( 
    as.data.frame( 
    matrix( vals, nrow=5 ) ) )


e <- 
  tab_options( 
    e, 
    column_labels.hidden = T )

pal <- 
  scales::col_numeric( 
    c( "white", "aquamarine3" ),
    domain=NULL )

e <- 
  data_color( 
    e,
    palette = pal  )


to_txt_string <- 
  function( x, x.lab=NULL ){

    txt <- 
      paste0( "**", 
              x.lab, 
              "**", 
              ": ",  
              x, 
              "\n\n" )
    cat( txt )
}


to_txt_factor <- 
  function( x, x.lab=NULL ) {

  cat( paste0( "##### ", x.lab, "\n\n" ) )
  cat( paste0( x, " \n" ), sep="" )
  cat( "\n\n" )
}


v_to_txt <- function( v, v.lab ) {

  if( class(v) == "character" )
  { to_txt_string( x=v, x.lab=v.lab ) }

  if( class(v) == "knitr_kable" )
  { to_txt_factor( x=v, x.lab=v.lab ) }
}


x <- rnorm( 1000 )

build_proptable_numeric <- 
  function( x, x.lab=NULL ) {

  dist        <- length( unique( x ) )
  dist.p      <- dist/length( x )
  miss        <- sum( is.na( x ) )
  miss.p      <- miss/length( x )
  prop.value  <- c( dist, dist.p, miss, miss.p )

  prop.labels <- 
    c( "Distinct (n)", 
       "Distinct (%)", 
       "Missing  (n)", 
       "Missing  (%)" )

  properties  <- 
    data.frame( 
       prop.labels, 
       prop.value )

  cat( paste0( "##### ", x.lab, "\n\n" ) )
  cat( paste0( kable( properties ), " \n" ), sep="" )
  cat( "\n\n" )

}


build_quanttable_numeric <- function( 
    x, x.lab=NULL ) {

  quant.value <- 
    quantile( 
      x, 
      c( 0.05, 0.25, 0.50, 0.75, 0.95 ) )

  quant.labels <- 
      c( "Q-05", "Q-25", "Q-50", "Q-75", "Q-95" )

  quant <- data.frame( quant.labels, quant.value )

  cat( paste0(  "##### ",  x.lab,  "\n\n" )  )
  cat( paste0(  
    kableExtra::remove_column( 
    knitr::kable( quant ), 1 ), 
    " \n" ), sep="" )
  cat( "\n\n" )
}


build_stattable_numeric <- 
  function( x, x.lab=NULL ) {

  min          <- min( x, na.rm=T )
  median       <- median( x, na.rm=T )
  mean         <- mean( x, na.rm=T )
  max          <- max( x, na.rm=T )
  skew         <- skew( x, na.rm=T )
  kurt         <- kurtosi( x, na.rm=T )
  stat.value   <- c( min, median, mean, max, skew, kurt)
  stat.labels  <- c( "Min", "Median", "Mean", "Max", "Skew", "Kurt" )
  stat         <- data.frame( stat.labels, stat.value )
  cat( paste0( "##### ", x.lab, "\n\n" ) )
  cat( paste0( kable( stat ), " \n" ), sep="" )
  cat( "\n\n" )
}


hg <- function( x ) {
  t <- table( cut( x, 10 ) )
  par( mar=c(0,0,0,0) )
  barplot( 
    t, col="steelblue", 
    axisnames = FALSE )
}







create_div1 <- function( x1=vname ) {
  cat(  "::: {.div1} \n\n"  )
  cat( paste0(  "#### ",  x1,  "\n\n"  ) )
  cat(  "::: \n\n"  )
}

create_div1( x1=vname )



create_div2 <- function( 
    x2=vlabel, 
    x2.lab="LABEL" ) {

  cat( "::: {.div2} \n\n" )
  v_to_txt( x2, x2.lab )
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

create_div5 <- function( 
    x8=x, x8.lab="Properties" ) {
  cat( "::: {.div5} \n\n" )
  build_proptable_numeric( x8, x8.lab )
  cat( "::: \n\n" )
}

create_div5( x8=x )

create_div6 <- function( 
    x9=x, x9.lab="Quantiles" ) {
  cat( "::: {.div6} \n\n" )
  build_quanttable_numeric( x9, x9.lab )
  cat( "::: \n\n" )
}

create_div6( x9=x )


create_div7 <- function( 
    x10=x, x10.lab="Statistics" ) {
  cat( "::: {.div7} \n\n" )
  build_stattable_numeric( x10, x10.lab )
  cat( "::: \n\n" )
}

create_div7( x10=x )






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
desc <- "description"


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




ff <- 
  c( sample( LETTERS, 250, replace=T ), 
     sample( LETTERS[8:15], 250, replace=T ) )

t <- 
  ff %>% 
  table() %>%
  sort( decreasing=T ) 

bp <- function( x, show=10 ) {
  t <- 
    table(x) %>%
    sort( decreasing=F )

  par( mar=c(4,0,0,1) )
  barplot( 
    t[1:show]/sum(t), col="firebrick4",
    horiz=T, 
    axisnames = FALSE )
}

bp( ff, show=20 )


f_table <- function(
    f, format="html") {
  t <- 
    table(ff) %>%
    sort( decreasing=T )
  pt <- 
    prop.table(t) %>%
    round(3)
  d <- data.frame( 
    F=names(t),
    N=as.numeric(t),
    Prop=as.numeric(pt) )
  kable( d, format )
}

f_table( ff )




