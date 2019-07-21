library(DBI)
library(RPostgres)
library(dplyr)
library(corrr)

con1 <- dbConnect(
  Postgres(),
  host="localhost", dbname = "datawarehouse", 
  user="dbadmin", password="dbadmin",
  bigint = "integer", port="5432"
)

taxi <- tbl(con1, "taxi")

c_taxi <- taxi %>%
  select_if(is.numeric) %>%
  select(-contains("id")) %>%
  correlate(quiet = TRUE)

dbDisconnect(con1)
rm(taxi, con1)