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
---





<br>

## Header 2

Test TOC

### Header 3

Some more text

## Header 2 


<br><br>













## Histogram Styles




::: {.cell}
::: {.cell-output-display}
![](RG_files/figure-html/unnamed-chunk-3-1.png){width=768}
:::
:::

::: {.cell}
::: {.cell-output-display}
![](RG_files/figure-html/unnamed-chunk-4-1.png){width=768}
:::
:::






<br>

<hr>

<br>







```{.r .cell-code}
#seperate out numberic factor just for testing purposes
dgf.factor <- dgf[6:15,  ]
create_all_sections( dgf.factor )
```


{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### SUBSECCD

::: 

::: {.div2} 

**LABEL**: SUBSECCD




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: IRS subsection code




::: 

::: {.div12} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        |     23| 
 |Distinct (%)        |      0| 
 |Duplicates (%)      |      1| 
 |Most Common Value   |      6| 
 |Most Common Val (%) |   0.26| 
 |Zero (N)            |      0| 
 |Zero (%)            |      0| 
 |All Empty (N)       |      0| 
 |Missing/NA (N)      |      0| 
 |Missing/NA (%)      |      0| 
 |Infinite (N)        |      0| 





::: 

::: {.div13} 

**MOST COMMON VALUES**: 

| Value| Frequency| 
 |-----:|---------:| 
 |     6|      6391| 
 |     4|      4936| 
 |     7|      3571| 
 |     5|      3449| 
 |     8|      1479| 
 |    19|      1459| 





::: 

::: {.div14} 

**TREEMAP**: 

![](RG_files/figure-html/unnamed-chunk-7-1.png){width=672}




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### BMF_ACTIV1

::: 

::: {.div2} 

**LABEL**: ACTIV1




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: IRS Activity Code 1




::: 

::: {.div12} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        |    230| 
 |Distinct (%)        |   0.01| 
 |Duplicates (%)      |   0.99| 
 |Most Common Value   |      0| 
 |Most Common Val (%) |   0.23| 
 |Zero (N)            |  5,807| 
 |Zero (%)            |   0.23| 
 |All Empty (N)       |  1,887| 
 |Missing/NA (N)      |  1,887| 
 |Missing/NA (%)      |   0.08| 
 |Infinite (N)        |      0| 





::: 

::: {.div13} 

**MOST COMMON VALUES**: 

| Value| Frequency| 
 |-----:|---------:| 
 |     0|      5807| 
 |   263|      1782| 
 |   200|      1648| 
 |   907|      1212| 
 |    36|      1054| 
 |   279|       998| 





::: 

::: {.div14} 

**TREEMAP**: 

![](RG_files/figure-html/unnamed-chunk-7-2.png){width=672}




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### NTMAJ12

::: 

::: {.div2} 

**LABEL**: NTMAJ12




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: NTEE major group (12)




::: 

::: {.div12} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        |      1| 
 |Distinct (%)        |      0| 
 |Duplicates (%)      |      1| 
 |Most Common Value   |      2| 
 |Most Common Val (%) |      1| 
 |Zero (N)            |      0| 
 |Zero (%)            |      0| 
 |All Empty (N)       |      0| 
 |Missing/NA (N)      |      0| 
 |Missing/NA (%)      |      0| 
 |Infinite (N)        |      0| 





::: 

::: {.div13} 

**MOST COMMON VALUES**: 

| Value| Frequency| 
 |-----:|---------:| 
 |    PU|      9128| 
 |    HU|      7955| 
 |    MU|      2480| 
 |    ED|      1528| 
 |    UN|      1524| 
 |    HE|       994| 





::: 

::: {.div14} 

**TREEMAP**: 

![](RG_files/figure-html/unnamed-chunk-7-3.png){width=672}




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### NTEE1

::: 

::: {.div2} 

**LABEL**: NTEE1




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: NTEE major group




::: 

::: {.div12} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        |      2| 
 |Distinct (%)        |      0| 
 |Duplicates (%)      |      1| 
 |Most Common Value   |      1| 
 |Most Common Val (%) |   0.94| 
 |Zero (N)            |      0| 
 |Zero (%)            |      0| 
 |All Empty (N)       |  1,497| 
 |Missing/NA (N)      |  1,497| 
 |Missing/NA (%)      |   0.06| 
 |Infinite (N)        |      0| 





::: 

::: {.div13} 

**MOST COMMON VALUES**: 

| Value| Frequency| 
 |-----:|---------:| 
 |     S|      5817| 
 |     N|      3018| 
 |     W|      2835| 
 |     Y|      2480| 
 |     J|      1961| 
 |     B|      1552| 





::: 

::: {.div14} 

**TREEMAP**: 

![](RG_files/figure-html/unnamed-chunk-7-4.png){width=672}




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### NTEEFINAL

::: 

::: {.div2} 

**LABEL**: NTEEFINAL




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: NA




::: 

::: {.div12} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        |      4| 
 |Distinct (%)        |      0| 
 |Duplicates (%)      |      1| 
 |Most Common Value   |      3| 
 |Most Common Val (%) |    0.9| 
 |Zero (N)            |      0| 
 |Zero (%)            |      0| 
 |All Empty (N)       |  1,497| 
 |Missing/NA (N)      |  1,497| 
 |Missing/NA (%)      |   0.06| 
 |Infinite (N)        |      0| 





::: 

::: {.div13} 

**MOST COMMON VALUES**: 

| Value| Frequency| 
 |-----:|---------:| 
 |   S41|      1947| 
 |   J40|      1815| 
 |   W30|      1582| 
 |   S80|      1515| 
 |   N50|      1088| 
 |   M24|       810| 





::: 

::: {.div14} 

**TREEMAP**: 

![](RG_files/figure-html/unnamed-chunk-7-5.png){width=672}




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### NTEESRC

::: 

::: {.div2} 

**LABEL**: NTEESRC




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: NA




::: 

::: {.div12} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        |      4| 
 |Distinct (%)        |      0| 
 |Duplicates (%)      |      1| 
 |Most Common Value   |      4| 
 |Most Common Val (%) |   0.67| 
 |Zero (N)            |      0| 
 |Zero (%)            |      0| 
 |All Empty (N)       |  1,378| 
 |Missing/NA (N)      |  1,378| 
 |Missing/NA (%)      |   0.06| 
 |Infinite (N)        |      0| 





::: 

::: {.div13} 

**MOST COMMON VALUES**: 

| Value| Frequency| 
 |-----:|---------:| 
 |  BEST|     12410| 
 |  WORD|      4000| 
 |   NEW|      2621| 
 |   IRS|      2540| 
 |   SOI|       855| 
 |    ZZ|       454| 





::: 

::: {.div14} 

**TREEMAP**: 

![](RG_files/figure-html/unnamed-chunk-7-6.png){width=672}




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### DEDUCTCD

::: 

::: {.div2} 

**LABEL**: DEDUCTCD




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: IRS Deductibility code




::: 

::: {.div12} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        |      5| 
 |Distinct (%)        |      0| 
 |Duplicates (%)      |      1| 
 |Most Common Value   |      2| 
 |Most Common Val (%) |   0.74| 
 |Zero (N)            |    685| 
 |Zero (%)            |   0.03| 
 |All Empty (N)       |  1,887| 
 |Missing/NA (N)      |  1,887| 
 |Missing/NA (%)      |   0.08| 
 |Infinite (N)        |      0| 





::: 

::: {.div13} 

**MOST COMMON VALUES**: 

| Value| Frequency| 
 |-----:|---------:| 
 |     2|     18494| 
 |     1|      3932| 
 |     0|       685| 
 |     4|         2| 





::: 

::: {.div14} 

**TREEMAP**: 

![](RG_files/figure-html/unnamed-chunk-7-7.png){width=672}




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### OUTREAS

::: 

::: {.div2} 

**LABEL**: OUTREAS




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: Reason why out of scope




::: 

::: {.div12} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        |      2| 
 |Distinct (%)        |      0| 
 |Duplicates (%)      |      1| 
 |Most Common Value   |     NA| 
 |Most Common Val (%) |      1| 
 |Zero (N)            |      0| 
 |Zero (%)            |      0| 
 |All Empty (N)       | 24,961| 
 |Missing/NA (N)      | 24,961| 
 |Missing/NA (%)      |      1| 
 |Infinite (N)        |      0| 





::: 

::: {.div13} 

**MOST COMMON VALUES**: 

| Value| Frequency| 
 |-----:|---------:| 
 |     T|        15| 
 |     F|        12| 
 |     S|        11| 
 |     N|         1| 





::: 

::: {.div14} 

**TREEMAP**: 

![](RG_files/figure-html/unnamed-chunk-7-8.png){width=672}




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_05_UBIZ_IMCOME_OVER_LIMIT_X

::: 

::: {.div2} 

**LABEL**: Q78A




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: Had unrelated business gross income of $1,000 or more [x]




::: 

::: {.div12} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        |      1| 
 |Distinct (%)        |      0| 
 |Duplicates (%)      |      1| 
 |Most Common Value   |      1| 
 |Most Common Val (%) |      1| 
 |Zero (N)            |      0| 
 |Zero (%)            |      0| 
 |All Empty (N)       |      0| 
 |Missing/NA (N)      |      0| 
 |Missing/NA (%)      |      0| 
 |Infinite (N)        |      0| 





::: 

::: {.div13} 

**MOST COMMON VALUES**: 

| Value| Frequency| 
 |-----:|---------:| 
 |     N|     21550| 
 |     Y|      3450| 





::: 

::: {.div14} 

**TREEMAP**: 

![](RG_files/figure-html/unnamed-chunk-7-9.png){width=672}




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### OUTNCCS

::: 

::: {.div2} 

**LABEL**: OUTNCCS




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: Out of Scope flag




::: 

::: {.div12} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        |      3| 
 |Distinct (%)        |      0| 
 |Duplicates (%)      |      1| 
 |Most Common Value   |      2| 
 |Most Common Val (%) |    0.9| 
 |Zero (N)            |      0| 
 |Zero (%)            |      0| 
 |All Empty (N)       |  2,361| 
 |Missing/NA (N)      |  2,361| 
 |Missing/NA (%)      |   0.09| 
 |Infinite (N)        |      0| 





::: 

::: {.div13} 

**MOST COMMON VALUES**: 

| Value| Frequency| 
 |-----:|---------:| 
 |    IN|     22600| 
 |   OUT|        39| 





::: 

::: {.div14} 

**TREEMAP**: 

![](RG_files/figure-html/unnamed-chunk-7-10.png){width=672}




::: 

:::::  


```{.r .cell-code}
#seperate out numberic values just for testing purposes
dgf.num <- dgf[22:27,  ]
create_all_sections( dgf.num )
```


{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_08_REV_TOT_TOT

::: 

::: {.div2} 

**LABEL**: TOTREV2




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: Total revenue - total




::: 

::: {.div5} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        | 23,817| 
 |Distinct (%)        |   0.95| 
 |Duplicates (%)      |   0.05| 
 |Most Common Value   |      0| 
 |Most Common Val (%) |   0.02| 
 |Zero (N)            |    413| 
 |Zero (%)            |   0.02| 
 |All Empty (N)       |      0| 
 |Missing/NA (N)      |      0| 
 |Missing/NA (%)      |      0| 
 |Infinite (N)        |      0| 





::: 

::: {.div6} 

**QUANTILES**: 

|STAT   |       VAL| 
 |:------|---------:| 
 |Q - 05 |   3,359.8| 
 |Q - 25 |  51,012.5| 
 |Q - 50 |   130,545| 
 |Q - 75 | 441,954.5| 
 |Q - 95 | 6,355,357| 





::: 

::: {.div7} 

**STATS**: 

|STAT    |           VAL| 
 |:-------|-------------:| 
 |Minimum |   -61,467,591| 
 |Median  |       130,545| 
 |Mean    |     3,740,777| 
 |Max     | 4,178,522,311| 
 |Skew    |         44.03| 
 |Kurt    |      2,561.13| 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-html/unnamed-chunk-8-1.png){width=768}




::: 

::: {.div9} 

**DATA PREVIEW**: 

0 ;; 100 ;; 1000 ;; 250000 ;; 2000 ;; 2250 ;; 50 ;; 200 ;; 45000 ;; 4 ;; 1500 ;; 5000 ;; 6000 ;; 8800 ;; 25000 ;; 25500 ;; 75000 ;; 1e+05 ;; 101225 ;; 1 ;; 3 ;; 8 ;; 9 ;; 101 ;; 575 ;; 600 ;; 1200 ;; 1800 ;; 2074 ;; 2400 ;; 4125 ;; 5400 ;; 6800 ;; 9465 ;; 9500 ;; 10000 ;; 15000 ;; 19611 ;; 20000 ;; 20649 ;; 26873 ;; 27567 ;; 30000 ;; 32500 ;; 40000 ;; 40500 ;; 43873 ;; 46814 ;; 48000 ;; 50000 ;; 5




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_10_ASSET_TOT_BOY

::: 

::: {.div2} 

**LABEL**: ASS_BOY




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: Total assets - beginning of year




::: 

::: {.div5} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        | 20,195| 
 |Distinct (%)        |   0.81| 
 |Duplicates (%)      |   0.19| 
 |Most Common Value   |      0| 
 |Most Common Val (%) |   0.12| 
 |Zero (N)            |  3,011| 
 |Zero (%)            |   0.12| 
 |All Empty (N)       |  1,377| 
 |Missing/NA (N)      |  1,377| 
 |Missing/NA (%)      |   0.06| 
 |Infinite (N)        |      0| 





::: 

::: {.div6} 

**QUANTILES**: 

|STAT   |        VAL| 
 |:------|----------:| 
 |Q - 05 |          0| 
 |Q - 25 |   31,558.5| 
 |Q - 50 |    169,734| 
 |Q - 75 |  729,844.5| 
 |Q - 95 | 13,488,117| 





::: 

::: {.div7} 

**STATS**: 

|STAT    |            VAL| 
 |:-------|--------------:| 
 |Minimum |        -69,049| 
 |Median  |        169,734| 
 |Mean    |     11,116,959| 
 |Max     | 11,226,543,829| 
 |Skew    |          41.82| 
 |Kurt    |       2,120.93| 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-html/unnamed-chunk-8-2.png){width=768}




