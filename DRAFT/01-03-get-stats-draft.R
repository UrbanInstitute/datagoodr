
####################################
### Functions
###################################

#
# most_common_p <- function(x,val){
#   if(is.na(val)){
#     mc.n <- sum( is.na(x))
#   }else{
#     mc.n <- sum( x == val, na.rm=T )
#   }
#   mc.p <- ( mc.n / length(x) ) |> round(2)
#   return(mc.p)
# }
#
# skew <- function(x) {
#   x <- x[!is.na(x)]
#   n <- length(x)
#   s <- (sum((x - mean(x))^3)/n)/(sum((x - mean(x))^2)/n)^(3/2)
#   return( round(s,2) )
# }

# kurtosis <- function(x) {
#   x <- x[!is.na(x)]
#   n <- length(x)
#   k <- n * sum((x - mean(x))^4)/(sum((x - mean(x))^2)^2)
#   return( round(k,2) )
# }
#
# get_top_vals <- function(x) {
#   t <- table(x) |> sort(decreasing=T) |> head(5)
#   tt <- as.vector(t)
#   names(tt) <- paste0( "top.", names(t) )
#   df <- tt |> as.list() |> data.frame()
#   return(df)
# }


#
#
#
# # FORMAT NUMBER LABELS
# # SO THEY ARE ALWAYS A
# # UNIFORM WIDTH FOR GRAPHS
#
# make3 <- function(x){
#   # need to fix for
#   # large negative nums
#   if( x < 0 ){
#     x <- paste0( round(x,3) )
#     return(x)
#   }
#   if( x >= 0 & x < 10 ){
#     x <- paste0( round(x,2)  )
#     return(x)
#   }
#   if( x >= 10 & x < 100 ){
#     x <- paste0( round(x,1)  )
#     return(x)
#   }
#   if( x > 10^2 & x < 10^6 ){
#     x <- paste0( round(x/(10^3),0), "K" )
#     return(x)
#   }
#   if( x >= 10^6 & x < 10^9 ){
#     x <- paste0( round(x/(10^6),0), "M" )
#     return(x)
#   }
#   if( x >= 10^9 & x < 10^12 ){
#     x <- paste0( round(x/(10^9),0), "B" )
#     return(x)
#   }
#   if( x >= 10^12 & x < 10^15 ){
#     x <- paste0( round(x/(10^12),0), "T" )
#     return(x)
#   }
#   if( x >= 10^15 ){
#     x <- "BFN"
#     return(x)
#   }
# }
#
#
#
# hg_dat <- function( x ) {
#
#   #trim off ends to make plot look a little nicer
#   q05 <- quantile( x, probs=0.05, na.rm=T, names=F )
#   q95 <- quantile( x, probs=0.95, na.rm=T, names=F )
#
#   x <- x[ x >= q05 & x <= q95 ]
#
#   t <- table( cut( x, 50 ) )
#
#   # can't overwrite "pretty" argument when plot is off :(
#   # h <- hist(x,
#   #           breaks = 10,
#   #           plot = FALSE,
#   #           pretty = F)
#   # h <- h[c("breaks", "counts")]
#
#   return(t)
# }
#
# # [1] "(-0.00345,0.149]"
# # [1] "(3.58,3.73]"
#
# get_bin_ave <- function( bin.name ){
#   gsub( "\\(|\\)|\\[|\\]", "", bin.name ) %>%
#   strsplit( "," ) %>%
#   unlist() %>%
#   as.numeric() %>%
#   mean() %>%
#   round(2)
# }
#
# get_bin_min <- function( bin.name ){
#   gsub( "\\(|\\)|\\[|\\]", "", bin.name ) %>%
#   strsplit( "," ) %>%
#   unlist() %>%
#   as.numeric() %>%
#   head(1)
# }
#
# get_bin_max <- function( bin.name ){
#   gsub( "\\(|\\)|\\[|\\]", "", bin.name ) %>%
#   strsplit( "," ) %>%
#   unlist() %>%
#   as.numeric() %>%
#   tail(1)
# }
#
# hg_plot <- function(t){
#
#   # par( mar=c(0,0,0,0) )
#   # barplot(
#   #   t, col="steelblue",
#   #   axisnames = FALSE,
#   #   names.arg = names(t))
#
#   bin1 <- names(t)[1]
#   bin2 <- names(t)[length(t)]
#   min.x <- get_bin_min( bin1 ) |> make3()
#   max.x <- get_bin_max( bin2 ) |> make3()
#
#   if( max( t/sum(t) ) > 0.1 )
#   { t <- log10( t + 1 ) }
#
#   # x11( width=8, height=2 )
#   par( mar=c(2,0,1,0) )
#   b <- barplot( t, col="gray25", border="white",
#                 axes=F, axisnames=F, space=0.05 )
#
#   axis( side=1, at=c(b[1],b[length(b)]),
#         labels=c(min.x,max.x), cex.axis=1.3,
#         line=-0.5, tick=F, font=2, col.axis="gray40" )
# }

