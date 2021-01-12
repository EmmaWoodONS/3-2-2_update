# Author: Emma Wood
# Date: 08/01/2021
# Purpose: To create csv data for birthweight: mother age disaggregations for indicator 3.2.2
# Requirements: This script is called by birthweight_by_mum_age_to_csv.R

'%not_in%' <- Negate('%in%')

get_birthweight_by_mother_age_for_csv <- function() { 
  
  setwd(filepath)
  source_data <- read.csv(filename)
  
  required_column_names <- c("Birthweight", "Mother_age", "Live_births", "Early_neonatal", "Neonatal", "Rates_Neonatal")
  
  columns_present <- names(source_data)
  all_required_columns_present <- length(columns_present[columns_present %in% required_column_names]) == length(required_column_names)
  
  if (all_required_columns_present == FALSE) {
    
    print("ERROR: Some columns may not be correctly named. See the README.txt file for requirements.
                The following columns are required and must be named exactly as below, including capitalisation and underscores:")
    required_column_names
    
  } else {
    
    no_whitespace <- as.data.frame(apply(source_data, 2, function(x)gsub("\\s+", "", x)))
    
    no_extra_columns <- no_whitespace[, substr(colnames(no_whitespace), 1, 1) != "X"]
    
    thousands_separator_present <- ifelse(length(grep(",", no_extra_columns$Live_births)) > 0|
                                            length(grep(",", no_extra_columns$Early_neonatal)) > 0|
                                            length(grep(",", no_extra_columns$Neonatal)) > 0 |
                                            length(grep(",", no_extra_columns$Rates_Neonatal)) > 0,
                                          TRUE, FALSE)
    if (thousands_separator_present == TRUE) {
      
      print(paste0("ERROR: Data MUST be in number format WITHOUT the thousands separator. Please ammend this in ", filename, ", save it, and try again."))
      
    } else {
      
      clean_data <- no_extra_columns %>% 
        filter((Mother_age != "" & Live_births != "")) %>% 
        mutate(Birthweight = ifelse(Birthweight == "", NA, as.character(Birthweight))) %>% 
        mutate(Live_births = as.numeric(as.character(Live_births)),
               Early_neonatal = as.numeric(as.character(Early_neonatal)),
               Neonatal = as.numeric(as.character(Neonatal)),
               Rates_Neonatal = as.numeric(as.character(Rates_Neonatal))) %>% 
        mutate(Birthweight = ifelse(Birthweight == "over", NA, Birthweight)) %>% # "4000 and over" spreads onto two rows in the csv. when we fill NA rows we want to fill it with "4000and", not with "over"
        fill(Birthweight)
      
      late_neonatal <- clean_data %>% 
        mutate(Late_neonatal = Neonatal - Early_neonatal) %>% 
        mutate(Rates_Late_neonatal = ifelse(Late_neonatal > 3, 
                                            round(Late_neonatal / (Live_births / 1000), 1),
                                            NA),
               Rates_Early_neonatal = ifelse(Early_neonatal > 3, 
                                             round(Early_neonatal / (Live_births / 1000), 1),
                                             NA),
               # overall neonatal rates are calculated already in the download, so we can check our calcs against these
               Rates_Neonatal_check = ifelse(Neonatal > 3,
                                             round(Neonatal / (Live_births / 1000), 1),
                                             NA))
      check_rate_calcs <- late_neonatal %>% 
        mutate(rate_calcs_comparison = ifelse(Rates_Neonatal_check == Rates_Neonatal, 0, 1)) %>% 
        summarise(check_rate_calcs = sum(rate_calcs_comparison, na.rm = TRUE))
      check_rate_calcs_pass <- ifelse(check_rate_calcs[1, 1] == 0, "passed", "FAILED")
      print(paste("check of rate caclulations has", check_rate_calcs_pass))
      
      if (check_rate_calcs_pass == "passed") {
        
        data_in_csv_format <- late_neonatal %>% 
          select(Birthweight, Mother_age, 
                 # Early_neonatal, Late_neonatal, Neonatal, 
                 Rates_Early_neonatal, Rates_Late_neonatal, Rates_Neonatal) %>% 
          pivot_longer(
            cols = starts_with("Rates"),
            names_to = "Neonatal_period",
            values_to = "Value")
        
        clean_csv_data <- data_in_csv_format %>% 
          mutate(Neonatal_period = gsub("Rates_", "", Neonatal_period),
                 Neonatal_period = gsub("_", " ", Neonatal_period),
                 Neonatal_period = ifelse(Neonatal_period == "Neonatal", "", Neonatal_period),
                 Mother_age = gsub("-", " to ", Mother_age),
                 Mother_age = gsub("&", " and ", Mother_age),
                 Mother_age = gsub("<", "Less than ", Mother_age),
                 Mother_age = ifelse(Mother_age == "Notstated", "Not stated", Mother_age),
                 Mother_age = ifelse(Mother_age == "All", "", Mother_age),
                 Birthweight = gsub("-", " to ", Birthweight),
                 Birthweight = gsub("<", "Less than ", Birthweight),
                 Birthweight = gsub("and", " and over", Birthweight),
                 Birthweight = ifelse(Birthweight == "<", "Less than", Birthweight),
                 Birthweight = ifelse(Birthweight == "Notstated", "Not stated", Birthweight),
                 Birthweight = ifelse(Birthweight == "All", "", Birthweight)) %>% 
          rename(`Neonatal period` = Neonatal_period,
                 Age = Mother_age) %>% 
          mutate(Year = year,
                 Sex = "",
                 Country = "England and Wales",
                 Region = "",
                 `Health board` = "",
                 `Unit measure` = "Rate per 1,000 live births",
                 `Unit multiplier` = "Units", 
                 `Observation status` = "Undefined",
                 GeoCode = "K04000001",
                 Value = ifelse(is.na(Value), "", Value)) %>% 
          select(Year, Sex, Country, Region, `Health board`, Birthweight, Age, `Neonatal period`, `Unit measure`, `Unit multiplier`, `Observation status`, GeoCode, Value)
        
        accepted_birthweight_categories <- c("", "Less than 1000", "1000 to 1499", "1500 to 1999", "2000 to 2499", "2500 to 2999", "3000 to 3499", "3500 to 3999", "4000 and over", "Not stated")
        accepted_mother_age_categories <- c("", "Less than 20", "20 to 24", "25 to 29", "30 to 34", "35 to 39", "40 and over", "Not stated")
        
        number_of_correct_birthweight_categories <- sum(unique(clean_csv_data$Birthweight) == accepted_birthweight_categories)
        birthweight_categories_match <- ifelse(number_of_correct_birthweight_categories == length(accepted_birthweight_categories), TRUE, FALSE)
        if (birthweight_categories_match == FALSE){ 
          birthweight_category_warning <- paste("WARNING: Birthweight categories in the new data do not match the expected categories.", 
                                                "Please check the output for strange birthweight categories. The expected output birthweight categories are:",
                                                sep = "\n")  
          cat(birthweight_category_warning)
          accepted_birthweight_categories
        }
        
        number_of_correct_mother_age_categories <- sum(unique(clean_csv_data$Age) == accepted_mother_age_categories)
        mother_age_categories_match <- ifelse(number_of_correct_mother_age_categories == length(accepted_mother_age_categories), TRUE, FALSE)
        if (mother_age_categories_match == FALSE){ 
          mother_age_category_warning <- paste("WARNING: Mother age categories in the new data do not match the expected categories.", 
                                               "Please check the output for strange mother age categories. The expected output mother age categories are:",
                                               sep = "\n")  
          cat(mother_age_category_warning)
          accepted_mother_age_categories
        }
        
        setwd('..')
        setwd('./Output')
        write.csv(clean_csv_data, paste0("birthweight_by_mother_age_for_csv_", year, ".csv"), row.names = FALSE)
        
        current_directory <- getwd()
        print(paste0("Birthweight by mother age data have been created and formatted for ", year, ", and saved in '", current_directory, 
                     "' as 'birthweight_by_mother_age_for_csv_", year, ".csv'"))
        
      }
    }
  }
}
