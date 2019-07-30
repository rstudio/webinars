library(DBI)
library(RPostgres)
library(dplyr)
library(corrr)
library(modeldb)
library(tidypredict)
library(yaml)

con1 <- dbConnect(
  Postgres(),
  host="localhost", dbname = "datawarehouse", 
  user="dbadmin", password="dbadmin",
  bigint = "integer", port="5432"
)

taxi <- tbl(con1, "taxi")

pm <- read_yaml("../modeldb.yml") %>%
  as_parsed_model()

modeldb_r2 <- taxi %>%  
  add_dummy_variables(payment_type, values = 1:6) %>%
  tidypredict_to_column(pm) %>%
  select(tip_amount, fit) %>%
  correlate(quiet = TRUE) %>%
  select(fit) %>%
  filter(!is.na(fit)) %>%
  mutate(r2 = fit ^ 2)

dbDisconnect(con1)
rm(taxi, con1, pm)