# used in get_graphics_num
# Histogram info - new histogram
# get_hist_info <- function(x){
#
#   # these values should be saved in the dgf for the quantiles table
#   me = mean(x, na.rm = TRUE)
#   med = median(x, na.rm = TRUE)
#   min = min(x, na.rm = TRUE)
#   max = max(x, na.rm = TRUE)
#   sk = skew(x)
#
#   #windsorize
#   x <- x[!is.na(x)]
#   lower <- quantile(x, probs = c(0.05), na.rm = TRUE)
#   upper <- quantile(x, probs = c(0.9), na.rm = TRUE)
#   x <- x[x >= lower & x <= upper]
#   # x[x < lower ] <- lower
#   # x[x > upper ] <- upper
#
#
#   #cutoff according to the skew
#   if(sk >0){
#     quant <- 0.75 +  0.25 / (log(sk+20))
#     cutoff <- quantile(x, quant)
#     x <- x[x<=cutoff]
#   }else{
#     quant <- 0.25 * (1-1/log(sk+20))
#     cutoff <- quantile(x, quant)
#     x <- x[x>=cutoff]
#   }
#
#
#
#   # cut off upper values
#   h <- hist( x, 100, plot=F )
#   b <- h$breaks
#   d <- h$density/sum(h$density)
#   y <- h$counts
#   mids <- h$mids # xx
#
#   return(list(breaks=b, density=d, y=y, mids=mids,
#               mean = me, median = med,
#               min = min, max = max))
# }

# # Moved to 03-00-BUILD-RG-DICT.R
# get_histogram <- function(VNAME, LABEL = "HIST"){
#
#   VNAME <- xx[VNAME]
#   # for testing VNAME <- all.vars[1]
#
#   x <- dat[[VNAME]] #this should be the input data set
#
#   x.info <- get_hist_info(x)
#
#   txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
#   cat( txt )
#
#   par( mar=c(2,0,1,0) )
#   plot( x.info$mids, x.info$d,
#         type="h", bty="n", lwd=4, axes=F, col="gray30" )
#
#   x1 <- x.info$mids[1]
#   x2 <- x.info$mids[length(x.info$mids)]
#   min.x <- x1 |> make3()
#   max.x <- x2 |> make3()
#
#   axis( side=1, at=c(x1,x2),
#         labels=c(x.info$min, x.info$max), cex.axis=1.3,
#         line=-0.5, tick=F, font=2, col.axis="gray40" )
#
#   avex <- x.info$mean
#   medx <- x.info$median
#
#   abline( v=avex, lty=3, lwd=2, col="firebrick" )
#   abline( v=medx, lty=3, lwd=2, col="steelblue" )
#   axis( side=1, at=medx, label="median", font=2,
#         col.axis="steelblue", tick=F, line=-1 )
#   axis( side=1, at=avex, label="mean", font=2,
#         col.axis="firebrick", tick=F, line=-0.5 )
#
#   cat( "\n\n" )
#
#
# }


# # Moved to 03-00-BUILD-RG-DICT.R
# get_histogram <- function( VNAME, LABEL = "HIST"){
#
#   VNAME <- xx[VNAME]
#   # for testing VNAME <- all.vars[1]
#
#   x <- dat[[VNAME]] #this should be the input data set
#
#   class.x <- class(x)
#
#   if( class(x) == "factor" )
#   {  x <- as.character(x)  }
#
#   if( class(x) == "character" )
#   {  x <- nchar(x)  }
#
#   hist.dat <- hg_dat(x)
#
#
#   txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
#   cat( txt )
#
#   hg_plot(hist.dat)
#   cat( "\n\n" )
#
# }




# # Moved to 03-00-BUILD-RG-DICT.R
# print_txt_block <- function( x ){
#
#   if( max(nchar(as.character(x)),na.rm=T) > 48 )
#   { x <- purrr::map_chr( x, function(x){ substr(x,1,48) } ) }
#
#   t <- table( x ) |> sort( d=T )
#   txt <- paste0( names(t[1:2000]), collapse=" ;; " )
#   # xx1 <- substr( txt,   1, 100 ) |> trimws()
#   # xx2 <- substr( txt, 101, 200 ) |> trimws()
#   # xx3 <- substr( txt, 201, 300 ) |> trimws()
#   # xx4 <- substr( txt, 301, 400 ) |> trimws()
#   # BLOCK <- paste0( c(xx1,xx2,xx3,xx4), collapse="\n\n" )
#   BLOCK <- substr( txt,   1, 400 ) |> trimws()
#   BLOCK <- gsub( " ?;{1,2} ?$", "", BLOCK )
#   return( BLOCK )
# }

