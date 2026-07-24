---
title: "Research Guide"
format:
  html:
    embed-resources: true
    toc: true
    toc-location: body
    toc-depth: 5
    toc-expand: true
  pdf: default
execute:
  keep-md: true
params:
  dgf_file: "DGF-V2.xlsx"
---

<!-- datagoodr research guide template.
     Customize without editing the package by editing:
       - DG.R          custom formatting/graphic functions & layout overrides
       - datagoodr.css  the page grid, fonts, and colors
     Render with:  quarto::quarto_render("research-guide.qmd") -->

<br>


<br><br>






## Logical

{{< pagebreak >}} 

::: {.div1} 

#### F9_05_UBIZ_IMCOME_OVER_LIMIT_X

::: 

::::: {.parent} 

::: {.div2} 

F9_05_UBIZ_IMCOME_OVER_LIMIT_X 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">logical</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">1</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Had unrelated business gross income of $1,000 or more [x]</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
N · Y

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     |    VAL|    PER| 
 |:--------|------:|------:| 
 |Rows     | 25,000|       | 
 |Distinct |      2| (0.0%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/logical-1.pdf)




::: 

::: {.div9} 

**CATEGORY LABELS**:

|N  |Y  | 
 |:--|:--| 
 |   |   | 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### OUTNCCS

::: 

::::: {.parent} 

::: {.div2} 

OUTNCCS 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">logical</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">3</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Out of Scope flag</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
IN · OUT

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|    PER| 
 |:----------|------:|------:| 
 |Rows       | 25,000|       | 
 |Distinct   |      3| (0.0%)| 
 |Missing/NA |  2,361| (9.4%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/logical-2.pdf)




::: 

::: {.div9} 

**CATEGORY LABELS**:

|IN |OUT | 
 |:--|:---| 
 |   |    | 





::: 

:::::  

## Factor

{{< pagebreak >}} 

::: {.div1} 

#### SUBSECCD

::: 

::::: {.parent} 

::: {.div2} 

SUBSECCD 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">factor</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">2</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">IRS subsection code</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
6 · 4 · 7 · 5 · 8 · 19 · 9 · 12 · 13 · 2 · 10 · 14 · 25 · 15 · 17
23 · 11 · 26 · 16 · 18 · 24 · 27 · 29

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     |    VAL|    PER| 
 |:--------|------:|------:| 
 |Rows     | 25,000|       | 
 |Distinct |     23| (0.1%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/factor-1.pdf)




::: 

::: {.div9} 

**FACTOR LEVELS**:

|Label | Frequency| 
 |:-----|---------:| 
 |6     |     6,391| 
 |4     |     4,936| 
 |7     |     3,571| 
 |5     |     3,449| 
 |8     |     1,479| 
 |19    |     1,459| 
 |9     |     1,033| 
 |12    |       642| 
 |13    |       561| 
 |2     |       545| 
 |10    |       466| 
 |14    |       311| 
 |25    |        88| 
 |15    |        32| 
 |17    |        22| 
 |23    |         6| 
 |11    |         2| 
 |26    |         2| 
 |16    |         1| 
 |18    |         1| 
 |24    |         1| 
 |27    |         1| 
 |29    |         1| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### BMF_ACTIV1

::: 

::::: {.parent} 

::: {.div2} 

BMF_ACTIV1 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">factor</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">3</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">IRS Activity Code 1</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
0 · 263 · 200 · 907 · 36 · 279 · 205 · 319 · 318 · 59 · 407 · 520
900 · 265 · 264 · 280 · 260 · 250 · 999 · 920 · 30 · 912 · 261 · 230
65 · 998 · 229 · 317 · 403 · 201 · 908 · 288 · 911 · 399 · 286 · 161
922 · 281 · 350 · 123 · 287 · 382 · 401 · 921 · 34 · 119 · 408 · 602

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|    PER| 
 |:----------|------:|------:| 
 |Rows       | 25,000|       | 
 |Distinct   |    230| (0.9%)| 
 |Missing/NA |  1,887| (7.5%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/factor-2.pdf)




::: 

::: {.div9} 

**FACTOR LEVELS**:

|Label | Frequency| 
 |:-----|---------:| 
 |0     |     5,807| 
 |263   |     1,782| 
 |200   |     1,648| 
 |907   |     1,212| 
 |36    |     1,054| 
 |279   |       998| 
 |205   |       949| 
 |319   |       547| 
 |318   |       467| 
 |59    |       467| 
 |407   |       401| 
 |520   |       401| 
 |900   |       323| 
 |265   |       322| 
 |264   |       301| 
 |280   |       293| 
 |260   |       276| 
 |250   |       203| 
 |999   |       200| 
 |920   |       187| 
 |30    |       179| 
 |912   |       163| 
 |261   |       162| 
 |230   |       145| 
 |65    |       143| 
 |998   |       140| 
 |229   |       137| 
 |317   |       137| 
 |403   |       136| 
 |201   |       136| 
 |908   |       125| 
 |288   |       121| 
 |911   |       120| 
 |399   |       117| 
 |286   |       115| 
 |161   |       112| 
 |922   |        97| 
 |281   |        93| 
 |350   |        91| 
 |123   |        85| 
 |287   |        78| 
 |382   |        73| 
 |401   |        69| 
 |921   |        67| 
 |34    |        60| 
 |119   |        59| 
 |408   |        58| 
 |602   |        57| 
 |251   |        56| 
 |262   |        55| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### NTMAJ12

