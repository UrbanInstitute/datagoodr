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
  dgf_file: "../data-dev/DGF.xlsx"
---




<br>


<br><br>










## Logical




{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_05_UBIZ_IMCOME_OVER_LIMIT_X

::: 

::: {.div2} 

**LABEL**: F9_05_UBIZ_IMCOME_OVER_LIMIT_X




::: 

::: {.div3} 

**DATA TYPE**: logical




::: 

::: {.div4} 

**DESCRIPTION**: Had unrelated business gross income of $1,000 or more [x]




::: 

::: {.div17} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 2 & \\
\hline
Most Common Value & N & (86\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 0 & (0\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div18} 

**VALUES**: 


\begin{tabular}{l|r}
\hline
Value & Frequency\\
\hline
N & 21550\\
\hline
Y & 3450\\
\hline
\end{tabular} 





::: 

::: {.div19} 

**BOOLPLOT**: 

![](RG_files/figure-pdf/logical-1.pdf)




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

**DATA TYPE**: logical




::: 

::: {.div4} 

**DESCRIPTION**: Out of Scope flag




::: 

::: {.div17} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 3 & \\
\hline
Most Common Value & IN & (100\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 2361 & (9.4\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div18} 

**VALUES**: 


\begin{tabular}{l|r}
\hline
Value & Frequency\\
\hline
IN & 22600\\
\hline
NA & 2361\\
\hline
OUT & 39\\
\hline
\end{tabular} 





::: 

::: {.div19} 

**BOOLPLOT**: 

![](RG_files/figure-pdf/logical-2.pdf)




::: 

:::::  



## Factor




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

::: {.div14} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 23 & \\
\hline
Most Common Value & 6 & (26\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 0 & (0\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div15} 

**MOST COMMON VALUES**: 


\begin{tabular}{l|r}
\hline
Value & Frequency\\
\hline
6 & 6391\\
\hline
4 & 4936\\
\hline
7 & 3571\\
\hline
5 & 3449\\
\hline
8 & 1479\\
\hline
19 & 1459\\
\hline
\end{tabular} 





::: 

::: {.div16} 

**TREEMAP**: 

![](RG_files/figure-pdf/factor-1.pdf)




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### BMF_ACTIV1

::: 

::: {.div2} 

**LABEL**: BMF_ACTIV1




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: IRS Activity Code 1




::: 

::: {.div14} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 230 & \\
\hline
Most Common Value & 0 & (25\%)\\
\hline
Zero & 5807 & (23.2\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 1887 & (7.5\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div15} 

**MOST COMMON VALUES**: 


\begin{tabular}{l|r}
\hline
Value & Frequency\\
\hline
0 & 5807\\
\hline
263 & 1782\\
\hline
200 & 1648\\
\hline
907 & 1212\\
\hline
36 & 1054\\
\hline
279 & 998\\
\hline
\end{tabular} 





::: 

::: {.div16} 

**TREEMAP**: 

![](RG_files/figure-pdf/factor-2.pdf)




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

::: {.div14} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 12 & \\
\hline
Most Common Value & PU & (37\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 0 & (0\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div15} 

**MOST COMMON VALUES**: 


\begin{tabular}{l|r}
\hline
Value & Frequency\\
\hline
PU & 9128\\
\hline
HU & 7955\\
\hline
MU & 2480\\
\hline
ED & 1528\\
\hline
UN & 1524\\
\hline
HE & 994\\
\hline
\end{tabular} 





::: 

::: {.div16} 

**TREEMAP**: 

![](RG_files/figure-pdf/factor-3.pdf)




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

::: {.div14} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 27 & \\
\hline
Most Common Value & S & (25\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 1497 & (6\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div15} 

**MOST COMMON VALUES**: 


\begin{tabular}{l|r}
\hline
Value & Frequency\\
\hline
S & 5817\\
\hline
N & 3018\\
\hline
W & 2835\\
\hline
Y & 2480\\
\hline
J & 1961\\
\hline
B & 1552\\
\hline
\end{tabular} 





::: 

::: {.div16} 

**TREEMAP**: 

![](RG_files/figure-pdf/factor-4.pdf)




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

::: {.div14} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 654 & \\
\hline
Most Common Value & S41 & (8\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 1497 & (6\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div15} 

**MOST COMMON VALUES**: 


\begin{tabular}{l|r}
\hline
Value & Frequency\\
\hline
S41 & 1947\\
\hline
J40 & 1815\\
\hline
W30 & 1582\\
\hline
S80 & 1515\\
\hline
N50 & 1088\\
\hline
M24 & 810\\
\hline
\end{tabular} 





::: 

::: {.div16} 

**TREEMAP**: 

![](RG_files/figure-pdf/factor-5.pdf)




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

::: {.div14} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 16 & \\
\hline
Most Common Value & BEST & (53\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 1378 & (5.5\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div15} 

**MOST COMMON VALUES**: 


\begin{tabular}{l|r}
\hline
Value & Frequency\\
\hline
BEST & 12410\\
\hline
WORD & 4000\\
\hline
NEW & 2621\\
\hline
IRS & 2540\\
\hline
SOI & 855\\
\hline
ZZ & 454\\
\hline
\end{tabular} 





::: 

::: {.div16} 

**TREEMAP**: 

![](RG_files/figure-pdf/factor-6.pdf)




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

::: {.div14} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 5 & \\
\hline
Most Common Value & 2 & (80\%)\\
\hline
Zero & 685 & (2.7\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 1887 & (7.5\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div15} 

**MOST COMMON VALUES**: 


\begin{tabular}{l|r}
\hline
Value & Frequency\\
\hline
2 & 18494\\
\hline
1 & 3932\\
\hline
0 & 685\\
\hline
4 & 2\\
\hline
\end{tabular} 





::: 

::: {.div16} 

**TREEMAP**: 

![](RG_files/figure-pdf/factor-7.pdf)




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

::: {.div14} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 5 & \\
\hline
Most Common Value & NA & (NaN\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 24961 & (99.8\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div15} 

**MOST COMMON VALUES**: 


\begin{tabular}{l|r}
\hline
Value & Frequency\\
\hline
T & 15\\
\hline
F & 12\\
\hline
S & 11\\
\hline
N & 1\\
\hline
\end{tabular} 





::: 

::: {.div16} 

**TREEMAP**: 

![](RG_files/figure-pdf/factor-8.pdf)




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_00_TAX_PERIOD_END_DATE

::: 

::: {.div2} 

**LABEL**: F9_00_TAX_PERIOD_END_DATE




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: Tax period end date




::: 

::: {.div14} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 47 & \\
\hline
Most Common Value & 2019-12 & (40\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 0 & (0\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div15} 

**MOST COMMON VALUES**: 


\begin{tabular}{l|r}
\hline
Value & Frequency\\
\hline
2019-12 & 9884\\
\hline
2018-12 & 3477\\
\hline
2019-06 & 2064\\
\hline
2017-12 & 1626\\
\hline
2020-06 & 1312\\
\hline
2018-06 & 840\\
\hline
\end{tabular} 





::: 

::: {.div16} 

**TREEMAP**: 

![](RG_files/figure-pdf/factor-9.pdf)




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_00_TAX_PERIOD_END_DATE_PY

::: 

::: {.div2} 

**LABEL**: F9_00_TAX_PERIOD_END_DATE_PY




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: Tax period end date - prior year




::: 

::: {.div14} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 47 & \\
\hline
Most Common Value & 2018-12 & (45\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 4344 & (17.4\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div15} 

**MOST COMMON VALUES**: 


\begin{tabular}{l|r}
\hline
Value & Frequency\\
\hline
2018-12 & 9298\\
\hline
2017-12 & 3002\\
\hline
2018-06 & 1767\\
\hline
2019-06 & 1060\\
\hline
2018-09 & 744\\
\hline
2017-06 & 539\\
\hline
\end{tabular} 





::: 

::: {.div16} 

**TREEMAP**: 

![](RG_files/figure-pdf/factor-10.pdf)




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_00_TAX_ACCPER

::: 

::: {.div2} 

**LABEL**: F9_00_TAX_ACCPER




::: 

::: {.div3} 

**DATA TYPE**: factor




::: 

::: {.div4} 

**DESCRIPTION**: Tax period end date




::: 

::: {.div14} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 12 & \\
\hline
Most Common Value & 12 & (60\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 0 & (0\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div15} 

**MOST COMMON VALUES**: 


\begin{tabular}{l|r}
\hline
Value & Frequency\\
\hline
12 & 14987\\
\hline
06 & 4578\\
\hline
09 & 1251\\
\hline
03 & 849\\
\hline
05 & 796\\
\hline
08 & 688\\
\hline
\end{tabular} 





::: 

::: {.div16} 

**TREEMAP**: 

![](RG_files/figure-pdf/factor-11.pdf)




::: 

:::::  



## Numeric 




{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### COUNTY_FIPS

::: 

::: {.div2} 

**LABEL**: COUNTY_FIPS




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: State + County FIPS code




::: 

::: {.div5} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 2411 & \\
\hline
Most Common Value & NA & (NaN\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 2389 & (9.6\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div7} 

**STATS**: 


\begin{tabular}{l|r}
\hline
STAT & VAL\\
\hline
Minimum & 1,001\\
\hline
Q - 05 & 6,019\\
\hline
Q - 25 & 17,027\\
\hline
Median & 27,163\\
\hline
Mean & 28,405.45\\
\hline
Q - 75 & 41,051\\
\hline
Q - 95 & 53,033\\
\hline
Maximum & 78,030\\
\hline
Skew & -0.01\\
\hline
\end{tabular} 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-pdf/numeric-1.pdf)




::: 

::: {.div9} 

**DATA PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
6001 & 11001\\
\hline
26163 & 25017\\
\hline
25021 & 6075\\
\hline
6085 & 9001\\
\hline
48201 & 36061\\
\hline
17031 & 36059\\
\hline
25009 & 9003\\
\hline
6037 & 36103\\
\hline
19153 & 34003\\
\hline
13121 & 6067\\
\hline
\end{tabu} 





::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### CEO_CENSUSTRACT

::: 

::: {.div2} 

**LABEL**: CEO_CENSUSTRACT




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: Census tract




::: 

::: {.div5} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 14265 & \\
\hline
Most Common Value & NA & (NaN\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 3110 & (12.4\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div7} 

**STATS**: 


\begin{tabular}{l|r}
\hline
STAT & VAL\\
\hline
Minimum & 1,001,020,500\\
\hline
Q - 05 & 6,029,003,250\\
\hline
Q - 25 & 17,031,320,100\\
\hline
Median & 28,012,950,350\\
\hline
Mean & 28,488,147,053\\
\hline
Q - 75 & 41,051,008,202\\
\hline
Q - 95 & 53,033,008,055\\
\hline
Maximum & 5.6043e+10\\
\hline
Skew & -0.02\\
\hline
\end{tabular} 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-pdf/numeric-2.pdf)




::: 

::: {.div9} 

**DATA PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
28049010500 & 36061016100\\
\hline
42003191100 & 39049004000\\
\hline
22033003501 & 6075011700\\
\hline
17031320100 & 48453000102\\
\hline
4013941000 & 18097391000\\
\hline
1097003707 & 6075061500\\
\hline
11001010700 & 48201531700\\
\hline
42003020100 & 350\\
\hline
11001005900 & 11001010100\\
\hline
17031839100 & 51510201900\\
\hline
\end{tabu} 





::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_08_REV_TOT_TOT

::: 

::: {.div2} 

**LABEL**: F9_08_REV_TOT_TOT




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: Total revenue - total




::: 

::: {.div5} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 23817 & \\
\hline
Most Common Value & 0 & (2\%)\\
\hline
Zero & 413 & (1.7\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 0 & (0\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div7} 

**STATS**: 


\begin{tabular}{l|r}
\hline
STAT & VAL\\
\hline
Minimum & -61,467,591\\
\hline
Q - 05 & 3,359.8\\
\hline
Q - 25 & 51,012.5\\
\hline
Median & 130,545\\
\hline
Mean & 3,740,777\\
\hline
Q - 75 & 441,954.5\\
\hline
Q - 95 & 6,355,357\\
\hline
Maximum & 4,178,522,311\\
\hline
Skew & 44.03\\
\hline
\end{tabular} 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-pdf/numeric-3.pdf)




::: 

::: {.div9} 

**DATA PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
4 & 15000\\
\hline
6000 & 40000\\
\hline
1800 & 26873\\
\hline
27567 & 32500\\
\hline
1 & 8800\\
\hline
48000 & 101\\
\hline
20000 & 2400\\
\hline
6800 & 5400\\
\hline
25500 & 9500\\
\hline
8 & 101225\\
\hline
\end{tabu} 





::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_10_ASSET_TOT_BOY

::: 

::: {.div2} 

**LABEL**: F9_10_ASSET_TOT_BOY




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: Total assets - beginning of year




::: 

::: {.div5} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 20195 & \\
\hline
Most Common Value & 0 & (13\%)\\
\hline
Zero & 3011 & (12\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 1377 & (5.5\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div7} 

**STATS**: 


\begin{tabular}{l|r}
\hline
STAT & VAL\\
\hline
Minimum & -69,049\\
\hline
Q - 05 & 0\\
\hline
Q - 25 & 31,558.5\\
\hline
Median & 169,734\\
\hline
Mean & 11,116,959\\
\hline
Q - 75 & 729,844.5\\
\hline
Q - 95 & 13,488,117\\
\hline
Maximum & 11,226,543,829\\
\hline
Skew & 41.82\\
\hline
\end{tabular} 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-pdf/numeric-4.pdf)




::: 

::: {.div9} 

**DATA PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
1020 & 718\\
\hline
49481 & 1535\\
\hline
8853 & 5761\\
\hline
3708 & 9369\\
\hline
6141 & 212\\
\hline
343 & 3068\\
\hline
1547 & 21915\\
\hline
9083 & 2155\\
\hline
9527 & 2\\
\hline
161 & 9110\\
\hline
\end{tabu} 





::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_10_ASSET_TOT_EOY

::: 

::: {.div2} 

**LABEL**: F9_10_ASSET_TOT_EOY




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: Total assets - end of year




::: 

::: {.div5} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 24122 & \\
\hline
Most Common Value & 1 & (1\%)\\
\hline
Zero & 110 & (0.4\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 0 & (0\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div7} 

**STATS**: 


\begin{tabular}{l|r}
\hline
STAT & VAL\\
\hline
Minimum & -1,119,570\\
\hline
Q - 05 & 4,421.45\\
\hline
Q - 25 & 55,668.25\\
\hline
Median & 212,649\\
\hline
Mean & 13,755,826\\
\hline
Q - 75 & 837,286\\
\hline
Q - 95 & 14,639,755\\
\hline
Maximum & 38,468,314,242\\
\hline
Skew & 85.67\\
\hline
\end{tabular} 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-pdf/numeric-5.pdf)




::: 

::: {.div9} 

**DATA PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
314 & 912\\
\hline
2000 & 1257\\
\hline
1203 & 340\\
\hline
25 & 39\\
\hline
3000 & 163\\
\hline
1932 & 1000\\
\hline
100 & 0\\
\hline
1374 & 212\\
\hline
200 & 281\\
\hline
627 & 1158\\
\hline
\end{tabu} 





::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_10_NAFB_TOT_BOY

::: 

::: {.div2} 

**LABEL**: F9_10_NAFB_TOT_BOY




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: Net assets or fund balances - beginning of year




::: 

::: {.div5} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 20145 & \\
\hline
Most Common Value & NA & (NaN\%)\\
\hline
Zero & 203 & (0.8\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 4344 & (17.4\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div7} 

**STATS**: 


\begin{tabular}{l|r}
\hline
STAT & VAL\\
\hline
Minimum & -333,005,908\\
\hline
Q - 05 & 1,659.5\\
\hline
Q - 25 & 52,689.5\\
\hline
Median & 192,629.5\\
\hline
Mean & 4,921,982\\
\hline
Q - 75 & 720,262.5\\
\hline
Q - 95 & 10,744,071\\
\hline
Maximum & 6,323,689,488\\
\hline
Skew & 61.69\\
\hline
\end{tabular} 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-pdf/numeric-6.pdf)




::: 

::: {.div9} 

**DATA PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
1000 & 3087\\
\hline
2870 & -826\\
\hline
5318 & 3306\\
\hline
20855 & 6812\\
\hline
7177 & -6426\\
\hline
29596 & 4414\\
\hline
161 & 3554\\
\hline
1020 & 500\\
\hline
1593 & 4772\\
\hline
97 & 334\\
\hline
\end{tabu} 





::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_09_EXP_TOT_TOT

::: 

::: {.div2} 

**LABEL**: F9_09_EXP_TOT_TOT




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: Total functional expenses - total expenses




::: 

::: {.div5} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 23740 & \\
\hline
Most Common Value & 0 & (2\%)\\
\hline
Zero & 489 & (2\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 0 & (0\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div7} 

**STATS**: 


\begin{tabular}{l|r}
\hline
STAT & VAL\\
\hline
Minimum & -11,719\\
\hline
Q - 05 & 3,886.95\\
\hline
Q - 25 & 46,845\\
\hline
Median & 121,792.5\\
\hline
Mean & 3,531,376\\
\hline
Q - 75 & 411,837.2\\
\hline
Q - 95 & 5,832,724\\
\hline
Maximum & 4,256,605,589\\
\hline
Skew & 46.21\\
\hline
\end{tabular} 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-pdf/numeric-7.pdf)




::: 

::: {.div9} 

**DATA PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
300 & 129\\
\hline
153299 & 16927\\
\hline
83368 & 48401\\
\hline
175 & 200\\
\hline
600 & 40526\\
\hline
1140 & 25\\
\hline
225 & 50\\
\hline
19327 & 4056\\
\hline
105341 & 261\\
\hline
950 & 60157\\
\hline
\end{tabu} 





::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_01_EXP_TOT_PY

::: 

::: {.div2} 

**LABEL**: F9_01_EXP_TOT_PY




::: 

::: {.div3} 

**DATA TYPE**: numeric




::: 

::: {.div4} 

**DESCRIPTION**: Total expenses - prior year




::: 

::: {.div5} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 19931 & \\
\hline
Most Common Value & 0 & (14\%)\\
\hline
Zero & 3257 & (13\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 1377 & (5.5\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div7} 

**STATS**: 


\begin{tabular}{l|r}
\hline
STAT & VAL\\
\hline
Minimum & -5,437,471\\
\hline
Q - 05 & 0\\
\hline
Q - 25 & 29,933\\
\hline
Median & 102,618\\
\hline
Mean & 3,407,085\\
\hline
Q - 75 & 362,012.5\\
\hline
Q - 95 & 5,357,595\\
\hline
Maximum & 4,624,922,368\\
\hline
Skew & 48.26\\
\hline
\end{tabular} 





::: 

::: {.div8} 

**HIST**: 

![](RG_files/figure-pdf/numeric-8.pdf)




::: 

::: {.div9} 

**DATA PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
2487 & 600\\
\hline
400 & 8214\\
\hline
7393 & 56378\\
\hline
55199 & 859\\
\hline
10 & 14221\\
\hline
736 & 126182\\
\hline
36 & 5791\\
\hline
0 & 43809\\
\hline
882 & 6032\\
\hline
7814 & 5000\\
\hline
\end{tabu} 





::: 

:::::  



## Character




{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_00_ORG_NAME_L1

::: 

::: {.div2} 

**LABEL**: F9_00_ORG_NAME_L1




::: 

::: {.div3} 

**DATA TYPE**: character




::: 

::: {.div4} 

**DESCRIPTION**: Organization name line 1




::: 

::: {.div10} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 17455 & \\
\hline
Most Common Value & NA & (NaN\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 1378 & (5.5\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div11} 

**PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
AMERICAN FEDERATION OF TEACHERS & INTERNATIONAL BROTHERHOO\\
\hline
AMERICAN LEGION & KIWANIS INTERNATIONAL INC\\
\hline
BENEVOLENT \& PROTECTIVE ORDER OF ELKS OF THE USA & KNIGHTS OF COLUMBUS\\
\hline
FRATERNAL ORDER OF EAGLES & ROTARY INTERNATIONAL\\
\hline
INTERNATIONAL ASSOCIATION OF FIRE FIGHTERS & UNITED STEELWORKERS\\
\hline
INTERNATIONAL ASSOCIATION OF LIONS CLUBS & VETERANS OF FOREIGN WARS OF THE UNITED STATES DE\\
\hline
\end{tabu} 





::: 

::: {.div12} 

**STATS**: 


\begin{tabular}{l|r|r}
\hline
STAT & CHARACTERS & WORDS\\
\hline
Minimum & 3 & 1\\
\hline
Median & 34 & 5\\
\hline
Mean & 35.64 & 5.08\\
\hline
Max & 97 & 17\\
\hline
Skew & 0.43 & 0.94\\
\hline
\end{tabular} 





::: 

::: {.div13} 

**Word Cloud**: 

![](RG_files/figure-pdf/character-1.pdf)




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F0_00_ORG_CONTACT

::: 

::: {.div2} 

**LABEL**: F0_00_ORG_CONTACT




::: 

::: {.div3} 

**DATA TYPE**: character




::: 

::: {.div4} 

**DESCRIPTION**: Contact person (from IRS files)




::: 

::: {.div10} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 10990 & \\
\hline
Most Common Value & NA & (NaN\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 13392 & (53.6\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div11} 

**PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
AGRECORDS & POST QUARTERMASTER\\
\hline
AIPSO & PRESIDENT\\
\hline
BOARD OF TRUSTEES & QUARTERMASTER\\
\hline
BRIANNE TILLOTSON & SCIARABBA WALKER\\
\hline
COMMANDER & SECRETARY\\
\hline
COMMERCE & SECRETARY TREASURER\\
\hline
CREST MANAGEMENT & SORORITY SOLUTIONS\\
\hline
FINANCIAL SECRETARY & THE BANK OF NEW YORK MELLON\\
\hline
GEO & THE ORGANIZATION\\
\hline
MIDAMERICA RET \& ADMIN SOL INC & TREASURER\\
\hline
PEO TREASURER & WORTHY SECRETARY\\
\hline
\end{tabu} 





::: 

::: {.div12} 

**STATS**: 


\begin{tabular}{l|r|r}
\hline
STAT & CHARACTERS & WORDS\\
\hline
Minimum & 1 & 1\\
\hline
Median & 14 & 2\\
\hline
Mean & 15.02 & 2.49\\
\hline
Max & 33 & 9\\
\hline
Skew & 1.29 & 1.63\\
\hline
\end{tabular} 





::: 

::: {.div13} 

**Word Cloud**: 

![](RG_files/figure-pdf/character-2.pdf)




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_00_ORG_ADDR_L1

::: 

::: {.div2} 

**LABEL**: F9_00_ORG_ADDR_L1




::: 

::: {.div3} 

**DATA TYPE**: character




::: 

::: {.div4} 

**DESCRIPTION**: Organization street address line 1




::: 

::: {.div10} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 18785 & \\
\hline
Most Common Value & NA & (NaN\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 1378 & (5.5\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div11} 

**PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
1154 TOWN AND COUNTRY COMMONS DR & PO BOX 24\\
\hline
3700 GRAND AVE & PO BOX 250\\
\hline
695 PRO MED LN STE 300 & PO BOX 26\\
\hline
9717 ELK GROVE FLORIN RD STE B & PO BOX 37\\
\hline
PO BOX 1 & PO BOX 4\\
\hline
PO BOX 111 & PO BOX 40\\
\hline
PO BOX 123 & PO BOX 5\\
\hline
PO BOX 151 & PO BOX 535007\\
\hline
PO BOX 175 & PO BOX 6\\
\hline
PO BOX 187 & PO BOX 66\\
\hline
PO BOX 2 & PO BOX 8\\
\hline
PO BOX 217 & PO BOX 86\\
\hline
PO BOX 23 & PO BOX 9\\
\hline
\end{tabu} 





::: 

::: {.div12} 

**STATS**: 


\begin{tabular}{l|r|r}
\hline
STAT & CHARACTERS & WORDS\\
\hline
Minimum & 2 & 1\\
\hline
Median & 15 & 3\\
\hline
Mean & 16.04 & 3.75\\
\hline
Max & 35 & 9\\
\hline
Skew & 0.97 & 1.42\\
\hline
\end{tabular} 





::: 

::: {.div13} 

**Word Cloud**: 

![](RG_files/figure-pdf/character-3.pdf)




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_00_ORG_ADDR_CITY

::: 

::: {.div2} 

**LABEL**: F9_00_ORG_ADDR_CITY




::: 

::: {.div3} 

**DATA TYPE**: character




::: 

::: {.div4} 

**DESCRIPTION**: Organization city




::: 

::: {.div10} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 5986 & \\
\hline
Most Common Value & NA & (NaN\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 1378 & (5.5\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div11} 

**PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
ALBANY & LOS ANGELES\\
\hline
ALEXANDRIA & LOUISVILLE\\
\hline
ATLANTA & MADISON\\
\hline
AUSTIN & NEW YORK\\
\hline
BOSTON & PHILADELPHIA\\
\hline
CHICAGO & PHOENIX\\
\hline
CLEVELAND & PITTSBURGH\\
\hline
COLUMBIA & PORTLAND\\
\hline
COLUMBUS & RICHMOND\\
\hline
DALLAS & SACRAMENTO\\
\hline
DENVER & SAINT LOUIS\\
\hline
HONOLULU & SAN DIEGO\\
\hline
HOUSTON & SAN FRANCISCO\\
\hline
INDIANAPOLIS & SEATTLE\\
\hline
LAS VEGAS & SPRINGFIELD\\
\hline
LEXINGTON & WASHINGTON\\
\hline
\end{tabu} 





::: 

::: {.div12} 

**STATS**: 


\begin{tabular}{l|r|r}
\hline
STAT & CHARACTERS & WORDS\\
\hline
Minimum & 3 & 1\\
\hline
Median & 9 & 1\\
\hline
Mean & 8.69 & 1.26\\
\hline
Max & 22 & 4\\
\hline
Skew & 0.23 & 1.46\\
\hline
\end{tabular} 





::: 

::: {.div13} 

**Word Cloud**: 

![](RG_files/figure-pdf/character-4.pdf)




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### EIN

::: 

::: {.div2} 

**LABEL**: EIN




::: 

::: {.div3} 

**DATA TYPE**: character




::: 

::: {.div4} 

**DESCRIPTION**: EIN




::: 

::: {.div10} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 24794 & \\
\hline
Most Common Value & 020212092 & (0\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 0 & (0\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div11} 

**PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
010100593 & 010874048\\
\hline
010218055 & 010961458\\
\hline
010220588 & 016011483\\
\hline
010266289 & 016012302\\
\hline
010273431 & 016019950\\
\hline
010286963 & 016022337\\
\hline
010440702 & 016123853\\
\hline
010468398 & 020172119\\
\hline
010523313 & 020187390\\
\hline
010524078 & 020212092\\
\hline
010573723 & 020232424\\
\hline
010715375 & 020241397\\
\hline
010744517 & 020257793\\
\hline
010815981 & 020324779\\
\hline
010852125 & 020349390\\
\hline
\end{tabu} 





::: 

::: {.div12} 

**STATS**: 


\begin{tabular}{l|r|r}
\hline
STAT & CHARACTERS & WORDS\\
\hline
Minimum & 9 & 1\\
\hline
Median & 9 & 1\\
\hline
Mean & 9 & 1\\
\hline
Max & 9 & 1\\
\hline
Skew & Skew & Skew\\
\hline
\end{tabular} 





::: 

::: {.div13} 

**Word Cloud**: 

![](RG_files/figure-pdf/character-5.pdf)




::: 

:::::  






{{< pagebreak >}} 



::::: {.parent} 

::: {.div1} 

#### F9_00_TAX_PERIOD_BEGIN_DATE

::: 

::: {.div2} 

**LABEL**: F9_00_TAX_PERIOD_BEGIN_DATE




::: 

::: {.div3} 

**DATA TYPE**: character




::: 

::: {.div4} 

**DESCRIPTION**: Tax period begin date




::: 

::: {.div10} 

**PROPERTIES**: 


\begin{tabular}{l|r|r}
\hline
STAT & VAL & PER\\
\hline
Rows & 25000 & \\
\hline
Distinct & 12 & \\
\hline
Most Common Value & 2019-0 & (41\%)\\
\hline
Zero & 0 & (0\%)\\
\hline
All Empty & 0 & (0\%)\\
\hline
Missing/NA & 0 & (0\%)\\
\hline
Infinite & 0 & (0\%)\\
\hline
\end{tabular} 





::: 

::: {.div11} 

**PREVIEW**: 


\begin{tabu} to \linewidth {>{\raggedright}X>{\raggedright}X}
\hline
2016-9 & 2018-9\\
\hline
2017-0 & 2019-0\\
\hline
2017-1 & 2019-1\\
\hline
2017-9 & 2019-9\\
\hline
2018-0 & 2020-0\\
\hline
2018-1 & 2020-1\\
\hline
\end{tabu} 





::: 

::: {.div12} 

**STATS**: 


\begin{tabular}{l|r|r}
\hline
STAT & CHARACTERS & WORDS\\
\hline
Minimum & 6 & 1\\
\hline
Median & 6 & 1\\
\hline
Mean & 6 & 1\\
\hline
Max & 6 & 1\\
\hline
Skew & Skew & Skew\\
\hline
\end{tabular} 





::: 

::: {.div13} 

**Word Cloud**: 

![](RG_files/figure-pdf/character-6.pdf)




::: 

:::::  


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
    grid-area: f;
    padding-left: 20px;
}

.div8 { 
    grid-area: h;
    padding-left: 30px;
}

.div9 { 
    grid-area: g;
    padding-left: 50px;
}

.div10 { 
    grid-area: e;
    padding-left: 30px;
}

.div11 { 
    grid-area: h;
    padding-left: 20px;
}

.div12 { 
    grid-area: f;
    padding-left: 30px;
}

.div13 { 
    grid-area: i;
    padding-left: 30px;
}

.div14 { 
    grid-area: e;
    padding-left: 30px;
}

.div15 { 
    grid-area: f;
    padding-left: 20px;
}

.div16 { 
    grid-area: h;
    padding-left: 20px;
}

.div17 { 
    grid-area: e;
    padding-left: 20px;
}

.div18 { 
    grid-area: f;
    padding-left: 20px;
}

.div19 { 
    grid-area: i;
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