# # Moved to 03-00-BUILD-RG-DICT.R

## Numeric Div8
# get_num_preview <- function( VNAME, LABEL = "DATA PREVIEW" ){
#
#   VNAME <- xx[VNAME] # for testing VNAME <- all.vars[1]
#
#   x <- dat[[VNAME]]  # this should be the input data set
#
#   txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
#   cat( txt )
#
#   cat( print_txt_block( x ) )
#   cat( "\n\n" )
#
# }






#
# #numeric Div 5, factor div 12
# get_properties <- function( VNAME, LABEL = "PROPERTIES" ){
#
#   VNAME <- xx[VNAME]  # for testing VNAME <- all.vars[1]
#   stats <- get_stats(VNAME)
#
#   f <- function(x){ format(x,big.mark=",") }
#   stats <- sapply( stats, f )
#
#   tab <- data.frame(
#     STAT = c( "Rows",  "Distinct",  "Most Common Value",
#               "Zero", "All Empty", "Missing/NA",
#               "Infinite"),
#     VAL =  c( stats[["N"]], stats[["distinct.n"]], stats[["most.common.v"]],
#               stats[["zero.n"]], stats[["missing.n"]], stats[["na.n"]],
#               stats[["inf.n"]]),
#     PER = c( "", stats[["distinct.p"]], stats[["most.common.p"]],
#              stats[["zero.p"]], stats[["missing.p"]], stats[["na.p"]],
#              ""))
#
#   per.index <- nchar(tab$PER) > 0
#   tab$PER[per.index] <- paste0("(", tab$PER[per.index], "%)")
#
#   # Olivia Adding
#   txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
#   cat( txt )
#
#   k <- knitr::kable( tab, align=c("l","r", "r"))
#   cat( paste0( k, " \n" ) )
#   cat( "\n\n" )
#
#   # VAL <-
#   #   c( stats[["N"]],
#   #      stats[["distinct.n"]], stats[["distinct.p"]],
#   #      stats[["duplicated.p"]],
#   #      stats[["most.common.v"]], stats[["most.common.p"]],
#   #      stats[["zero.n"]], stats[["zero.p"]],
#   #      stats[["missing.n"]],
#   #      stats[["na.n"]], stats[["na.p"]],
#   #      stats[["inf.n"]] )
#   #
#   #
#   # STAT <-
#   #   c( "Rows (N)",
#   #      "Distinct (N)", "Distinct (%)", "Duplicates (%)",
#   #      "Most Common Value", "Most Common Val (%)",
#   #      "Zero (N)", "Zero (%)",
#   #      "All Empty (N)",
#   #      "Missing/NA (N)", "Missing/NA (%)",
#   #      "Infinite (N)")
#
#   # Olivia Adding
#   # txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
#   # cat( txt )
#   #
#   # t <- data.frame( STAT, VAL )
#   # k <- knitr::kable( t, align=c("l","r"))
#   # cat( paste0( k, " \n" ) )
#   # cat( "\n\n" )
# }
#
#
# # get_properties( VNAME )
#

# Now just included as get_stats in numeric variables
# ## Numeric Div6
# get_quantiles <- function(VNAME, LABEL = "QUANTILES"){
#
#   VNAME <- xx[VNAME]
#   # for testing VNAME <- all.vars[1]
#
#   stats <- get_stats(VNAME)
#   f <- function(x){ format(x,big.mark=",") }
#   stats <- sapply( stats, f )
#
#   VAL <-
#     c(stats[["q05"]],
#       stats[["q25"]],
#       stats[["q50"]],
#       stats[["q75"]],
#       stats[["q95"]] )
#
#   STAT <-
#     c( "Q - 05",
#        "Q - 25",
#        "Q - 50",
#        "Q - 75",
#        "Q - 95")
#
#   txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
#   cat( txt )
#
#   t <- data.frame( STAT, VAL )
#   k <- knitr::kable( t, align=c("l","r"))
#   cat( paste0( k, " \n" ) )
#   cat( "\n\n" )
#
# }
#

