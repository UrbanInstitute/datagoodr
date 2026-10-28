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



## Factor

{{< pagebreak >}} 

::: {.div1} 

#### hair_color

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">categorical</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">geographic</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v"> 13</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
none · brown · black · white · blond · auburn · auburn, grey
auburn, white · blonde · brown, grey · grey

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       | VAL|     PER| 
 |:----------|---:|-------:| 
 |Rows       |  87|        | 
 |Distinct   |  12| (13.8%)| 
 |Missing/NA |   5|  (5.7%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/factor-1.png){width=672}




::: 

::: {.div9} 

**FACTOR LEVELS**:

| Frequency|     (%)|Label         | 
 |---------:|-------:|:-------------| 
 |        38| (43.7%)|none          | 
 |        18| (20.7%)|brown         | 
 |        13| (14.9%)|black         | 
 |         4|  (4.6%)|white         | 
 |         3|  (3.4%)|blond         | 
 |         1|  (1.1%)|auburn        | 
 |         1|  (1.1%)|auburn, grey  | 
 |         1|  (1.1%)|auburn, white | 
 |         1|  (1.1%)|blonde        | 
 |         1|  (1.1%)|brown, grey   | 
 |         1|  (1.1%)|grey          | 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### eye_color

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">categorical</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">geographic</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v"> 13</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
brown · blue · yellow · black · orange · red · hazel · unknown
blue-gray · dark · gold · green, yellow · pink · red, blue · white

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     |  87|        | 
 |Distinct |  15| (17.2%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/factor-2.png){width=672}




::: 

::: {.div9} 

**FACTOR LEVELS**:

| Frequency|     (%)|Label         | 
 |---------:|-------:|:-------------| 
 |        21| (24.1%)|brown         | 
 |        19| (21.8%)|blue          | 
 |        11| (12.6%)|yellow        | 
 |        10| (11.5%)|black         | 
 |         8|  (9.2%)|orange        | 
 |         5|  (5.7%)|red           | 
 |         3|  (3.4%)|hazel         | 
 |         3|  (3.4%)|unknown       | 
 |         1|  (1.1%)|blue-gray     | 
 |         1|  (1.1%)|dark          | 
 |         1|  (1.1%)|gold          | 
 |         1|  (1.1%)|green, yellow | 
 |         1|  (1.1%)|pink          | 
 |         1|  (1.1%)|red, blue     | 
 |         1|  (1.1%)|white         | 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### sex

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">categorical</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">unordered</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v"> 14</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
male · female · none · hermaphroditic

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       | VAL|    PER| 
 |:----------|---:|------:| 
 |Rows       |  87|       | 
 |Distinct   |   5| (5.7%)| 
 |Missing/NA |   4| (4.6%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/factor-3.png){width=672}




::: 

::: {.div9} 

**FACTOR LEVELS**:

| Frequency|     (%)|Label          | 
 |---------:|-------:|:--------------| 
 |        60| (69.0%)|male           | 
 |        16| (18.4%)|female         | 
 |         6|  (6.9%)|none           | 
 |         1|  (1.1%)|hermaphroditic | 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### gender

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">categorical</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">unordered</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">  9</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
masculine · feminine

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       | VAL|    PER| 
 |:----------|---:|------:| 
 |Rows       |  87|       | 
 |Distinct   |   3| (3.4%)| 
 |Missing/NA |   4| (4.6%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/factor-4.png){width=672}




::: 

::: {.div9} 

**FACTOR LEVELS**:

| Frequency|     (%)|Label     | 
 |---------:|-------:|:---------| 
 |        66| (75.9%)|masculine | 
 |        17| (19.5%)|feminine  | 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### homeworld

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">categorical</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">geographic</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v"> 14</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
Naboo · Tatooine · Alderaan · Coruscant · Kamino · Corellia
Kashyyyk · Mirial · Ryloth · Aleen Minor · Bespin · Bestine IV
Cato Neimoidia · Cerea · Champala · Chandrila · Concord Dawn
Dathomir · Dorin · Endor · Eriadu · Geonosis · Glee Anselm

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       | VAL|     PER| 
 |:----------|---:|-------:| 
 |Rows       |  87|        | 
 |Distinct   |  49| (56.3%)| 
 |Missing/NA |  10| (11.5%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/factor-5.png){width=672}




::: 

::: {.div9} 

**FACTOR LEVELS**:

| Frequency|     (%)|Label          | 
 |---------:|-------:|:--------------| 
 |        11| (12.6%)|Naboo          | 
 |        10| (11.5%)|Tatooine       | 
 |         3|  (3.4%)|Alderaan       | 
 |         3|  (3.4%)|Coruscant      | 
 |         3|  (3.4%)|Kamino         | 
 |         2|  (2.3%)|Corellia       | 
 |         2|  (2.3%)|Kashyyyk       | 
 |         2|  (2.3%)|Mirial         | 
 |         2|  (2.3%)|Ryloth         | 
 |         1|  (1.1%)|Aleen Minor    | 
 |         1|  (1.1%)|Bespin         | 
 |         1|  (1.1%)|Bestine IV     | 
 |         1|  (1.1%)|Cato Neimoidia | 
 |         1|  (1.1%)|Cerea          | 
 |         1|  (1.1%)|Champala       | 
 |         1|  (1.1%)|Chandrila      | 
 |         1|  (1.1%)|Concord Dawn   | 
 |         1|  (1.1%)|Dathomir       | 
 |         1|  (1.1%)|Dorin          | 
 |         1|  (1.1%)|Endor          | 
 |         1|  (1.1%)|Eriadu         | 
 |         1|  (1.1%)|Geonosis       | 
 |         1|  (1.1%)|Glee Anselm    | 
 |         1|  (1.1%)|Haruun Kal     | 
 |         1|  (1.1%)|Iktotch        | 
 |         1|  (1.1%)|Iridonia       | 
 |         1|  (1.1%)|Kalee          | 
 |         1|  (1.1%)|Malastare      | 
 |         1|  (1.1%)|Mon Cala       | 
 |         1|  (1.1%)|Muunilinst     | 
 |         1|  (1.1%)|Nal Hutta      | 
 |         1|  (1.1%)|Ojom           | 
 |         1|  (1.1%)|Quermia        | 
 |         1|  (1.1%)|Rodia          | 
 |         1|  (1.1%)|Serenno        | 
 |         1|  (1.1%)|Shili          | 
 |         1|  (1.1%)|Skako          | 
 |         1|  (1.1%)|Socorro        | 
 |         1|  (1.1%)|Stewjon        | 
 |         1|  (1.1%)|Sullust        | 
 |         1|  (1.1%)|Toydaria       | 
 |         1|  (1.1%)|Trandosha      | 
 |         1|  (1.1%)|Troiken        | 
 |         1|  (1.1%)|Tund           | 
 |         1|  (1.1%)|Umbara         | 
 |         1|  (1.1%)|Utapau         | 
 |         1|  (1.1%)|Vulpter        | 
 |         1|  (1.1%)|Zolan          | 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### films

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">categorical</span></div>





<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">131</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
Attack of the Clones · The Phantom Menace
A New Hope|The Empire Strikes Back|Return of the
The Phantom Menace|Attack of the Clones|Revenge
Attack of the Clones|Revenge of the Sith · Return of the Jedi

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     |  87|        | 
 |Distinct |  24| (27.6%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/factor-6.png){width=672}




::: 

::: {.div9} 

**FACTOR LEVELS**:

