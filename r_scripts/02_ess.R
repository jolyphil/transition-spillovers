# ******************************************************************************
# Project: Transition spillovers
# Task:    Import ESS data and create tidy dataset
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("countrycode", # Harmonize country codes
       "dplyr", # Used for data wrangling
       "essurvey", # Download main ESS datafiles
       "forcats", # Factor operations
       "labelled", # Download main ESS datafiles
       "RCurl", # Download file from Internet
       "readr" # Import CSV data
       )

load_packages(p)

# ______________________________________________________________________________
# Save ESS email ====

ess_email <- "your@email.com" # <-- Replace: your email has to be
                              #              registered on the ESS
                              #              website.

# ______________________________________________________________________________
# Download and save ESS datasets ====
# 
for (i in 1:8) {
rootname <- paste0("ESS", i)
  rdafilepath <- file.path("data", "temp", paste0(rootname, ".rds"))
  import_rounds(rounds = i, ess_email = ess_email) %>%
  saveRDS(file = rdafilepath)
}

# ______________________________________________________________________________
# Append datasets ====

for (i in 1:8) {
  
  # _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
  # Import rds file ----
  
  round_i <- file.path("data", "temp", paste0("ESS", i, ".rds")) %>% 
   readRDS() %>%
   recode_missings()
  
  # _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
  # year, harmonize variable name ----
 
 if (i < 3) { # inwyr, "year of interview" --> only in ESS1 and ESS2
   round_i <- round_i %>%
     group_by(cntry) %>%
     mutate(year = round(mean(inwyr, na.rm = T))) %>%
     ungroup
   
 } else { # inwyys, "Start of interview, year" --> in essround > 2
   round_i <- round_i %>%
     group_by(cntry) %>%
     mutate(year = round(mean(inwyys, na.rm = T))) %>%
     ungroup
 } 
 
 # Add old education var (in ESS 1 to 4) if missing
 if (any(names(round_i) == "edulvla") == F) { 
   round_i <- round_i %>%
     mutate(edulvla = NA)
 }
 
  # _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
  # Merge with German country-specific data ----
  
  round_i <- paste0("ESS", i, "csDE.rds") %>% # get file name
    file.path("data", "temp", .) %>%
    readRDS() %>%
    left_join(round_i, ., by = c("cntry", "idno"))

  # _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
  # Select variables ----
  
  round_i <- round_i %>%
    dplyr::select(essround, 
                  idno, 
                  cntry, 
                  year,
                  dweight,
                  sgnptit,
                  pbldmn,
                  bctprd,
                  yrbrn,
                  gndr,
                  eisced,
                  edulvla,
                  mnactic,
                  mbtru,
                  domicil,
                  brncntr,
                  intewde,
                  wherebefore1990)
 
 if (i == 1) {
   ess <- round_i
 } else {
   ess <- rbind(ess, round_i)
 }
 
}

# Remove temporary dataset
rm(round_i, i)

# ______________________________________________________________________________
# Recode and rename variables ====

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Country | cntry --> country_iso3c ----

ess <- ess %>%
  mutate(country_iso3c = case_when(
    cntry == "DE" & intewde == 1 ~ "DEE", # East Germany
    cntry == "DE" & intewde == 2 ~ "DEW", # West Germany
    cntry == "XK" ~ "XKX", # Kosovo
    TRUE ~ countrycode(cntry, 'iso2c', 'iso3c')))

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Country-wave | country_iso3c, essround --> countrywave ----

ess <- ess %>%
 mutate(countrywave = paste0(country_iso3c, essround))

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# 1989 generation | --> gen1989 ----

ess <- ess %>%
  mutate(gen1989 = case_when(yrbrn >= 1964 & yrbrn <= 1972 ~ 1,
                             TRUE ~ 0))

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Protest | sgnptit, bctprd, pbldmn --> petition, boycott, demonstration ----

recode_action_var <- function(var) {
  var_label <- c("Not done", "Has done")
  r <- case_when(var == 1 ~ "Has done",
                 var == 2 ~ "Not done")
  r <- r %>% factor(levels = var_label)
  return(r)
}

ess <- ess %>%
  mutate(petition = recode_action_var(sgnptit),
         boycott = recode_action_var(bctprd),
         demonstration = recode_action_var(pbldmn))

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Gender (woman) | gndr --> female ----

var_levels <- c("Male", "Female")