::: 

::: {.div9} 

**DATA PREVIEW**: 

0 ;; 1 ;; 300 ;; 161 ;; 1593 ;; 10571 ;; 20855 ;; 21915 ;; 43506 ;; 49481 ;; 2 ;; 97 ;; 212 ;; 219 ;; 343 ;; 388 ;; 500 ;; 718 ;; 1000 ;; 1020 ;; 1222 ;; 1535 ;; 1547 ;; 1607 ;; 1642 ;; 2155 ;; 2745 ;; 3068 ;; 3073 ;; 3087 ;; 3708 ;; 4412 ;; 4414 ;; 4612 ;; 5251 ;; 5501 ;; 5619 ;; 5761 ;; 6141 ;; 6267 ;; 6812 ;; 6865 ;; 7575 ;; 8302 ;; 8451 ;; 8528 ;; 8853 ;; 9083 ;; 9110 ;; 9369 ;; 9527 ;; 9937




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_10_ASSET_TOT_EOY

::: 

::: {.div2} 

**LABEL**: ASS_EOY




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: Total assets - end of year




::: 

::: {.div5} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        | 24,122| 
 |Distinct (%)        |   0.96| 
 |Duplicates (%)      |   0.04| 
 |Most Common Value   |      1| 
 |Most Common Val (%) |   0.01| 
 |Zero (N)            |    110| 
 |Zero (%)            |      0| 
 |All Empty (N)       |      0| 
 |Missing/NA (N)      |      0| 
 |Missing/NA (%)      |      0| 
 |Infinite (N)        |      0| 





