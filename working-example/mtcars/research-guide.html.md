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
  dgf_file: 'DGF.xlsx'
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

#### vs

<p class="dg-vlabel">engine shape</p>

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">boolean</span></div>





<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">1</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Engine shape: 0 = V-shaped, 1 = straight (inline)</span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
0 · 1

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|    PER| 
 |:--------|---:|------:| 
 |Rows     |  32|       | 
 |Distinct |   2| (6.2%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/logical-1.png){width=672}




::: 

::: {.div9} 

**CATEGORY LABELS**:

|0            |1            | 
 |:------------|:------------| 
 |0 (V-shaped) |1 (straight) | 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### am

<p class="dg-vlabel">transmission</p>

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">boolean</span></div>





<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">1</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Transmission: 0 = automatic, 1 = manual</span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
0 · 1

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|    PER| 
 |:--------|---:|------:| 
 |Rows     |  32|       | 
 |Distinct |   2| (6.2%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/logical-2.png){width=672}




::: 

::: {.div9} 

**CATEGORY LABELS**:

|0             |1          | 
 |:-------------|:----------| 
 |0 (automatic) |1 (manual) | 





::: 

:::::  

## Factor

{{< pagebreak >}} 

::: {.div1} 

#### make

<p class="dg-vlabel">manufacturer</p>

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">categorical</span></div>





<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">8</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Car manufacturer, split from the mtcars row names</span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
Merc · Fiat · Hornet · Mazda · Toyota · AMC · Cadillac · Camaro
Chrysler · Datsun · Dodge · Duster · Ferrari · Ford · Honda
Lincoln · Lotus · Maserati · Pontiac · Porsche · Valiant · Volvo

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     |  32|        | 
 |Distinct |  22| (68.8%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/factor-1.png){width=672}




::: 

::: {.div9} 

**FACTOR LEVELS**:

| Frequency|     (%)|Label    | 
 |---------:|-------:|:--------| 
 |         7| (21.9%)|Merc     | 
 |         2|  (6.2%)|Fiat     | 
 |         2|  (6.2%)|Hornet   | 
 |         2|  (6.2%)|Mazda    | 
 |         2|  (6.2%)|Toyota   | 
 |         1|  (3.1%)|AMC      | 
 |         1|  (3.1%)|Cadillac | 
 |         1|  (3.1%)|Camaro   | 
 |         1|  (3.1%)|Chrysler | 
 |         1|  (3.1%)|Datsun   | 
 |         1|  (3.1%)|Dodge    | 
 |         1|  (3.1%)|Duster   | 
 |         1|  (3.1%)|Ferrari  | 
 |         1|  (3.1%)|Ford     | 
 |         1|  (3.1%)|Honda    | 
 |         1|  (3.1%)|Lincoln  | 
 |         1|  (3.1%)|Lotus    | 
 |         1|  (3.1%)|Maserati | 
 |         1|  (3.1%)|Pontiac  | 
 |         1|  (3.1%)|Porsche  | 
 |         1|  (3.1%)|Valiant  | 
 |         1|  (3.1%)|Volvo    | 





::: 

:::::  

## Numeric 

{{< pagebreak >}} 

::: {.div1} 

#### mpg

<p class="dg-vlabel">miles per gallon</p>

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">number</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">measurement</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">4</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Fuel economy in miles per (US) gallon</span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
10.4 · 15.2 · 19.2 · 21 · 21.4 · 22.8 · 30.4 · 13.3 · 14.3 · 14.7
15 · 15.5 · 15.8 · 16.4 · 17.3 · 17.8 · 18.1 · 18.7 · 19.7 · 21.5
24.4 · 26 · 27.3 · 32.4 · 33.9

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     |  32|        | 
 |Distinct |  25| (78.1%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/numeric-1.png){width=768}




::: 

::: {.div9} 

**STATS**:

|  MIN| Q05|   Q25|  Q50|  MEAN|  Q75|  Q95|  MAX| 
 |----:|---:|-----:|----:|-----:|----:|----:|----:| 
 | 10.4|  12| 15.43| 19.2| 20.09| 22.8| 31.3| 33.9| 



**DISTRIBUTION SHAPE**:

::: {.dg-shape}

|stat     |   num|interpretation | 
 |:--------|-----:|:--------------| 
 |Skew     |  0.61|MED            | 
 |Kurtosis | -0.37|LOW            | 


::: 




::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### cyl