| Frequency|     (%)|Label                                                                                                                                                             | 
 |---------:|-------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------| 
 |        13| (14.9%)|Attack of the Clones                                                                                                                                              | 
 |        13| (14.9%)|The Phantom Menace                                                                                                                                                | 
 |         8|  (9.2%)|The Phantom Menace&#124;Attack of the Clones&#124;Revenge of the Sith                                                                                             | 
 |         7|  (8.0%)|Attack of the Clones&#124;Revenge of the Sith                                                                                                                     | 
 |         5|  (5.7%)|Return of the Jedi                                                                                                                                                | 
 |         5|  (5.7%)|The Force Awakens                                                                                                                                                 | 
 |         4|  (4.6%)|A New Hope                                                                                                                                                        | 
 |         4|  (4.6%)|The Phantom Menace&#124;Attack of the Clones                                                                                                                      | 
 |         3|  (3.4%)|A New Hope&#124;The Empire Strikes Back&#124;Return of the Jedi&#124;Revenge of the Sith&#124;The Force Awakens                                                   | 
 |         3|  (3.4%)|Revenge of the Sith                                                                                                                                               | 
 |         3|  (3.4%)|The Empire Strikes Back                                                                                                                                           | 
 |         3|  (3.4%)|The Phantom Menace&#124;Revenge of the Sith                                                                                                                       | 
 |         2|  (2.3%)|A New Hope&#124;Attack of the Clones&#124;Revenge of the Sith                                                                                                     | 
 |         2|  (2.3%)|A New Hope&#124;Revenge of the Sith                                                                                                                               | 
 |         2|  (2.3%)|A New Hope&#124;The Empire Strikes Back&#124;Return of the Jedi&#124;The Phantom Menace&#124;Attack of the Clones&#124;Revenge of the Sith                        | 
 |         2|  (2.3%)|The Empire Strikes Back&#124;Return of the Jedi&#124;The Phantom Menace&#124;Attack of the Clones&#124;Revenge of the Sith                                        | 
 |         1|  (1.1%)|A New Hope&#124;Return of the Jedi&#124;The Phantom Menace                                                                                                        | 
 |         1|  (1.1%)|A New Hope&#124;The Empire Strikes Back&#124;Return of the Jedi                                                                                                   | 
 |         1|  (1.1%)|A New Hope&#124;The Empire Strikes Back&#124;Return of the Jedi&#124;Revenge of the Sith                                                                          | 
 |         1|  (1.1%)|A New Hope&#124;The Empire Strikes Back&#124;Return of the Jedi&#124;The Force Awakens                                                                            | 
 |         1|  (1.1%)|A New Hope&#124;The Empire Strikes Back&#124;Return of the Jedi&#124;The Phantom Menace&#124;Attack of the Clones&#124;Revenge of the Sith&#124;The Force Awakens | 
 |         1|  (1.1%)|Return of the Jedi&#124;The Force Awakens                                                                                                                         | 
 |         1|  (1.1%)|The Empire Strikes Back&#124;Return of the Jedi                                                                                                                   | 
 |         1|  (1.1%)|The Empire Strikes Back&#124;Return of the Jedi&#124;Attack of the Clones                                                                                         | 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### vehicles

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">categorical</span></div>





<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v"> 35</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
Tribubble bongo · AT-ST · Flitknot speeder · Imperial Speeder Bike
Koro-2 Exodrive airspeeder · Sith speeder · Snowspeeder
Snowspeeder|Imperial Speeder Bike · Tsmeu-6 personal wheel bike
Zephyr-G swoop bike|XJ-6 airspeeder

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       | VAL|     PER| 
 |:----------|---:|-------:| 
 |Rows       |  87|        | 
 |Distinct   |  11| (12.6%)| 
 |Missing/NA |  76| (87.4%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/factor-7.png){width=672}




::: 

::: {.div9} 

**FACTOR LEVELS**:

| Frequency|    (%)|Label                                    | 
 |---------:|------:|:----------------------------------------| 
 |         2| (2.3%)|Tribubble bongo                          | 
 |         1| (1.1%)|AT-ST                                    | 
 |         1| (1.1%)|Flitknot speeder                         | 
 |         1| (1.1%)|Imperial Speeder Bike                    | 
 |         1| (1.1%)|Koro-2 Exodrive airspeeder               | 
 |         1| (1.1%)|Sith speeder                             | 
 |         1| (1.1%)|Snowspeeder                              | 
 |         1| (1.1%)|Snowspeeder&#124;Imperial Speeder Bike   | 
 |         1| (1.1%)|Tsmeu-6 personal wheel bike              | 
 |         1| (1.1%)|Zephyr-G swoop bike&#124;XJ-6 airspeeder | 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### starships

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">categorical</span></div>





<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">100</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
X-wing · Millennium Falcon · Millennium Falcon|Imperial shuttle
A-wing · Belbullab-22 starfighter · Jedi starfighter
Jedi starfighter|Trade Federation cruiser|Naboo · Naboo fighter
Naboo fighter|H-type Nubian yacht|Naboo star ski

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       | VAL|     PER| 
 |:----------|---:|-------:| 
 |Rows       |  87|        | 
 |Distinct   |  16| (18.4%)| 
 |Missing/NA |  67| (77.0%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/factor-8.png){width=672}




::: 

::: {.div9} 

**FACTOR LEVELS**:

| Frequency|    (%)|Label                                                                                                                    | 
 |---------:|------:|:------------------------------------------------------------------------------------------------------------------------| 
 |         4| (4.6%)|X-wing                                                                                                                   | 
 |         2| (2.3%)|Millennium Falcon                                                                                                        | 
 |         2| (2.3%)|Millennium Falcon&#124;Imperial shuttle                                                                                  | 
 |         1| (1.1%)|A-wing                                                                                                                   | 
 |         1| (1.1%)|Belbullab-22 starfighter                                                                                                 | 
 |         1| (1.1%)|Jedi starfighter                                                                                                         | 
 |         1| (1.1%)|Jedi starfighter&#124;Trade Federation cruiser&#124;Naboo star skiff&#124;Jedi Interceptor&#124;Belbullab-22 starfighter | 
 |         1| (1.1%)|Naboo fighter                                                                                                            | 
 |         1| (1.1%)|Naboo fighter&#124;H-type Nubian yacht&#124;Naboo star skiff                                                             | 
 |         1| (1.1%)|Naboo fighter&#124;Trade Federation cruiser&#124;Jedi Interceptor                                                        | 
 |         1| (1.1%)|Naboo Royal Starship                                                                                                     | 
 |         1| (1.1%)|Scimitar                                                                                                                 | 
 |         1| (1.1%)|Slave 1                                                                                                                  | 
 |         1| (1.1%)|TIE Advanced x1                                                                                                          | 
 |         1| (1.1%)|X-wing&#124;Imperial shuttle                                                                                             | 





::: 

:::::  

## Numeric 

{{< pagebreak >}} 

::: {.div1} 

#### height

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">number</span></div>





<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">3</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
183 · 180 · 188 · 170 · 178 · 175 · 191 · 193 · 196 · 96 · 150 · 163
165 · 167 · 185 · 198 · 206 · 66 · 79 · 88 · 94 · 97 · 112 · 122
137 · 157 · 160 · 166 · 168 · 171 · 172 · 173 · 177 · 182 · 184
190 · 200 · 202 · 213 · 216 · 224 · 228 · 229 · 234 · 264

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       | VAL|     PER| 
 |:----------|---:|-------:| 
 |Rows       |  87|        | 
 |Distinct   |  46| (52.9%)| 
 |Missing/NA |   6|  (6.9%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/numeric-1.png){width=768}




::: 

::: {.div9} 

**STATS**:

| MIN| Q05| Q25| Q50|  MEAN| Q75| Q95| MAX| 
 |---:|---:|---:|---:|-----:|---:|---:|---:| 
 |  66|  96| 167| 180| 174.6| 191| 224| 264| 



**DISTRIBUTION SHAPE**:

::: {.dg-shape}

|stat     |   num|interpretation | 
 |:--------|-----:|:--------------| 
 |Skew     | -1.05|HIGH           | 
 |Kurtosis |   1.8|MED            | 


::: 




::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### mass

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">number</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">measurement</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">4</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
80 · 79 · 75 · 77 · 84 · 32 · 45 · 48 · 50 · 55 · 82 · 136 · 15 · 17
20 · 40 · 49 · 56.2 · 57 · 65 · 66 · 68 · 74 · 78.2 · 83 · 85 · 87
88 · 89 · 90 · 102 · 110 · 112 · 113 · 120 · 140 · 159 · 1358

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       | VAL|     PER| 
 |:----------|---:|-------:| 
 |Rows       |  87|        | 
 |Distinct   |  39| (44.8%)| 
 |Missing/NA |  28| (32.2%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/numeric-2.png){width=768}




::: 

::: {.div9} 

**STATS**:

| MIN|  Q05|  Q25| Q50|  MEAN|  Q75|   Q95|   MAX| 
 |---:|----:|----:|---:|-----:|----:|-----:|-----:| 
 |  15| 30.8| 55.6|  79| 97.31| 84.5| 136.4| 1,358| 



**DISTRIBUTION SHAPE**:

::: {.dg-shape}

|stat     |   num|interpretation | 
 |:--------|-----:|:--------------| 
 |Skew     |  6.97|HIGH           | 
 |Kurtosis | 48.93|HIGH           | 


::: 




::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### birth_year

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">number</span></div>





<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">4</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
19 · 41.9 · 48 · 52 · 72 · 82 · 92 · 8 · 15 · 21 · 22 · 24 · 29 · 31
31.5 · 33 · 37 · 40 · 41 · 44 · 46 · 47 · 53 · 54 · 57 · 58 · 62
64 · 66 · 67 · 91 · 102 · 112 · 200 · 600 · 896

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       | VAL|     PER| 
 |:----------|---:|-------:| 
 |Rows       |  87|        | 
 |Distinct   |  37| (42.5%)| 
 |Missing/NA |  44| (50.6%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/numeric-3.png){width=768}




::: 

::: {.div9} 

**STATS**:

| MIN| Q05| Q25| Q50|  MEAN| Q75|   Q95| MAX| 
 |---:|---:|---:|---:|-----:|---:|-----:|---:| 
 |   8|  19|  35|  52| 87.57|  72| 191.2| 896| 



**DISTRIBUTION SHAPE**:

::: {.dg-shape}