::: 

::: {.div6} 

**QUANTILES**: 

|STAT   |        VAL| 
 |:------|----------:| 
 |Q - 05 |   4,421.45| 
 |Q - 25 |  55,668.25| 
 |Q - 50 |    212,649| 
 |Q - 75 |    837,286| 
 |Q - 95 | 14,639,755| 





::: 

::: {.div7} 

**STATS**: 

|STAT    |            VAL| 
 |:-------|--------------:| 
 |Minimum |     -1,119,570| 
 |Median  |        212,649| 
 |Mean    |     13,755,826| 
 |Max     | 38,468,314,242| 
 |Skew    |          85.67| 
 |Kurt    |       9,680.45| 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-html/unnamed-chunk-8-3.png){width=768}




::: 

::: {.div9} 

**DATA PREVIEW**: 

1 ;; 0 ;; 100 ;; 1000 ;; 15000 ;; 21 ;; 480 ;; 529 ;; 680 ;; 1257 ;; 1374 ;; 1932 ;; 2000 ;; 2076 ;; 2280 ;; 2680 ;; 2965 ;; 3000 ;; 10000 ;; 24731 ;; 24753 ;; 37977 ;; 40760 ;; 25 ;; 30 ;; 39 ;; 90 ;; 99 ;; 140 ;; 149 ;; 200 ;; 212 ;; 230 ;; 248 ;; 249 ;; 281 ;; 314 ;; 340 ;; 415 ;; 459 ;; 478 ;; 627 ;; 628 ;; 663 ;; 912 ;; 957 ;; 997 ;; 1107 ;; 1158 ;; 1203 ;; 1353 ;; 1383 ;; 1389 ;; 1500 ;; 163




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_10_NAFB_TOT_BOY

