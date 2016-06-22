# Import from Text
library(readr)
csv <- read_csv("data/Water_Right_Applications.csv")

# Import from Excel
library(readxl)
excel <- read_excel("data/Water_Right_Applications.xls")

# Import from SPSS
library(haven)
sav <- read_sav("data/Child_Data.sav")

# Import fomr SAS
sas <- read_sas("data/iris.sas7bdat")

# Import from STATA
stata <- read_dta("data/Milk_Production.dta")
