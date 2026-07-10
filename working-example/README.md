# Working Example 


The following code executes a working example of the datagoodR workflow. 

## Step 0: Save data file in data-dev/ directory. 

Currently data-dev/DEMO-DATA-SMALL.csv is a good example. 

## Step 1: Create the DGF

Run the STEP1.R file to create the DGF. This step inputs a data file then outputs 
the DGF as an excel and csv file. These files can then be manually (or iteratively)
updated until they have all the information you want. 

This step creates DGF-V1.csv and DGF-V1.xlsx as the "first" attempt at a DGF. 
Then makes DGF-V2.csv and DGF-V2.xlsx as "updated" versions with more information. 

The goal of the DGF is to store the "minimum" amount of information to render the 
research guide without needed to read the raw data into the quarto document in
step 3. 

## Step 2: Validate the DGF

Run the STEP2.R file to validate the DGF before rendering. `inspect_dgf()`
checks that each column is in a format Step 3 can handle: all required columns
are present, every `vtype_class` is renderable, the JSON columns still contain
valid JSON, every function named in `vconvert`/`vformat` is defined, and every
variable has an `rg_hash`. It prints a report and returns `report$valid` plus a
list of any problems found.

## Step 3: Render the RG


This step inputs the DGF you made in step 1 (and vaildated in step 2) 
then renders qmd-templates/RG.qmd file. This file makes the reacher guide in PDF 
and HTML file type at qmd-template/RG.pdf and qmd-template/RG.html. 

If you are only generating documentation for this data set one time, you can stop 
here. Step 4 and 5 are for when you need to regularly update the data, and thus 
regularly update the associated RG. 


## Step 4: Refresh the DGF

Run the STEP4.R file to refresh the DGF when the data set is updated.
`update_dgf()` compares the new data to the old DGF using each variable's
`rg_hash`: if the new hash matches, that variable is unchanged and its curated
DGF row is kept as-is; if it differs, that variable's data summaries
(`rg_[preview/properties/stats/graphics/hash]`) are refreshed. Curated fields
and hand-edited factor level labels are preserved, and any added / removed
variables are reported. The updated DGF is written to `DGF-V3.*`.


## Step 5: Customize

The R/05*.R functions are designed for customization of the RG. This could be templates, 
div arrangements, fonts, colors, or "polishing" functions for the variables (such as `dollarize`
for monetary values). 
