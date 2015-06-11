library(DBI)

path <- system.file("db", "datasets.sqlite", package = "RSQLite")
db <- dbConnect(RSQLite::SQLite(), path)

dbListTables(db)
str(dbGetQuery(db, "SELECT * FROM mtcars"))

# Polite to disconnect from db when done
dbDisconnect(db)
