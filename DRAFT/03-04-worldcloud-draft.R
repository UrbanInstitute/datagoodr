# library( wordcloud )
#
# library(wordcloud2)
# head(demoFreq)
#
# w <- demoFreq$word |> as.character()
# frq <- demoFreq$freq
# ww <- rep( w, times=frq )
# df <- simplify_char(ww)
# jsonify_df( df )
#
# scale.f <- get_scale_f(df)
#
# dev.new( width=10, height=5 )
# par( fin=c(9.8,4.9), mar=c(0,0,0,0) )
# wordcloud( words=df$ww, freq=df$Freq,
#            max.words=500, min.freq=1,
#            random.order=FALSE,
#            scale=c(scale.f,0.5), col=vc(),
#            rot.per=0, fixed.asp=F,
#            vfont=vf() )
#
#

#  returns the max num
#  to be used in the
#  scale argument in wordcloud
#  using a ratio of the
#  sum of characters across
#  all words in the word count table,
#  and the distribution of their frequency

get_scale_f <- function( df ) {
  n.char <- sum( nchar(as.character( df$ww )) )
  xx <- df$Freq / max(df$Freq, na.rm = TRUE)
  n.scale <- sum( xx )
  n.row <- nrow(df)
  scale.f <- 0.003 * ( n.char / exp( n.scale/n.row ) )
  return( scale.f )
}



########################################################


# library( wordcloud )
# v <- df[["NAME"]]
# dd <- simplify_char( v )
# jsonify_df( dd )
# v_to_wordcloud( v )





v_to_wordcloud <- function( VNAME, LABEL = "WORD CLOUD" ) {

  VNAME <- xx[VNAME]
  # for testing VNAME <- all.vars[1]

  v <- dat[[VNAME]] #this should be the input data set


  #the next two lines should be replaced with rg_graphics column from DGF
  ddd <- head(simplify_char( v ), 100)
  scale.f <- get_scale_f( ddd )

  dev.new( width=10, height=5 )
  # par( fin=c(9.8,4.9), mar=c(0,0,0,0) )
  wordcloud::wordcloud(
    words=ddd$ww, freq=ddd$Freq,
    max.words=nrow(ddd),
    min.freq=1,
    random.order=FALSE,
    scale=c( scale.f, 0.5 ),
    rot.per=0, fixed.asp=F,
    col=vc(), vfont=vf()  )
  dev.off()
}



#  returns the max num
#  to be used in the
#  scale argument in wordcloud
#  using a ratio of the
#  sum of characters across
#  all words in the word count table,
#  and the distribution of their frequency

get_scale_f <- function( df ) {
  n.char <- sum( nchar(as.character( df$ww )) )
  xx <- df$Freq / max(df$Freq)
  n.scale <- sum( xx )
  n.row <- nrow(df)
  scale.f <- 0.004 * ( n.char / exp( n.scale/n.row ) )
  return( scale.f )
}





simplify_char <- function(v) {

  ww <- strsplit( v, " " ) |> unlist()
  stop.words <- tm::stopwords("english")
  stop.words <- c( stop.words, toupper(stop.words) )
  ww <- ww[ ! ww %in% stop.words ]
  ww <- gsub( "[[:punct:]]", "", ww )
  ww <- ww[ ww != "" ]

  dd <- as.data.frame(sort(table(ww),decreasing=T))
  n.row <- nrow(dd)
  if( n.row > 400 )
  { dd <- dd[1:400,] }

  return(dd)
}



jsonify_df <- function( df )
{
  jd <- jsonlite::toJSON( df )
  jd <- gsub( "\\{", "  \\{  ", jd )
  jd <- gsub( ":", " :  ", jd )
  jd <- gsub( '",', '"  ,  ', jd )
  jd <- gsub( '","', '",  "', jd )
  jd <- gsub( "\\},", "  \\}, \n", jd )
  jd <- gsub( "\\[", "\\[ \n", jd )
  jd <- gsub( "\\]", "\n\\]", jd )
  jd <- gsub( "\\}\n", "  \\}\n", jd )
  return(jd)
}


# SAMPLE FONTS

vf <- function(){

  fonts <- list(
    c("script","bold"),
    c("gothic english","plain"),
    c("serif","plain"),
    c("sans serif","bold"),
    NULL )

  sample( fonts, 1 ) |> unlist()

}

# SAMPLE COLORS

vc <- function() {

  colz <-
    c("navy", "slategray4", "darkorchid4", "forestgreen", "goldenrod4",
      "darkolivegreen4", "mistyrose4", "navajowhite4", "magenta4",
      "seagreen4", "yellow4", "dodgerblue1", "mediumvioletred")

  sample( colz, 1 )

}







######################################
######################################
######################################
######################################



#
#
# library( wordcloud )
#
# library(wordcloud2)
# head(demoFreq)
#
# w <- demoFreq$word |> as.character()
# frq <- demoFreq$freq
# ww <- rep( w, times=frq )
# df <- simplify_char(ww)
# jsonify_df( df )
#
# scale.f <- get_scale_f(df)
#
# dev.new( width=10, height=5 )
# par( fin=c(9.8,4.9), mar=c(0,0,0,0) )
# wordcloud( words=df$ww, freq=df$Freq,
#            max.words=500, min.freq=1,
#            random.order=FALSE,
#            scale=c(scale.f,0.5), col=vc(),
#            rot.per=0, fixed.asp=F,
#            vfont=vf() )
#
#


######################################
######################################
######################################
######################################