::: 

::::: {.parent} 

::: {.div2} 

NTMAJ12 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">factor</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">2</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">NTEE major group (12)</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
PU · HU · MU · ED · UN · HE · AR · EN · IN · EH · RE · BH

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     |    VAL|    PER| 
 |:--------|------:|------:| 
 |Rows     | 25,000|       | 
 |Distinct |     12| (0.0%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/factor-3.pdf)




::: 

::: {.div9} 

**FACTOR LEVELS**:

|Label | Frequency| 
 |:-----|---------:| 
 |PU    |     9,128| 
 |HU    |     7,955| 
 |MU    |     2,480| 
 |ED    |     1,528| 
 |UN    |     1,524| 
 |HE    |       994| 
 |AR    |       615| 
 |EN    |       508| 
 |IN    |       101| 
 |EH    |        79| 
 |RE    |        64| 
 |BH    |        24| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### NTEE1

::: 

::::: {.parent} 

::: {.div2} 

NTEE1 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">factor</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">1</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">NTEE major group</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
S · N · W · Y · J · B · M · L · A · K · E · I · G · C · P · D · U
R · T · F · Q · O · X · Z · H · V

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|    PER| 
 |:----------|------:|------:| 
 |Rows       | 25,000|       | 
 |Distinct   |     27| (0.1%)| 
 |Missing/NA |  1,497| (6.0%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/factor-4.pdf)




::: 

::: {.div9} 

**FACTOR LEVELS**:

|Label | Frequency| 
 |:-----|---------:| 
 |S     |     5,817| 
 |N     |     3,018| 
 |W     |     2,835| 
 |Y     |     2,480| 
 |J     |     1,961| 
 |B     |     1,552| 
 |M     |       876| 
 |L     |       669| 
 |A     |       615| 
 |K     |       590| 
 |E     |       574| 
 |I     |       557| 
 |G     |       382| 
 |C     |       338| 
 |P     |       210| 
 |D     |       170| 
 |U     |       166| 
 |R     |       164| 
 |T     |       142| 
 |F     |       103| 
 |Q     |       101| 
 |O     |        74| 
 |X     |        64| 
 |Z     |        27| 
 |H     |        14| 
 |V     |         4| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### NTEEFINAL

::: 

::::: {.parent} 

::: {.div2} 

NTEEFINAL 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">factor</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">5</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
S41 · J40 · W30 · S80 · N50 · M24 · B83 · W80 · N60 · Y42 · Y50
Y41 · K28 · S20 · Y43 · S47 · B03 · L50 · W61 · N61 · Y40 · S03
Y20 · S30 · S01 · S40 · G90 · I03 · I0360 · N52 · S99 · A23 · S22
N67 · N6A · E11 · N68 · K20 · N69 · L99 · S46 · N32 · U42 · S21

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|    PER| 
 |:----------|------:|------:| 
 |Rows       | 25,000|       | 
 |Distinct   |    654| (2.6%)| 
 |Missing/NA |  1,497| (6.0%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/factor-5.pdf)




::: 

::: {.div9} 

**FACTOR LEVELS**:

|Label | Frequency| 
 |:-----|---------:| 
 |S41   |     1,947| 
 |J40   |     1,815| 
 |W30   |     1,582| 
 |S80   |     1,515| 
 |N50   |     1,088| 
 |M24   |       810| 
 |B83   |       771| 
 |W80   |       681| 
 |N60   |       600| 
 |Y42   |       514| 
 |Y50   |       484| 
 |Y41   |       453| 
 |K28   |       374| 
 |S20   |       371| 
 |Y43   |       355| 
 |S47   |       347| 
 |B03   |       346| 
 |L50   |       328| 
 |W61   |       270| 
 |N61   |       269| 
 |Y40   |       265| 
 |S03   |       236| 
 |Y20   |       236| 
 |S30   |       214| 
 |S01   |       201| 
 |S40   |       185| 
 |G90   |       173| 
 |I03   |       172| 
 |I0360 |       166| 
 |N52   |       146| 
 |S99   |       142| 
 |A23   |       138| 
 |S22   |       133| 
 |N67   |       129| 
 |N6A   |       124| 
 |E11   |       100| 
 |N68   |        98| 
 |K20   |        93| 
 |N69   |        92| 
 |L99   |        89| 
 |S46   |        89| 
 |N32   |        78| 
 |U42   |        77| 
 |S21   |        74| 
 |W20   |        72| 
 |T20   |        70| 
 |J22   |        68| 
 |C32   |        65| 
 |S81   |        64| 
 |E03   |        64| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### NTEESRC

