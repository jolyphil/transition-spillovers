load_packages <- function(p){
    
  load_one_package <- function(one_package){
    if (one_package %in% rownames(installed.packages()) == FALSE){
      # install.packages(p,dep=TRUE)
      install.packages(one_package)
    }
    
    if(!require(one_package,character.only = TRUE)) {
      stop("Package not found")
    }
    
    require(one_package,character.only = TRUE)
    
  }
  
  sapply(p, load_one_package)
  
}