<p class="dg-vlabel">cylinders</p>

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">number</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">rank</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">1</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Number of engine cylinders</span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
8 · 4 · 6

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|    PER| 
 |:--------|---:|------:| 
 |Rows     |  32|       | 
 |Distinct |   3| (9.4%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/numeric-2.png){width=768}




::: 

::: {.div9} 

**STATS**:

| MIN| Q05| Q25| Q50| MEAN| Q75| Q95| MAX| 
 |---:|---:|---:|---:|----:|---:|---:|---:| 
 |   4|   4|   4|   6| 6.19|   8|   8|   8| 



**DISTRIBUTION SHAPE**:

::: {.dg-shape}

|stat     |   num|interpretation | 
 |:--------|-----:|:--------------| 
 |Skew     | -0.17|LOW            | 
 |Kurtosis | -1.76|MED            | 


::: 




::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### disp

<p class="dg-vlabel">displacement (cu. in.)</p>

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">number</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">measurement</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">5</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Engine displacement in cubic inches</span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
275.8 · 160 · 167.6 · 360 · 71.1 · 75.7 · 78.7 · 79 · 95.1 · 108
120.1 · 120.3 · 121 · 140.8 · 145 · 146.7 · 225 · 258 · 301 · 304
318 · 350 · 351 · 400 · 440 · 460 · 472

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     |  32|        | 
 |Distinct |  27| (84.4%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/numeric-3.png){width=768}




::: 

::: {.div9} 

**STATS**:

|  MIN|   Q05|    Q25|   Q50|   MEAN| Q75| Q95| MAX| 
 |----:|-----:|------:|-----:|------:|---:|---:|---:| 
 | 71.1| 77.35| 120.83| 196.3| 230.72| 326| 449| 472| 



**DISTRIBUTION SHAPE**:

::: {.dg-shape}

|stat     |   num|interpretation | 
 |:--------|-----:|:--------------| 
 |Skew     |  0.38|LOW            | 
 |Kurtosis | -1.21|MED            | 


::: 




::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### hp

<p class="dg-vlabel">gross horsepower</p>

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">number</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">count</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">3</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Gross horsepower</span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
110 · 175 · 180 · 66 · 123 · 150 · 245 · 52 · 62 · 65 · 91 · 93 · 95
97 · 105 · 109 · 113 · 205 · 215 · 230 · 264 · 335

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     |  32|        | 
 |Distinct |  22| (68.8%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/numeric-4.png){width=768}




::: 

::: {.div9} 

**STATS**:

| MIN|   Q05|  Q25| Q50|   MEAN| Q75|    Q95| MAX| 
 |---:|-----:|----:|---:|------:|---:|------:|---:| 
 |  52| 63.65| 96.5| 123| 146.69| 180| 253.55| 335| 



**DISTRIBUTION SHAPE**:

::: {.dg-shape}

|stat     |   num|interpretation | 
 |:--------|-----:|:--------------| 
 |Skew     |  0.73|MED            | 
 |Kurtosis | -0.14|LOW            | 


::: 




::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### drat

<p class="dg-vlabel">rear axle ratio</p>

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">number</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">measurement</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">4</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Rear axle ratio</span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
3.07 · 3.92 · 2.76 · 3.08 · 3.15 · 3.9 · 4.08 · 4.22 · 2.93 · 3
3.21 · 3.23 · 3.54 · 3.62 · 3.69 · 3.7 · 3.73 · 3.77 · 3.85 · 4.11
4.43 · 4.93

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     |  32|        | 
 |Distinct |  22| (68.8%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/numeric-5.png){width=768}




::: 

::: {.div9} 

**STATS**:

|  MIN|  Q05|  Q25| Q50| MEAN|  Q75|  Q95|  MAX| 
 |----:|----:|----:|---:|----:|----:|----:|----:| 
 | 2.76| 2.85| 3.08| 3.7|  3.6| 3.92| 4.31| 4.93| 



**DISTRIBUTION SHAPE**:

::: {.dg-shape}

|stat     |   num|interpretation | 
 |:--------|-----:|:--------------| 
 |Skew     |  0.27|LOW            | 
 |Kurtosis | -0.71|LOW            | 


::: 




::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### wt