::: 

::::: {.parent} 

::: {.div2} 

NTEESRC 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">factor</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">4</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
BEST · WORD · NEW · IRS · SOI · ZZ · SUB · SUB2 · SUB3 · ACT1 · VER
ntCO · HIED · END2 · thp

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|    PER| 
 |:----------|------:|------:| 
 |Rows       | 25,000|       | 
 |Distinct   |     16| (0.1%)| 
 |Missing/NA |  1,378| (5.5%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/factor-6.pdf)




::: 

::: {.div9} 

**FACTOR LEVELS**:

|Label | Frequency| 
 |:-----|---------:| 
 |BEST  |    12,410| 
 |WORD  |     4,000| 
 |NEW   |     2,621| 
 |IRS   |     2,540| 
 |SOI   |       855| 
 |ZZ    |       454| 
 |SUB   |       306| 
 |SUB2  |       140| 
 |SUB3  |        86| 
 |ACT1  |        84| 
 |VER   |        48| 
 |ntCO  |        46| 
 |HIED  |        19| 
 |END2  |        11| 
 |thp   |         2| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### DEDUCTCD

::: 

::::: {.parent} 

::: {.div2} 

DEDUCTCD 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">factor</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">1</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">IRS Deductibility code</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
2 · 1 · 0 · 4

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|    PER| 
 |:----------|------:|------:| 
 |Rows       | 25,000|       | 
 |Distinct   |      5| (0.0%)| 
 |Missing/NA |  1,887| (7.5%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/factor-7.pdf)




::: 

::: {.div9} 

**FACTOR LEVELS**:

|Label | Frequency| 
 |:-----|---------:| 
 |2     |    18,494| 
 |1     |     3,932| 
 |0     |       685| 
 |4     |         2| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### OUTREAS

::: 

::::: {.parent} 

::: {.div2} 

OUTREAS 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">factor</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">1</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Reason why out of scope</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
T · F · S · N

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|     PER| 
 |:----------|------:|-------:| 
 |Rows       | 25,000|        | 
 |Distinct   |      5|  (0.0%)| 
 |Missing/NA | 24,961| (99.8%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/factor-8.pdf)




::: 

::: {.div9} 

**FACTOR LEVELS**:

|Label | Frequency| 
 |:-----|---------:| 
 |T     |        15| 
 |F     |        12| 
 |S     |        11| 
 |N     |         1| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### F9_00_TAX_PERIOD_END_DATE

::: 

::::: {.parent} 

::: {.div2} 

F9_00_TAX_PERIOD_END_DATE 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">factor</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">7</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Tax period end date</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
2019-12 · 2018-12 · 2019-06 · 2017-12 · 2020-06 · 2018-06 · 2019-09
2019-08 · 2017-06 · 2019-03 · 2020-03 · 2019-05 · 2019-04 · 2019-10
2020-05 · 2018-09 · 2020-04 · 2019-07 · 2018-05 · 2018-08 · 2019-11
2017-09 · 2018-03 · 2018-04 · 2018-10 · 2020-07 · 2020-08 · 2020-09

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     |    VAL|    PER| 
 |:--------|------:|------:| 
 |Rows     | 25,000|       | 
 |Distinct |     47| (0.2%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/factor-9.pdf)




::: 

::: {.div9} 

**FACTOR LEVELS**:

|Label   | Frequency| 
 |:-------|---------:| 
 |2019-12 |     9,884| 
 |2018-12 |     3,477| 
 |2019-06 |     2,064| 
 |2017-12 |     1,626| 
 |2020-06 |     1,312| 
 |2018-06 |       840| 
 |2019-09 |       812| 
 |2019-08 |       406| 
 |2017-06 |       362| 
 |2019-03 |       356| 
 |2020-03 |       352| 
 |2019-05 |       326| 
 |2019-04 |       278| 
 |2019-10 |       272| 
 |2020-05 |       252| 
 |2018-09 |       244| 
 |2020-04 |       183| 
 |2019-07 |       161| 
 |2018-05 |       154| 
 |2018-08 |       139| 
 |2019-11 |       123| 
 |2017-09 |       121| 
 |2018-03 |       110| 
 |2018-04 |       102| 
 |2018-10 |        94| 
 |2020-07 |        91| 
 |2020-08 |        79| 
 |2020-09 |        74| 
 |2020-01 |        66| 
 |2018-07 |        65| 
 |2017-05 |        64| 
 |2017-08 |        64| 
 |2020-02 |        59| 
 |2019-02 |        57| 
 |2017-04 |        46| 
 |2017-10 |        46| 
 |2018-11 |        46| 
 |2019-01 |        34| 
 |2017-07 |        32| 
 |2018-02 |        32| 
 |2017-03 |        31| 
 |2017-11 |        25| 
 |2020-10 |        13| 
 |2018-01 |         9| 
 |2017-01 |         8| 
 |2017-02 |         8| 
 |2020-11 |         1| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### F9_00_TAX_PERIOD_END_DATE_PY