::: 

::: {.div2} 

**LABEL**: NETA_BOY




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: Net assets or fund balances - beginning of year




::: 

::: {.div5} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        | 20,145| 
 |Distinct (%)        |   0.81| 
 |Duplicates (%)      |   0.19| 
 |Most Common Value   |     NA| 
 |Most Common Val (%) |   0.17| 
 |Zero (N)            |    203| 
 |Zero (%)            |   0.01| 
 |All Empty (N)       |  4,344| 
 |Missing/NA (N)      |  4,344| 
 |Missing/NA (%)      |   0.17| 
 |Infinite (N)        |      0| 





::: 

::: {.div6} 

**QUANTILES**: 

|STAT   |        VAL| 
 |:------|----------:| 
 |Q - 05 |    1,659.5| 
 |Q - 25 |   52,689.5| 
 |Q - 50 |  192,629.5| 
 |Q - 75 |  720,262.5| 
 |Q - 95 | 10,744,071| 





::: 

::: {.div7} 

**STATS**: 

|STAT    |           VAL| 
 |:-------|-------------:| 
 |Minimum |  -333,005,908| 
 |Median  |     192,629.5| 
 |Mean    |     4,921,982| 
 |Max     | 6,323,689,488| 
 |Skew    |         61.69| 
 |Kurt    |      5,415.74| 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-html/unnamed-chunk-8-4.png){width=768}




