Author: Emma Wood
Date: 08/01/2021
Purpose: To create csv data for birthweight: mother age disaggregations for indicator 3.2.2
        
Requirements: 

1) Save 'Child mortality (death cohort) tables in England and Wales' as an xlsx file in Jemalex/code for updates/3.2.2/Input. This is in table 10 (Live births, stillbirths and linked infant deaths: birthweight by age of mother, numbers and rates) of source 1 data
2) Check birthweight_by_mum_age_table_name is correct. If not edit it to be exactly the tab name for that table.
2) Check that the first row of column headings is correct (first_column_header_row). If not, change it.

TROUBLESHOOTING:
If you get this error in red:
Error in file(file, "rt") : cannot open the connection
In addition: Warning message:
In file(file, "rt") :
  cannot open file 'birthweight_by_mum_age_2017.csv': No such file or directory
You have specified a filename that does not exist. The file needs to be a csv and needs to be saved in the location specified by filepath. 
filename must exactly match the name of the file, be in "", and have the .csv suffix included.

If you get the error : Error in setwd("./Output") : cannot change working directory, check that there is a folder called Output (capitalisation matters)