<p class="dg-vlabel">weight (1,000 lbs)</p>

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">number</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">measurement</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">5</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Vehicle weight in thousands of pounds</span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
3.44 · 3.57 · 1.513 · 1.615 · 1.835 · 1.935 · 2.14 · 2.2 · 2.32
2.465 · 2.62 · 2.77 · 2.78 · 2.875 · 3.15 · 3.17 · 3.19 · 3.215
3.435 · 3.46 · 3.52 · 3.73 · 3.78 · 3.84 · 3.845 · 4.07 · 5.25
5.345 · 5.424

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     |  32|        | 
 |Distinct |  29| (90.6%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/numeric-6.png){width=768}




::: 

::: {.div9} 

**STATS**:

|  MIN|  Q05|  Q25|  Q50| MEAN|  Q75|  Q95|  MAX| 
 |----:|----:|----:|----:|----:|----:|----:|----:| 
 | 1.51| 1.74| 2.58| 3.33| 3.22| 3.61| 5.29| 5.42| 



**DISTRIBUTION SHAPE**:

::: {.dg-shape}

|stat     |   num|interpretation | 
 |:--------|-----:|:--------------| 
 |Skew     |  0.42|LOW            | 
 |Kurtosis | -0.02|LOW            | 


::: 




::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### qsec

<p class="dg-vlabel">quarter-mile time (sec)</p>

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">number</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">measurement</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">5</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Fastest quarter-mile time from a standing start, in seconds</span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
17.02 · 18.9 · 14.5 · 14.6 · 15.41 · 15.5 · 15.84 · 16.46 · 16.7
16.87 · 16.9 · 17.05 · 17.3 · 17.4 · 17.42 · 17.6 · 17.82 · 17.98
18 · 18.3 · 18.52 · 18.6 · 18.61 · 19.44 · 19.47 · 19.9 · 20 · 20.01
20.22 · 22.9

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     |  32|        | 
 |Distinct |  30| (93.8%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/numeric-7.png){width=768}




::: 

::: {.div9} 

**STATS**:

|  MIN|   Q05|   Q25|   Q50|  MEAN|  Q75|  Q95|  MAX| 
 |----:|-----:|-----:|-----:|-----:|----:|----:|----:| 
 | 14.5| 15.05| 16.89| 17.71| 17.85| 18.9| 20.1| 22.9| 



**DISTRIBUTION SHAPE**:

::: {.dg-shape}

|stat     |  num|interpretation | 
 |:--------|----:|:--------------| 
 |Skew     | 0.37|LOW            | 
 |Kurtosis | 0.34|LOW            | 


::: 




::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### gear

<p class="dg-vlabel">forward gears</p>

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">number</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">rank</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">1</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Number of forward gears</span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
3 · 4 · 5

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|    PER| 
 |:--------|---:|------:| 
 |Rows     |  32|       | 
 |Distinct |   3| (9.4%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/numeric-8.png){width=768}




::: 

::: {.div9} 

**STATS**:

| MIN| Q05| Q25| Q50| MEAN| Q75| Q95| MAX| 
 |---:|---:|---:|---:|----:|---:|---:|---:| 
 |   3|   3|   3|   4| 3.69|   4|   5|   5| 



**DISTRIBUTION SHAPE**:

::: {.dg-shape}

|stat     |   num|interpretation | 
 |:--------|-----:|:--------------| 
 |Skew     |  0.53|MED            | 
 |Kurtosis | -1.07|MED            | 


::: 




::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### carb

<p class="dg-vlabel">carburetors</p>

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">number</span></div>





<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">1</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Number of carburetors</span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
2 · 4 · 1 · 3 · 6 · 8

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     |  32|        | 
 |Distinct |   6| (18.8%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/numeric-9.png){width=768}




::: 

::: {.div9} 

**STATS**:

| MIN| Q05| Q25| Q50| MEAN| Q75| Q95| MAX| 
 |---:|---:|---:|---:|----:|---:|---:|---:| 
 |   1|   1|   2|   2| 2.81|   4| 4.9|   8| 



**DISTRIBUTION SHAPE**:

::: {.dg-shape}

|stat     |  num|interpretation | 
 |:--------|----:|:--------------| 
 |Skew     | 1.05|HIGH           | 
 |Kurtosis | 1.26|MED            | 


::: 




::: 

:::::  

## Character



## Identifier

{{< pagebreak >}} 

::: {.div1} 

#### model

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">identifier</span></div>





<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">11</span></div>




::: 

::: {.div4} 


