# ******************************************************************************
# Project: Transition spillovers
# Task:    Import World Bank data and create tidy dataset
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("dplyr", # Used for data wrangling
       "wbstats" # Load world Bank data
       )

load_packages(p)


# ______________________________________________________________________________
# Import World Bank Raw Data 

wbsearch(pattern = "GDP per Capita")

# NY.GDP.PCAP.PP.KD: GDP per capita, PPP (constant 2011 international $)
wb <- wb(indicator = "NY.GDP.PCAP.PP.KD", 
          startdate = 2002, 
          enddate = 2017,
          return_wide = TRUE)

# ______________________________________________________________________________
# Select and recode variables

wb <- wb %>%
  rename(country_iso3c = "iso3c",
         year = "date",
         gdp = "NY.GDP.PCAP.PP.KD") %>%
  mutate(year = as.integer(year))

# ______________________________________________________________________________
# Adjust values for East and West Germany

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Deplicate observations for Germany ----

wb <- wb %>%
  mutate(country_iso3c = ifelse(country_iso3c == "DEU", 
                                "DEW", 
                                country_iso3c)) # Code West Germany

wb <- wb %>% 
  filter(country_iso3c == "DEW") %>%
  mutate(country_iso3c = "DEE") %>% # Code East Germany
  bind_rows(wb)

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Merge with VGRDL data ----

vgrdl <- readRDS(file = file.path("data", "temp", "vgrdl.rds")) 

wb <- wb %>% 
  left_join(vgrdl, by = c("country_iso3c", "year"))

rm(vgrdl)

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Adjust GDP with VGRDL data ----

wb <- wb %>% 
  mutate(gdp = ifelse(!is.na(gap), gdp * gap, gdp))

# ______________________________________________________________________________
# Rescale

wb <- wb %>%
  mutate(lgdp = log(gdp))

# ______________________________________________________________________________
# Select variables and save dataset

wb <- wb %>%
  dplyr::select(country_iso3c, year, lgdp) %>%
  arrange(country_iso3c, year)

saveRDS(wb, file = file.path("data", "temp", "wb.rds")) 

# Clean
rm(load_packages, 
   p,
   wb)
gc()
