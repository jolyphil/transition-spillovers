# ******************************************************************************
# Project: Transition spillovers
# Task:    Extract ESS country-specific data for Germany
# Author:  Philippe Joly, WZB & HU-Berlin
# ******************************************************************************

source("r_scripts/functions/load_packages.R")

p <- c("dplyr", # Used for data wrangling
       "foreign", # Converts SPSS files to R objects
       "stringr" # Performs string operations
)

load_packages(p)

# ______________________________________________________________________________
# Find paths to country-specific datasets ====

spssfiles <- file.path("data", "raw") %>% 
  list.files() %>%
  .[(str_detect(., "ESS[:digit:]csDE.(por|sav)"))]

# ______________________________________________________________________________
# Save datasets as RDS ====

for (i in seq_along(spssfiles)) {
  
  rootname <- str_sub(spssfiles[i], end = -5)
  
  spssfilepath <- file.path("data", "raw", spssfiles[i])
  
  rdsfilepath <- file.path("data", "temp", paste0(rootname, ".rds"))
  
  temp <- read.spss(spssfilepath, use.value.labels = F, to.data.frame = T) %>%
    as_tibble()
  
  # Rename variable names to lowercase
  names(temp) <- names(temp) %>% 
    tolower()
  
  # Create new variable: where respondent lived before 1990
  if (any(names(temp) == "splow2de")) { # var. name for ESS 1, 2, 3, 4, 6, 7, 8
    temp <- temp %>% 
      mutate(wherebefore1990 = splow2de)
  } else if (any(names(temp) == "n3")) { # var. name for ESS 5
    temp <- temp  %>% 
      mutate(wherebefore1990 = n3)
  } else {
    print("Wrong data!")
    break
  }
  
  temp <- temp %>% 
    select(idno, cntry, wherebefore1990)
  
  rdsfilepath %>% saveRDS(temp, file = .)
}

# ______________________________________________________________________________
# Clear ====

rm("i",
   "load_packages",
   "p",
   "rdsfilepath",
   "rootname",
   "spssfilepath",
   "spssfiles",
   "temp")