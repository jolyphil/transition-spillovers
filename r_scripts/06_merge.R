# ******************************************************************************
# Project: Transition spillovers
# Task:    Merge micro and macro data
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("dplyr", # Used for data wrangling
       "haven", # Export to Stata
       "magrittr" # Use pipe operator
       )

load_packages(p)

# ______________________________________________________________________________
# Load datasets ----

ess <- file.path("data", "temp", "ess.rds") %>% 
  readRDS()

evs <- file.path("data", "temp", "evs.rds") %>%
  readRDS() 

wb <- file.path("data", "temp", "wb.rds") %>% 
  readRDS()

# ______________________________________________________________________________
# Merge datasets ----

master <- ess %>% 
  inner_join(evs) %>%
  inner_join(wb) %>%
  arrange(country_iso3c) %>%
  rename(country = country_iso3c) # Rename country variable

rm(ess, evs, wb)

# ______________________________________________________________________________
# Create between- and within country variable ----

master <- master %>%
  group_by(country) %>%
  mutate(lgdp_mean = mean(lgdp),
         lgdp_diff = lgdp - lgdp_mean) %>%
  ungroup() %>%
  select(-lgdp)

# ______________________________________________________________________________
# Create dummy for new democracies ----

var_levels <- c("Old democracy",
                "New democracy")

old <- c("AUT", "BEL", "DEW", "DNK", "ESP", "FIN", "FRA", "GBR", "IRL", "ISL", 
         "ITA", "NLD", "NOR", "PRT", "SWE")
new <- c("BGR", "CZE", "DEE", "EST", "HUN", "LTU", "LVA", "POL", "SVK", "SVN")
  
master <- master %>% 
  mutate(newdem = case_when(country %in% old ~ "Old democracy",
                            country %in% new ~ "New democracy"),
         newdem = factor(newdem, levels = var_levels))

# ______________________________________________________________________________
# reorder variables ----

master <- master  %>% 
  dplyr::select(essround,
                idno,
                country,
                countrywave,
                dweight,
                demonstration,
                petition,
                boycott,
                gen1989,
                female,
                agerel,
                edu,
                unemp,
                union,
                native,
                city,
                class5,
                newdem,
                earlyprotest,
                year,
                lgdp_mean,
                lgdp_diff)

# ______________________________________________________________________________
# Save master dataset

file.path("data", "master.rds") %>%
  saveRDS(master, file = .) 

file.path("data", "master.dta") %>%
  write_dta(master, path = .) 

# ______________________________________________________________________________
# Clear

rm(load_packages,
   master,
   new,
   old,
   p,
   var_levels)

gc()