<div class="dg-field"><span class="dg-k">DESCRIPTION</span><span class="dg-v">Car model, split from the mtcars row names</span></div>




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
128 · 142E · 230 · 240D · 280 · 280C · 360 · 4 Drive · 450SE · 450SL
450SLC · 710 · 914-2 · Bora · Challenger · Civic · Continental
Corolla · Corona · Dino · Europa · Firebird · Fleetwood · Imperial
Javelin · Pantera L · RX4 · RX4 Wag · Sportabout · X1-9 · Z28

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT          | VAL|      PER| 
 |:-------------|---:|--------:| 
 |Rows          |  32|         | 
 |Distinct      |  32| (100.0%)| 
 |Missing/Empty |   1|   (3.1%)| 





::: 

::: {.div8} 

**MOST COMMON VALUES**: 

|Value | Frequency|    (%)| 
 |:-----|---------:|------:| 
 |128   |         1| (3.1%)| 
 |142E  |         1| (3.1%)| 
 |230   |         1| (3.1%)| 
 |240D  |         1| (3.1%)| 
 |280   |         1| (3.1%)| 
 |280C  |         1| (3.1%)| 





::: 

:::::  

## Temporal






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

/* Title row: variable name + its plain-language label on one line, sharing
   one full-width rule. Wraps the label under the name when space runs out. */
.div1 {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  column-gap: 0.9em;
  row-gap: 0.1em;
  border-bottom: 2px solid var(--dg-accent);
  /* extra top margin sets each variable's title apart from the block above */
  margin: 2em 0 0.6em 0;
  padding-bottom: 4px;
}

h4 {
  font-family: var(--dg-mono);   /* a variable name is code: show it as code */
  font-size: 1.55em;
  font-weight: 700;
  letter-spacing: 0;
  color: var(--dg-ink);
  margin: 0;
  overflow-wrap: anywhere;       /* very long names wrap, never overflow */
}

/* L2 - the plain-language variable label, beside the name */
.div1 .dg-vlabel {
  font-family: var(--dg-serif);
  font-size: 1.2em;
  font-style: italic;
  color: var(--dg-label);
  line-height: 1.3;
  margin: 0;
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
   label followed by flowing prose (e.g. DESCRIPTION). */
.dg-field .dg-k {
  font-family: var(--dg-sans);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  font-size: 0.72em;
  font-weight: 700;
}

/* div3 is a 1/3 grid cell: min-width 0 lets it shrink to its track, and long
   values (e.g. a semantic type like "percentage_change") wrap inside it rather
   than bleeding into the DESCRIPTION column. */
.div3 { min-width: 0; }
.div3 .dg-field {
  display: grid;
  grid-template-columns: 6.6em minmax(0, 1fr);
  align-items: baseline;
  column-gap: 0.5em;
  margin: 0 0 0.32em 0;
}
.div3 .dg-k { color: var(--dg-label); white-space: nowrap; }
.div3 .dg-v {
  font-family: var(--dg-mono);
  font-weight: 700;
  font-size: 0.92em;
  color: var(--dg-ink);
  min-width: 0;
  overflow-wrap: anywhere;
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

/* ==========================================================================
   Responsive: the three-column grid needs real width. Below ~640px (phones,
   split-screen or narrow windows) collapse it to a single column so every
   block stacks full-width, in source order. Without this a 1/3-width div3 is
   too thin to hold its 6.2em field label plus value, and the value bleeds
   across into the neighbouring cell.
   ========================================================================== */
@media (max-width: 640px) {
  .parent {
    grid-template-columns: 1fr;
    padding-left: 0;                /* reclaim the flush-left title indent */
  }
  /* span every cell across the single column (grid-column: span N would create
     phantom implicit columns); this keeps one full-width block per row. */
  .div1, .div2, .div3, .div4, .div5, .div6, .div7, .div8, .div9,
  .blank1, .blank2 { grid-column: 1 / -1; }
}

/* very narrow (small phones / long values): stack each field's label above its
   value so a long value can never overrun the fixed label column. */
@media (max-width: 400px) {
  .div3 .dg-field { grid-template-columns: 1fr; column-gap: 0; row-gap: 0.05em; }
}

@media print {
  body {
    display: table;
    table-layout: fixed;
    padding: 2.5cm 1.5cm 3cm 1.5cm;
    height: auto;
  }
} 
</style>


<!-- datagoodr-render-record {"datagoodr":"0.1.0","rendered_utc":"2026-10-28T07:12:09Z","r":"4.5.3","quarto":"1.8.25","dgf_file":"DGF.xlsx","dgf_hash":"a9872d22fd9f5413d70fa1e160d8dc27","dgf_variables":13} -->
