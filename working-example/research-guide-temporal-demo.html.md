---
title: "Research Guide"
format:
  html:
    embed-resources: true
    toc: true
    toc-location: body
    toc-depth: 5
    toc-expand: true
execute:
  keep-md: true
params:
  dgf_file: 'DGF-temporal-demo.xlsx'
  data_file: null
---

<!-- datagoodr research guide template.

     Customize without editing the package:
       - DG.R           custom functions & layout overrides
       - datagoodr.css  the page grid, fonts, and colors
     See vignette("customizing", package = "datagoodr").

     Render from the console with:  quarto::quarto_render("research-guide.qmd")
     or re-render against a different DGF/dataset without editing this file:
       datagoodr::update_rg("research-guide.qmd", DGF = "DGF-V2.xlsx") -->

<br>


<br><br>




## Logical

{{< pagebreak >}} 

::: {.div1} 

#### is_501c3

::: 

::::: {.parent} 

::: {.div2} 

is_501c3 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">boolean</span></div>



<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">5</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
TRUE · FALSE

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|    PER| 
 |:--------|---:|------:| 
 |Rows     | 300|       | 
 |Distinct |   2| (0.7%)| 





::: 

::: {.div8} 

![](research-guide-temporal-demo_files/figure-html/logical-1.png){width=672}




::: 

::: {.div9} 




::: 

:::::  

## Factor

{{< pagebreak >}} 

::: {.div1} 

#### ntee_program

::: 

::::: {.parent} 

::: {.div2} 

ntee_program 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">categorical</span></div>



<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">14</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
Environment · Health · Human Services · Arts · Education

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|    PER| 
 |:--------|---:|------:| 
 |Rows     | 300|       | 
 |Distinct |   5| (1.7%)| 





::: 

::: {.div8} 

![](research-guide-temporal-demo_files/figure-html/factor-1.png){width=672}




::: 

::: {.div9} 

**FACTOR LEVELS**:

| Frequency|     (%)|Label          | 
 |---------:|-------:|:--------------| 
 |        65| (21.7%)|Environment    | 
 |        62| (20.7%)|Health         | 
 |        60| (20.0%)|Human Services | 
 |        58| (19.3%)|Arts           | 
 |        55| (18.3%)|Education      | 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### num_programs

::: 

::::: {.parent} 

::: {.div2} 

num_programs 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">categorical</span></div>



<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v"> 2</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
5 · 7 · 8 · 4 · 6 · 10 · 9 · 3 · 2 · 1 · 12 · 11 · 13

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|    PER| 
 |:--------|---:|------:| 
 |Rows     | 300|       | 
 |Distinct |  13| (4.3%)| 





::: 

::: {.div8} 

![](research-guide-temporal-demo_files/figure-html/factor-2.png){width=672}




::: 

::: {.div9} 

**FACTOR LEVELS**:

| Frequency|     (%)|Label | 
 |---------:|-------:|:-----| 
 |        43| (14.3%)|5     | 
 |        43| (14.3%)|7     | 
 |        39| (13.0%)|8     | 
 |        31| (10.3%)|4     | 
 |        31| (10.3%)|6     | 
 |        22|  (7.3%)|10    | 
 |        21|  (7.0%)|9     | 
 |        18|  (6.0%)|3     | 
 |        16|  (5.3%)|2     | 
 |        15|  (5.0%)|1     | 
 |        11|  (3.7%)|12    | 
 |         9|  (3.0%)|11    | 
 |         1|  (0.3%)|13    | 





::: 

:::::  

## Numeric 



## Character

{{< pagebreak >}} 

::: {.div1} 

#### org_name

::: 

::::: {.parent} 

::: {.div2} 

org_name 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">string</span></div>



<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">18</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
Organization A 158 · Organization A 202 · Organization A 276
Organization A 279 · Organization A 412 · Organization A 530
Organization A 589 · Organization A 604 · Organization A 605
Organization A 657 · Organization A 735 · Organization A 74

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|      PER| 
 |:--------|---:|--------:| 
 |Rows     | 300|         | 
 |Distinct | 300| (100.0%)| 





