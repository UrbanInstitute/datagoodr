library( tidyverse )


data( starwars )

head( starwars )




d <- starwars
d$films <- lapply( d$films, paste, collapse=";; " ) %>% unlist()
d$vehicles <- lapply( d$vehicles, paste, collapse=";; " ) %>% unlist()
d$starships <- lapply( d$starships, paste, collapse=";; " ) %>% unlist()




write.csv( d, "starwars.csv", row.names=F )


library( Lahman )

install.packages("Lahmann")

[ Batting$AB == 0 ] <- NA

Batting <- 
  Batting %>% 
  mutate( AVG = H / AB,
          X1B = H - X2B - X3B - HR,
          SLUG = ( X1B + 2*X2B + 3*X3B + 4*HR ) / AB )

summary( Batting$SLUG )

df1 <- merge( Batting, Salaries )



Batting$AB[ Batting$AB == 0 ] <- NA

Batting <- 
  Batting %>% 
  mutate( AVG = H / AB,
          X1B = H - X2B - X3B - HR,
          SLUG = ( X1B + 2*X2B + 3*X3B + 4*HR ) / AB )

df2 <- merge( Batting, Salaries )

yearID teamID lgID stint

df3 <- 
  df2 %>% 
  select( - c(yearID,teamID,lgID,stint) ) %>%
  filter( G > 10 ) %>% 
  group_by( playerID ) %>% 
  summarise_all( mean, na.rm=T ) %>% 
  select( "playerID", "G", "AB", "H", 
          "X1B", "X2B", "X3B", "HR", 
          "R", "RBI", "AVG",  "SLUG", "salary" )


df4 <- merge( People, df3 )


write.csv( df4, "pbs.csv", row.names=F )


# CREATE BASEBALL SUBSET 
# WITH ERRORS FOR DEMO 

bb <- df4

these <- 
c( "nameFirst", "nameLast",
   "birthDate","birthYear", "birthMonth", 
   "birthState", "birthCity",
   "weight", "height", "bats", "throws",
   "debut", "finalGame",
   "G", "AB", "H", "AVG", "SLUG", "salary" )

bb <- as.data.frame( bb[these] )
birth.date <- bb$birthDate
bb$birthDate <- format( bb$birthDate, "%b %d, %Y" )
bb$birthMonth <- format( birth.date, "%b" )
bb$G <- round( bb$G, 0 )
bb$AB <- round( bb$AB, 0 )
bb$H <- round( bb$H, 0 )
bb$salary <- dollarize( bb$salary )
head( bb )

get_class_df( bb )

write.csv( bb, "bb.csv", row.names=F )




plot( df3$AVG, log( df3$salary + 1 ) )

  
c(  )

df3



BT <- with(People, table(bats, throws))
require(vcd)
structable(BT)
mosaic(BT, shade=TRUE)


nm <- strsplit( row.names(mtcars), " " )

get_first <- function(x)
{
  return( x[1] )
}

drop_first <- function(x)
{
  return( paste( x[-1], collapse=" " ) )
}

make <- lapply( nm, get_first ) %>% unlist()
model <- lapply( nm, drop_first ) %>% unlist()


mtcars$make <- make
mtcars$model <- model 

write.csv( mtcars, "mtcars.csv", row.names=F )





