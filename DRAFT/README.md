

------------------------------------------------------
 format                      desc                     
-------- ---------------------------------------------
   %a             Abbreviated weekday name in         
                  the current locale on this          
                 platform. (Also matches full         
                name on input: in some locales        
                 there are no abbreviations of        
                            names.)                   

   %A              Full weekday name in the           
                 current locale. (Also matches        
                  abbreviated name on input.)         

   %b            Abbreviated month name in the        
                    current locale on this            
                 platform. (Also matches full         
                name on input: in some locales        
                 there are no abbreviations of        
                            names.)                   

   %B           Full month name in the current        
                     locale. (Also matches            
                  abbreviated name on input.)         

   %c           Date and time. Locale-specific        
                 on output, "%a %b %e %H:%M:%S        
                         %Y" on input.                

   %C            Century (00–99): the integer         
                  part of the year divided by         
                             100.                     

   %d             Day of the month as decimal         
                        number (01–31).               

   %D            Date format such as %m/%d/%y:        
                   the C99 standard says it           
                  should be that exact format         
                  (but not all OSes comply).          

   %e             Day of the month as decimal         
                 number (1–31), with a leading        
                   space for a single-digit           
                            number.                   

   %F             Equivalent to %Y-%m-%d (the         
                    ISO 8601 date format).            

   %g             The last two digits of the          
                   week-based year (see %V).          
                   (Accepted but ignored on           
                            input.)                   

   %G            The week-based year (see %V)         
                as a decimal number. (Accepted        
                    but ignored on input.)            

   %h                  Equivalent to %b.              

   %H               Hours as decimal number           
                     (00–23). As a special            
                   exception strings such as          
                  ‘?24:00:00?’ are accepted for         
                 input, since ISO 8601 allows         
                            these.                    

   %I               Hours as decimal number           
                           (01–12).                   

   %j            Day of year as decimal number        
                 (001–366): For input, 366 is         
                  only valid in a leap year.          

   %m               Month as decimal number           
                           (01–12).                   

   %M              Minute as decimal number           
                           (00–59).                   

   %n            Newline on output, arbitrary         
                     whitespace on input.             

   %p           AM/PM indicator in the locale.        
                      Used in conjunction             
                  with %I and not with %H. An         
                 empty string in some locales         
                  (for example on some OSes,          
                 non-English European locales         
                    including Russia). The            
                behaviour is undefined if used        
                  for input in such a locale.         
                 Some platforms accept %P for         
                     output, which uses a             
                  lower-case version (%p may          
                 also use lower case): others         
                        will output P.                

   %r            For output, the 12-hour clock        
                time (using the locale's AM or        
                   PM): only defined in some          
                   locales, and on some OSes          
                misleading in locales which do        
                not define an AM/PM indicator.        
                     For input, equivalent            
                        to %I:%M:%S %p.               

   %R                Equivalent to %H:%M.             

   %S             Second as integer (00–61),          
                    allowing for up to two            
                       leap-seconds (but              
                        POSIX-compliant               
                  implementations will ignore         
                        leap seconds).                

   %t              Tab on output, arbitrary           
                     whitespace on input.             

   %T               Equivalent to %H:%M:%S.           

   %u             Weekday as a decimal number         
                      (1–7, Monday is 1).             

   %U             Week of the year as decimal         
                number (00–53) using Sunday as        
                  the first day 1 of the week         
                 (and typically with the first        
                Sunday of the year as day 1 of        
                  week 1). The US convention.         

   %V             Week of the year as decimal         
                 number (01–53) as defined in         
                     ISO 8601. If the week            
                     (starting on Monday)             
                 containing 1 January has four        
                 or more days in the new year,        
                 then it is considered week 1.        
                Otherwise, it is the last week        
                 of the previous year, and the        
                next week is week 1. (Accepted        
                    but ignored on input.)            

   %w              Weekday as decimal number          
                      (0–6, Sunday is 0).             

   %W             Week of the year as decimal         
                number (00–53) using Monday as        
                  the first day of week (and          
                   typically with the first           
                Monday of the year as day 1 of        
                  week 1). The UK convention.         

   %x              Date. Locale-specific on           
                 output, "%y/%m/%d" on input.         

   %X              Time. Locale-specific on           
                 output, "%H:%M:%S" on input.         

   %y            Year without century (00–99).        
                 On input, values 00 to 68 are        
                prefixed by 20 and 69 to 99 by        
                  19 – that is the behaviour          
                  specified by the 2018 POSIX         
                standard, but it does also say        
                   ‘it is expected that in a          
                  future version the default          
                    century inferred from a           
                  2-digit year will change’.          

   %Y            Year with century. Note that         
                 whereas there was no zero in         
                    the original Gregorian            
                    calendar, ISO 8601:2004           
                    defines it to be valid            
                     (interpreted as 1BC):            
          see https://en.wikipedia.org/wiki/0_(year). 
                  However, the standards also         
                 say that years before 1582 in        
                  its calendar should only be         
                  used with agreement of the          
                 parties involved. For input,         
                     only years 0:9999 are            
                           accepted.                  

   %z             Signed offset in hours and          
                 minutes from UTC, so -0800 is        
                 8 hours behind UTC. (Standard        
                     only for output. For             
                 input R currently supports it        
                   on all platforms – values          
                    from -1400 to +1400 are           
                          accepted.)                  

   %Z              (Output only.) Time zone           
                  abbreviation as a character         
                     string (empty if not             
                  available). This may not be         
                 reliable when a time zone has        
                changed abbreviations over the        
                            years.                    
------------------------------------------------------

