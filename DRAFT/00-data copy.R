#' Baseball player stats
#'
#' Player stats created by combining `People`, `Batting`, and `Salaries` 
#' tables from the Lahman package. It contains a nice mix of variable
#' types for demonstrating guess_type() functions. 
#'
#' @format ## `baseball`
#' A data frame with 4,620 rows and 38 columns:
#' \describe{
#'   \item{playerID}{Unique player IDs}
#'   \item{birthYear}{Year in which the player was born (YYYY).}
#'   \item{birthMonth}{Month in which the player was born (MM).}
#'   \item{playerID}{A unique code assigned to each player.  The playerID links
#'                   the data in this file with records on players in the other files.}
#'   \item{birthYear}{Year player was born}
#'   \item{birthMonth}{Month player was born}
#'   \item{birthDay}{Day player was born}
#'   \item{birthCountry}{Country where player was born}
#'   \item{birthState}{State where player was born}
#'   \item{birthCity}{City where player was born}
#'   \item{deathYear}{Year player died}
#'   \item{deathMonth}{Month player died}
#'   \item{deathDay}{Day player died}
#'   \item{deathCountry}{Country where player died}
#'   \item{deathState}{State where player died}
#'   \item{deathCity}{City where player died}
#'   \item{nameFirst}{Player's first name}
#'   \item{nameLast}{Player's last name}
#'   \item{nameNote}{Note about player's name (usually signifying that they changed
#'               their name or played under two differnt names)}
#'   \item{nameGiven}{Player's given name (typically first and middle)}
#'   \item{nameNick}{Player's nickname}
#'   \item{weight}{Player's weight in pounds}
#'   \item{height}{Player's height in inches}
#'   \item{bats}{a factor: Player's batting hand (left (L), right (R), or both (B))         }
#'   \item{throws}{a factor: Player's throwing hand (left(L) or right(R))}
#'   \item{debut}{Date that player made first major league appearance}
#'   \item{finalGame}{Date that player made first major league appearance (blank if still active)}
#'   \item{retroID}{ID used by retrosheet, \url{https://www.retrosheet.org/}
#'   \item{bbrefID}{ID used by Baseball Reference website, \url{https://www.baseball-reference.com/}
#'   \item{birthDate}{Player's birthdate, in as.Date} format}
#'   \item{deathDate}{Player's deathdate, in as.Date} format}
#' }
#' @source <https://github.com/cdalzell/Lahman>
#'   Lahman, S. (2023) Lahman's Baseball Database, 1871-2022, 2022 version, 
#'   <https://www.seanlahman.com/baseball-archive/statistics/>
"baseball"




#' Starwars characters
#'
#' The original data, from SWAPI, the Star Wars API, <https://swapi.dev/>, has been revised
#' to reflect additional research into gender and sex determinations of characters.
#'
#' @format A tibble with 87 rows and 14 variables:
#' \describe{
#'   \item{name}{Name of the character}
#'   \item{height}{Height (cm)}
#'   \item{mass}{Weight (kg)}
#'   \item{hair_color,skin_color,eye_color}{Hair, skin, and eye colors}
#'   \item{birth_year}{Year born (BBY = Before Battle of Yavin)}
#'   \item{sex}{The biological sex of the character, namely male, female, hermaphroditic, or none (as in the case for Droids).}
#'   \item{gender}{The gender role or gender identity of the character as determined by their personality or the way they were programmed (as in the case for Droids).}
#'   \item{homeworld}{Name of homeworld}
#'   \item{species}{Name of species}
#'   \item{films}{List of films the character appeared in}
#'   \item{vehicles}{List of vehicles the character has piloted}
#'   \item{starships}{List of starships the character has piloted}
#' }
#' @examples
#' starwars
"starwars"




#' road tests 
#'
#' @format ## `mtcars`
#' A data frame with 32 rows and 13 columns:
#' \describe{
#'   \item{playerID}{Unique player IDs}
#'   \item{birthYear}{Year in which the player was born (YYYY).}
#'   \item{birthMonth}{Month in which the player was born (MM).}
#' }
#' @source <https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/mtcars.html>
"mtcars"


