#' ---
#' title: "Generate data from different distributions via pmap()"
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
#' ## Uniform[min, max] via `runif()`
#'
#' CONSIDER:
#' ```
#' runif(n, min = 0, max = 1)
#' ```
#'
#' Want to do this for several triples of (n, min, max).
#'
#' Store each triple as a row in a data frame.
#'
#' Now iterate over the rows.

library(tidyverse)

#' Notice how df's variable names are same as runif's argument names. Do this
#' when you can!
df <- tribble(
  ~ n, ~ min, ~ max,
   1L,     0,     1,
   2L,    10,   100,
   3L,   100,  1000
)
df

#' Set seed to make this repeatedly random.
#'
#' Practice on single rows.
set.seed(123)
(x <- df[1, ])
runif(n = x$n, min = x$min, max = x$max)

x <- df[2, ]
runif(n = x$n, min = x$min, max = x$max)

x <- df[3, ]
runif(n = x$n, min = x$min, max = x$max)

#' Think out loud in pseudo-code.

## x <- df[i, ]
## runif(n = x$n, min = x$min, max = x$max)

## runif(n = df$n[i], min = df$min[i], max = df$max[i])
## runif with all args from the i-th row of df

#' Just. Do. It. with `pmap()`.
set.seed(123)
pmap(df, runif)

#' ## Finessing variable and argument names
#'
#' Q: What if you can't arrange it so that variable names and arg names are
#' same?
foofy <- tibble(
  alpha = 1:3,            ## was: n
  beta = c(0, 10, 100),   ## was: min
  gamma = c(1, 100, 1000) ## was: max
)
foofy

#' A: Rename the variables on-the-fly, on the way in.
set.seed(123)
foofy %>%
  rename(n = alpha, min = beta, max = gamma) %>%
  pmap(runif)

#' A: Write a wrapper around `runif()` to say how df vars <--> runif args.

## wrapper option #1:
##   ARGNAME = l$VARNAME
my_runif <- function(...) {
  l <- list(...)
  runif(n = l$alpha, min = l$beta, max = l$gamma)
}
set.seed(123)
pmap(foofy, my_runif)

## wrapper option #2:
my_runif <- function(alpha, beta, gamma, ...) {
  runif(n = alpha, min = beta, max = gamma)
}
set.seed(123)
pmap(foofy, my_runif)

#' You can use `..i` to refer to input by position.
set.seed(123)
pmap(foofy, ~ runif(n = ..1, min = ..2, max = ..3))
#' Use this with *extreme caution*. Easy to shoot yourself in the foot.
#'
#' ## Extra variables in the data frame
#'
#' What if data frame includes variables that should not be passed to `.f()`?
df_oops <- tibble(
  n = 1:3,
  min = c(0, 10, 100),
  max = c(1, 100, 1000),
  oops = c("please", "ignore", "me")
)
df_oops

#' This will not work!
set.seed(123)
pmap(df_oops, runif)

#' A: use `dplyr::select()` to limit the variables passed to `pmap()`.
set.seed(123)
df_oops %>%
  select(n, min, max) %>% ## if it's easier to say what to keep
  pmap(runif)

set.seed(123)
df_oops %>%
  select(-oops) %>%       ## if it's easier to say what to omit
  pmap(runif)

#' A: Use a custom wrapper and absorb extra variables with `...`.
my_runif <- function(n, min, max, ...) runif(n, min, max)

set.seed(123)
pmap(df_oops, my_runif)

#' ## Add the generated data to the data frame as a list-column
set.seed(123)
(df_aug <- df %>%
    mutate(data = pmap(., runif)))
#View(df_aug)

#' ## Review
#'
#' What have we done?
#'
#'   * Arranged inputs as rows in a data frame
#'   * Used `pmap()` to implement a loop over the rows.
#'   * Used dplyr verbs `rename()` and `select()` to manipulate data on the way
#'   into `pmap()`.
#'   * Wrote custom wrappers around `runif()` to deal with:
#'     - df var names != `.f()` arg names
#'     - df vars that aren't formal args of `.f()`
#'   * Added generated data as a list-column
