
# (1) variable name

vname <- "name"
v <- df[["vname"]]

# (2) strings 

vtype <- "type"
vscope <- "PC"
desc <- "description"
loc, loc.label

# (3) factors/tables


divx ;; name ;; label


dd <- d[ d$vname==vname , ]

design.num <- 
 c( "div2 ;; vlabel  ;; LABEL",
    "div3 ;; vtype   ;; DATA TYPE",
    "div3 ;; scope   ;; SCOPE",
    "div4 ;; desc    ;; DESCRIPTION",
    "div4 ;; flevels ;; LEVELS",
    "div4 ;; loc     ;; LOCATION CODE" )

create_section_n( 
    dgf, df,
    vname,
    vtype, 
    properties = TRUE,
    quantiles  = TRUE,
    statistics = TRUE,
    histogram" = TRUE,
    values     = TRUE,
    "div2 ;; vlabel ;; LABEL",
    "div3 ;; vtype ;; DATA TYPE",
    "div3 ;; scope ;; SCOPE",
    "div4 ;; desc ;; DESCRIPTION",
    "div4 ;; flevels ;; LEVELS",
    "div4 ;; loc ;; LOCATION CODE" )
    

    
create_section_n( 
    vname,
    vlabel,     x2.lab="LABEL",
    vtype,      x3.lab="DATA TYPE", 
    x4=vscope,  x4.lab="SCOPE",
    x5=desc,    x5.lab="DESCRIPTION", 
    x6=k,       x6.lab="LEVELS", 
    x7=loc,     x7.lab="LOCATION CODE",
    properties = TRUE,
    quantiles  = TRUE,
    statistics = TRUE,
    histogram" = TRUE,
    values     = TRUE )


create_div1( x=vname )

create_div2( x=vlabel, 
             x.lab="LABEL" )

create_div3( x3=vtype, 
             x3.lab="DATA TYPE", 
             x4=vscope, 
             x4.lab="SCOPE" ) 
    
create_div4( x5=desc, x5.lab="DESCRIPTION", 
             x6=k,    x6.lab="LEVELS", 
             x7=loc,  x7.lab="LOCATION CODE" )
    