|stat     |   num|interpretation | 
 |:--------|-----:|:--------------| 
 |Skew     |  4.15|HIGH           | 
 |Kurtosis | 17.17|HIGH           | 


::: 




::: 

:::::  

## Character

{{< pagebreak >}} 

::: {.div1} 

#### name

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">text</span></div>



<div class="dg-field"><span class="dg-k">DATA TYPE</span><span class="dg-v">organization</span></div>




<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">21</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
Ackbar · Adi Gallia · Anakin Skywalker · Arvel Crynyd · Ayla Secura
Bail Prestor Organa · Barriss Offee · BB8 · Ben Quadinaros
Beru Whitesun Lars · Bib Fortuna · Biggs Darklighter · Boba Fett
Bossk · C-3PO · Captain Phasma · Chewbacca · Cliegg Lars · Cordé

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|      PER| 
 |:--------|---:|--------:| 
 |Rows     |  87|         | 
 |Distinct |  87| (100.0%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/character-1.png){width=768}




::: 

::: {.div9} 

**MOST COMMON VALUES**: 

|Value               | Frequency|    (%)| 
 |:-------------------|---------:|------:| 
 |Ackbar              |         1| (1.1%)| 
 |Adi Gallia          |         1| (1.1%)| 
 |Anakin Skywalker    |         1| (1.1%)| 
 |Arvel Crynyd        |         1| (1.1%)| 
 |Ayla Secura         |         1| (1.1%)| 
 |Bail Prestor Organa |         1| (1.1%)| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### skin_color

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">text</span></div>





<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">19</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
fair · light · dark · green · grey · pale · brown · blue
blue, grey · none · orange · tan · white · white, blue · yellow
brown mottle · brown, white · fair, green, yellow · gold
green-tan, brown · green, grey · grey, blue · grey, green, yellow

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT     | VAL|     PER| 
 |:--------|---:|-------:| 
 |Rows     |  87|        | 
 |Distinct |  31| (35.6%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/character-2.png){width=768}




::: 

::: {.div9} 

**MOST COMMON VALUES**: 

|Value | Frequency|     (%)| 
 |:-----|---------:|-------:| 
 |fair  |        17| (19.5%)| 
 |light |        11| (12.6%)| 
 |dark  |         6|  (6.9%)| 
 |green |         6|  (6.9%)| 
 |grey  |         6|  (6.9%)| 
 |pale  |         5|  (5.7%)| 





::: 

:::::  





{{< pagebreak >}} 

::: {.div1} 

#### species

::: 

::::: {.parent} 

::: {.div3} 


<div class="dg-field"><span class="dg-k">DATA MODE</span><span class="dg-v">text</span></div>





<div class="dg-field"><span class="dg-k">MAX NCHAR</span><span class="dg-v">14</span></div>




::: 

::: {.div4} 




::: 

::: {.div5} 

**PREVIEW**:




::: 

::: {.div6} 

<pre class="dg-preview">
Human · Droid · Gungan · Kaminoan · Mirialan · Twi'lek · Wookiee
Zabrak · Aleena · Besalisk · Cerean · Chagrian · Clawdite · Dug
Ewok · Geonosian · Hutt · Iktotchi · Kaleesh · Kel Dor
Mon Calamari · Muun · Nautolan · Neimodian · Pau'an · Quermian

</pre>




::: 

::: {.div7} 

**PROPERTIES**: 

|STAT       | VAL|     PER| 
 |:----------|---:|-------:| 
 |Rows       |  87|        | 
 |Distinct   |  38| (43.7%)| 
 |Missing/NA |   4|  (4.6%)| 





::: 

::: {.div8} 

![](research-guide_files/figure-html/character-3.png){width=768}




::: 

::: {.div9} 

**MOST COMMON VALUES**: 

|Value    | Frequency|     (%)| 
 |:--------|---------:|-------:| 
 |Human    |        35| (40.2%)| 
 |Droid    |         6|  (6.9%)| 
 |Gungan   |         3|  (3.4%)| 
 |Kaminoan |         2|  (2.3%)| 
 |Mirialan |         2|  (2.3%)| 
 |Twi'lek  |         2|  (2.3%)| 





::: 

:::::  

## Identifier



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


<!-- datagoodr-render-record {"datagoodr":"0.1.0","rendered_utc":"2026-10-28T07:05:24Z","r":"4.5.3","quarto":"1.8.25","dgf_file":"DGF.xlsx","dgf_hash":"79c740edf2df783c6e4bb613d91d46f1","dgf_variables":14} -->
