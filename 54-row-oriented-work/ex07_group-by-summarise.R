#' ---
#' title: "Work on groups of rows via dplyr::group_by() + summarise()"
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

#' What if you need to work on groups of rows? Such as the groups induced by
#' the levels of a factor.
#'
#' You do not need to ... split the data frame into mini-data-frames, loop over
#' them, and glue it all back together.
#'
#' Instead, use `dplyr::group_by()`, followed by `dplyr::summarize()`, to
#' compute group-wise summaries.

library(tidyverse)

iris %>%
  group_by(Species) %>%
  summarise(pl_avg = mean(Petal.Length), pw_avg = mean(Petal.Width))

#' What if you want to return summaries that are not just a single number?
#'
#' This does not "just work".
iris %>%
  group_by(Species) %>%
  summarise(pl_qtile = quantile(Petal.Length, c(0.25, 0.5, 0.75)))

#' Solution: package as a length-1 list that contains 3 values, creating a
#' list-column.
iris %>%
  group_by(Species) %>%
  summarise(pl_qtile = list(quantile(Petal.Length, c(0.25, 0.5, 0.75))))

#' Q from
#' [\@jcpsantiago](https://twitter.com/jcpsantiago/status/983997363298717696) via
#' Twitter: How would you unnest so the final output is a data frame with a
#' factor column `quantile` with levels "25%", "50%", and "75%"?
#'
#' A: I would `map()` `tibble::enframe()` on the new list column, to convert
#' each entry from named list to a two-column data frame. Then use
#' `tidyr::unnest()` to get rid of the list column and return to a simple data
#' frame and, if you like, convert `quantile` into a factor.

iris %>%
  group_by(Species) %>%
  summarise(pl_qtile = list(quantile(Petal.Length, c(0.25, 0.5, 0.75)))) %>%
  mutate(pl_qtile = map(pl_qtile, enframe, name = "quantile")) %>%
  unnest() %>%
  mutate(quantile = factor(quantile))

#' If something like this comes up a lot in an analysis, you could package the
#' key "moves" in a function, like so:
enquantile <- function(x, ...) {
  qtile <- enframe(quantile(x, ...), name = "quantile")
  qtile$quantile <- factor(qtile$quantile)
  list(qtile)
}

#' This makes repeated downstream usage more concise.
iris %>%
  group_by(Species) %>%
  summarise(pl_qtile = enquantile(Petal.Length, c(0.25, 0.5, 0.75))) %>%
  unnest()