::: 

::: {.div9} 

**DATA PREVIEW**: 

0 ;; 300 ;; 1593 ;; 8311 ;; 20855 ;; 24587 ;; 29596 ;; 56803 ;; -21474 ;; -6426 ;; -989 ;; -826 ;; 97 ;; 161 ;; 212 ;; 334 ;; 388 ;; 500 ;; 718 ;; 1000 ;; 1020 ;; 1547 ;; 1642 ;; 2745 ;; 2870 ;; 3068 ;; 3073 ;; 3087 ;; 3306 ;; 3554 ;; 3708 ;; 4412 ;; 4414 ;; 4612 ;; 4772 ;; 5318 ;; 5501 ;; 5619 ;; 6141 ;; 6267 ;; 6812 ;; 6865 ;; 7177 ;; 8302 ;; 8451 ;; 8528 ;; 8853 ;; 8942 ;; 9110 ;; 9369 ;; 9527




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_09_EXP_TOT_TOT

::: 

::: {.div2} 

**LABEL**: EXPS




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: Total functional expenses - total expenses




::: 

::: {.div5} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        | 23,740| 
 |Distinct (%)        |   0.95| 
 |Duplicates (%)      |   0.05| 
 |Most Common Value   |      0| 
 |Most Common Val (%) |   0.02| 
 |Zero (N)            |    489| 
 |Zero (%)            |   0.02| 
 |All Empty (N)       |      0| 
 |Missing/NA (N)      |      0| 
 |Missing/NA (%)      |      0| 
 |Infinite (N)        |      0| 





::: 

::: {.div6} 

**QUANTILES**: 

|STAT   |       VAL| 
 |:------|---------:| 
 |Q - 05 |  3,886.95| 
 |Q - 25 |    46,845| 
 |Q - 50 | 121,792.5| 
 |Q - 75 | 411,837.2| 
 |Q - 95 | 5,832,724| 





::: 

::: {.div7} 

**STATS**: 

|STAT    |           VAL| 
 |:-------|-------------:| 
 |Minimum |       -11,719| 
 |Median  |     121,792.5| 
 |Mean    |     3,531,376| 
 |Max     | 4,256,605,589| 
 |Skew    |         46.21| 
 |Kurt    |      2,822.92| 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-html/unnamed-chunk-8-5.png){width=768}




