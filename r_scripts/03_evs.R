# ******************************************************************************
# Project: Transition spillovers
# Task:    Import EVS data and create tidy dataset
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("countrycode", # Harmonize country codes
       "dplyr", # Used for data wrangling
       "haven", # Used to import Stata and SPSS files
       "magrittr", # Allow pipe operator
       "survey" # Handle post-stratification weights
       )

load_packages(p)

#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Set path to EVS data ---- 

datapath <- file.path("data", "raw", "ZA4804_v3-0-0.dta")

# ______________________________________________________________________________
# Import EVS-2 data

#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Load raw dataset ----

evs2_raw <- datapath %>%
  
  # Convert Stata datafile to R dataframe
  read_dta  %>%
  
  # Keep second wave only
  filter(S002EVS == 2)

#_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Select and recode variables ----

evs <- evs2_raw %>%
  
  # Select useful variables
  select(S003A, S017A, S020, E027, X002, X003)  %>%
  
  # Rename variables
  rename(country = S003A, weight = S017A, year = S020, demonstration = E027, 
         yrbrn = X002, age = X003) %>%
  
  # Convert country names to ISO3C
  mutate(country_iso3c = case_when(
    country == 900 ~ "DEW", # Special case: Western Germany
    country == 901 ~ "DEE", # Special case: Eastern Germany
    country == 909 ~ "NIE", # Special case: Northern Ireland
    TRUE ~ countrycode(country, 'wvs', 'iso3c'))
    ) 

rm(evs2_raw)

# ______________________________________________________________________________
# Compute weighted mean

get_subpop_mean <- function(var, cond, weight){
  
  # Assemble variables as "mini" survey
  df <- data.frame(var, cond, weight)
  
  # Save survey design
  dfpc <- svydesign(id = ~1, weights= ~weight, data = df)
  
  # Save subpopulation
  dsub <- subset(dfpc, cond)
  
  # Extract mean of subpopulation
  svymean(~var,design=dsub, na.rm=T)[[1]]
}

evs <- evs %>%
  filter(!is.na(demonstration)) %>%
  
  mutate(demonstration = as.numeric(demonstration == 1),
         # Subpopulation: 1989 generation
         gen1989 = yrbrn >= 1964 & yrbrn <= 1972) %>%
  
  group_by(country_iso3c) %>%
  
  summarize(earlyprotest = get_subpop_mean(var = demonstration,
                                      cond = gen1989,
                                      weight = weight))

# ______________________________________________________________________________
# Clean and save main dataset

saveRDS(evs, file = file.path("data", "temp", "evs.rds"))

# clean environment
rm(evs, 
   datapath, 
   get_subpop_mean, 
   load_packages, 
   p)

