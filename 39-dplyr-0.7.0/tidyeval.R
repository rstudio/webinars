# tidyeval ----------------------------------------------------------------
# http://dplyr.tidyverse.org/articles/programming.html

library(tidyverse)

df <- tibble(
  g1 = c(1, 1, 2, 2, 2),
  g2 = c(1, 2, 1, 2, 1),
  g3 = c(2, 2, 1, 2, 1),
  a = sample(5),
  b = sample(5)
)

df %>%
  group_by(g1) %>%
  summarise(a = mean(a))
df %>%
  group_by(g2) %>%
  summarise(a = mean(a))
df %>%
  group_by(g3) %>%
  summarise(a = mean(a))

# This is hard because you're used to referential transparency
f <- function(x) x * 10
g <- function(x) x + 1

f(g(10) + 2)
# that is the same as this:
y <- g(10) + 2
f(y)

# But dplyr is not referentially transparent: you can't
# replace an intermediate expression with a variable
group_var <- g2
df %>%
  group_by(group_var) %>%
  summarise(a = mean(a))

# You might hope that this works:
group_var <- "g2"
df %>%
  group_by(group_var) %>%
  summarise(a = mean(a))

# To solve this problem we need a new data structure:
# the quosure

quo(g1)
quo(x + y + z)

group_var <- quo(g1)
df %>%
  group_by(group_var) %>%
  summarise(a = mean(a))

# and we need some way to "unquote" or insert the
# value of quosure into the call.
df %>%
  group_by(!!group_var) %>%
  summarise(a = mean(a))

my_group_by <- function(df, group_var) {
  group_var <- enquo(group_var)

  df %>%
    group_by(!!group_var) %>%
    summarise(a = mean(a))
}
my_group_by(df, g1)



summary_var <- quo(a)

df %>%
  group_by(g1) %>%
  summarise(
    mean = mean(!!summary_var),
    sd = sd(!!summary_var)
  )
)


df %>%
  group_by(g1) %>%
  summarise(
    mean = mean(!!summary_var),
    sd = sd(!!summary_var)
  )
)
