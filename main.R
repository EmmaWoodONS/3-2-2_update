# Author: Emma Wood
# Date: 08/01/2021
# Purpose: To create csv data for birthweight: mother age disaggregations for indicator 3.2.2
# Requirements: The data from the source should be saved as a csv, and all data columns MUST be number format without the comma separator
#               This script calls birthweight_by_mum_age_function - if edits are needed to the script that is where you will need to make them

# install.packages("tidyr", dependencies = TRUE)
# install.packages("dplyr", dependencies = TRUE)
# install.packages("tidyxl", dependencies = TRUE)
# install.packages("unpivotr", dependencies = TRUE)

rm(list = ls())

library(tidyr)
library(dplyr)
library(tidyxl)
library(unpivotr)
library(stringr)



working_directory <- "H:\\Coding_repos\\3-2-2_update\\" # you should not need to edit this
filename <- "Input/cms2018workbookf.xlsx"

birthweight_by_mum_age_tab_name <- "Table 10"
first_header_row_birthweight_by_mum_age <- 4

country_of_occurrence_by_sex_tab_name <- "Table 2"
first_header_row_country_by_sex <- 4


# source(paste0(filepath,"basic_checks_and_setup.R"))
source("birthweight_by_mum_age_function.R")


# run_basic_checks_and_setup()
get_birthweight_by_mother_age_for_csv() 
