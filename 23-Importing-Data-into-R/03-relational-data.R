# Connect to Postgres
library(DBI)
db <- dbConnect(RPostgres::Postgres(), user, pass, ...)

# Connect to MySQL
db <- dbConnect(RMySQL::MySQL(), user, pass, ...)

# Connect to SQLite
db <- dbConnect(RSQLite::SQLite(), dbname = "data/database.sqlite")

# Import data from SQLite
dbListTables(db)
dbGetQuery(db, "SELECT * FROM packages")

# Disconnect
dbDisconnect(db)