::: 

::: {.div9} 

**DATA PREVIEW**: 

0 ;; 100 ;; 1000 ;; 10 ;; 50 ;; 600 ;; 4056 ;; 7500 ;; 25 ;; 200 ;; 400 ;; 539 ;; 786 ;; 1140 ;; 5000 ;; 10000 ;; 11085 ;; 13669 ;; 16927 ;; 16993 ;; 19327 ;; 28348 ;; 36264 ;; 40526 ;; 45638 ;; 48401 ;; 50154 ;; 60157 ;; 62391 ;; 80427 ;; 83368 ;; 83437 ;; 105341 ;; 153299 ;; 41 ;; 60 ;; 129 ;; 130 ;; 143 ;; 175 ;; 225 ;; 261 ;; 300 ;; 316 ;; 397 ;; 418 ;; 450 ;; 500 ;; 588 ;; 732 ;; 890 ;; 950




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_01_EXP_TOT_PY

::: 

::: {.div2} 

**LABEL**: EXPSP




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: Total expenses - prior year




::: 

::: {.div5} 

**PROPERTIES**: 

|STAT                |    VAL| 
 |:-------------------|------:| 
 |Rows (N)            | 25,000| 
 |Distinct (N)        | 19,931| 
 |Distinct (%)        |    0.8| 
 |Duplicates (%)      |    0.2| 
 |Most Common Value   |      0| 
 |Most Common Val (%) |   0.13| 
 |Zero (N)            |  3,257| 
 |Zero (%)            |   0.13| 
 |All Empty (N)       |  1,377| 
 |Missing/NA (N)      |  1,377| 
 |Missing/NA (%)      |   0.06| 
 |Infinite (N)        |      0| 





::: 

::: {.div6} 

**QUANTILES**: 

|STAT   |       VAL| 
 |:------|---------:| 
 |Q - 05 |         0| 
 |Q - 25 |    29,933| 
 |Q - 50 |   102,618| 
 |Q - 75 | 362,012.5| 
 |Q - 95 | 5,357,595| 





::: 

::: {.div7} 

**STATS**: 

|STAT    |           VAL| 
 |:-------|-------------:| 
 |Minimum |    -5,437,471| 
 |Median  |       102,618| 
 |Mean    |     3,407,085| 
 |Max     | 4,624,922,368| 
 |Skew    |         48.27| 
 |Kurt    |      3,044.67| 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-html/unnamed-chunk-8-6.png){width=768}




::: 

::: {.div9} 

**DATA PREVIEW**: 

0 ;; 10 ;; 36 ;; 600 ;; 1450 ;; 2279 ;; 3200 ;; 4742 ;; 8214 ;; 14221 ;; 25853 ;; 32965 ;; 43809 ;; 44039 ;; 44951 ;; 54368 ;; 55199 ;; 56378 ;; 78821 ;; 126182 ;; 20 ;; 400 ;; 656 ;; 736 ;; 827 ;; 859 ;; 1220 ;; 1540 ;; 1938 ;; 2206 ;; 2487 ;; 2489 ;; 2505 ;; 2831 ;; 3371 ;; 3400 ;; 3433 ;; 3552 ;; 4500 ;; 5000 ;; 5640 ;; 5791 ;; 5853 ;; 6032 ;; 7191 ;; 7268 ;; 7393 ;; 7500 ;; 7814 ;; 8379 ;; 882




::: 

:::::  

::: {.cell}

:::






<br>
<br>
<hr>
<br>
<br>


<link href='https://fonts.googleapis.com/css?family=Fira Code' rel='stylesheet'> <link rel="stylesheet" type="text/css" href="//fonts.googleapis.com/css?family=Anonymous+Pro" />






