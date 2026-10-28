
#' Guess whether a vector should be treated as a factor
#'
#' Applies a series of heuristics to decide whether a vector represents a
#' categorical (factor) variable rather than free text, an identifier, a
#' continuous number, a date, or a logical. Character and integer vectors are
#' flagged as factors when they have few unique values relative to their
#' length, use fixed-width standardized codes, are dominated by their most
#' common levels, or form an approximate integer sequence. Diagnostic details
#' about the decision are printed to the console.
#'
#' @param x A vector of any type to evaluate.
#' @param unique.p Maximum proportion of unique values for `x` to be
#'   considered a factor. Default `0.05`.
#' @param unique.n Maximum count of unique values for `x` to be considered a
#'   factor. The more conservative of `unique.p`/`unique.n` is used. Default `100`.
#' @param top.n Number of most-common levels used when testing whether a few
#'   levels account for the bulk of the data. Default `25`.
#' @param max.variance Variance threshold below which an integer vector is
#'   treated as categorical. Default `2`.
#' @param b.to.f Logical; if `TRUE`, binary (0/1 or single-value) vectors are
#'   converted to factors. Default `FALSE`.
#' @param verbose Logical; print the per-column reasoning to the console.
#'   Default `TRUE`. `FALSE` skips building those diagnostic strings entirely,
#'   which is why the batch path ([is_factor_df()]) is markedly faster - the
#'   decision itself is unchanged.
#'
#' @return A single logical value: `TRUE` if `x` should be treated as a
#'   factor, otherwise `FALSE`.
#' @seealso \code{\link[DescTools]{IsDate}}, \code{\link[hablar]{retype}}
#' @rdname is_factor
#' @export
is_factor <- function(        # --------------------

    x, 
    unique.p = 0.05, 
    unique.n = 100,  
    top.n  = 25, 
    max.variance = 2, 
    b.to.f  = FALSE,
    verbose = TRUE )
    
{   # -----------------------------------------------

  need_pkg( "DescTools", "hablar" )

  ## The diagnostics below are the expensive part of this function when its
  ## output is discarded: every `cat( paste0( ..., head( unique(x), 10 ), ... ) )`
  ## tabulates and pastes the column before anything is printed. Shadowing `cat`
  ## with a no-op leaves those arguments as unforced promises, so on the quiet
  ## path (is_factor_df(), and therefore every create_dgf() call) the strings are
  ## never built at all. Measured on 4,620 x 19, this trims is_factor_df() by
  ## roughly 0.2s of the 1.0s it spent; what remains is hablar::retype(), which
  ## is real typing work rather than discarded reporting.
  if( ! verbose ) cat <- function( ... ) invisible( NULL )

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
    
    ## one tabulation, used for both the share test and the diagnostic. This
    ## was previously table(x) twice over the full column - the counts and the
    ## names come from the same ranked table.
    top.levels <- table(x) %>% sort(desc=T) %>% head( top.n )
    first.n.total <- sum( top.levels )
    total.p <- first.n.total / n
    is.large.p.total <- total.p > 0.90

    if( is.large.p.total )
    { 
      cat( paste0( "First ", top.n, " levels accounts for > 90% of total cases \n" ) ) 
      cat( paste0( "First N levels: \n", paste( names( top.levels ), collapse=",\n" ), "\n\n" ) )
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
  # blanks retype to NA; drop them so the integer checks below (x < 0,
  # min/max, sequence tests) compare real values instead of erroring on NA
  x <- x[ ! is.na(x) ]
  if( length(x) == 0 ) return(FALSE)

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




#' Guess factor columns across a data frame
#'
#' Applies [is_factor()] to every column of a data frame, suppressing the
#' per-column console diagnostics.
#'
#' @param df A data frame.
#' @param verbose Logical; print [is_factor()]'s per-column reasoning. Default
#'   `FALSE` - the diagnostics were previously generated and then discarded.
#'
#' @return A named logical vector, one element per column, indicating which
#'   columns should be treated as factors.
#' @seealso [is_factor()], [recast_factors()]
#' @rdname is_factor_df
#' @export
is_factor_df <- function( df, verbose = FALSE )
{
  ## verbose = FALSE skips building the per-column diagnostics entirely (see
  ## is_factor()); capture.output() stays as a guard so a dependency that prints
  ## cannot leak into a create_dgf() transcript.
  invisible( capture.output( 
     ff <- lapply( df, is_factor, verbose = verbose ) %>% unlist() ) )
  names(ff) <- names(df)
  return(ff)
}



#' Convert guessed factor columns to factors
#'
#' Uses [is_factor_df()] to identify columns that should be treated as
#' categorical and converts each of them to a factor, leaving all other
#' columns unchanged.
#'
#' @param df A data frame.
#'
#' @return The input data frame with guessed-categorical columns coerced to
#'   factors.
#' @seealso [is_factor_df()]
#' @rdname recast_factors
#' @export
recast_factors <- function( df )
{
  ff <- is_factor_df( df )
  df[ names(ff)[ff] ] <- 
    lapply( df[ names(ff)[ff] ], as.factor )
  return(df)
}