::: 

::::: {.parent} 

::: {.div2} 

F9_00_TAX_PERIOD_END_DATE_PY 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">factor</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">7</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Tax period end date - prior year</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
2018-12 · 2017-12 · 2018-06 · 2019-06 · 2018-09 · 2017-06 · 2016-12
2018-08 · 2018-03 · 2019-03 · 2018-05 · 2018-10 · 2018-04 · 2019-05
2017-09 · 2016-06 · 2019-04 · 2018-07 · 2018-11 · 2017-08 · 2017-05
2017-10 · 2017-04 · 2019-01 · 2019-07 · 2017-03 · 2019-02 · 2018-02

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|     PER| 
 |:----------|------:|-------:| 
 |Rows       | 25,000|        | 
 |Distinct   |     47|  (0.2%)| 
 |Missing/NA |  4,344| (17.4%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/factor-10.pdf)




::: 

::: {.div9} 

**FACTOR LEVELS**:

|Label   | Frequency| 
 |:-------|---------:| 
 |2018-12 |     9,298| 
 |2017-12 |     3,002| 
 |2018-06 |     1,767| 
 |2019-06 |     1,060| 
 |2018-09 |       744| 
 |2017-06 |       539| 
 |2016-12 |       478| 
 |2018-08 |       370| 
 |2018-03 |       321| 
 |2019-03 |       319| 
 |2018-05 |       265| 
 |2018-10 |       255| 
 |2018-04 |       246| 
 |2019-05 |       206| 
 |2017-09 |       195| 
 |2016-06 |       164| 
 |2019-04 |       162| 
 |2018-07 |       123| 
 |2018-11 |       122| 
 |2017-08 |       101| 
 |2017-05 |        90| 
 |2017-10 |        88| 
 |2017-04 |        64| 
 |2019-01 |        61| 
 |2019-07 |        58| 
 |2017-03 |        51| 
 |2019-02 |        49| 
 |2018-02 |        46| 
 |2019-08 |        44| 
 |2019-09 |        42| 
 |2017-11 |        41| 
 |2017-07 |        39| 
 |2016-05 |        36| 
 |2016-09 |        34| 
 |2018-01 |        29| 
 |2016-04 |        27| 
 |2016-08 |        23| 
 |2017-02 |        22| 
 |2016-03 |        18| 
 |2016-07 |        16| 
 |2016-10 |        13| 
 |2016-11 |         9| 
 |2019-10 |         7| 
 |2016-01 |         5| 
 |2016-02 |         4| 
 |2017-01 |         3| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### F9_00_TAX_ACCPER

::: 

::::: {.parent} 

::: {.div2} 

F9_00_TAX_ACCPER 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">factor</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">2</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Tax period end date</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
12 · 06 · 09 · 03 · 05 · 08 · 04 · 10 · 07 · 11 · 02 · 01

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     |    VAL|    PER| 
 |:--------|------:|------:| 
 |Rows     | 25,000|       | 
 |Distinct |     12| (0.0%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/factor-11.pdf)




::: 

::: {.div9} 

**FACTOR LEVELS**:

|Label | Frequency| 
 |:-----|---------:| 
 |12    |    14,987| 
 |06    |     4,578| 
 |09    |     1,251| 
 |03    |       849| 
 |05    |       796| 
 |08    |       688| 
 |04    |       609| 
 |10    |       425| 
 |07    |       349| 
 |11    |       195| 
 |02    |       156| 
 |01    |       117| 





::: 

:::::  

## Numeric 

{{< pagebreak >}} 

::: {.div1} 

#### COUNTY_FIPS

::: 

::::: {.parent} 

::: {.div2} 

COUNTY_FIPS 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">numeric</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v"> 5</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">State + County FIPS code</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
6037 · 17031 · 11001 · 36061 · 48201 · 53033 · 6067 · 42003 · 39049
6073 · 6059 · 25017 · 4013 · 27053 · 48113 · 36103 · 18097 · 48453
39035 · 36059 · 6085 · 6001 · 25025 · 51059 · 9003 · 36119 · 13121
26163 · 19153 · 26125 · 6075 · 9001 · 48439 · 42101 · 9009 · 17043

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|    PER| 
 |:----------|------:|------:| 
 |Rows       | 25,000|       | 
 |Distinct   |  2,411| (9.6%)| 
 |Missing/NA |  2,389| (9.6%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/numeric-1.pdf)




::: 

::: {.div9} 

**STATS**:

|   MIN|    MAX|      MEAN|   Q05|    Q25|    Q50|    Q75|    Q95|  SKEW| KURTOSIS| 
 |-----:|------:|---------:|-----:|------:|------:|------:|------:|-----:|--------:| 
 | 1,001| 78,030| 28,405.45| 6,019| 17,027| 27,163| 41,051| 53,033| -0.01|    -1.15| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### CEO_CENSUSTRACT

::: 

::::: {.parent} 

::: {.div2} 

CEO_CENSUSTRACT 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">numeric</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">11</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Census tract</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
11001010700 · 48201531700 · 6037294421 · 11001010100 · 11001005800
17031839100 · 6067001101 · 6073020809 · 48113020300 · 11001005900
18097391000 · 4013941000 · 51510201900 · 6085512100 · 36061016100
42003020100 · 48453000102 · 48453001100 · 6075011700 · 11001006202

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|     PER| 
 |:----------|------:|-------:| 
 |Rows       | 25,000|        | 
 |Distinct   | 14,265| (57.1%)| 
 |Missing/NA |  3,110| (12.4%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/numeric-2.pdf)




::: 

::: {.div9} 

**STATS**:

|           MIN|        MAX|           MEAN|           Q05|            Q25|            Q50|            Q75|            Q95|  SKEW| KURTOSIS| 
 |-------------:|----------:|--------------:|-------------:|--------------:|--------------:|--------------:|--------------:|-----:|--------:| 
 | 1,001,020,500| 5.6043e+10| 28,488,147,053| 6,029,003,250| 17,031,320,100| 28,012,950,350| 41,051,008,202| 53,033,008,055| -0.02|    -1.17| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### F9_08_REV_TOT_TOT

::: 

::::: {.parent} 

::: {.div2} 

F9_08_REV_TOT_TOT 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">numeric</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">10</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Total revenue - total</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
0 · 100 · 1000 · 250000 · 2000 · 2250 · 50 · 200 · 45000 · 4 · 1500
5000 · 6000 · 8800 · 25000 · 25500 · 75000 · 1e+05 · 101225 · 1 · 3
8 · 9 · 101 · 575 · 600 · 1200 · 1800 · 2074 · 2400 · 4125 · 5400
6800 · 9465 · 9500 · 10000 · 15000 · 19611 · 20000 · 20649 · 26873

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     |    VAL|     PER| 
 |:--------|------:|-------:| 
 |Rows     | 25,000|        | 
 |Distinct | 23,817| (95.3%)| 
 |Zero     |    413|  (1.7%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/numeric-3.pdf)




::: 

::: {.div9} 

**STATS**:

|         MIN|           MAX|      MEAN|     Q05|      Q25|     Q50|       Q75|       Q95|  SKEW| KURTOSIS| 
 |-----------:|-------------:|---------:|-------:|--------:|-------:|---------:|---------:|-----:|--------:| 
 | -61,467,591| 4,178,522,311| 3,740,777| 3,359.8| 51,012.5| 130,545| 441,954.5| 6,355,357| 44.03| 2,557.92| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### F9_10_ASSET_TOT_BOY

::: 

::::: {.parent} 

::: {.div2} 

F9_10_ASSET_TOT_BOY 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">numeric</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">11</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Total assets - beginning of year</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
0 · 1 · 300 · 161 · 1593 · 10571 · 20855 · 21915 · 43506 · 49481 · 2
97 · 212 · 219 · 343 · 388 · 500 · 718 · 1000 · 1020 · 1222 · 1535
1547 · 1607 · 1642 · 2155 · 2745 · 3068 · 3073 · 3087 · 3708 · 4412
4414 · 4612 · 5251 · 5501 · 5619 · 5761 · 6141 · 6267 · 6812 · 6865

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|     PER| 
 |:----------|------:|-------:| 
 |Rows       | 25,000|        | 
 |Distinct   | 20,195| (80.8%)| 
 |Missing/NA |  1,377|  (5.5%)| 
 |Zero       |  3,011| (12.0%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/numeric-4.pdf)




::: 

::: {.div9} 

**STATS**:

|     MIN|            MAX|       MEAN| Q05|      Q25|     Q50|       Q75|        Q95|  SKEW| KURTOSIS| 
 |-------:|--------------:|----------:|---:|--------:|-------:|---------:|----------:|-----:|--------:| 
 | -69,049| 11,226,543,829| 11,116,959|   0| 31,558.5| 169,734| 729,844.5| 13,488,117| 41.82| 2,117.75| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### F9_10_ASSET_TOT_EOY

::: 

::::: {.parent} 

::: {.div2} 

