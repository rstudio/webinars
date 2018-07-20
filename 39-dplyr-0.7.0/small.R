# Do you know about http://dplyr.tidyverse.org ?

# dev version of tidyverse package + RStudio dailies gives more
# information about package loading
library(tidyverse)

# new data ----------------------------------------------------------------

starwars
starwars$films
starwars$vehicles

# ---

storms
?storms

storms %>% count(name)

storms %>%
  filter(year > 2000) %>%
  ggplot(aes(long, lat)) +
    borders("usa") +
    geom_path(aes(group = name), alpha = 0.2)


# pull --------------------------------------------------------------------
# new verb that gives you a single column

starwars %>% select(name)
starwars %>% pull(name)

# Equivalent to:
starwars %>% .$name
# But also works on database backends

starwars %>% pull(2)
starwars %>% pull(-1)
starwars %>% pull()

# other -------------------------------------------------------------------

# * better error messages
summarise(mtcars, foo = mean)
summarise(mtcars, foo = 1:10)
mutate(mtcars, foo = 1:10)

# * much better CJK support on Windows
# * better support for joins etc when columns have different encodings

x <- "élève"
y <- iconv(x, to = "latin1")
identical(x, y)
charToRaw(x)
charToRaw(y)
Encoding(x)
Encoding(y)

# * case_when works inside mutate

x <- 1:50
case_when(
  x %% 35 == 0 ~ "fizz buzz",
  x %% 5 == 0 ~ "fizz",
  x %% 7 == 0 ~ "buzz",
  TRUE ~ as.character(x)
)

starwars %>%
  select(name:mass, gender, species) %>%
  mutate(
    type = case_when(
      height > 200 | mass > 200 ~ "large",
      species == "Droid"        ~ "robot",
      species == "Human"        ~ "human",
      TRUE                      ~ "other"
    )
  )

ifelse(height > 200 | mass > 200, "large",
  ifelse(species == "Droid"), "droid"),
    ifelse(...))

# * so so so many bug fixes

paste0(case_when(
  x %% 35 == 0 ~ "fizz buzz",
  x %% 5 == 0 ~ "fizz",
  x %% 7 == 0 ~ "buzz",
  TRUE ~ as.character(x)
), collapse = ", ")