::: 

::: {.div8} 

![](research-guide-temporal-demo_files/figure-html/character-1.png){width=768}




::: 

::: {.div9} 

**MOST COMMON VALUES**: 

|Value              | Frequency|    (%)| 
 |:------------------|---------:|------:| 
 |Organization A 158 |         1| (0.3%)| 
 |Organization A 202 |         1| (0.3%)| 
 |Organization A 276 |         1| (0.3%)| 
 |Organization A 279 |         1| (0.3%)| 
 |Organization A 412 |         1| (0.3%)| 
 |Organization A 530 |         1| (0.3%)| 





::: 

:::::  

## Identifier

{{< pagebreak >}} 

::: {.div1} 

#### ein

::: 

::::: {.parent} 

::: {.div2} 

ein 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">identifier</span></div>



<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">9</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
101578358 · 105981903 · 106643114 · 107326985 · 108277070
113137014 · 113200319 · 116652886 · 118561463 · 122903686
123933062 · 130282978 · 132536339 · 133339764 · 146739486
151775857 · 155493354 · 155704899 · 155760701 · 160743970

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|      PER| 
 |:--------|---:|--------:| 
 |Rows     | 300|         | 
 |Distinct | 300| (100.0%)| 





::: 

::: {.div8} 

**MOST COMMON VALUES**: 

|Value     | Frequency|    (%)| 
 |:---------|---------:|------:| 
 |101578358 |         1| (0.3%)| 
 |105981903 |         1| (0.3%)| 
 |106643114 |         1| (0.3%)| 
 |107326985 |         1| (0.3%)| 
 |108277070 |         1| (0.3%)| 
 |113137014 |         1| (0.3%)| 





::: 

:::::  

## Temporal

{{< pagebreak >}} 

::: {.div1} 

#### day_of_week

::: 

::::: {.parent} 

::: {.div2} 

day_of_week 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">temporal</span></div>



<div class="dg-field"><span class="dg-k">UNIT</span><span class="dg-v">dow</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
TUE · WED · MON · THU · FRI · SAT · SUN

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|    PER| 
 |:--------|---:|------:| 
 |Rows     | 300|       | 
 |Distinct |   7| (2.3%)| 





::: 

::: {.div8} 

![](research-guide-temporal-demo_files/figure-html/temporal-1.png){width=768}


::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### date_mdy

::: 

::::: {.parent} 

::: {.div2} 

date_mdy 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">temporal</span></div>



<div class="dg-field"><span class="dg-k">UNIT</span><span class="dg-v">date</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
01-01-2017 · 01-24-2015 · 02-18-2015 · 02-24-2018 · 05-17-2017
05-22-2018 · 06-05-2018 · 06-09-2016 · 06-30-2017 · 07-10-2017
07-14-2016 · 08-01-2018 · 08-02-2017 · 08-08-2017 · 08-08-2018
08-26-2017 · 08-27-2016 · 09-10-2017 · 09-11-2017 · 09-19-2015

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     | 300|        | 
 |Distinct | 274| (91.3%)| 





::: 

::: {.div8} 

![](research-guide-temporal-demo_files/figure-html/temporal-2.png){width=768}


::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### date_dmy

::: 

::::: {.parent} 

::: {.div2} 

date_dmy 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">temporal</span></div>



<div class="dg-field"><span class="dg-k">UNIT</span><span class="dg-v">date</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
01-01-17 · 01-08-18 · 02-08-17 · 03-10-18 · 05-06-18 · 06-12-16
08-08-17 · 08-08-18 · 09-06-16 · 10-07-17 · 10-09-17 · 11-09-17
14-07-16 · 17-05-17 · 18-02-15 · 19-09-15 · 20-12-16 · 22-05-18
24-01-15 · 24-02-18 · 24-10-18 · 25-09-15 · 26-08-17 · 26-10-15

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     | 300|        | 
 |Distinct | 274| (91.3%)| 