F9_10_ASSET_TOT_EOY 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">numeric</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">11</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Total assets - end of year</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
1 · 0 · 100 · 1000 · 15000 · 21 · 480 · 529 · 680 · 1257 · 1374
1932 · 2000 · 2076 · 2280 · 2680 · 2965 · 3000 · 10000 · 24731
24753 · 37977 · 40760 · 25 · 30 · 39 · 90 · 99 · 140 · 149 · 200
212 · 230 · 248 · 249 · 281 · 314 · 340 · 415 · 459 · 478 · 627

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     |    VAL|     PER| 
 |:--------|------:|-------:| 
 |Rows     | 25,000|        | 
 |Distinct | 24,122| (96.5%)| 
 |Zero     |    110|  (0.4%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/numeric-5.pdf)




::: 

::: {.div9} 

**STATS**:

|        MIN|            MAX|       MEAN|      Q05|       Q25|     Q50|     Q75|        Q95|  SKEW| KURTOSIS| 
 |----------:|--------------:|----------:|--------:|---------:|-------:|-------:|----------:|-----:|--------:| 
 | -1,119,570| 38,468,314,242| 13,755,826| 4,421.45| 55,668.25| 212,649| 837,286| 14,639,755| 85.67| 9,676.68| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### F9_10_NAFB_TOT_BOY

::: 

::::: {.parent} 

::: {.div2} 

F9_10_NAFB_TOT_BOY 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">numeric</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">10</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Net assets or fund balances - beginning of year</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
0 · 300 · 1593 · 8311 · 20855 · 24587 · 29596 · 56803 · -21474
-6426 · -989 · -826 · 97 · 161 · 212 · 334 · 388 · 500 · 718 · 1000
1020 · 1547 · 1642 · 2745 · 2870 · 3068 · 3073 · 3087 · 3306 · 3554
3708 · 4412 · 4414 · 4612 · 4772 · 5318 · 5501 · 5619 · 6141 · 6267

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|     PER| 
 |:----------|------:|-------:| 
 |Rows       | 25,000|        | 
 |Distinct   | 20,145| (80.6%)| 
 |Missing/NA |  4,344| (17.4%)| 
 |Zero       |    203|  (0.8%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/numeric-6.pdf)




::: 

::: {.div9} 

**STATS**:

|          MIN|           MAX|      MEAN|     Q05|      Q25|       Q50|       Q75|        Q95|  SKEW| KURTOSIS| 
 |------------:|-------------:|---------:|-------:|--------:|---------:|---------:|----------:|-----:|--------:| 
 | -333,005,908| 6,323,689,488| 4,921,982| 1,659.5| 52,689.5| 192,629.5| 720,262.5| 10,744,071| 61.69| 5,412.22| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### F9_09_EXP_TOT_TOT

::: 

::::: {.parent} 

::: {.div2} 

F9_09_EXP_TOT_TOT 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">numeric</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">10</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Total functional expenses - total expenses</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
0 · 100 · 1000 · 10 · 50 · 600 · 4056 · 7500 · 25 · 200 · 400 · 539
786 · 1140 · 5000 · 10000 · 11085 · 13669 · 16927 · 16993 · 19327
28348 · 36264 · 40526 · 45638 · 48401 · 50154 · 60157 · 62391
80427 · 83368 · 83437 · 105341 · 153299 · 41 · 60 · 129 · 130 · 143

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     |    VAL|     PER| 
 |:--------|------:|-------:| 
 |Rows     | 25,000|        | 
 |Distinct | 23,740| (95.0%)| 
 |Zero     |    489|  (2.0%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/numeric-7.pdf)




::: 

::: {.div9} 

**STATS**:

|     MIN|           MAX|      MEAN|      Q05|    Q25|       Q50|       Q75|       Q95|  SKEW| KURTOSIS| 
 |-------:|-------------:|---------:|--------:|------:|---------:|---------:|---------:|-----:|--------:| 
 | -11,719| 4,256,605,589| 3,531,376| 3,886.95| 46,845| 121,792.5| 411,837.2| 5,832,724| 46.21| 2,819.69| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### F9_01_EXP_TOT_PY

::: 

::::: {.parent} 

::: {.div2} 

F9_01_EXP_TOT_PY 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">numeric</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">10</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Total expenses - prior year</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
0 · 10 · 36 · 600 · 1450 · 2279 · 3200 · 4742 · 8214 · 14221 · 25853
32965 · 43809 · 44039 · 44951 · 54368 · 55199 · 56378 · 78821
126182 · 20 · 400 · 656 · 736 · 827 · 859 · 1220 · 1540 · 1938
2206 · 2487 · 2489 · 2505 · 2831 · 3371 · 3400 · 3433 · 3552 · 4500

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|     PER| 
 |:----------|------:|-------:| 
 |Rows       | 25,000|        | 
 |Distinct   | 19,931| (79.7%)| 
 |Missing/NA |  1,377|  (5.5%)| 
 |Zero       |  3,257| (13.0%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/numeric-8.pdf)




::: 

::: {.div9} 

**STATS**:

|        MIN|           MAX|      MEAN| Q05|    Q25|     Q50|       Q75|       Q95|  SKEW| KURTOSIS| 
 |----------:|-------------:|---------:|---:|------:|-------:|---------:|---------:|-----:|--------:| 
 | -5,437,471| 4,624,922,368| 3,407,085|   0| 29,933| 102,618| 362,012.5| 5,357,595| 48.26| 3,041.41| 





::: 

:::::  

## Character

{{< pagebreak >}} 

::: {.div1} 

#### F9_00_ORG_NAME_L1

::: 

::::: {.parent} 

::: {.div2} 

F9_00_ORG_NAME_L1 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">character</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">97</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Organization name line 1</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
AMERICAN LEGION · ROTARY INTERNATIONAL
BENEVOLENT &amp; PROTECTIVE ORDER OF ELKS OF THE USA
VETERANS OF FOREIGN WARS OF THE UNITED STATES DE
INTERNATIONAL ASSOCIATION OF LIONS CLUBS · KNIGHTS OF COLUMBUS

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|     PER| 
 |:----------|------:|-------:| 
 |Rows       | 25,000|        | 
 |Distinct   | 17,455| (69.8%)| 
 |Missing/NA |  1,378|  (5.5%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/character-1.pdf)




::: 

::: {.div9} 

**MOST COMMON VALUES**: 

|Value                                            | Frequency|    (%)| 
 |:------------------------------------------------|---------:|------:| 
 |AMERICAN LEGION                                  |       573| (2.3%)| 
 |ROTARY INTERNATIONAL                             |       493| (2.0%)| 
 |BENEVOLENT & PROTECTIVE ORDER OF ELKS OF THE USA |       302| (1.2%)| 
 |INTERNATIONAL ASSOCIATION OF LIONS CLUBS         |       250| (1.0%)| 
 |KNIGHTS OF COLUMBUS                              |       236| (0.9%)| 
 |FRATERNAL ORDER OF EAGLES                        |       195| (0.8%)| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### F0_00_ORG_CONTACT

::: 

::::: {.parent} 

::: {.div2} 

F0_00_ORG_CONTACT 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">character</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">33</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Contact person (from IRS files)</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
TREASURER · FINANCIAL SECRETARY · THE ORGANIZATION
SORORITY SOLUTIONS · WORTHY SECRETARY · COMMERCE · PEO TREASURER
PRESIDENT · SECRETARY · THE BANK OF NEW YORK MELLON · COMMANDER
SECRETARY TREASURER · AGRECORDS · SCIARABBA WALKER · AIPSO

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|     PER| 
 |:----------|------:|-------:| 
 |Rows       | 25,000|        | 
 |Distinct   | 10,990| (44.0%)| 
 |Missing/NA | 13,392| (53.6%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/character-2.pdf)




::: 

::: {.div9} 

**MOST COMMON VALUES**: 

|Value               | Frequency|    (%)| 
 |:-------------------|---------:|------:| 
 |TREASURER           |        67| (0.3%)| 
 |FINANCIAL SECRETARY |        66| (0.3%)| 
 |THE ORGANIZATION    |        44| (0.2%)| 
 |SORORITY SOLUTIONS  |        27| (0.1%)| 
 |WORTHY SECRETARY    |        24| (0.1%)| 
 |COMMERCE            |        18| (0.1%)| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### F9_00_ORG_ADDR_L1

::: 

::::: {.parent} 

::: {.div2} 

F9_00_ORG_ADDR_L1 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">character</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">35</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Organization street address line 1</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
9717 ELK GROVE FLORIN RD STE B · 1154 TOWN AND COUNTRY COMMONS DR
PO BOX 1 · PO BOX 2 · PO BOX 5 · PO BOX 66 · PO BOX 86 · PO BOX 111
PO BOX 217 · PO BOX 26 · PO BOX 6 · 695 PRO MED LN STE 300
PO BOX 187 · PO BOX 123 · PO BOX 40 · PO BOX 535007 · PO BOX 8

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|     PER| 
 |:----------|------:|-------:| 
 |Rows       | 25,000|        | 
 |Distinct   | 18,785| (75.1%)| 
 |Missing/NA |  1,378|  (5.5%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/character-3.pdf)




::: 

::: {.div9} 

**MOST COMMON VALUES**: 

|Value                            | Frequency|    (%)| 
 |:--------------------------------|---------:|------:| 
 |9717 ELK GROVE FLORIN RD STE B   |        37| (0.1%)| 
 |1154 TOWN AND COUNTRY COMMONS DR |        23| (0.1%)| 
 |PO BOX 1                         |        20| (0.1%)| 
 |PO BOX 2                         |        19| (0.1%)| 
 |PO BOX 5                         |        19| (0.1%)| 
 |PO BOX 66                        |        18| (0.1%)| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### F9_00_ORG_ADDR_CITY

::: 

::::: {.parent} 

::: {.div2} 

