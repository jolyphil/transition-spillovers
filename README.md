# Contents
1. [Description](#Description)
  - Author
  - Abstract of the research project
  - What this repository contains
2. [Raw data](#Raw_data)
  - Conditions of use
  - Sources
3. [Generated data and codebook](#Generated_data)
  - Social classes
  - Codebook
4. [Instructions to reproduce the analysis](#Instructions)
  - Necessary software
  - Steps 1 to 6
5. [License](#License)
  - Code

---

# 1 Description <a name="Description"></a>

This repository assembles documentation and materials to reproduce the findings of Philippe Joly's paper entitled "Transition Spillovers? The Protest Behaviour of the 1989 Generation in Europe" (2019) in R and Stata (version 15).

## Author

- [Philippe Joly](http://philippejoly.net/), Humboldt-Universität zu Berlin & WZB Berlin Social Science Center

## Abstract of the research project

Many studies suggest that citizens of Central and Eastern Europe are less politically active than their peers in Western Europe. Yet, it is unclear whether previous experiences of mobilization moderate these differences. This article focuses on the protest behaviour of the 1989 generation, which is composed of citizens who reached political maturity during the collapse of communism. Building on political socialization theory, the article proposes that citizens exposed to high levels of protest during their formative years might be more inclined to protest later. This implies that mobilization during the transitions from communism might moderate the current East-West gap in participation. The article combines data from 25 new and old democracies to assess how early exposure to protest has affected the participation of the 1989 generation. The results of multilevel models indicate that participation in demonstrations is not significantly lower in Central and Eastern Europe once we account for the level of protest at the turn of the nineties. Furthermore, the Eastern deficit in participation in petitions and boycotts is lower in societies that experienced higher levels of protest during the collapse of communism. Some results, however, are sensitive to the inclusion of Eastern Germany, an influential case.

## What this repository contains

* Folders
  * `codebook/` contains the file [`codebook.md`](codebook/codebook.md), the codebook of the final dataset.
  * `data/` stores the master dataset, [`master.dta`](data/master.dta), produced by merging various openly available datasets. The folder also contains two subfolders `raw/`, which contains raw data (some survey data and macro-level indicators), and `temp/`, which will store temporary datasets produced on the fly before merging. 
  * `figures/` contains empty subfolders where figures will be saved in different formats: EPS, GPH, PDF, and PNG.
  * `r_scripts/` contains R scripts to produce the master dataset in the appropriate order. The subfolder `functions/` contains R functions used in many scripts. 
  * `stata_files/` contains Stata do-files in the appropriate order to run the analysis and export tables and figures. The subfolder `dir/` contains the do-file `mydirectory.do`, which loads the maps the working directory into global macros (see [Instructions](#Instructions) below). `logfiles/` is an empty subfolder where Stata logfiles will be stored. The subfolder `programs/` contains a series of do-files. Files with names like `export_*.do` are programms exporting tables and figures. The subfolder`schemes/` contains the file [`minimal.scheme`](stata_files/scheme/minimal.scheme), a Stata scheme I designed.
  * `tables/` contains empty subfolders where tables will be saved in TEX or RTF formats.

* Other key documents
  * [CONTRIBUTING.md](CONTRIBUTING.md): How to contribute to the development of this project.
  * [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md): The code of conduct that contributors are expected to adhere to.

# 2 Raw data <a name="Raw_data"></a>

The master dataset on which are based the figures and the tables combines data from four sources:
1. The European Social Survey, rounds 1 to 8;
2. The European Values Study, Wave 2;
3. The World Bank's World Development Indicators;
4. The Arbeitskreis “Volkswirtschaftliche Gesamtrechnungen der Länder” (for economic data on Eastern and Western Germany).

## Conditions of use

Please consult the conditions of use of the [ESS]( http://www.europeansocialsurvey.org/data/conditions_of_use.html), the [EVS]( https://www.gesis.org/en/services/data-analysis/international-survey-programs/european-values-study/data-access/), the [World Bank data](https://data.worldbank.org/summary-terms-of-use), and data from the [Arbeitskreis “Volkswirtschaftliche Gesamtrechnungen der Länder” (VGRdL)](https://www.statistik-bw.de/VGRdL/Impressum.jsp) before downloading the data. 

## Sources

### ESS

ESS. 2002. ESS Round 1: European Social Survey Round 1 Data. Data file edition 6.5. NSD - Norwegian Centre for Research Data, Norway - Data Archive and distributor of ESS data for ESS ERIC.

ESS. 2004. ESS Round 2: European Social Survey Round 2 Data. Data file edition 3.5. NSD - Norwegian Centre for Research Data, Norway - Data Archive and distributor of ESS data for ESS ERIC.

ESS. 2006. ESS Round 3: European Social Survey Round 3 Data. Data file edition 3.6. NSD - Norwegian Centre for Research Data, Norway - Data Archive and distributor of ESS data for ESS ERIC.

ESS. 2008. ESS Round 4: European Social Survey Round 4 Data. Data file edition 4.4. NSD - Norwegian Centre for Research Data, Norway - Data Archive and distributor of ESS data for ESS ERIC.

ESS. 2010. ESS Round 5: European Social Survey Round 5 Data. Data file edition 3.3. NSD - Norwegian Centre for Research Data, Norway - Data Archive and distributor of ESS data for ESS ERIC.

ESS. 2012. ESS Round 6: European Social Survey Round 6 Data. Data file edition 2.3. NSD - Norwegian Centre for Research Data, Norway - Data Archive and distributor of ESS data for ESS ERIC.

ESS. 2014. ESS Round 7: European Social Survey Round 7 Data. Data file edition 2.1. NSD - Norwegian Centre for Research Data, Norway - Data Archive and distributor of ESS data for ESS ERIC.

ESS. 2016. ESS Round 8: European Social Survey Round 8 Data. Data file edition 2.0. NSD - Norwegian Centre for Research Data, Norway - Data Archive and distributor of ESS data for ESS ERIC.

### EVS

EVS. 2015. European Values Study Longitudinal Data File 1981-2008, ZA4804 Data File, Version 3.0.0. Cologne: GESIS Data Archive. (https://doi.org/10.4232/1.12253)

### World Bank

World Bank. 2018. World Development Indicators. (https://datacatalog.worldbank.org/dataset/world-development-indicators)

### Arbeitskreis “Volkswirtschaftliche Gesamtrechnungen der Länder” (VGRdL)

Arbeitskreis “Volkswirtschaftliche Gesamtrechnungen der Länder,” ed. 2018. Bruttoinlandsprodukt, Bruttowertschöpfung in Den Ländern Der Bundesrepublik Deutschland 1991 Bis 2017. Stuttgart: Statistisches Landesamt Baden-Württemberg. (https://www.statistik-bw.de/VGRdL/)


# 3 Generated data and codebook <a name="Generated_data"></a>

Transformations operated on the ESS, EVS, World Bank, and VGRdL data are described in a series of R scripts. `r_scripts/00_master.R`calls the scripts sequentially. Data is generated by recoding existing variables. For most variables, this involved minimal transformation (e.g., renaming or merging categories together). 

## Social classes

Social classes were coded using [scripts provided by Daniel Oesch](http://people.unil.ch/danieloesch/scripts/). These do-files recode occupation variables in the ESS to create 5-, 8-, or 16-class schemas. This paper uses the 5-class schema. More information on how to use the scripts in R can be found [here](http://philippejoly.net/files/code/oesch-class-ess-R/vignette.html).

See:

Oesch, Daniel. 2006a. "Coming to Grips with a Changing Class Structure: An Analysis of Employment Stratification in Britain, Germany, Sweden and Switzerland." _International Sociology_ 21(2):263-88.

Oesch, Daniel. 2006b. _Redrawing the Class Map: Stratification and Institutions in Britain, Germany, Sweden and Switzerland_. Houndmills, Basingstoke, Hampshire: Palgrave Macmillan.

## Codebook

Running `r_scripts/00_master.R` will generate the master dataset, `data/master.dta`. The repository contains a [codebook](codebook/codebook.md) describing all variables in the final dataset.

# 4 Instructions to reproduce the analysis <a name="Instructions"></a>
A few steps are necessary to run the analysis.

## Necessary software

R is used to generate the master dataset and Stata is used to run the analysis and export the tables and the figures. Why did I use both programs? My first intention was to perform all the empirical work in R to share the procedure to a broader audience. Unfortunately, the multilevel models failed to converge in R while they worked directly with Stata's `melogit` command. Also, Stata offered the possibility to weight the results based on the ESS post-stratification weights.

If you do not want to generate the master dataset yourself and would like to jump right into the analysis, the final data is stored in the repository under `data/master.dta`. Running the R scripts will simply regenerate this file. 

## Steps 1 to 6

* If you want to replicate the analysis using the raw data, go through steps 1 to 6.
* If you want to start from the final dataset, do step 1 and jump directly to steps 5 and 6. 

### Step 1: Clone the repository

* Clone or download the repository on your own computer. 

### Step 2: Download the EVS data

* Download the EVS Longitudinal datafile 1981-2008 (ZA4804 Data file Version 3.0.0, Stata Dataset) from the [Gesis website](https://doi.org/10.4232/1.12253).
* Unzip the file.
* Save the dataset in the working directory as `data/raw/ZA4804_v3-0-0.dta`.

### Step 3: Save your email address to download the ESS datafiles 

* The R scripts can download the ESS datafiles on the fly if you provide an email address registered on the ESS website. 
* Be sure to register on the [ESS website](https://www.europeansocialsurvey.org/user/login).
* Open the R script `r_scripts/02_ess.R`.
* On line 23, replace `your@email.com` by your own registered email.
* Save `r_scripts/02_ess.R`.

### Step 4: Generate the master dataset 

* In RStudio, open the project `transition-spillovers.Rproj`.
* Rrun `r_scripts/00_master.R` to generate the master dataset.

### Step 5: Set up your working directory for Stata

* Before running the analysis you have to map your working directory in global macros. If you cloned the repository, the only change you need to do is to save the path to your local copy of the repository.
* Update the do-file `stata_files/dir/00_mydirectory.do` to save the path to your working directory.
* Run `stata_files/dir/00_mydirectory.do`.

### Step 6: Run the analysis

* Run `0_master.do`. 

# 5 License <a name="License"></a>

## Code

Code associated with this project carries the following license: [![License:MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# 6 Citation

You can refer to the first release of this repository as:

Philippe Joly. (2019, February 8). Transition Spillovers? The Protest Behaviour of the 1989 Generation in Europe. Documentation and materials. First release (Version v1.0). Zenodo. [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2560280.svg)](https://doi.org/10.5281/zenodo.2560280)