::: 

::: {.div8} 

![](research-guide-temporal-demo_files/figure-html/temporal-3.png){width=768}


::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### month_abbr

::: 

::::: {.parent} 

::: {.div2} 

month_abbr 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">temporal</span></div>



<div class="dg-field"><span class="dg-k">UNIT</span><span class="dg-v">month</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
SEP · JUN · OCT · AUG · FEB · JAN · JUL · MAR · MAY · APR · NOV
DEC

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|    PER| 
 |:--------|---:|------:| 
 |Rows     | 300|       | 
 |Distinct |  12| (4.0%)| 





::: 

::: {.div8} 

![](research-guide-temporal-demo_files/figure-html/temporal-4.png){width=768}


::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### month_ym

::: 

::::: {.parent} 

::: {.div2} 

month_ym 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">temporal</span></div>



<div class="dg-field"><span class="dg-k">UNIT</span><span class="dg-v">month</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
2017-09 · 2017-01 · 2018-05 · 2018-08 · 2018-10 · 2015-06 · 2015-10
2016-09 · 2016-12 · 2017-08 · 2018-06 · 2015-02 · 2015-09 · 2017-07
2018-02 · 2015-03 · 2015-07 · 2016-04 · 2016-06 · 2017-02 · 2015-04
2016-01 · 2016-08 · 2017-10 · 2018-01 · 2018-03 · 2015-01 · 2015-11

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     | 300|        | 
 |Distinct |  48| (16.0%)| 





::: 

::: {.div8} 

![](research-guide-temporal-demo_files/figure-html/temporal-5.png){width=768}


::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### hour_ampm

::: 

::::: {.parent} 

::: {.div2} 

hour_ampm 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">temporal</span></div>



<div class="dg-field"><span class="dg-k">UNIT</span><span class="dg-v">hour</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
00:36:00 · 01:51:00 · 02:16:00 · 02:32:00 · 02:38:00 · 02:55:00
04:09:00 · 04:18:00 · 04:52:00 · 05:07:00 · 05:59:00 · 07:06:00
07:39:00 · 08:08:00 · 08:15:00 · 08:22:00 · 09:52:00 · 10:26:00
13:27:00 · 14:26:00 · 14:48:00 · 15:02:00 · 15:12:00 · 15:26:00

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     | 300|        | 
 |Distinct | 268| (89.3%)| 





::: 

::: {.div8} 

![](research-guide-temporal-demo_files/figure-html/temporal-6.png){width=768}


::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### event_ts

::: 

::::: {.parent} 

::: {.div2} 

event_ts 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">temporal</span></div>



<div class="dg-field"><span class="dg-k">UNIT</span><span class="dg-v">week</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
2015-01-02 11:02:24 MST · 2015-01-16 17:17:50 MST
2015-01-24 01:18:30 MST · 2015-01-24 10:05:07 MST
2015-01-25 14:20:16 MST · 2015-02-02 14:48:47 MST
2015-02-06 01:48:49 MST · 2015-02-09 15:18:51 MST

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|      PER| 
 |:--------|---:|--------:| 
 |Rows     | 300|         | 
 |Distinct | 300| (100.0%)| 





::: 

::: {.div8} 

![](research-guide-temporal-demo_files/figure-html/temporal-7.png){width=768}


::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### rule_year

::: 

::::: {.parent} 

::: {.div2} 

rule_year 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">temporal</span></div>



<div class="dg-field"><span class="dg-k">UNIT</span><span class="dg-v">year</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
1999 · 1964 · 2000 · 1977 · 1992 · 1996 · 2005 · 1957 · 1974 · 1993
1997 · 1998 · 2012 · 1979 · 1987 · 2015 · 1960 · 1962 · 1963 · 1965
1970 · 1972 · 1973 · 1976 · 1981 · 1982 · 1985 · 1988 · 2009 · 2010
2011 · 2014 · 1958 · 1969 · 1975 · 1980 · 1983 · 1984 · 1986 · 1995

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     | 300|        | 
 |Distinct |  61| (20.3%)| 