#
#
# dev.new( width=10, height=5 )
# par( fin=c(9.8,4.9), mar=c(0,0,0,0) )
# wordcloud( words=w, freq=frq,
#            max.words=500, min.freq=1,
#            random.order=FALSE,
#            scale=c(5,0.5), col=vc(),
#            rot.per=0, fixed.asp=F,
#            vfont=vf() )
#
#
#
# wf <- df$ww
# sum( nchar(as.character(df$ww)) )
# xx <- df$Freq / max(df$Freq)
# sum( xx )
#
# n.char <- sum( nchar(as.character(df$ww)) )
# n.scale <- sum( xx )
# n.row <- nrow(df)
# n.scale/n.row
# exp( n.scale/n.row  )
#
# 8 / ( n.char / exp( n.scale/n.row ) )
#
# scale.f <- 0.003 * ( n.char / exp( n.scale/n.row ) )
#
# par( fin=c(9.8,4.9), mar=c(0,0,0,0) )
# wordcloud( words=df$ww, freq=df$Freq,
#            max.words=500, min.freq=1,
#            random.order=FALSE,
#            scale=c(scale.f,0.5), col=vc(),
#            rot.per=0, fixed.asp=F,
#            vfont=vf() )
#
#
# df2 <- tail( x, 500 )
#
#
# w <- df2$Var1 |> as.character()
# frq <- df2$Freq
# ww <- rep( w, times=frq )
# df <- simplify_char(ww)
#
#
# xx2 <- df$Freq / max(df$Freq)
# n.char <- sum( nchar(as.character( df$ww )) )
# n.scale <- sum( xx2 )
# n.row <- nrow(df)
# n.scale/n.row
# exp( n.scale/n.row )
#
# 7 / ( n.char / exp( n.scale/n.row ) )
#
# df2 <- dplyr::arrange( df2, - Freq )
#
# scale.f <- 0.0025*( n.char / exp( n.scale/n.row ) )
#
# # dev.new( width=10, height=5 )
# par( fin=c(9.8,4.9), mar=c(0,0,0,0) )
# wordcloud( words=df$ww, freq=df$Freq,
#            max.words=500, min.freq=1,
#            random.order=FALSE,
#            scale=c(scale.f,0.5), col=vc(),
#            rot.per=0, fixed.asp=F,
#            vfont=vf() )
#
#
#
#
# #############################
# #############################
# #############################
#
#
# library(wordcloud2)
#
# # have a look to the example dataset
# # head(demoFreq)
#
# # Basic plot
# wordcloud2(data=demoFreq, size=1.6)
#
# library( wordcloud )
#
# w <- demoFreq$word
# frq <- demoFreq$freq
#
# w <- as.character(x$Var1)
# frq <- x$Freq
#
# library( testthat )
#
# ww <-
# capture_warnings(
#
# par("fin")
#
# par( fin = c( 9.1, 4.5 ) )
#
# par( fin = c( 9, 6 ) )
#
# par( din=c(10,8) )
#
#
#
# dev.new( width=10, height=5 )
# par( fin=c(9.8,4.9) )
#
# wordcloud( words=w, freq=frq,
#            max.words=500, min.freq=1,
#            random.order=FALSE,
#            scale=c(5,0.5), col="steelblue",
#            rot.per=0, fixed.asp=F )
#
#
# dev.new( width=10, height=5 )
# par( fin=c(9.8,4.9) )
#
# wordcloud( words=w, freq=frq,
#            max.words=500, min.freq=1,
#            random.order=FALSE,
#            scale=c(7,0.5), col="orange3",
#            rot.per=0, fixed.asp=F,
#            vfont=c("gothic english","plain") )
#
# wordcloud( words=w, freq=frq,
#            max.words=500, min.freq=1,
#            random.order=FALSE,
#            scale=c(5,0.5), col="mediumvioletred",
#            rot.per=0, fixed.asp=F,
#            vfont=c("script","bold") )
#
#
# fonts <- list(
#   c("script","bold"),
#   c("gothic english","plain"),
#   c("serif","plain"),
#   c("sans serif","bold"),
#   NULL )
#
# colz <-
# c("navy", "slategray4", "darkorchid4", "forestgreen", "goldenrod4",
# "darkolivegreen4", "mistyrose4", "navajowhite4", "magenta4",
# "seagreen4", "yellow4", "dodgerblue1", "mediumvioletred")
#
# vf <- sample( fonts, 1 ) |> unlist()
# vc <- sample( colz, 1 )
#
#
#
vf <- function(){

  fonts <- list(
    c("script","bold"),
    c("gothic english","plain"),
    c("serif","plain"),
    c("sans serif","bold"),
    NULL )

  sample( fonts, 1 ) |> unlist()

}

vc <- function() {

  colz <-
    c("navy", "slategray4", "darkorchid4", "forestgreen", "goldenrod4",
      "darkolivegreen4", "mistyrose4", "navajowhite4", "magenta4",
      "seagreen4", "yellow4", "dodgerblue1", "mediumvioletred")

  sample( colz, 1 )

}
#
# par( fin=c(9.8,4.9), mar=c(0,0,0,0) )
# wordcloud( words=w, freq=frq,
#            max.words=500, min.freq=1,
#            random.order=FALSE,
#            scale=c(5,0.5), col=vc(),
#            rot.per=0, fixed.asp=F,
#            vfont=vf() )
#
#
# navy
# slategray4
# darkorchid4
# forestgreen
# goldenrod4
# darkolivegreen4
# mistyrose4
# navajowhite4
# magenta4
# seagreen4
# yellow4
# dodgerblue1
# mediumvioletred
#


#
# #calculate standardized MDS coordinates
# dat <- sweep(USArrests,2,colMeans(USArrests))
# dat <- sweep(dat,2,sqrt(diag(var(dat))),"/")
# loc <- cmdscale(dist(dat))
#
# #plot with no overlap
# textplot(loc[,1],loc[,2],rownames(loc))



#
# simplify_char <- function(v) {
#
#   ww <- strsplit( w, " " ) |> unlist()
#   ww <- tm::tm_map( ww, removePunctuation )
#   ww <- tm::tm_map( ww, function(x)removeWords(x,stopwords()) )
#
#   dd <- as.data.frame(sort(table(ww),decreasing=T))
#   n.row <- nrow(dd)
#   if( n.row > 500 )
#   { dd <- dd[1:500,] }
#
#   jsonify_df( dd )
#
# }


jsonify_df <- function( df )
{
  jd <- jsonlite::toJSON( df )
  jd <- gsub( "\\{", "  \\{  ", jd )
  jd <- gsub( ":", " :  ", jd )
  jd <- gsub( '",', '"  ,  ', jd )
  jd <- gsub( '","', '",  "', jd )
  jd <- gsub( "\\},", "  \\}, \n", jd )
  jd <- gsub( "\\[", "\\[ \n", jd )
  jd <- gsub( "\\]", "\n\\]", jd )
  jd <- gsub( "\\}\n", "  \\}\n", jd )
  return(jd)
}



