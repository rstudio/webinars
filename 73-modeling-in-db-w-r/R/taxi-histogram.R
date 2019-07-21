library(DBI)
library(RPostgres)
library(dplyr)
library(dbplot)

con1 <- dbConnect(
  Postgres(),
  host="localhost", dbname = "datawarehouse", 
  user="dbadmin", password="dbadmin",
  bigint = "integer", port="5432"
)

taxi <- tbl(con1, "taxi")

tip_amount_histogram <- taxi %>%
  filter(tip_amount >= 0, tip_amount <= 16) %>%
  dbplot_histogram(tip_amount, binwidth = 1)

dbDisconnect(con1)
rm(taxi, con1)