::: 

::: {.div8} 

![](research-guide-temporal-demo_files/figure-html/temporal-8.png){width=768}


::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### age_years

::: 

::::: {.parent} 

::: {.div2} 

age_years 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">temporal</span></div>



<div class="dg-field"><span class="dg-k">UNIT</span><span class="dg-v">year</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
27 · 62 · 26 · 21 · 30 · 34 · 49 · 14 · 28 · 29 · 33 · 52 · 69 · 11
39 · 47 · 12 · 15 · 16 · 17 · 38 · 41 · 44 · 45 · 50 · 53 · 54 · 56
61 · 63 · 64 · 66 · 13 · 19 · 24 · 25 · 31 · 40 · 42 · 43 · 46 · 51
57 · 68 · 18 · 32 · 35 · 36 · 37 · 55 · 59 · 65 · 67 · 70 · 71 · 20

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     | 300|        | 
 |Distinct |  61| (20.3%)| 





::: 

::: {.div8} 

![](research-guide-temporal-demo_files/figure-html/temporal-9.png){width=768}


::: 

:::::  




<style>
 /* ==========================================================================
   datagoodr report stylesheet
   Single source of truth for the RG / DD templates (served via datagoodr_css()).
   Tweak the tokens in :root to restyle the whole report.
   ========================================================================== */

:root {
  --dg-serif: Georgia, "Times New Roman", serif;
  --dg-sans:  -apple-system, "Segoe UI", Helvetica, Arial, sans-serif;
  --dg-mono:  "Anonymous Pro", Consolas, Menlo, monospace;

  --dg-ink:    #1a1a1a;   /* primary text            */
  --dg-label:  #6b6b6b;   /* field / section labels  */
  --dg-muted:  #8a8a8a;   /* secondary text          */
  --dg-rule:   #dcdcdc;   /* hairline table rules     */
  --dg-accent: #1a1a1a;   /* title underline          */

  --dg-gap-row: 6px;
  --dg-gap-col: 26px;
}

/* --- per-variable grid ---------------------------------------------------- */
/* Three equal columns. Each section (a div) is placed by flow, in layout
   order, and sized with `grid-column: span N` -> 1/3, 2/3, or full width.
   The div number stays the section's identity + style hook; only the span
   sets width. Keep each visual row's spans summing to 3 (1+2, 1+1+1, 3). */
.parent {
  display: grid;
  width: 100%;
  box-sizing: border-box;
  /* the whole grid is indented under the flush-left variable title (which is
     emitted outside .parent), matching the reference layout. */
  padding-left: 3.2em;
  /* minmax(0, 1fr) keeps the three columns strictly equal and lets wide
     content (long preview lines, wide tables) overflow instead of blowing
     out a column. */
  grid-template-columns: repeat(3, minmax(0, 1fr));
  grid-auto-rows: auto;
  grid-column-gap: var(--dg-gap-col);
  grid-row-gap: var(--dg-gap-row);
  /* breathing room after each variable block, before the next section title */
  margin-bottom: 2.2em;
}

/* keep every rendered graphic inside its cell - never overflow the column */
.parent img, .parent svg {
  max-width: 100%;
  height: auto;
}

/* Standard section template - one div scheme shared by every variable type:
     div3 attributes (1/3)  + div4 description (2/3)
     div5 PREVIEW label (1/3) + div6 preview data (2/3)
     div7 PROPERTIES (1/3)  + div8 graphic (2/3)
     div9 full-width extra table (3/3): STATS / levels / most-common values */
.div1  { grid-column: span 3; padding-bottom: 4px; }  /* title (outside grid) */
.div2  { grid-column: span 3; }   /* label            */
.div3  { grid-column: span 1; }   /* type/scope/length */
.div4  { grid-column: span 2; }   /* description       */
.div5  { grid-column: span 1; }   /* preview label     */
.div6  { grid-column: span 2; }   /* preview data      */
.div7  { grid-column: span 1; }   /* properties        */
.div8  { grid-column: span 2; }   /* graphic           */
.div9  { grid-column: span 3; }   /* full-width table  */

