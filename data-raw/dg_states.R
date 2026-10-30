# Generates data/dg_states.rda - a states test dataset built by merging two
# sources on the state name:
#
#   1. state.x77 (base R): the 50 states with eight numeric indicators
#      (population, income, illiteracy, life expectancy, murder rate, high
#      school graduation, frost days, area), plus region and two logical flags
#      (south, west) and a hashed id.
#   2. a hand-entered table of state mottos (Latin/other), their English
#      translations, and the year each motto was adopted.
#
# The motto table carries a few real-world messes that make it a good fixture:
# "Hawaii" is spelled "Hawai'i" (with an okina), four states appear twice
# (Kentucky, North Dakota, South Carolina, Vermont), and it includes six
# non-states (DC + five territories). We normalise the okina, keep the first
# row per state, and left-join onto the 50 states, so the non-states and
# duplicates fall away and the result is a clean 50-row frame. "-N/a"
# placeholders become real NAs (e.g. Alaska has no English translation;
# Washington's unofficial motto has no adoption year).
#
# The result exercises the full range datagoodr renders: character (state, id,
# motto, motto_english), factor (region), logical (south, west), numeric (the
# eight indicators), and temporal/year (motto_year). Re-run with:
#   Rscript data-raw/dg_states.R

# --- motto table (one row per jurisdiction, as hand-entered) -----------------
m <- structure(list(Jurisdiction = c("Alabama", "Alaska", "American Samoa",
"Arizona", "Arkansas", "California", "Colorado", "Connecticut",
"Delaware", "District of Columbia", "Florida", "Georgia", "Guam",
"Hawaiʻi", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas",
"Kentucky", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts",
"Michigan", "Minnesota", "Mississippi", "Missouri", "Montana",
"Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico",
"New York", "North Carolina", "North Dakota", "North Dakota",
"Northern Mariana Islands", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
"Puerto Rico", "Rhode Island", "South Carolina", "South Carolina",
"South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Vermont",
"Virginia", "U.S. Virgin Islands", "Washington", "West Virginia",
"Wisconsin", "Wyoming"), Motto = c("Audemus jura nostra defendere",
"North to the Future", "Sāmoa, Muamua Le Atua", "Ditat Deus",
"Regnat populus", "Eureka (Εὕρηκα)", "Nil sine numine",
"Qui transtulit sustinet", "Liberty and Independence", "Justitia Omnibus",
"In God We Trust", "Wisdom, Justice, Moderation", "—N/a", "Ua mau ke ea o ka ʻāina i ka pono",
"Esto perpetua", "State sovereignty, national union", "Crossroads of America",
"Our liberties we prize and our rights we will maintain", "Ad astra per aspera",
"United we stand, divided we fall", "Deo gratiam habeamus", "Union, justice, confidence",
"Dirigo", "Fatti maschi, parole femine", "Ense petit placidam sub libertate quietem",
"Si quaeris peninsulam amoenam circumspice", "L'Étoile du Nord",
"Virtute et armis", "Salus populi suprema lex esto", "Oro y plata",
"Equality before the law", "All For Our Country", "Live Free or Die",
"Liberty and prosperity", "Crescit eundo", "Excelsior", "Esse quam videri",
"Liberty and union, now and forever, one and inseparable", "Serit ut alteri saeclo prosit",
"—N/a", "With God, all things are possible", "Labor omnia vincit",
"Alis volat propriis", "Virtue, liberty, and independence", "Joannes Est Nomen Ejus",
"Hope", "Dum spiro spero", "Animis opibusque parati", "Under God the people rule",
"Agriculture and Commerce", "Friendship", "Industry", "Freedom and Unity",
"Stella quarta decima fulgeat", "Sic semper tyrannis", "United in Pride and Hope",
"Al-ki or Alki (Unofficial)", "Montani semper liberi", "Forward",
"Equal Rights"), `English translation` = c("We dare defend our rights",
"—N/a", "Samoa, let Atua be first", "God enriches", "The people rule",
"I have found it", "Nothing without providence", "He who transplanted still sustains",
"—N/a", "Justice for all", "—N/a", "—N/a", "—N/a", "The life of the land is perpetuated in righteousness / The sovereignty of the land is perpetuated in righteousness",
"Let it be perpetual", "—N/a", "—N/a", "—N/a", "To the stars through difficulties",
"—N/a", "Let us be grateful to God", "—N/a", "I lead", "Strong deeds, gentle words",
"By the sword we seek peace, but peace only under liberty", "If you seek a pleasant peninsula, look about you",
"The star of the North", "By valor and arms", "Let the welfare of the people be the supreme law",
"Gold and silver", "—N/a", "—N/a", "—N/a", "—N/a", "It grows as it goes",
"Ever upward", "To be, rather than to seem", "—N/a", "One sows for the benefit of another age",
"—N/a", "—N/a", "Labor conquers all things", "She flies with her own wings",
"—N/a", "John is his name", "—N/a", "While I breathe, I hope",
"Ready in soul and resource", "—N/a", "—N/a", "—N/a", "—N/a",
"—N/a", "May the fourteenth star shine bright", "Thus always to tyrants",
"—N/a", "By and by", "Mountaineers are always free", "—N/a",
"—N/a"), Date = c(1923L, 1967L, 1973L, 1863L, 1907L, 1849L,
1861L, 1662L, 1847L, 1871L, 1868L, 1798L, NA, 1843L, 1890L, 1819L,
1937L, 1847L, 1861L, 1942L, 2002L, 1902L, 1820L, 1874L, 1775L,
1835L, 1861L, 1894L, 1822L, 1865L, 1867L, 1866L, 1945L, 1928L,
1887L, 1778L, 1893L, 1863L, 2011L, NA, 1959L, 1893L, 1854L, 1875L,
1511L, 1664L, 1777L, 1777L, 1885L, 1802L, 1930L, 1896L, 1779L,
2015L, 1776L, 1991L, NA, 1863L, 1851L, 1893L)), class = "data.frame",
row.names = c(NA, -60L))

