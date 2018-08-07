#' ---
#' title: "Add or modify a variable"
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
library(tidyverse)

# ----
#' ### Function to produce a fresh example data frame
new_df <- function() {
  tribble(
      ~ name, ~ age,
      "Reed",   14L,
    "Wesley",   12L,
       "Eli",   12L,
      "Toby",    1L
  )
}

# ----
#' ## The `df$var <- ...` syntax

#' How to create or modify a variable is a fairly low stakes matter, i.e. really
#' a matter of taste. This is not a hill I plan to die on. But here's my two
#' cents.
#'
#' Of course, `df$var <- ...` absolutely works for creating new variables or
#' modifying existing ones. But there are downsides:
#'
#'   * Silent recycling is a risk.
#'   * `df` is not special. It's not the implied place to look first for things,
#'   so you must be explicit. This can be a drag.
#'   * I have aesthetic concerns. YMMV.
df <- new_df()
df$eyes <- 2L
df$snack <- c("chips", "cheese")
df$uname <- toupper(df$name)
df

# ----
#' ## `dplyr::mutate()` works "inside the box"

#' `dplyr::mutate()` is the tidyverse way to work on a variable. If I'm working
#' in a script-y style and the tidyverse packages are already available, I
#' generally prefer this method of adding or modifying a variable.
#'
#'   * Only a length one input can be recycled.
#'   * `df` is the first place to look for things. It turns out that making a
#'   new variable out of existing variables is very, very common, so it's nice
#'   when this is easy.
#'   * This is pipe-friendly, so I can easily combine with a few other logical
#'   data manipuluations that need to happen around the same point.
#'   * I like the way this looks. YMMV.

new_df() %>%
  mutate(
    eyes = 2L,
    snack = c("chips", "cheese"),
    uname = toupper(name)
  )

#' Oops! I did not provide enough snacks!

new_df() %>%
  mutate(
    eyes = 2L,
    snack = c("chips", "cheese", "mixed nuts", "nerf bullets"),
    uname = toupper(name)
  )
