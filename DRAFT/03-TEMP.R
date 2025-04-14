
start_date <- as.Date('2015-01-01')  
end_date <- as.Date('2017-01-01') 

x <- 
  sample( 
  seq(
   as.Date('2015-01-01'), 
   as.Date('2018-06-01'), 
   by = "day" ), 
   1000 ) 

format( head(x), "%Y" )
format( head(x), "%b" )
format( head(x), "%d" )





# library
library(treemap)
 
# Create data
group <- c("group-1","group-2","group-3")
value <- c(13,5,22)
data <- data.frame(group,value)
 
# treemap
treemap(data,
            index="group",
            vSize="value",
            type="index"
            )
            
            
Searing, EA &amp; Lecy, JD (2022).. 2023. "Form 990-N ePostcard Filers." Growing up nonprofit: Predictors of early-stage nonprofit formalization. Nonprofit and Voluntary Sector Quarterly, 51(3), 680-698.. <a href="https://doi.org/10.1177/08997640211014280" target="_blank">https://doi.org/10.1177/08997640211014280</a> 