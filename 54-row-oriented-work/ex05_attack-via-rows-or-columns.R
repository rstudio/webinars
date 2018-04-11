#' ---
#' title: "Attack via rows or columns?"
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

#' **WARNING: half-baked**

#+ body
# ----
library(tidyverse)

# ----
#' ## If you must sweat, compare row-wise work vs. column-wise work
#'
#' The approach you use in that first example is not always the one that scales
#' up the best.

x <- list(
  list(name = "sue", number = 1, veg = c("onion", "carrot")),
  list(name = "doug", number = 2, veg = c("potato", "beet"))
)

# row binding

# frustrating base attempts
rbind(x)
do.call(rbind, x)
do.call(rbind, x) %>% str()

# tidyverse fail
bind_rows(x)
map_dfr(x, ~ .x)

map_dfr(x, ~ .x[c("name", "number")])

tibble(
  name = map_chr(x, "name"),
  number = map_dbl(x, "number"),
  veg = map(x, "veg")
)
