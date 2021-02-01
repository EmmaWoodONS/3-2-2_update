# Author: Emma Wood
# Date: 29/01/2021
# Purpose: To create csv data for country of occurrence: baby sex disaggregations for indicator 3.2.2
# Requirements: This script is called by main.R. It calls functions.R.

source("functions.R")


get_country_by_sex_for_csv <- function() { 

  setwd(working_directory)
  
  is_table_name_correct <- menu(c("Yes", "No"),
                                title = paste("Are country of occurrence by sex data in:", country_of_occurrence_by_sex_tab_name, "\n \n",
                                              "(please type relevant number and hit enter)"))

  if(is_table_name_correct == 2) {
    print("Please enter correct Table name between the quote marks after 'country_of_occurrence_by_sex_tab_name <- ', then re-run the script")
  } else {

    source_data <- xlsx_cells(filename, sheets = country_of_occurrence_by_sex_tab_name)

    info_cells <- get_info_cells(source_data)
    
    Year <- get_year(info_cells)
    
    clean_data <- remove_superscripts_blanks_and_info_cells(source_data)
  
    tidy_data <- clean_data %>%
      behead("left-up", area_code) %>%
      behead("left-up", country) %>%
      behead("left", sex) %>%
      behead("up-left", measure) %>%
      behead("up-left", rate_type) %>% 
      behead("up-left", life_event_age) %>% 
      behead("up", baby_age) %>% 
      filter(!is.na(numeric)) %>% # to remove cells that are just ends of a header that have run on to the next row
      mutate(country = trimws(country,  which = "both"),
             sex = trimws(sex,  which = "both")) %>% 
      select(area_code, country, sex, measure, rate_type, life_event_age, baby_age,
             numeric)
    
    data_for_calculations <- tidy_data %>% 
      pivot_wider(names_from = c(measure, rate_type, life_event_age, baby_age), 
                  values_from = numeric) 
    
    # should count dp and do to that number here
    
    #### EDIT FROM HERE ####
    # In 2018 data 'Numbers' heading hasn't been pulled all the way to the left, so Births aren't included under that heading.
    if ("NA_NA_Births_Live births" %in% colnames(data_for_calculations)) {
    headings_standardised <- rename(data_for_calculations, `Numbers_NA_Births_Live births` = `NA_NA_Births_Live births`)
    } else {
      headings_standardised <- data_for_calculations
    }
    
    late_neonatal <- headings_standardised %>% 
      mutate(Numbers_Deaths_Late_neonatal = `Numbers_NA_Deaths under 1_Neonatal` - `Numbers_NA_Deaths under 1_Early`) %>% 
      mutate(Rates_Late_neonatal = ifelse(Numbers_Deaths_Late_neonatal > 3, 
                                                 round(Numbers_Deaths_Late_neonatal / (`Numbers_NA_Births_Live births` / 1000), 1), # calculating late neonatal
                                                 NA),
             # overall neonatal rates are calculated already in the download, so we can check our calcs against these
             Rates_Neonatal_check = ifelse(`Numbers_NA_Deaths under 1_Neonatal` > 3,
                                           round(`Numbers_NA_Deaths under 1_Neonatal` / (`Numbers_NA_Births_Live births` / 1000), 1),
                                           NA))

    check_rate_calcs <- late_neonatal %>% 
      mutate(rate_calcs_comparison = ifelse(Rates_Neonatal_check == `Rates_Per 1,000  live births_Childhood deaths_Neonatal`, 0, 1)) %>% 
      summarise(check_rate_calcs = sum(rate_calcs_comparison, na.rm = TRUE))
    
    check_rate_calcs_pass <- ifelse(check_rate_calcs[1, 1] == 0, TRUE, FALSE)
    
    if(check_rate_calcs_pass == FALSE){
      print(paste("check of rate caclulations has failed.", 
                  check_rate_calcs[1, 1], "of", nrow(late_neonatal), "neonatal death rates do not match.",
      "Calculations are performed in the block of code where 'late_neonatal' is created."))
    } else {
      print(paste("check of rate caclulations has passed: calculated neonatal rates match given neonatal rates")) # checking to see if the neonatal calculations have passed
    }
    
      data_in_csv_format <- late_neonatal %>% 
        select(country, sex, area_code,
               `Rates_Per 1,000  live births_Childhood deaths_Early`,
               Rates_Late_neonatal,
               `Rates_Per 1,000  live births_Childhood deaths_Neonatal`) %>% 
        pivot_longer(
          cols = starts_with("Rates"),
          names_to = "Neonatal_period",
          values_to = "Value")  
      
      clean_csv_data <- data_in_csv_format %>% 
        mutate(Neonatal_period = case_when(
          Neonatal_period == "Rates_Per 1,000  live births_Childhood deaths_Early" ~ "Early neonatal",
          Neonatal_period == "Rates_Late_neonatal" ~ "Late neonatal",
          Neonatal_period == "Rates_Per 1,000  live births_Childhood deaths_Neonatal" ~ ""),
          sex = ifelse(sex == "All", "", sex)) %>% 
        rename(`Neonatal period` = Neonatal_period,
               Sex = sex,
               Country = country,
               GeoCode = area_code) %>% 
        mutate(Year = Year,
               Birthweight = "",
               Age = "",
               Region = "",
               `Health board` = "",
               `Unit measure` = "Rate per 1,000 live births",
               `Unit multiplier` = "Units", 
               `Observation status` = "Undefined",
               Value = ifelse(is.na(Value), "", Value)) %>% # this turns the value into a character string
        select(Year, Sex, Country, Region, `Health board`, Birthweight, Age, `Neonatal period`, `Unit measure`, `Unit multiplier`, `Observation status`, GeoCode, Value)
      
      
      setwd('./Output')
      write.csv(clean_csv_data, paste0("country_by_sex_for_csv_", Year, ".csv"), row.names = FALSE)
      
      current_directory <- getwd()
      print(paste0("Country by sex data have been created and formatted for ", Year, ", and saved in '", current_directory, 
                   "' as 'country_by_sex_for_csv_", Year, ".csv'"))
      
    
  }
}