# Code that needs running regardless of which other functions are run.
# This is required for birthweight_by_mum_age_function.R and country_of_occurrence_by_sex_function.R to work
# This function is called by main.R


run_basic_checks_and_setup <- function() {
  
  
  
  
  are_table_names_correct <- menu(c("Yes", "No"), 
                                  title = paste("Are the following data in these tabs (please type relevant number and hit enter):\n \n", 
                                                "birthweight by mother age:", birthweight_by_mum_age_tab_name, "\n",
                                                "country of occurrence by sex:", country_of_occurrence_by_sex_tab_name, "\n"))
  
  if(are_table_names_correct == 2) {
    print("Please enter correct tab name between the quote marks e.g. after 'birthweight_by_mum_age_tab_name <- ', then re-run the script")
  } else {
    
    source_data <- xlsx_cells(filename, sheets = country_of_occurrence_by_sex_tab_name)
    
    '%not_in%' <- Negate('%in%')
    
  }
}