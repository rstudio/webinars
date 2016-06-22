# Create relational data

library(DBI)
db <- dbConnect(RSQLite::SQLite(), dbname="data/database.sqlite")
dbSendQuery(db, "CREATE TABLE packages (id INTEGER, name TEXT)")
dbSendQuery(db, "INSERT INTO packages VALUES (1, 'readr'), (2, 'readxl'), (3, 'haven')")

# Disconnect
dbDisconnect(db)