F9_00_ORG_ADDR_CITY 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">character</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v">22</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Organization city</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
WASHINGTON · NEW YORK · CHICAGO · HOUSTON · COLUMBUS · INDIANAPOLIS
SPRINGFIELD · SACRAMENTO · AUSTIN · LOS ANGELES · PITTSBURGH
ATLANTA · DALLAS · SAN FRANCISCO · SAN DIEGO · SEATTLE · PORTLAND
COLUMBIA · ALEXANDRIA · PHILADELPHIA · DENVER · SAINT LOUIS

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       |    VAL|     PER| 
 |:----------|------:|-------:| 
 |Rows       | 25,000|        | 
 |Distinct   |  5,986| (23.9%)| 
 |Missing/NA |  1,378|  (5.5%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/character-4.pdf)




::: 

::: {.div9} 

**MOST COMMON VALUES**: 

|Value        | Frequency|    (%)| 
 |:------------|---------:|------:| 
 |WASHINGTON   |       331| (1.3%)| 
 |NEW YORK     |       262| (1.0%)| 
 |CHICAGO      |       187| (0.7%)| 
 |HOUSTON      |       184| (0.7%)| 
 |COLUMBUS     |       143| (0.6%)| 
 |INDIANAPOLIS |       133| (0.5%)| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### EIN

::: 

::::: {.parent} 

::: {.div2} 

EIN 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">character</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v"> 9</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">EIN</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
010100593 · 010218055 · 010220588 · 010266289 · 010273431
010286963 · 010440702 · 010468398 · 010523313 · 010524078
010573723 · 010715375 · 010744517 · 010815981 · 010852125
010874048 · 010961458 · 016011483 · 016012302 · 016019950

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     |    VAL|     PER| 
 |:--------|------:|-------:| 
 |Rows     | 25,000|        | 
 |Distinct | 24,794| (99.2%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/character-5.pdf)




::: 

::: {.div9} 

**MOST COMMON VALUES**: 

|Value     | Frequency|    (%)| 
 |:---------|---------:|------:| 
 |010100593 |         2| (0.0%)| 
 |010218055 |         2| (0.0%)| 
 |010220588 |         2| (0.0%)| 
 |010266289 |         2| (0.0%)| 
 |010273431 |         2| (0.0%)| 
 |010286963 |         2| (0.0%)| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### F9_00_TAX_PERIOD_BEGIN_DATE

::: 

::::: {.parent} 

::: {.div2} 

F9_00_TAX_PERIOD_BEGIN_DATE 




::: 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">character</span></div>



<div class="dg-field"><span class="dg-k">SCOPE</span><span class="dg-v"></span></div>



<div class="dg-field"><span class="dg-k">LENGTH</span><span class="dg-v"> 6</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Tax period begin date</span></div>



<div class="dg-field"><span class="dg-k">LOCATION CODE</span><span class="dg-v"></span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
2019-0 · 2018-9 · 2018-0 · 2019-9 · 2017-9 · 2017-0 · 2016-9
2019-1 · 2020-0 · 2018-1 · 2017-1 · 2020-1

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     |    VAL|    PER| 
 |:--------|------:|------:| 
 |Rows     | 25,000|       | 
 |Distinct |     12| (0.0%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-pdf/character-6.pdf)




::: 

::: {.div9} 

**MOST COMMON VALUES**: 

|Value  | Frequency|     (%)| 
 |:------|---------:|-------:| 
 |2019-0 |     10190| (40.8%)| 
 |2018-9 |      4460| (17.8%)| 
 |2018-0 |      3580| (14.3%)| 
 |2019-9 |      2402|  (9.6%)| 
 |2017-9 |      1686|  (6.7%)| 
 |2017-0 |      1680|  (6.7%)| 





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
  margin-bottom: 1.2em;
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
  margin: 0.1em 0 0.2em 0;
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

/* mono cells in the properties (div7) and full-width (div9) tables */
.div7 td, .div9 td {
  font-family: var(--dg-mono);
  font-size: 0.85em;
}

.div7 table, .div9 table { margin-left: 2px; }

/* strip default table chrome; use tight cells + hairline row rules */
.table { width: auto; }
.table > tbody { border-top: none; }
.table > :not(caption) > * > * { padding: 0.05rem 0.6rem 0.05rem 0; }

tbody, tfoot, tr, td, th {
  border-color: inherit;
  border-style: none;
  border-width: 0;
}

.div7 tr, .div9 tr {
  border-bottom: 1px solid var(--dg-rule);
}
/* hide the header on the self-evident STAT/VAL/PER properties table ... */
.div7 th { display: none; }
/* ... but keep it on the full-width extra table, where the columns aren't
   self-evident (STATS names, factor LABEL/FREQUENCY/MEANING, most-common
   VALUE/FREQUENCY, logical category codes). */
.div9 th {
  font-family: var(--dg-sans);
  text-transform: uppercase;
  letter-spacing: 0.03em;
  font-size: 0.7em;
  font-weight: 700;
  color: var(--dg-label);
  text-align: left;
}

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
