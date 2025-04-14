# datagoodr
R package for documenting and profiling research datasets. Gooder data means gooder research.


## Acronyms 

- RG = Research Guide
- DGF = Data Governance File/Framework

## Current file structure; 

- data-dev/ contains all the data for testing purposes
  - DEMO-DATA-SMALL.CSV is the small data set used for testing
  - DGF-CORE-CO-2019-V1.xlsx is a template of what the DGF should looks like that was created by hand to serve as an example.
  - DGF-CORE-CO-2019-blank.xlsx is used in the datagoodr pipeline for examples of adding meta data to each variable. 
  - DGF.csv and DGF.xlsx are examples of generated DGF from Step 01 (see below)
  


- dev/ contains some documentation of the work flow and tasks that still need to be done 
  - 03-work-flow.md describes the workflow for Step 3 (see below)
  - data-type-funcs.md describes the functions and their locations for each data type in Steps 1 and 3 below 
  - TO-DO.md is a list of things that still need to be addressed 
  
  
- DRAFT/ is all the draft scripts 


-  pptx/ are various powerpoints describing the overall goals of the datagoodr package

- qmd-templates contains quarto documents templates for the final research guide 
  - qmd-templates-DRAFT/ contains all the draft files 
  - test-render/ contains testing scripts 
  - RG_files contains meta data that is updated with RG.md is rendered 
  - RG.qmd is the script to generate the research guide from Step 3 below 
  - RG.html, .html.md, .md, .pdf are the rendered RG
  
- R/ contains all the R scripts used in the datagoodr pipeline
  - 01*.R scripts are scripts used for Step 1
  - 02*.R scripts are scripts used for Step 2
  - 03*.R scripts are scripts used for Step 3
  - 04*.R scripts are scripts used for Step 4
  - 05*.R scripts are scripts used for Step 5
  
- working-example/ contains scripts and instructions for a working example of the datagoodr package. 



## Workflow

The datagoodr general work flow is listed below. See working-example/README.md for instructions on how to execute this workflow in the current set up. 


### Step 0: Save data file in data-dev/ directory. 

Currently data-dev/DEMO-DATA-SMALL.csv is a good example. 

### Step 1: Create the DGF

This step inputs a data file from Step 0 then outputs 
the DGF as an excel and csv file. These files can then be manually (or iteratively)
updated until they have all the information you want.  

The goal of the DGF is to store the "minimum" amount of information to render the 
research guide without needed to read the raw data into the quarto document in
step 3. Once the DGF is generated, the raw data is no longer needed to generate the RG. 

Data inside each cell of the DGF is generally stored in JSON format. 


### Step 2: Validate the DGF

This step would include many of the DGF validation steps in the R/02*.R files. 
This is not currently operational. The goal of this step is to validate each 
column to make sure it is in a format that step 3 can process correctly. 

### Step 3: Render the RG

This step inputs the DGF you made in step 1 (and validated in step 2) then makes the 
 research guide in PDF  and HTML file types. 

If you are only generating documentation for this data set one time, you can stop 
here. Step 4 and 5 are for when you need to regularly update the data, and thus 
regularly update the associated RG. 


## Step 4: Refresh the DGF

When the data set is updated, this step is meant to compare the old data set to the new one. 
If anything changed, the DGF should also updated. This updating is designed to be done through the 
rg_hash column of the DGF. The hashing allows us to check if a variable needs to up updated 
in the DGF without actually verifying each individual entry. 

In the new data set for each variable, generate the hash value. If the new hash value
matches the one in the rg_hash column of the old DGF, no need to update that variable, great! 
If the new hash value does not match the  one in the rg_hash column of the old DGF, then 
that variable's rg_[preview/properties/stats/graphics/hash] need to be updated. 


## Step 5: Customize

The R/05*.R functions are designed for customization of the RG. This could be templates, 
div arrangements, fonts, colors, or "polishing" functions for the variables (such as `dollarize`
for monetary values). 