/* empty spacers usable directly from a layout object (e.g. "blank1") */
.blank1 { grid-column: span 1; }
.blank2 { grid-column: span 2; }

/* left-hand column cells get a small indent to sit under the title's text */
.div3, .div5, .div7 { padding-left: 2px; }

/* PROPERTIES (div7) shares a row with the tall word cloud (div8). The cell
   still stretches to the row height (so the band rule below aligns at the top),
   but its content is centered vertically to sit level with the graphic. */
.div7 { display: flex; flex-direction: column; justify-content: center; }

/* Band separators: a full-width hairline + breathing room at the start of each
   major block (preview / properties+graphic / stats). Applying the rule to both
   cells of a row spans it across all three columns (grid items stretch, so the
   tops align). The dictionary block (div2/div3/div4) gets no top rule. */
.div5, .div6,          /* PREVIEW band         */
.div7, .div8,          /* PROPERTIES + graphic */
.div9 {                /* stats / most-common  */
  border-top: 1px solid var(--dg-rule);
  padding-top: 0.9em;
  margin-top: 0.5em;
}

/* the full-width extra table is height-capped and scrolls when long (e.g. a
   factor with many levels, or a long most-common-values list) */
.div9 { max-height: 22em; overflow-y: auto; }

/* ==========================================================================
   Visual hierarchy
   L1 title  >  L2 label  >  L3 field labels  >  L4 values/data
   ========================================================================== */

