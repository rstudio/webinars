library(tidyr)
library(dplyr, warn = FALSE)
library(readr)

# Load the data
tb <- read_csv("tb.csv")
tb

# To convert this messy data into tidy data
# we need two verbs. First we need to gather
# together all the columns that aren't variables
tb2 <- tb %>%
  gather(demo, n, m04:fu, na.rm = TRUE)
tb2

# Then separate the demographic variable into
# sex and age
tb3 <- tb2 %>%
  separate(demo, c("sex", "age"), 1)
tb3

tb4 <- tb3 %>%
  rename(country = iso2) %>%
  arrange(country, year, sex, age)
tb4

# Do it in one pipeline
"tb.csv" %>%
  read.csv(stringsAsFactors = FALSE) %>%
  tbl_df() %>%
  gather(demo, n, -iso2, -year, na.rm = TRUE) %>%
  separate(demo, c("sex", "age"), 1) %>%
  arrange(iso2, year, sex, age) %>%
  rename(country = iso2)
