
#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param x PARAM_DESCRIPTION
#' @param unique.p PARAM_DESCRIPTION, Default: 0.05
#' @param unique.n PARAM_DESCRIPTION, Default: 100
#' @param top.n PARAM_DESCRIPTION, Default: 25
#' @param max.variance PARAM_DESCRIPTION, Default: 2
#' @param b.to.f PARAM_DESCRIPTION, Default: FALSE
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[DescTools]{IsDate}}
#'  \code{\link[hablar]{retype}}
#' @rdname is_factor
#' @export 
#' @importFrom DescTools IsDate
#' @importFrom hablar retype
is_factor <- function(        # --------------------

    x, 
    unique.p = 0.05, 
    unique.n = 100,  
    top.n  = 25, 
    max.variance = 2, 
    b.to.f  = FALSE )
    
{   # -----------------------------------------------


  # exclude NA, NaN, and Inf

  if( is.numeric(x) | is.logical(x) )
  {  x <- x[ is.finite(x) ] }

  if( is.character(x) )
  {  
    x[ x == "NaN" | x == "Inf" ] <- NA
    x <- na.omit(x)
  }
 

  n <- length(x)

  if( n == 0 )
  {
    cat( "The variable is empty (all NAs)" )
    return(FALSE)
  }
  
  if( n > 10000 )
  { 
    set.seed(123)
    x <- x[ sample( length(x), 10000 ) ]
    n <- length(x)
    cat( "Using the first 10,000 values of x. \n\n"  )
  }
  
  
  # use the more conservative criteria
  up.n <- unique.p * length(x)
  if( up.n > unique.n )
    { unique.p <- unique.n / length(x) }
  if( unique.n > up.n )
    { unique.n <- unique.p * length(x) }
  
  
  # cat( paste0( "\n-----------------  ", deparse(substitute(x)), "\n\n" ) )

  cat( paste0( "Examining N cases: ", n, "\n" ) )
  cat( paste0( "Unique levels/values of x = ", length(unique(x)), "\n" ) )
  cat( paste0( "unique.n argument = ", unique.n, "\n" ) )
  cat( paste0( "unique.p argument = ", unique.p, "\n\n" ) )

  if( "factor" %in% class(x) )
  { 
    cat( "has class FACTOR \n" )
    cat( paste0( "Values of x: \n", paste( head( unique(x), 10 ), collapse=",\n" ), "\n\n" ) )
    cat( "####   IS FACTOR   #### \n\n\n" )
    return(TRUE) 
  }

  if( "logical" %in% class(x) )
  { 
    cat( "has class LOGICAL: is NOT a factor \n\n" )
    cat( paste0( "Values of x: \n", paste( head( unique(x), 10 ), collapse=",\n" ), "\n\n" ) )
    return(FALSE) 
  }

  if( any( DescTools::IsDate(x) ) )
  {
    x.dates <- x[ DescTools::IsDate(x) ]
    cat( "x has class DATE: is NOT a factor \n" )
    cat( paste0( "Values of x: \n", paste( head( unique(x.dates), 10 ), collapse=",\n\n" ) ) )
    return(FALSE)
  }
  
  if( "character" %in% class(x) )
  {
    cat( "x has class CHARACTER: \n\n" )

    # is a logical vector
    if( length(unique(x)) == 1 )
    { 
      cat( "All values of x are the same: \n" )
      cat( paste0( "Values of x: \n", paste( head( unique(x), 10 ), collapse=",\n" ), "\n" ) )
      if( b.to.f )
      { 
        cat( "Convert binary to factor is set to TRUE \n\n" )
        cat( "####   IS FACTOR   #### \n\n\n" )
        return(TRUE) 
      }
      cat( "Convert binary to factor is set to FALSE \n\n" )
      return(FALSE) 
    }


    # strings with same length (standardized categories) 
    #  but keep the total levels low so it doesn't flag IDs
    is.same <- length( unique( nchar(x) ) ) == 1  & length(unique(x)) < ( n * unique.p )
    
    if( is.same )
    { 
      cat( "All strings have the same number of characters \n\n" )
      cat( paste0( "Values of x (first 10): \n", paste( head( unique(x), 10 ), collapse=",\n" ), "\n\n" ) ) 
    }
    
    # small number of unique cases
    n.unique <- length( unique( x ) ) 
    
    # small prop of total cases unique
    p.unique <- length( unique( x ) ) / n
    
    is.small.unique.n <- n.unique <= unique.n & p.unique <= unique.p

    if( is.small.unique.n )
    { 
      cat( "x has a small number & proportion of unique cases\n" )
      cat( paste0( "N < ", unique.n, " & prop < ", unique.p, "\n" ) )
      cat( paste0( "Number of unique values of x: ", length(unique(x)), "\n" ) )
      cat( paste0( "Values of x (first 10): \n", paste( head( sort(unique(x)), 10 ), collapse=",\n" ), "\n\n" ) )
    }
   
    # most common levels account for large portion of total
    
    first.n.total <- table(x) %>% sort(desc=T) %>% head( top.n ) %>% sum() 
    total.p <- first.n.total / n
    is.large.p.total <- total.p > 0.90

    first.n.levels <- table(x) %>% sort(desc=T) %>% head( top.n ) %>% names()

    if( is.large.p.total )
    { 
      cat( paste0( "First ", top.n, " levels accounts for > 90% of total cases \n" ) ) 
      cat( paste0( "First N levels: \n", paste( first.n.levels, collapse=",\n" ), "\n\n" ) )
    }
    
    # if it meets any criteria return factor
    if( is.same | is.small.unique.n | is.large.p.total )
    { 
      cat( "####   IS FACTOR   #### \n\n\n" )
      return(TRUE) 
    }
  }
  
  # only test integers 
  x <- hablar::retype(x)

  if( "numeric" %in% class(x) )
  { 
    cat( "x is non-integer number: NOT a factor \n\n" )
    cat( paste0( "Values of x (first 10): \n", paste( head( unique(x), 10 ), collapse=",\n" ), "\n\n" ) )
    return(FALSE)
  }
  
  if( "integer" %in% class(x) )
  {
    cat( "x has class INTEGER: \n\n" )

    # is a logical vector
    if( all( x %in% c(0,1) ) | length(unique(x))==1 )
    { 
      cat( "All values of x are 0/1 or a single value: \n" )
      cat( paste0( "Values of x: ", paste( head( unique(x), 10 ), collapse=", " ), "\n" ) )
      if( b.to.f )
      { 
        cat( "Convert binary to factor is set to TRUE \n\n" )
        cat( "####  x IS A FACTOR   #### \n\n\n" )
        return(TRUE) 
      }
      cat( "Convert binary to factor is set to FALSE \n\n" )
      cat( "#### ------- x is NOT a factor \n\n\n" )
      return(FALSE) 
    }
    
    # has negative values 
    if( any( x < 0 ) )
    { 
      cat( "Contains negative integers \n" )
      cat( paste0( "Range x: ", range(x), "\n\n" ) )
      return(FALSE) 
    }
    
    # small numer of unique values
    n.unique <- length( unique( x ) ) 
    
    # small prop of total cases unique
    p.unique <- length( unique( x ) ) / n
    
    is.small.unique.n <- n.unique <= unique.n & p.unique <= unique.p

    if( is.small.unique.n )
    { 
      cat( "x has a small number & proportion of unique cases \n" )
      cat( paste0( "unique(x) < ", unique.n, " & unique(x)/length(x) < ", unique.p, " \n" ) )
      cat( paste0( "Number of unique values of x: ", length(unique(x)), "\n" ) )
      cat( paste0( "Unique values of x (first 10): \n", paste( head( sort(unique(x)), 10 ), collapse=",\n" ), "\n\n" ) )
    }
    
    # starts with 1 and is an approximate sequence
    starts.with.one <- min(x) == 1 
    width.of.range.x <- max(x) - min(x) + 1
    is.approx.seq <- length(unique(x)) / width.of.range.x > 0.8
    
    is.seq.from.one <- starts.with.one & is.approx.seq

    if( is.seq.from.one )
    { cat( "x is an approximate sequence of integers starting with one \n\n" ) }
    
    # is a true sequence, e.g. 9,10,11,12
    is.true.seq <- length(unique(x)) == width.of.range.x & 
                   length(unique(x))/length(x) < unique.p

    if( is.true.seq )
    { 
      cat( "x is a true sequence of integers \n" )
      cat( paste0( "Values: \n", paste( sort(unique(x)), collapse=", \n" ), "\n\n" ) )
    }
    
    # equal intervals between all numbers
    is.equal.intervals <- length( unique( x[-1] - x[-length(x)] ) ) == 1
    
    if( is.equal.intervals )
    {
      cat( "All values of x have equal intervals between them \n" )
      cat( paste0( "Values: ", paste( head(sort(unique(x))), collapse=", " ), "\n\n" ) )
    }

    # small variance
    is.small.var <- var(x) < max.variance

    if( is.small.var )
    { cat( paste0( "The variance of x is below ", max.variance, "\n\n" ) ) }
    
    # if it meets any criteria and less than twice unique.n return factor
    if( ( is.small.unique.n | is.seq.from.one | is.true.seq | is.equal.intervals ) & n.unique < 2*unique.n )
    { 
      cat( "####  X IS A FACTOR   #### \n\n\n" )
      cat( "--------------------------------------------\n\n\n" )
      return(TRUE) 
    }  
  }

  cat( "There are a large number of unique values: x is NOT a factor \n" )
  cat( paste0( "Number of unique values of x: ", length(unique(x)), "\n" ) )
  cat( paste0( "Values of x (first 10): \n", paste( head( sort(unique(x)), 10 ), collapse=",\n" ), "\n\n" ) )
  cat( "------------------------------------------------\n\n\n" )
  return( FALSE )
}




#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param df PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname is_factor_df
#' @export 
is_factor_df <- function( df )
{
  invisible( capture.output( 
     ff <- lapply( df, is_factor ) %>% unlist() ) )
  names(ff) <- names(df)
  return(ff)
}



#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param df PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname recast_factors
#' @export 
recast_factors <- function( df )
{
  ff <- is_factor_df( df )
  df[ names(ff)[ff] ] <- 
    lapply( df[ names(ff)[ff] ], as.factor )
  return(df)
}