#
#
# dev.new( width=10, height=5 )
# par( fin=c(9.8,4.9) )
#
# t <- table(ww)
# wlabs <- names(t)
# wfreq <- as.numeric(t)
#
# dev.new( width=10, height=5 )
# par( fin=c(9.8,4.9) )
#
# wordcloud( words=wlabs, freq=wfreq,
#            max.words=500, min.freq=1,
#            random.order=FALSE,
#            scale=c(5,0.5), col="steelblue",
#            rot.per=0, fixed.asp=F,
#            use.r.layout=T )
#
#
#
# strwidth( w )
# strheight( w )
#
#            strwidth, strheight )
# )
#
# ww2 <- gsub( " could not be fit on page. It will not be plotted.", "", ww )
#
# x2 <- dplyr::filter( x, Var1 %in% ww2 )
#
#
# w2 <- as.character(x2$Var1)
# frq2 <- x2$Freq
# wordcloud( words=w2, freq=frq2,
#            max.words=100, random.order=FALSE,
#            scale=c(2,0.1), col="steelblue" )
#
#
#
# row.names( demoFreq ) <- NULL
# dput( demoFreq )
#
#
#
# library(htmlwidgets)
# install.packages("webshot")
# webshot::install_phantomjs()
# library(wordcloud2)
#
# x <- x[ order(x$Freq, decreasing=T) , ]
# head(x)
#
# x2 <- x[1:500,]
#
# names(x2) <- c("word","freq")
# x2$word <- as.character( x2$word )
#
# nchar( x2$word[1] )
#
# # weightFactor = size * 180/max(dataOut$freq)
#
#
#
# len <- nchar( x2$word[1] )
# w <- 1.8
# m <- max( x2$freq)
# size <- ( w * ( m * len ) ) / 180
#
# w <- size * 180 / 89
#
# ( 3.64 * 0.003 ) / 180
#
# s <- 1.4
# m <- 89
# l <- 13
# z <- l / 13
# ( s * 180 ) / ( m * z )
#
# s * (180/m)
# ( s * l * 180 ) / m
#
# a =  ( s * l * 180 ) / m
# # w = 2.83
#
# s <- 1.8
# m <- 71
# l <- 11
# z <- l / 13
# s * (180/m)
# ( s * 180 ) / ( m * z )
#
# s * (180/m)
# # w = 4.56
#
# m <- 71
# l <- 11
# ( 3.64 * ( m * l ) ) / 180
#
# w <- size * 180 / m
#
# ( s * 180 ) / ( m * l )
#
#
# hw <- wordcloud2( x2[1:500,], size=2 )
# saveWidget( hw, "wc.html", selfcontained=F )
# webshot::webshot( "wc.html","wc-diamond.png", vwidth = 1992, vheight = 1744, delay=10 )
#
#
# wordcloud2(x, shape='diamond')
#
#
# x <-
# structure(list(Var1 = structure(1:1576, levels = c("Aberdeen",
# "Abilene", "Abington", "Acarigua", "Ada", "Adelaide", "Adrian",
# "Agua Blanca", "Agua Negra", "Aguada", "Aguadilla", "Aguadulce",
# "Aibonito", "Aira-gun", "Akron", "Alameda", "Alamogordo", "Albany",
# "Albuquerque", "Alexander City", "Alexandria", "Algona", "Alhambra",
# "Allentown", "Alpena", "Alpharetta", "Altamira", "Altamonte Springs",
# "Altoona", "Amarillo", "American Fork", "Amherst", "Amityville",
# "Amory", "Amsterdam", "Anaco", "Anaconda", "Anadarko", "Anaheim",
# "Anchorage", "Anchorville", "Anderson", "Andover", "Ann Arbor",
# "Annapolis", "Anola", "Antigo", "Antioch", "Apple Valley", "Appleton",
# "Aragua", "Arcadia", "Arcata", "Arecibo", "Arita-gun", "Arjona",
# "Arkansas City", "Arlington", "Arlington Heights", "Arroyo",
# "Artesia", "Asheville", "Ashland", "Astoria", "Athens", "Atlanta",
# "Attadale", "Atwater", "Auburn", "Auburndale", "Augusta", "Aurora",
# "Austell", "Austin", "Avon Lake", "Avon Park", "Azua", "Bad Kissingen",
# "Bainbridge", "Bajos de Haina", "Bakersfield", "Baldwin Park",
# "Baltimore", "Bamberg", "Bangor", "Bani", "Barahona", "Barberton",
# "Barcelona", "Barinas", "Barquisimeto", "Barranquilla", "Barstow",
# "Bastrop", "Bath", "Baton Rouge", "Battle Creek", "Baxley", "Bay Shore",
# "Bayamon", "Bayonne", "Bayside", "Baytown", "Beaufort", "Beaumont",
# "Beaver Falls", "Bedford", "Beech Grove", "Beeville", "Belize",
# "Bellaire", "Belle Fourche", "Belleville", "Bellevue", "Bellflower",
# "Bellows Falls", "Belton", "Bemidji", "Bennettsville", "Benton",
# "Berea", "Berkeley", "Berwick", "Bessemer", "Beverly", "Big Rapids",
# "Billings", "Biloxi", "Binghamton", "Birmingham", "Bishop", "Blackwell",
# "Blackwood", "Blaine", "Blanco", "Bloomington", "Blue Island",
# "Bluebell", "Bluefields", "Blythe", "Bobures", "Boca Chica",
# "Bocas del Toro", "Bogalusa", "Boise", "Bolivar", "Bonao", "Bonham",
# "Boone", "Bossier City", "Boston", "Bowling Green", "Boynton Beach",
# "Bradenton", "Brandon", "Brattleboro", "Brawley", "Breese", "Bremerton",
# "Brenham", "Brentwood", "Brewster", "Bridgehampton", "Bridgeport",
# "Brighton", "Brisbane", "Bristol", "Britton", "Brockport", "Brockton",
# "Bronx", "Bronxville", "Brookline", "Brooklyn", "Brooksville",
# "Brownsburg", "Brownwood", "Brunswick", "Bryan", "Bryn Mawr",
# "Bryson City", "Buffalo", "Burbank", "Burley", "Burlingame",
# "Burlington", "Burnaby", "Busan", "Butler", "Butte", "Butzbach",
# "Cagua", "Caguas", "Cairo", "Caja Seca", "Calgary", "Camaguey",
# "Camarillo", "Cambiaso", "Cambridge", "Camden", "Camden County",
# "Campechuela", "Campina", "Canoga Park", "Canovanas", "Cantaura",
# "Canton", "Cape Coral", "Cape Girardeau", "Cape May", "Caracas",
# "Cariaco", "Caripito", "Carlisle", "Carmel", "Carmichael", "Carnegie",
# "Carson", "Cartagena", "Carupano", "Cascade", "Casper", "Castro Valley",
# "Catano", "Catskill", "Cayey", "Cedar City", "Cedar Rapids",
# "Centennial", "Centerville", "Centralia", "Cerro Azul", "Chalmette",
# "Chambersburg", "Champaign", "Changuinola", "Channelview", "Chapel Hill",
# "Chardon", "Charleston", "Charlotte", "Chatsworth", "Chattahoochee",
# "Chattanooga", "Chepo", "Cherry Hill", "Chesapeake", "Chester",
# "Chesterfield", "Chestertown", "Cheverly", "Chevy Chase", "Cheyenne",
# "Chiba", "Chicago", "Chicago Heights", "Chickasha", "Chico",
# "Chillicothe", "Chinandega", "Chiriqui", "Chitre", "Choon Chung Do",
# "Chorrera", "Chouteau", "Christiana", "Christiansted", "Chula Vista",
# "Cidra", "Ciego de Avila", "Cienfuegos", "Cincinnati", "Ciudad Bolivar",
# "Ciudad Juarez", "Ciudad Obregon", "Ciudad Ojeda", "Ciudad Victoria",
# "Clairton", "Clarks Summit", "Clay", "Clearfield", "Clearwater",
# "Cleburne", "Clermont", "Cleveland", "Clifton", "Clifton Park",
# "Clinton", "Clio", "Cloverdale", "Clovis", "Coeur d'Alene", "Coffee",
# "Coldwater", "Coleman", "Colon", "Colorado Springs", "Columbia",
# "Columbus", "Colusa", "Commack", "Compton", "Concord", "Connellsville",
# "Conroe", "Consolacion del Sur", "Constanza", "Conway", "Conyers",
# "Coon Rapids", "Coral Gables", "Coral Springs", "Cordell", "Cordoba",
# "Cordova", "Corning", "Corona", "Coronado", "Corpus Christi",
# "Corvallis", "Coshocton", "Costa Mesa", "Cotui", "Coudersport",
# "Council Bluffs", "Covina", "Covington", "Crest Hill", "Crestwood",
# "Creve Coeur", "Crockett", "Crosby", "Crowley", "Cua", "Cuitlahuac",
# "Culiacan", "Culver City", "Cumana", "Cumberland", "Cupira",
# "Cushing", "Cynthiana", "Dade City", "Daejeon", "Daito", "Dallas",
# "Dalton", "Daly City", "Danbury", "Danville", "Darby", "Darlinghurst",
# "Darlington", "Davenport", "David", "Dayton", "De Leon Springs",
# "Dearborn", "Decatur", "Defiance", "Del City", "DeLand", "Delano",
# "Denton", "Denver", "Des Moines", "Des Plaines", "Deshler", "Detroit",
# "Devils Lake", "Dhahran", "Dickson", "Don Gregorio", "Donelson",
# "Donora", "Dorado", "Dos Palos", "Dothan", "Douglas", "Douglasville",
# "Dover", "Downey", "Doylestown", "Du Bois", "Dundee", "Dunedin",
# "Durango", "Durham", "Easley", "East Bontang", "East Chicago",
# "East Longmeadow", "East Los Angeles", "East Orange", "East Point",
# "East Providence", "East St. Louis", "East York", "Easton", "Eatontown",
# "Eau Claire", "Edina", "Edison", "Edmonds", "Edmonton", "Edwardsville",
# "Effingham", "Eindhoven", "El Cajon", "El Cercado", "El Mojan",
# "El Paso", "El Seibo", "El Tigre", "Elias Pina", "Elizabeth",
# "Elizabethtown", "Elkhorn", "Elkton", "Ellsworth Air Force Base",
# "Elmhurst", "Elmira", "Elsberry", "Encino", "Englewood", "Ennis",
# "Erie", "Escondido", "Esperanza", "Estacion Lagunas", "Euclid",
# "Eugene", "Eureka", "Eureka Springs", "Eustis", "Evanston", "Evansville",
# "Everett", "Evergreen", "Evergreen Park", "Excelsior Springs",
# "Exeter", "Fairfax", "Fairfield", "Fairhope", "Fajardo", "Fall River",
# "Falmouth", "Fargo", "Farmington", "Farmville", "Fayetteville",
# "Federal Way", "Festus", "Findlay", "Flagstaff", "Flemington",
# "Flint", "Florence", "Florissant", "Flushing", "Fomento", "Fond du Lac",
# "Fontana", "Forest Grove", "Fort Belvoir", "Fort Benning", "Fort Campbell",
# "Fort Collins", "Fort Dodge", "Fort Gaines", "Fort Knox", "Fort Lauderdale",
# "Fort Meade", "Fort Myers", "Fort Pierce", "Fort Polk", "Fort Riley",
# "Fort Rucker", "Fort Scott", "Fort Smith", "Fort Thomas", "Fort Walton Beach",
# "Fort Wayne", "Fort Worth", "Fountain", "Fountain Valley", "Framingham",
# "Frankfort", "Frankfurt", "Franklin", "Fredericksburg", "Freehold",
# "Freeport", "Freer", "Fremont", "Fresno", "Front Royal", "Fullerton",
# "Gadsden", "Gainesville", "Galesburg", "Gallup", "Galveston",
# "Gambrills", "Garden City", "Garden Grove", "Gary", "Gastonia",
# "Gatineau", "Gatun", "Geelong", "Georgetown", "Gilroy", "Gladwin",
# "Glen Cove", "Glen Dale", "Glen Ridge", "Glendale", "Glendora",
# "Glens Falls", "Goddard", "Golden Valley", "Goldsboro", "Goleta",
# "Gongju", "Goose Creek", "Granada", "Granada Hills", "Grand Island",
# "Grand Junction", "Grand Rapids", "Grangeville", "Grantham",
# "Grants Pass", "Green Bay", "Greenbrae", "Greenfield", "Greensboro",
# "Greenville", "Greenwich", "Greenwood", "Grenada", "Greybull",
# "Griffin", "Grove City", "Guacara", "Guadalajara", "Guanare",
# "Guarenas", "Guasave", "Guatire", "Guayama", "Guayanilla", "Guaymas",
# "Guaymate", "Guaynabo", "Guayubin", "Guelph", "Guiria", "Gulfport",
# "Guthrie", "Gwangju", "Habikino", "Hackensack", "Hagerstown",
# "Hahira", "Hahn", "Halifax", "Hallettsville", "Hamilton", "Hammond",
# "Hampton", "Hanford", "Hannibal", "Harbor City", "Harlingen",
# "Harrisburg", "Harrisonburg", "Hartford", "Hartland", "Hartselle",
# "Hartsville", "Harvey", "Hato Mayor del Rey", "Hato Rey", "Hattiesburg",
# "Havre", "Havre de Grace", "Hawthorne", "Hayward", "Hebron",
# "Hempstead", "Hermosillo", "Herrin", "Hialeah", "Hickory", "Hicksville",
# "Hidden Hills", "Higashi-Osaka", "Higashi Yamato", "Highland",
# "Highland Park", "Higuera de Zaragoza", "Higuerote", "Higuey",
# "Hillsboro", "Hilo", "Hilton Head Island", "Hinsdale", "Hirara",
# "Hiroshima", "Hobart", "Hobbs", "Hoboken", "Holguin", "Holly Hill",
# "Hollywood", "Holyoke", "Homer", "Homestead", "Honolulu", "Hornsby",
# "Houston", "Hoyleton", "Huatabampo", "Humacao", "Humble", "Huntingburg",
# "Huntingdon", "Huntington", "Huntington Beach", "Huntsville",
# "Hutchinson", "Hwasun", "Hyuga", "Idabel", "Incheon", "Independence",
# "Indiana", "Indianapolis", "Inglewood", "Iowa City", "Irving",
# "Isla de la Juventud", "Itami", "Ithaca", "Jacagua", "Jackson",
# "Jackson Heights", "Jacksonville", "Jamaica", "Jamestown", "Jarabacoa",
# "Jefferson City", "Jeffersonville", "Jennings", "Jeongeup", "Jerome",
# "Jersey City", "Johnson City", "Johnstown", "Joliet", "Joplin",
# "Juan Jose Rios", "Junction City", "Juneau", "Kabul", "Kailua",
# "Kalamazoo", "Kaneohe", "Kankakee", "Kansas City", "Kaohsiung City",
# "Kapuskasing", "Kashiwa", "Kelowna", "Kemmerer", "Kennesaw",
# "Kennett", "Kennewick", "Kenton", "Kettering", "Kewaunee", "Key West",
# "Kingman", "Kingston", "Kinnelon", "Kinston", "Kirkland", "Kirkwood",
# "Kishiwada", "Kitchener", "Kittanning", "Klamath Falls", "Knob Noster",
# "Knoxville", "Kobe", "Kochi", "Kokomo", "Kokubunji", "Kosciusko",
# "Kula", "Kyoto", "La Crosse", "La Delgada", "La Grange", "La Guaira",
# "La Habana", "La Habra", "La Jolla", "La Junta", "La Marque",
# "La Mesa", "La Mirada", "La Palma", "La Pica", "La Plata", "La Porte",
# "La Romana", "La Sabana", "La Vega", "Lackawanna", "Ladner",
# "Lafayette", "Laguna Salada", "Lake Charles", "Lake City", "Lake Forest",
# "Lake Jackson", "Lake Wales", "Lakehurst", "Lakeland", "Lakewood",
# "Lamar", "Lancaster", "Land O' Lakes", "Landes de Bussac", "Landstuhl",
# "Langdale", "Langley", "Lansdale", "Laredo", "Larned", "Las Martinas",
# "Las Matas de Farfan", "Las Matas de Santa Cruz", "Las Mercedes",
# "Las Tablas", "Las Tunas", "Las Vegas", "Laurens", "Laurinburg",
# "Lawrenceburg", "Lawrenceville", "Lawton", "League City", "Leamington",
# "Leary", "Lebanon", "Lee's Summit", "Leesburg", "Lemoore", "Leon",
# "Lewisburg", "Lewiston", "Lewistown", "Lexington", "Libertador",
# "Libertyville", "Lihue", "Lihue-Kauai", "Lima", "Lincoln", "Lincolnwood",
# "Little Rock", "Littleton", "Live Oak", "Livermore", "Liverpool",
# "Livonia", "Lockney", "Lodi", "Logansport", "Loma de Cabrera",
# "Loma Linda", "Lomita", "Lompoc", "London", "Londonderry", "Long Beach",
# "Long Branch", "Longmont", "Longview", "Los Alcarrizos", "Los Altos",
# "Los Angeles", "Los Gatos", "Los Llanos", "Los Mochis", "Los Santos",
# "Los Teques", "Louisville", "Lowell", "Lower Merion", "Lubbock",
# "Lumberton", "Lutcher", "Lynchburg", "Lynn", "Lynwood", "Lyons",
# "Macon", "Madera", "Madison", "Madras", "Malden", "Malvern",
# "Mamou", "Mamporal", "Managua", "Manakin Sabot", "Manati", "Manchester",
# "Manhasset", "Manhattan", "Manila", "Manlio Fabio Altamirano",
# "Manning", "Manoguayabo", "Mansfield", "Mao", "Maple Ridge",
# "Maracaibo", "Maracay", "Margarita", "Margate", "Marianna", "Mariemont",
# "Marietta", "Marion", "Marlton", "Marquette", "Marshall", "Marshalltown",
# "Marshfield", "Martinez", "Martins Ferry", "Martinsburg", "Martinsville",
# "Maryland Heights", "Marysville", "Maryvale", "Mason City", "Massena",
# "Mayaguez", "Maysville", "Maywood", "Mazatlan", "McAllen", "McCandless",
# "McCloud", "McComb", "McKeesport", "McKinney", "McMinnville",
# "Meadowbrook", "Meadville", "Medford", "Melbourne", "Melrose Park",
# "Melville", "Memphis", "Menasha", "Menlo Park", "Merced", "Meridian",
# "Merrillville", "Mesa", "Metairie", "Methuen", "Mexicali", "Mexico",
# "Miami", "Miami Beach", "Miami Lakes", "Middletown", "Midland",
# "Midwest City", "Milledgeville", "Milwaukee", "Minami Muro-gun",
# "Mineola", "Minneapolis", "Mission Hills", "Mission Viejo", "Mississauga",
# "Missoula", "Mobile", "Moca", "Modesto", "Moncion", "Monclova",
# "Moncton", "Monee", "Monmouth Beach", "Monroe", "Monroeville",
# "Montclair", "Monte Cristi", "Monte Plata", "Montebello", "Monterey",
# "Monterey Park", "Monterrey", "Montgomery", "Monticello", "Montreal",
# "Montrose", "Mooresboro", "Morehead City", "Morgantown", "Morristown",
# "Moses Lake", "Moultrie", "Mount Clemens", "Mount Gilead", "Mount Holly",
# "Mount Joy", "Mount Juliet", "Mount Kisco", "Mount Lebanon",
# "Mount Vernon", "Mountain View", "Muncie", "Mundo Nobo", "Munich",
# "Murfreesboro", "Muskegon", "Muskogee", "Nacogdoches", "Nagua",
# "Naguabo", "Naha", "Nandaime", "Napa", "Naperville", "Naples",
# "Nara", "Nashville", "Natchez", "Natchitoches", "National City",
# "Navan", "Navojoa", "Nederland", "Neenah", "Neosho", "Neptune",
# "Neu-Ulm", "New Albany", "New Bedford", "New Braunfels", "New Brighton",
# "New Britain", "New Brunswick", "New Haven", "New London", "New Milford",
# "New Orleans", "New Port Richey", "New Rochelle", "New Ulm",
# "New Westminster", "New York", "Newark", "Newberry", "Newburgh",
# "Newbury Park", "Newburyport", "Newfane", "Newhall", "Newnan",
# "Newport", "Newport Beach", "Newport News", "Newton", "Neyagawa",
# "Niagara Falls", "Nichi Kasugai-gun", "Nigua", "Niles", "Nishinomiya",
# "Nizao", "Nogales", "Nomi", "Noord", "Norfolk", "Norristown",
# "North Adams", "North Bellmore", "North Conway", "North Hollywood",
# "North Little Rock", "North Miami", "North Olmsted", "North Star",
# "North Vancouver", "Northampton", "Northbrook", "Northfield",
# "Northridge", "Norwalk", "Norwich", "Oak Lawn", "Oak Park", "Oakland",
# "Oaklawn", "Oarai", "Oaxaca", "Ocala", "Oceanside", "Ocumare de la Costa",
# "Ocumare del Tuy", "Odessa", "Ogden", "Ojai", "Okinawa", "Oklahoma City",
# "Olney", "Olympia", "Omaha", "Oneonta", "Ontario", "Opelika",
# "Orange", "Orange County", "Orange Park", "Orangeburg", "Oranjestad",
# "Oregon", "Oregon City", "Orlando", "Orleans", "Orrville", "Osaka",
# "Otsuki", "Ottawa", "Owensboro", "Oxford", "Oxnard", "Ozona",
# "Ozone Park", "Paducah", "Paintsville", "Palm Beach", "Palm Beach Gardens",
# "Palm Springs", "Palmarejo", "Palo Alto", "Palos Park", "Panama",
# "Panama City", "Panorama City", "Paris", "Park Ridge", "Park View",
# "Parkland", "Parramatta", "Pasadena", "Pascagoula", "Pasco",
# "Paso Robles", "Passaic", "Patchogue", "Paterson", "Pawtucket",
# "Pebble Beach", "Pelham", "Pella", "Pembroke Pines", "Pendleton",
# "Penjamillo", "Pennington Gap", "Pensacola", "Peoria", "Pequannock",
# "Perkins", "Perryton", "Perryville", "Perth", "Peru", "Petaluma",
# "Petersburg", "Petoskey", "Philadelphia", "Philipsburg", "Phoenix",
# "Phoenixville", "Pierre", "Pikeville", "Pimentel", "Pinar del Rio",
# "Pine Bluff", "Pinehurst", "Pinellas Park", "Pingtung County",
# "Pittsburg", "Pittsburgh", "Pittsfield", "Plainfield", "Plantation",
# "Pleasanton", "Plymouth", "Point Pleasant", "Pomona", "Ponca City",
# "Ponce", "Pontiac", "Pontotoc", "Poplar Bluff", "Porlamar", "Port Arthur",
# "Port Charlotte", "Port Hueneme", "Port Huron", "Port Jefferson",
# "Portales", "Porterville", "Portland", "Portsmouth", "Potosi",
# "Poughkeepsie", "Poway", "Pratt", "Prattville", "Prescott", "Presque Isle",
# "Providence", "Pryor", "Pueblo Nuevo", "Pueblo Viejo", "Puerto Armuelles",
# "Puerto Cabello", "Puerto La Cruz", "Puerto Ordaz", "Puerto Palenque",
# "Puerto Piritu", "Puerto Plata", "Pullman", "Punto Fijo", "Punxsutawney",
# "Queens", "Queensbury", "Quibor", "Quincy", "Quisqueya", "Raceland",
# "Racine", "Radford", "Raleigh", "Ramon Santana", "Rancho Viejo",
# "Rapid City", "Rawlins", "Reading", "Redding", "Redlands", "Redmond",
# "Redondo Beach", "Redwood City", "Refugio", "Rembert", "Remedios",
# "Reno", "Renton", "Rexburg", "Reynosa", "Richland", "Richmond",
# "Richmond Hill", "Ridgewood", "Rio Piedras", "Rio San Juan",
# "Ripley", "Rivas", "Riverhead", "Riverside", "Roanoke", "Roanoke Rapids",
# "Robstown", "Rochester", "Rock Island", "Rockford", "Rockingham",
# "Rockville", "Rockville Centre", "Rome", "Roseburg", "Roselle",
# "Rosenberg", "Roseville", "Roswell", "Rotterdam", "Round Lake Beach",
# "Round Rock", "Royal Oak", "Royse City", "Rusk", "Russellville",
# "Ruston", "Rutherford", "Sabana de la Mar", "Sabana Grande de Palenque",
# "Sacramento", "Safford", "Saginaw", "Saigon", "Salem", "Salina",
# "Salinas", "Salisbury", "Salt Lake City", "Samana", "San Angelo",
# "San Antonio", "San Benito", "San Bernardino", "San Carlos",
# "San Carlos del Zulia", "San Cristobal", "San Diego", "San Dimas",
# "San Felipe", "San Felix", "San Fernando", "San Francisco", "San Francisco de Macoris",
# "San Gabriel", "San Ignacio", "San Isidro", "San Jose", "San Jose de Ocoa",
# "San Juan", "San Juan de la Maguana", "San Juan de los Morros",
# "San Leandro", "San Luis Potosi", "San Luis Rio Colorado", "San Mateo",
# "San Nicolas de los Garza", "San Pedro", "San Pedro de Macoris",
# "San Rafael", "San Sebastian", "Sanchez", "Sandpoint", "Sanford",
# "Sanremo", "Santa Ana", "Santa Barbara", "Santa Clara", "Santa Cruz",
# "Santa Fe", "Santa Isabel", "Santa Lucia", "Santa Maria", "Santa Monica",
# "Santa Rosa", "Santa Teresa del Tuy", "Santiago", "Santiago de Cuba",
# "Santiago Rodriguez", "Santo Domingo", "Santurce", "Sao Paulo",
# "Sarasota", "Sarnia", "Sasebo", "Satellite Beach", "Saugus",
# "Savannah", "Scarborough", "Schenectady", "Scotia", "Scottsbluff",
# "Scottsdale", "Scranton", "Scribner", "Seaford", "Seattle", "Sebring",
# "Sechelt", "Seguin", "Sellersville", "Selma", "Selmer", "Senboku-gun",
# "Sendai", "Seneca", "Senoia", "Seoul", "Sewickley", "Sharon",
# "Shawnee", "Shelby", "Shelbyville", "Sherman", "Shiner", "Shirley",
# "Shreveport", "Sikeston", "Silver Spring", "Simcoe", "Simi Valley",
# "Singapore", "Sioux City", "Sioux Falls", "Sissonville", "Sleepy Eye",
# "Slidell", "Smithtown", "Smyrna", "So-gun", "Soddy-Daisy", "Solito",
# "Somerset", "Somerville", "Sonora", "Soro", "Souderton", "South Adelaide",
# "South Bend", "South Boston", "South Haven", "South Holland",
# "South Kingstown", "South Laguna", "South Lake Tahoe", "South Miami",
# "South Ozone Park", "South Portland", "South Weymouth", "Southampton",
# "Southfield", "Spartanburg", "Spokane", "Spring", "Spring Valley",
# "Springfield", "St. Amant", "St. Augustine", "St. Charles", "St. Clair",
# "St. Clairsville", "St. Cloud", "St. George", "St. James", "St. John",
# "St. Louis", "St. Louis Park", "St. Marys", "St. Paul", "St. Petersburg",
# "St. Thomas", "Stamford", "Starkville", "State College", "Staten Island",
# "Statesboro", "Staunton", "Stayton", "Steamboat Springs", "Sterling",
# "Steubenville", "Stillwater", "Stockton", "Stony Brook", "Stoughton",
# "Stringtown", "Stuart", "Suffern", "Sumter", "Sun Valley", "Sunbury",
# "Sunflower", "Sunnyside", "Sunnyvale", "Sydney", "Syosset", "Syracuse",
# "Tabara Arriba", "Tachira", "Tacoma", "Tainan City", "Takoma Park",
# "Tallahassee", "Taloga", "Tampa", "Tanashi", "Tanner", "Tarzana",
# "Taunton", "Taylorsville", "Taylorville", "Teaneck", "Tecamachalco",
# "Tela", "Telford", "Tempe", "Temple", "Templeton", "Tenares",
# "Terre Haute", "Texarkana", "Texas City", "The Dalles", "The Woodlands",
# "Thomaston", "Thomasville", "Thousand Oaks", "Three Rivers",
# "Tijuana", "Tinley Park", "Titusville", "Tlalnepantla", "Toa Baja",
# "Toabaja", "Tokushima", "Tokyo", "Toledo", "Tomball", "Toms River",
# "Tonawanda", "Topeka", "Toronto", "Torrance", "Tovar", "Towanda",
# "Trail", "Trenton", "Trion", "Troy", "Tsushima", "Tucson", "Tulare",
# "Tularosa", "Tullahoma", "Tulsa", "Tupelo", "Turners Falls",
# "Tuscaloosa", "Tuskegee", "Tuxedo", "Twentynine Palms", "Tyler",
# "Union", "Union City", "Uniontown", "Unionville", "Upata", "Upland",
# "Upper Darby", "Urama", "Utica", "Uwajima", "Valdosta", "Valencia",
# "Valera", "Valle de la Pascua", "Vallejo", "Valparaiso", "Van Nuys",
# "Vancouver", "Vega Baja", "Vega de Alatorre", "Venice", "Ventura",
# "Veracruz", "Vicksburg", "Victoria", "Vienna", "Villa Altagracia",
# "Villa Clara", "Villa de Cura", "Villa Gonzalez", "Villa Mella",
# "Villa Park", "Villa Riva", "Villa Tapia", "Villa Vasquez", "Vincennes",
# "Vineland", "Virginia Beach", "Visalia", "Vista", "Voorhees",
# "Waco", "Wailuku", "Walla Walla", "Walnut Creek", "Warner Robins",
# "Warren", "Warrenton", "Washington", "Washington Court House",
# "Waterbury", "Waukegan", "Waverly", "Waycross", "Waynesboro",
# "Weatherford", "Wellington", "Wellston", "West", "West Chester",
# "West Covina", "West Hills", "West Palm Beach", "Westerville",
# "Westlake Village", "Westminster", "Westwood", "Wheat Ridge",
# "Wheeling", "Whiteman AFB", "Whiteville", "Whittier", "Wichita",
# "Wichita Falls", "Wilkes-Barre", "Willemstad", "Williams", "Williamsburg",
# "Williamsport", "Williamston", "Willingboro", "Willis", "Williston",
# "Wilmington", "Wilrijk", "Wilson", "Winchester", "Windermere",
# "Windsor", "Winfield", "Winston-Salem", "Winter Haven", "Winter Park",
# "Woodbury", "Woodland", "Woodland Hills", "Woodstock", "Woodsville",
# "Woonsocket", "Worcester", "Wright Patterson AFB", "Wurzburg",
# "Wyandotte", "Wymore", "Yaguate", "Yakima", "Yamasa", "Yauco",
# "Yoakum", "Yokohama", "Yonkers", "York", "Youngstown", "Yreka",
# "Yucaipa", "Zanesville", "Zaragoza", "Zeist", "Zephyrhills"), class = "factor"),
#     Freq = c(3L, 1L, 3L, 2L, 2L, 1L, 1L, 1L, 1L, 1L, 2L, 2L,
#     1L, 1L, 2L, 3L, 1L, 4L, 2L, 1L, 5L, 1L, 1L, 2L, 1L, 1L, 1L,
#     1L, 1L, 1L, 1L, 1L, 1L, 2L, 2L, 4L, 1L, 1L, 11L, 8L, 1L,
#     2L, 1L, 2L, 4L, 1L, 1L, 2L, 1L, 1L, 1L, 3L, 1L, 3L, 1L, 2L,
#     1L, 5L, 2L, 2L, 1L, 3L, 5L, 1L, 3L, 29L, 1L, 1L, 1L, 2L,
#     6L, 3L, 1L, 17L, 1L, 1L, 7L, 1L, 3L, 5L, 7L, 1L, 16L, 2L,
#     1L, 15L, 4L, 2L, 4L, 1L, 10L, 2L, 1L, 1L, 1L, 13L, 2L, 1L,
#     1L, 9L, 1L, 2L, 1L, 1L, 8L, 1L, 4L, 1L, 1L, 1L, 1L, 1L, 7L,
#     6L, 9L, 1L, 1L, 2L, 1L, 2L, 1L, 8L, 1L, 1L, 2L, 1L, 1L, 1L,
#     1L, 14L, 1L, 1L, 1L, 1L, 1L, 1L, 2L, 1L, 1L, 1L, 1L, 1L,
#     2L, 1L, 3L, 1L, 8L, 1L, 1L, 1L, 9L, 7L, 3L, 7L, 1L, 1L, 2L,
#     2L, 1L, 2L, 2L, 1L, 1L, 4L, 1L, 1L, 8L, 1L, 1L, 1L, 7L, 1L,
#     1L, 21L, 1L, 1L, 2L, 2L, 2L, 2L, 1L, 8L, 7L, 1L, 1L, 2L,
#     1L, 2L, 5L, 1L, 1L, 1L, 5L, 2L, 1L, 1L, 1L, 1L, 1L, 3L, 2L,
#     1L, 1L, 1L, 2L, 2L, 1L, 2L, 1L, 1L, 1L, 29L, 1L, 1L, 1L,
#     2L, 4L, 1L, 1L, 4L, 1L, 1L, 3L, 4L, 1L, 1L, 2L, 1L, 7L, 1L,
#     2L, 2L, 1L, 1L, 1L, 2L, 1L, 1L, 1L, 1L, 7L, 8L, 1L, 1L, 6L,
#     1L, 1L, 1L, 1L, 1L, 1L, 2L, 1L, 2L, 3L, 36L, 2L, 2L, 1L,
#     1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 2L, 3L, 2L, 2L, 3L, 37L,
#     5L, 1L, 5L, 1L, 1L, 1L, 1L, 1L, 1L, 4L, 2L, 1L, 17L, 2L,
#     1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 3L, 1L, 8L, 21L, 1L,
#     1L, 3L, 3L, 1L, 3L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L,
#     1L, 2L, 1L, 6L, 3L, 1L, 1L, 5L, 1L, 1L, 11L, 3L, 1L, 1L,
#     1L, 2L, 1L, 1L, 1L, 1L, 1L, 1L, 4L, 1L, 1L, 1L, 1L, 1L, 1L,
#     1L, 33L, 1L, 1L, 1L, 5L, 2L, 1L, 1L, 3L, 1L, 12L, 1L, 4L,
#     6L, 2L, 1L, 2L, 1L, 5L, 8L, 7L, 1L, 1L, 19L, 1L, 1L, 1L,
#     1L, 1L, 2L, 2L, 1L, 1L, 1L, 2L, 2L, 7L, 1L, 1L, 1L, 2L, 1L,
#     5L, 1L, 1L, 3L, 1L, 1L, 1L, 1L, 1L, 2L, 2L, 2L, 1L, 1L, 3L,
#     1L, 1L, 1L, 1L, 1L, 1L, 5L, 1L, 1L, 7L, 4L, 3L, 1L, 2L, 1L,
#     1L, 2L, 1L, 3L, 1L, 1L, 2L, 3L, 1L, 3L, 2L, 2L, 1L, 2L, 1L,
#     2L, 1L, 2L, 5L, 8L, 2L, 3L, 3L, 1L, 3L, 3L, 4L, 1L, 3L, 2L,
#     1L, 1L, 2L, 2L, 4L, 1L, 1L, 1L, 1L, 3L, 4L, 4L, 1L, 4L, 1L,
#     1L, 8L, 1L, 1L, 2L, 1L, 2L, 1L, 1L, 2L, 13L, 1L, 1L, 4L,
#     2L, 2L, 2L, 1L, 3L, 1L, 3L, 5L, 14L, 1L, 5L, 3L, 1L, 3L,
#     2L, 3L, 2L, 3L, 1L, 1L, 8L, 1L, 15L, 1L, 6L, 1L, 1L, 3L,
#     1L, 1L, 5L, 6L, 2L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 3L, 13L,
#     2L, 2L, 1L, 1L, 2L, 2L, 1L, 2L, 1L, 1L, 1L, 1L, 8L, 1L, 1L,
#     2L, 2L, 5L, 2L, 1L, 10L, 1L, 3L, 1L, 1L, 1L, 1L, 3L, 1L,
#     2L, 3L, 1L, 1L, 1L, 1L, 1L, 2L, 1L, 3L, 1L, 1L, 1L, 2L, 3L,
#     1L, 2L, 1L, 1L, 1L, 1L, 1L, 4L, 3L, 2L, 4L, 1L, 4L, 1L, 1L,
#     3L, 1L, 1L, 1L, 1L, 1L, 4L, 3L, 7L, 1L, 2L, 3L, 1L, 1L, 1L,
#     2L, 1L, 7L, 1L, 1L, 1L, 1L, 1L, 1L, 3L, 1L, 1L, 2L, 2L, 3L,
#     1L, 3L, 1L, 1L, 1L, 1L, 1L, 2L, 2L, 11L, 1L, 1L, 2L, 11L,
#     1L, 61L, 1L, 1L, 7L, 1L, 1L, 1L, 3L, 5L, 2L, 1L, 1L, 1L,
#     1L, 3L, 3L, 1L, 11L, 8L, 2L, 4L, 1L, 1L, 2L, 1L, 9L, 1L,
#     22L, 3L, 3L, 1L, 4L, 1L, 1L, 1L, 1L, 4L, 4L, 3L, 11L, 3L,
#     1L, 1L, 1L, 1L, 2L, 3L, 1L, 1L, 15L, 1L, 1L, 1L, 2L, 1L,
#     1L, 1L, 1L, 1L, 2L, 1L, 3L, 1L, 6L, 1L, 2L, 2L, 2L, 1L, 1L,
#     1L, 1L, 1L, 10L, 2L, 2L, 1L, 1L, 1L, 1L, 2L, 4L, 1L, 5L,
#     6L, 20L, 1L, 2L, 2L, 1L, 4L, 2L, 1L, 1L, 2L, 1L, 14L, 1L,
#     1L, 1L, 1L, 10L, 2L, 7L, 3L, 1L, 1L, 1L, 1L, 5L, 5L, 1L,
#     13L, 1L, 1L, 2L, 1L, 1L, 1L, 1L, 1L, 1L, 4L, 2L, 1L, 1L,
#     1L, 17L, 1L, 3L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L,
#     1L, 2L, 3L, 1L, 10L, 1L, 1L, 2L, 1L, 4L, 3L, 1L, 4L, 1L,
#     1L, 3L, 1L, 2L, 1L, 1L, 1L, 1L, 1L, 3L, 2L, 3L, 1L, 31L,
#     2L, 1L, 5L, 1L, 1L, 71L, 2L, 2L, 4L, 1L, 2L, 16L, 1L, 1L,
#     7L, 2L, 1L, 6L, 2L, 6L, 1L, 5L, 1L, 3L, 1L, 3L, 1L, 2L, 1L,
#     1L, 1L, 5L, 4L, 1L, 2L, 1L, 1L, 1L, 1L, 4L, 3L, 1L, 19L,
#     15L, 1L, 1L, 3L, 1L, 3L, 6L, 2L, 1L, 3L, 1L, 1L, 1L, 1L,
#     1L, 1L, 1L, 2L, 1L, 1L, 1L, 6L, 1L, 1L, 1L, 2L, 1L, 1L, 5L,
#     3L, 1L, 2L, 1L, 1L, 3L, 2L, 1L, 1L, 15L, 1L, 1L, 6L, 3L,
#     1L, 6L, 3L, 1L, 3L, 2L, 30L, 3L, 1L, 5L, 6L, 2L, 4L, 8L,
#     1L, 1L, 5L, 3L, 3L, 2L, 1L, 6L, 3L, 4L, 1L, 1L, 1L, 1L, 1L,
#     5L, 1L, 3L, 6L, 1L, 2L, 1L, 1L, 3L, 7L, 1L, 1L, 1L, 1L, 1L,
#     2L, 1L, 1L, 1L, 1L, 1L, 2L, 1L, 1L, 1L, 1L, 2L, 4L, 3L, 1L,
#     1L, 1L, 2L, 1L, 3L, 5L, 2L, 1L, 1L, 2L, 1L, 2L, 1L, 5L, 1L,
#     1L, 1L, 1L, 3L, 1L, 1L, 1L, 2L, 1L, 1L, 1L, 1L, 2L, 4L, 2L,
#     4L, 5L, 1L, 12L, 1L, 1L, 1L, 1L, 20L, 6L, 1L, 1L, 1L, 1L,
#     1L, 2L, 3L, 1L, 8L, 3L, 3L, 1L, 1L, 1L, 2L, 1L, 1L, 4L, 1L,
#     1L, 1L, 7L, 2L, 1L, 1L, 1L, 2L, 1L, 1L, 1L, 1L, 2L, 1L, 1L,
#     2L, 4L, 4L, 5L, 4L, 2L, 23L, 1L, 1L, 1L, 1L, 3L, 1L, 2L,
#     1L, 1L, 1L, 1L, 14L, 2L, 3L, 8L, 1L, 3L, 2L, 15L, 1L, 1L,
#     3L, 1L, 1L, 2L, 11L, 1L, 1L, 2L, 1L, 1L, 1L, 1L, 8L, 1L,
#     1L, 3L, 1L, 2L, 1L, 1L, 1L, 4L, 1L, 8L, 1L, 3L, 3L, 3L, 1L,
#     1L, 1L, 14L, 1L, 1L, 1L, 3L, 1L, 2L, 2L, 1L, 1L, 1L, 1L,
#     1L, 1L, 1L, 10L, 3L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 2L, 1L,
#     18L, 1L, 9L, 1L, 1L, 2L, 1L, 3L, 4L, 3L, 1L, 1L, 2L, 11L,
#     2L, 1L, 2L, 1L, 2L, 1L, 6L, 2L, 10L, 3L, 1L, 1L, 1L, 3L,
#     1L, 1L, 1L, 1L, 1L, 1L, 25L, 8L, 1L, 1L, 1L, 1L, 1L, 1L,
#     1L, 4L, 1L, 1L, 1L, 1L, 10L, 4L, 2L, 1L, 2L, 6L, 2L, 2L,
#     2L, 4L, 1L, 2L, 4L, 1L, 1L, 2L, 1L, 6L, 1L, 1L, 6L, 1L, 4L,
#     1L, 6L, 1L, 1L, 8L, 1L, 1L, 1L, 3L, 3L, 2L, 1L, 1L, 10L,
#     2L, 4L, 23L, 2L, 1L, 1L, 1L, 13L, 2L, 1L, 1L, 7L, 1L, 2L,
#     2L, 1L, 1L, 2L, 2L, 1L, 1L, 3L, 1L, 1L, 1L, 1L, 1L, 1L, 1L,
#     1L, 1L, 1L, 1L, 2L, 26L, 2L, 1L, 1L, 5L, 2L, 4L, 1L, 5L,
#     3L, 3L, 10L, 1L, 9L, 1L, 1L, 24L, 50L, 2L, 3L, 1L, 1L, 16L,
#     3L, 4L, 1L, 1L, 22L, 2L, 14L, 4L, 1L, 1L, 1L, 2L, 5L, 2L,
#     3L, 53L, 1L, 1L, 1L, 2L, 3L, 1L, 9L, 9L, 6L, 7L, 1L, 1L,
#     1L, 3L, 16L, 3L, 2L, 20L, 2L, 1L, 89L, 14L, 2L, 7L, 1L, 1L,
#     1L, 1L, 5L, 1L, 1L, 1L, 1L, 4L, 1L, 1L, 1L, 16L, 3L, 1L,
#     1L, 1L, 2L, 1L, 1L, 2L, 1L, 1L, 3L, 1L, 1L, 1L, 2L, 1L, 1L,
#     1L, 1L, 7L, 1L, 2L, 1L, 2L, 1L, 2L, 1L, 1L, 1L, 2L, 2L, 2L,
#     1L, 1L, 1L, 1L, 1L, 2L, 1L, 1L, 1L, 5L, 2L, 1L, 1L, 1L, 1L,
#     1L, 1L, 1L, 1L, 1L, 1L, 4L, 3L, 2L, 3L, 1L, 13L, 1L, 1L,
#     4L, 1L, 1L, 1L, 1L, 2L, 1L, 19L, 1L, 1L, 8L, 6L, 1L, 1L,
#     1L, 1L, 2L, 3L, 1L, 1L, 1L, 2L, 1L, 1L, 5L, 1L, 1L, 1L, 4L,
#     3L, 2L, 1L, 1L, 1L, 1L, 1L, 4L, 2L, 3L, 1L, 1L, 7L, 3L, 2L,
#     7L, 1L, 35L, 1L, 1L, 2L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 2L,
#     3L, 1L, 3L, 3L, 4L, 1L, 1L, 1L, 1L, 2L, 1L, 1L, 5L, 2L, 1L,
#     1L, 1L, 1L, 1L, 4L, 7L, 2L, 1L, 1L, 2L, 5L, 13L, 1L, 1L,
#     1L, 7L, 1L, 1L, 1L, 12L, 3L, 1L, 2L, 14L, 4L, 1L, 6L, 1L,
#     1L, 1L, 3L, 1L, 3L, 1L, 1L, 1L, 5L, 1L, 1L, 3L, 1L, 2L, 23L,
#     1L, 1L, 4L, 1L, 9L, 6L, 3L, 1L, 1L, 3L, 1L, 4L, 7L, 1L, 3L,
#     3L, 1L, 1L, 5L, 1L, 1L, 1L, 2L, 1L, 1L, 6L, 6L, 1L, 1L, 5L,
#     2L, 1L, 3L, 1L, 2L, 1L, 12L, 2L, 2L, 4L, 1L, 1L, 2L, 1L,
#     1L, 1L, 2L, 2L, 7L, 3L, 10L, 1L, 1L, 5L, 1L, 2L, 2L, 1L,
#     1L, 7L, 7L, 2L, 1L, 9L, 1L, 1L, 1L, 1L, 2L, 1L, 1L, 12L,
#     1L, 1L, 2L, 1L, 1L, 1L, 3L, 3L, 1L, 1L, 2L, 1L, 1L, 1L, 1L,
#     5L, 1L, 1L, 1L, 1L, 3L, 2L, 1L, 2L, 1L, 1L, 4L, 2L, 1L, 1L,
#     1L, 2L, 1L, 1L, 1L)), class = "data.frame", row.names = c(NA,
# -1576L))
#
#
#
