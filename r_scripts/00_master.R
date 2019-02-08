# ******************************************************************************
# Project: Transition spillovers
# Task:    Execute all the R scripts
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("magrittr" # Allow pipe operator
       )

load_packages(p)

# ______________________________________________________________________________
# Execute all R scripts

# Task 1: Extract ESS country-specific data for Germany
file.path("r_scripts", "01_essDE.R") %>% source()

# Task 2: Import ESS data and create tidy dataset
file.path("r_scripts", "02_ess.R") %>% source()

# Task 3: Import EVS data and create tidy dataset
file.path("r_scripts", "03_evs.R") %>% source()

# Task 4: Import German regional data and calculate gap in GDP per capita
#         between Eastern and Western Germany
file.path("r_scripts", "04_vgrdl.R") %>% source()

# Task 5: Import World Bank data and create tidy dataset
file.path("r_scripts", "05_wb.R") %>% source()

# Task 6: Merge micro and macro data
file.path("r_scripts", "06_merge.R") %>% source()