ess <- ess %>%
  mutate(female = case_when(gndr == 1 ~ "Male", 
                            gndr == 2 ~ "Female"),
         female = factor(female, levels = var_levels)) 

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Relative age | yrbrn --> agerel ----  

# Age relative to others within cohort
ess <- ess %>%
  mutate(agerel = as.numeric(yrbrn) - 1964)

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Year of birth | yrbrn --> yrbrn ----  

ess <- ess %>%
  mutate(yrbrn = as.numeric(yrbrn))

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Highest level of education (3 categories) | eisced --> edu ----

var_levels <- c("Lower", "Medium", "Higher")

ess <- ess %>%
  mutate(edu = case_when(eisced %in% c(1:2) ~ "Lower", 
                          eisced %in% c(3:4) ~ "Medium",
                          eisced %in% c(5:7) ~ "Higher",
                          eisced == 0 & edulvla %in% c(1:2) ~ "Lower",
                          eisced == 0 & edulvla %in% c(3:4) ~ "Medium",
                          eisced == 0 & edulvla == 5 ~ "Higher"),
         edu = factor(edu, levels = var_levels)) 

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Unemployed | mnactic --> unemp ----

var_levels <- c("Other", "Unemployed")

ess <- ess %>%
  mutate(unemp = case_when(mnactic %in% c(3,4) ~ "Unemployed",
                           mnactic %in% c(1,2,5,6,7,8,9) ~ "Other"),
         unemp = factor(unemp, levels = var_levels))

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Native | brncntr --> native ----

var_levels <- c("Not native", "Native")

ess <- ess %>%
  mutate(native = case_when(brncntr == 1 ~ "Native",
                            brncntr == 2 ~ "Not native"),
         native = case_when(country_iso3c == "DEW" & wherebefore1990 != 2 ~ "Not native",
                            country_iso3c == "DEE" & wherebefore1990 != 1 ~ "Not native",
                            TRUE ~ native),
         native = factor(native, levels = var_levels)
  )

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Member of trade union (currently or previously) | mbtru --> union ----

var_levels <- c("Not member", "Member")

ess <- ess %>%
  mutate(union = case_when(mbtru %in% c(1,2) ~ "Member",
                           mbtru == 3 ~ "Not member"),
         union = factor(union, levels = var_levels))

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Size of town | domicil --> city ----

var_levels <- c("Home in countryside", 
                "Country village", 
                "Town or small city", 
                "Outskirts of big city", 
                "Big city")

ess <- ess %>%
  mutate(city = case_when(domicil == 1 ~ "Big city",
                          domicil == 2 ~ "Outskirts of big city",
                          domicil == 3 ~ "Town or small city",
                          domicil == 4 ~ "Country village",
                          domicil == 5 ~ "Home in countryside"),
         city = factor(city, levels = var_levels))

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Social class | Import Oesch data (Oesch 2006) --> class5 ----

ess <- "https://raw.githubusercontent.com/jolyphil/" %>% # download class data
  paste0("oesch-class/master/data/oesch_class_ess_1-8.csv") %>% # from GitHub
  getURL() %>%
  read_csv() %>%
  mutate(essround = as.numeric(essround), # convert variable class to allow join
         idno = as.numeric(idno)) %>%
  dplyr::select(essround, cntry, idno, class5) %>%
  left_join(ess, ., by = c("essround", "cntry", "idno"))

var_levels <- c("Unskilled workers",
                "Skilled workers",
                "Small business owners",
                "Lower service class",
                "Higher service class")

ess <- ess %>%
  mutate(class5 = case_when(class5 == 1 ~ "Higher service class",
                            class5 == 2 ~ "Lower service class",
                            class5 == 3 ~ "Small business owners",
                            class5 == 4 ~ "Skilled workers",
                            class5 == 5 ~ "Unskilled workers"),
         class5 = factor(class5, levels = var_levels))

# ______________________________________________________________________________
# Clean and save main dataset ====

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Select variables for final dataset ----

ess <- ess %>% 
  dplyr::select(essround,
         idno,
         country_iso3c,
         countrywave,
         year,
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
         class5)

# _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
# Save dataset ----

saveRDS(ess, file = file.path("data", "temp", "ess.rds")) 

# ______________________________________________________________________________
# Clean environment

rm(ess,
   ess_country_years,
   ess_email,
   load_packages,
   p,
   var_levels, 
   recode_action_var,
   rdafilepath,
   rootname)

gc()