# --- state.x77 indicators + region / flags / id ------------------------------
df <- state.x77 |> as.data.frame()
df$state  <- state.name
df$region <- state.region
df$south  <- df$region == "South"
df$west   <- df$region == "West"
df$id     <- purrr::map_chr(df[["state"]], rlang::hash)

# --- tidy the motto table, then merge ----------------------------------------
na_mark <- function(x) ifelse(x == "—N/a", NA_character_, x)

mottos <- m
mottos$Jurisdiction <- sub("Hawaiʻi", "Hawaii", mottos$Jurisdiction)  # drop okina
mottos$Motto                 <- na_mark(mottos$Motto)
mottos$`English translation` <- na_mark(mottos$`English translation`)
mottos <- mottos[!duplicated(mottos$Jurisdiction), ]                       # first per state
mottos <- data.frame(
  state         = mottos$Jurisdiction,
  motto         = mottos$Motto,
  motto_english = mottos$`English translation`,
  motto_year    = mottos$Date,
  stringsAsFactors = FALSE
)

dg_states <- merge(df, mottos, by = "state", all.x = TRUE, sort = TRUE)

# --- order columns and clean indicator names ---------------------------------
dg_states <- dg_states[, c("state", "region", "south", "west",
                           "Population", "Income", "Illiteracy", "Life Exp",
                           "Murder", "HS Grad", "Frost", "Area",
                           "motto", "motto_english", "motto_year", "id")]
names(dg_states)[5:12] <- c("population", "income", "illiteracy", "life_exp",
                            "murder", "hs_grad", "frost", "area")
rownames(dg_states) <- NULL

save(dg_states, file = "data/dg_states.rda", version = 2)
cat("wrote data/dg_states.rda:", nrow(dg_states), "rows x", ncol(dg_states), "cols\n")
