# Author: Emma Wood
# Date: 08/01/2021
# Purpose: To create csv data for birthweight: mother age disaggregations for indicator 3.2.2
# Requirements: The data from the source should be saved as a csv, and all data columns MUST be number format without the comma separator
#               This script calls birthweight_by_mum_age_function - if edits are needed to the script that is where you will need to make them

# install.packages("tidyr", dependencies = TRUE)
# install.packages("dplyr", dependencies = TRUE)

rm(list = ls())

library(tidyr)
library(dplyr)


filepath <- "Y:\\Data Collection and Reporting\\Jemalex\\Code for updates\\3.2.2\\Input\\" # you should not need to edit this

filename <- "birthweight_by_mum_age_2017.csv"

year <- "2017"

source("Y:\\Data Collection and Reporting\\Jemalex\\Code for updates\\3.2.2\\birthweight_by_mum_age_function.R")

get_birthweight_by_mother_age_for_csv() 