```{=html}
<style>

@import url('https://fonts.cdnfonts.com/css/aharoni');

.parent {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  grid-template-rows: auto;  
    grid-column-gap: 20px;
  grid-row-gap: 10px;
  grid-template-areas:
    "a a a"
    "b b b"
    "c d d"
    "e f g" 
    "h h h"
    "i i i"
    "j k k"
    "m o o"
    "n o o"
    "p p p";
}


.div1 { 
  grid-area: a;
  padding-bottom: 15px;
}

.div2 { 
    grid-area: b;
    padding-left: 30px;
}

.div3 { 
    grid-area: c;
    padding-left: 30px;
}

.div4 { 
    grid-area: d;
    padding-left: 20px;
}

.div5 { 
    grid-area: e;
    padding-left: 30px;
}

.div6 { 
    grid-area: f;
    padding-left: 20px;
}

.div7 { 
    grid-area: g;
    padding-left: 20px;
}

.div8 { 
    grid-area: h;
    padding-left: 30px;
}

.div9 { 
    grid-area: i;
    padding-left: 50px;
}

.div10 { 
    grid-area: j;
    padding-left: 30px;
}

.div11 { 
    grid-area: k;
    padding-left: 20px;
}

.div12 { 
    grid-area: m;
    padding-left: 30px;
}

.div13 { 
    grid-area: n;
    padding-left: 30px;
}

.div14 { 
    grid-area: o;
    padding-left: 30px;
}

.div15 { 
    grid-area: p;
    padding-left: 20px;
}

h1.title { 
  color: black;
  font-family: 'Aharoni', sans-serif;
  font-size: 2.5em; }
h2.anchored { color: lightgray; }
h3.anchored { color: gray; }

h4 {
    /* text-decoration: underline; */
    /* text-underline-offset: 10px; */
    /* text-decoration-thickness: 2px; */
    font-family: Georgia, Times, "Times New Roman", serif; 
    /* font-family: 'Fira Code'; */
    /* font-family: 'Aharoni', sans-serif; */
    font-size: 2.2em;
    font-weight: 700;  
    /* line-height: 120px; */ 
    border-bottom:3px solid #000; 
    /* font-size:14px; */
    /* line-height:12px; */
    width:100%;
}

h5 { font-size: 0.9em; }

.div2 p { 
    font-family: Verdana;
    font-size: 1.1em;
}

.div3 td { 
    font-family: "Aharoni", sans-serif;
    font-size: 0.9em;
}

.div4 p { 
    font-family: "Calibri", sans-serif;
    font-size: 1.1em;
}

.div9 p { 
    font-family: "Anonymous Pro";
    font-size: 0.8em;
    color: gray;
    text-align: justify;
}

.div9 strong { 
    font-family: "Calibri", sans-serif;
    font-size: 1.6em;
    color: black;
}


.div4 table {
    margin-left: 20px;
    font-family: "Anonymous Pro";
}

.div5 td { 
    font-family: "Anonymous Pro";
    font-size: 0.9em;
}

.div6 td { 
    font-family: "Anonymous Pro";
    font-size: 0.9em;
}

.div7 td { 
    font-family: "Anonymous Pro";
    font-size: 0.9em;
}

.div12 td { 
    font-family: "Anonymous Pro";
    font-size: 0.9em;
}

.div13 td { 
    font-family: "Anonymous Pro";
    font-size: 0.9em;
}

.div14 td { 
    font-family: "Anonymous Pro";
    font-size: 0.9em;
}


.div5 table {
    margin-left: 20px;
}

.table>tbody {
    border-top: none;
}

.table>:not(caption)>*>* {
    padding: 0rem 0rem;
}

tbody, tfoot, tr, td, th {
    border-color: inherit;
    border-style: none; 
    border-width: 0;
}


.div5 tr {
  border-bottom: 1px solid;
  border-color: #D3D3D3;
}

.div5 th {
  display:none;
}

.div6 tr {
  border-bottom: 1px solid;
  border-color: #D3D3D3;
}

.div6 th {
  display:none;
}

.div7 tr {
  border-bottom: 1px solid;
  border-color: #D3D3D3;
}

.div7 th {
  display:none;
}

.div8 img, svg {
    /* vertical-align: bottom;*/
    align-self: end;
    justify-self: end;
}

.div9 img, svg {
    /* vertical-align: bottom;*/
    align-self: end;
    justify-self: end;
}

#pb_agent .gt_table {
    border-top-width: 0px; 
    /* border-top-color: #A8A8A8; */
}  

#pb_agent .gt_title {
    font-size: 1.3em !important;
}

#pb_agent .gt_left { color: black !important; }

@media print {
   body {
   display:table;
   table-layout:fixed;
   padding-top:2.5cm;
   padding-bottom:3cm;
   padding-left:1.5cm;
   padding-right:1.5cm;
   height:auto;
    }
}

</style>
```


::: {.cell}

:::