#
# ## Numeric Div7
# get_stats_num <- function(VNAME, LABEL = "STATS"){
#
#   VNAME <- xx[VNAME]
#   # for testing VNAME <- all.vars[1]
#
#   stats <- get_stats(VNAME)
#   f <- function(x){ format(x,big.mark=",") }
#   stats <- sapply( stats, f )
#
#   tab <- data.frame(
#     STAT = c("Minimum", "Q - 05", "Q - 25", "Median", "Mean",
#              "Q - 75", "Q - 95", "Maximum", "Skew"),
#     VAL = c(stats[["min.x"]], stats[["q05"]], stats[["q25"]], stats[["median.x"]],
#             stats[["mean.x"]], stats[["q75"]], stats[["q95"]],
#             stats[["max.x"]],  stats[["skew.x"]])
#   )
#
#
#
#   # VAL <-
#   #   c(stats[["min.x"]],
#   #     stats[["median.x"]],
#   #     stats[["mean.x"]],
#   #     stats[["max.x"]],
#   #     stats[["skew.x"]],
#   #     stats[["kurt.x"]])
#   #
#   # STAT <-
#   #   c( "Minimum",
#   #      "Median",
#   #      "Mean",
#   #      "Max",
#   #      "Skew",
#   #      "Kurt")
#
#   txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
#   cat( txt )
#
#   # t <- data.frame( STAT, VAL )
#   k <- knitr::kable( tab, align=c("l","r"))
#   cat( paste0( k, " \n" ) )
#   cat( "\n\n" )
#
# }
#
#
#
#
#
#
#
#
#
# ## Numeric Div9
# get_examples_num <- function(VNAME, LABEL = "PREVIEW"){
#
#   VNAME <- xx[VNAME]
#   # for testing VNAME <- all.vars[1]
#
#   x <- dat[[VNAME]] #this should be the input data set
#
#   class.x <- class(x)
#
#   if( class(x) == "factor" )
#   {  x <- as.character(x)  }
#
#   if( class(x) == "character" )
#   {  x <- nchar(x)  }
#
#
#   # convert to table
#   e <- gt::gt( as.data.frame( matrix( sample(x, 25), nrow=5 ) ) )
#   e <- gt::tab_options( e, column_labels.hidden = T )
#
#   e <- gt::data_color( e,
#               fn=scales::col_numeric( c( "white", "aquamarine3" ),
#                                       domain=NULL ) )
#
#
#
#   txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
#   cat( txt )
#   cat(gt::as_raw_html(e))
#   cat( "\n\n" )
#
#
# }
#
# ## Character Div9
# get_examples_chr <- function(VNAME, LABEL = "PREVIEW"){
#
#   VNAME <- xx[VNAME]
#   # for testing VNAME <- all.vars[1]
#
#   x <- dat[[VNAME]] #this should be the input data set
#
#
#   # convert to table
#   e <- gt::gt( as.data.frame( matrix( sample(x, 10), nrow=5 ) ) )
#   e <- gt::tab_options( e, column_labels.hidden = T )
#
#
#   txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
#   cat( txt )
#   cat(gt::as_raw_html(e))
#   cat( "\n\n" )
#
#
# }
#
#
#
#
#
#
#
#

### Old get_stats funciton, keeping until brach off
#
# get_stats <- function( varname ){
#
#   # Jesse Original
#   # x <- df[[varname]]
#
#   #Olivia Fix
#   x <- dat[[varname]] #this should be the input data set
#
#   class.x <- class(x)
#
#   if( class(x) == "factor" )
#   {  x <- as.character(x)  }
#
#   if( class(x) == "character" )
#   {  x <- nchar(x)  }
#
#   N <- length(x)
#   distinct.n <- unique(x) |> length()
#   distinct.p <- ( distinct.n / N  )|> round(2)
#   duplicated.p <- 1 - distinct.p
#   zero.n  <- sum( x == 0, na.rm=T )
#   zero.p  <- ( zero.n / N ) |> round(2)
#   empty.n <- sum( x == "", na.rm=T )
#   empty.p <- ( empty.n / N ) |> round(2)
#   na.n    <- sum( is.na(x) | is.nan(x) )
#   na.p    <- ( na.n / N ) |> round(2)
#   inf.n   <- sum( is.infinite(x) )
#   missing.n <- is_missing(x)
#   missing.p <- ( is_missing(x) / N ) |> round(2)
#   most.common.v <- most_common_val(x)
#   most.common.p <- most_common_p( x, most.common.v )
#
#   q05 <- quantile( x, probs=0.05, na.rm=T, names=F )
#   q25 <- quantile( x, probs=0.25, na.rm=T, names=F )
#   q50 <- quantile( x, probs=0.50, na.rm=T, names=F )
#   q75 <- quantile( x, probs=0.75, na.rm=T, names=F )
#   q95 <- quantile( x, probs=0.95, na.rm=T, names=F )
#
#   min.x    <- min(  x, na.rm=T )
#   max.x    <- max(  x, na.rm=T )
#   mean.x   <- mean( x, na.rm=T )
#   median.x <- q50
#
#   skew.x <- skew(x)
#   kurt.x <- kurtosis(x)
#
#   df <- data.frame(
#     varname, N, class.x,
#     distinct.n, distinct.p, duplicated.p,
#     zero.n, zero.p, empty.n, empty.p,
#     na.n, na.p, inf.n,
#     missing.p, missing.n,
#     most.common.v, most.common.p,
#     q05, q25, q50, q75, q95,
#     min.x, median.x, mean.x, max.x,
#     skew.x, kurt.x )
#
#   return( df )
# }
#
#