/* L1 - variable name */
h1.title { color: var(--dg-ink); font-family: var(--dg-serif); font-size: 2.3em; }
h2.anchored { color: #c9c9c9; }
h3.anchored { color: var(--dg-muted); }

h4 {
  font-family: var(--dg-serif);
  font-size: 2.5em;
  font-weight: 700;
  letter-spacing: -0.01em;
  color: var(--dg-ink);
  border-bottom: 3px solid var(--dg-accent);
  width: 100%;
  /* extra top margin sets each variable's title apart from the block above */
  margin: 0.8em 0 0.2em 0;
  padding-bottom: 2px;
}

h5 { font-size: 0.9em; }

/* L2 - the plain-language variable label (div2), printed without a prefix */
.div2 p {
  font-family: var(--dg-sans);
  font-size: 1.3em;
  font-weight: 400;
  color: var(--dg-ink);
  line-height: 1.3;
  margin: 0.1em 0 0.5em 0;
}

/* L3 - field & section labels (DATA TYPE:, DEFINITION:, LEVELS:, ...) rendered
   as <strong>. One consistent treatment across all descriptor divs. */
.div3 strong, .div4 strong {
  font-family: var(--dg-sans);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  font-size: 0.72em;
  font-weight: 700;
  color: var(--dg-label);
}

/* L4 - values */
.div3 p {
  font-family: var(--dg-sans);
  font-size: 0.95em;
  color: var(--dg-ink);
  line-height: 1.2;
  margin: 0 0 0.15em 0;
}

.div4 p {
  font-family: var(--dg-sans);
  font-size: 0.95em;
  color: var(--dg-ink);
  line-height: 1.4;
  margin: 0 0 0.55em 0;
}

/* --- descriptor fields (v_to_txt) ----------------------------------------- */
/* Emitted as <div class="dg-field"><span class="dg-k">LABEL</span>
   <span class="dg-v">value</span></div>. div3 = short metadata aligned into a
   two-column definition block (dark label + bold mono value); div4 = uppercase
   label followed by flowing prose (DESCRIPTION, LOCATION CODE). */
.dg-field .dg-k {
  font-family: var(--dg-sans);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  font-size: 0.72em;
  font-weight: 700;
}

.div3 .dg-field {
  display: grid;
  grid-template-columns: 6.2em 1fr;
  align-items: baseline;
  column-gap: 0.5em;
  margin: 0 0 0.32em 0;
}
.div3 .dg-k { color: var(--dg-ink); }
.div3 .dg-v {
  font-family: var(--dg-mono);
  font-weight: 700;
  font-size: 0.92em;
  color: var(--dg-ink);
}

.div4 .dg-field { margin: 0 0 0.55em 0; line-height: 1.4; }
.div4 .dg-k { color: var(--dg-label); }
.div4 .dg-k::after { content: ":\00a0"; }
.div4 .dg-v {
  font-family: var(--dg-sans);
  font-size: 0.95em;
  color: var(--dg-ink);
}

/* --- data preview: wrapped monospace block (wrap_preview / paste_preview) -- */
pre.dg-preview {
  font-family: var(--dg-mono);
  font-size: 0.7em;
  line-height: 1.4;
  white-space: pre;
  overflow-x: auto;      /* contain any stray long line inside the cell */
  max-width: 100%;
  background: none;
  border: none;
  padding: 0;
  margin: 0.15em 0 0 0;
  color: #333;
}

/* ==========================================================================
   Data-profile tables (properties / quantiles / stats)
   ========================================================================== */

/* section labels: div5 (PREVIEW), div7 (PROPERTIES), div9 (STATS/levels/...) */
.div5 p, .div7 p, .div9 p {
  margin: 0 0 0.15em 0;
}
.div5 strong, .div7 strong, .div9 strong {
  font-family: var(--dg-sans);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  font-size: 0.72em;
  font-weight: 700;
  color: var(--dg-label);
}

/* mono cells in the properties (div7), graphic-cell table (div8, the identifier
   MOST COMMON VALUES table), and full-width (div9) tables. div8 is a graphic for
   every other type, so these table rules only bite for the identifier. */
.div7 td, .div8 td, .div9 td {
  font-family: var(--dg-mono);
  font-size: 0.85em;
}

.div7 table, .div8 table, .div9 table { margin-left: 2px; }

/* strip default table chrome; use tight cells + hairline row rules */
.table { width: auto; }
.table > tbody { border-top: none; }
.table > :not(caption) > * > * { padding: 0.05rem 0.6rem 0.05rem 0; }

tbody, tfoot, tr, td, th {
  border-color: inherit;
  border-style: none;
  border-width: 0;
}

.div7 tr, .div8 tr, .div9 tr {
  border-bottom: 1px solid var(--dg-rule);
}
/* hide the header on the self-evident STAT/VAL/PER properties table ... */
.div7 th { display: none; }
/* ... but keep it on the div8 identifier table and the full-width extra table,
   where the columns aren't self-evident (STATS names, factor
   LABEL/FREQUENCY/MEANING, most-common VALUE/FREQUENCY, logical category
   codes). */
.div8 th, .div9 th {
  font-family: var(--dg-sans);
  text-transform: uppercase;
  letter-spacing: 0.03em;
  font-size: 0.7em;
  font-weight: 700;
  color: var(--dg-label);
  text-align: left;
}

/* the DISTRIBUTION SHAPE table (numeric div9, under STATS) is self-evident, so
   its header (stat / num / interpretation) is hidden - same treatment as the
   PROPERTIES table. */
.dg-shape thead, .dg-shape th { display: none; }

/* graphic anchored to the bottom-right of its cell */
.div8 img, .div8 svg { align-self: end; justify-self: end; }

@media print {
  body {
    display: table;
    table-layout: fixed;
    padding: 2.5cm 1.5cm 3cm 1.5cm;
    height: auto;
  }
} 
</style>


<!-- datagoodr-render-record {"datagoodr":"0.1.0","rendered_utc":"2026-07-18T20:31:36Z","r":"4.5.1","quarto":"1.8.25","dgf_file":"DGF-temporal-demo.xlsx","dgf_hash":"30d2510094ca584b30615d9180331906","dgf_variables":14} -->
