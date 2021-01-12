**Author:** Emma Wood  
**Date:** 08/01/2021  
**Purpose:** To create csv data for birthweight: mother age disaggregations for indicator 3.2.2  
        
**Requirements:** 

1) Save mother age by birthweight data as a csv in Jemalex/code for updates/3.2.2/Input. This is in table 10 (Live births, stillbirths and linked infant deaths: birthweight by age of mother, numbers and rates) of source 1 data
2) In that csv make one header row with the headings:  
  	Birthweight  
  	Mother_age  
  	Live births  
  	Stillbirths  
  	Early_neonatal  
	Neonatal  
	Post-neonatal  
	Infant  
	Rates_Stillbirths  
	Rates_Perinatal  
	Rates_Neonatal  
	Rates_Post-neonatal  
	Rates_Infant  

**Troubleshooting:**

If you get this error in red:

_Error in file(file, "rt") : cannot open the connection
In addition: Warning message:
In file(file, "rt") :
  cannot open file 'birthweight_by_mum_age_2017.csv': No such file or directory_
  
You have specified a filename that does not exist. The file needs to be a csv and needs to be saved in the location specified by filepath. 
filename must exactly match the name of the file, be in "", and have the .csv suffix included
