# http://dbplyr.tidyverse.org
library(dplyr)

# Better DBI integration --------------------------------------------------

con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
DBI::dbWriteTable(con, "mtcars", mtcars)

mtcars2 <- tbl(con, "mtcars")
mtcars2

# SQL generation ----------------------------------------------------------

# Many improvements to SQL generation, including a new optimiser
# (thanks to https://github.com/hhoeflin)

mtcars2 %>%
  filter(cyl > 2) %>%
  select(mpg:hp) %>%
  head(10) %>%
  show_query()

# Previously would have generated three subqueries
# Similarly optimisations for joins

# More translation support for type coercion:
mtcars2 %>%
  transmute(as.character(cyl)) %>%
  pull()

# Fixed annyoing IN bug
mtcars2 %>%
  filter(cyl %in% 4L) %>%
  show_query()

# Translation support for MS SQL, Impala, and Hive when used
# with odbc package: https://github.com/rstats-db/odbc. Support
# for Oracle coming next week

# Many other small improvements that should reduce friction

# Schema support ----------------------------------------------------------

# Set up additional database and attach as aux
tmp <- tempfile()
DBI::dbExecute(con, DBI::sqlInterpolate(con, "ATTACH ?path AS aux", path = tmp))
# Copy data across
copy_to(con, iris, "df", temporary = FALSE)
copy_to(con, mtcars, dbplyr::in_schema("aux", "df"), temporary = FALSE)

con %>% tbl("df")
con %>% tbl(dbplyr::in_schema("aux", "df"))
