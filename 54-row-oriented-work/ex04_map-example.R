#' ---
#' title: "Small demo of purrr::map()"
#' author: "Jenny Bryan"
#' date: "`r format(Sys.Date())`"
#' output: github_document
#' ---

#+ setup, include = FALSE, cache = FALSE
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  error = TRUE
)
options(tidyverse.quiet = TRUE)

#+ body
# ----
#' ## `purrr::map()` can be used to work with functions that aren't vectorized.

df_list <- list(
  iris = head(iris, 2),
  mtcars = head(mtcars, 3)
)
df_list

#' This does not work. `nrow()` expects a single data frame as input.
nrow(df_list)

#' `purrr::map()` applies `nrow()` to each element of `df_list`.
library(purrr)

map(df_list, nrow)

#' Different calling styles make sense in more complicated situations. Hard to
#' justify in this simple example.
map(df_list, ~ nrow(.x))

df_list %>%
  map(nrow)

#' If you know what the return type is (or *should* be), use a type-specific
#' variant of `map()`.

map_int(df_list, ~ nrow(.x))

#' More on coverage of `map()` and friends: <https://jennybc.github.io/purrr-tutorial/>.
