#' ---
#' title: "Leave your data in that big, beautiful data frame"
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
#' ## Don't create odd little excerpts and copies of your data.
#'
#' Code style that results from (I speculate) minimizing the number of key
#' presses.

## :(
sl <- iris[51:100,1]
pw <- iris[51:100,4]
plot(sl ~ pw)

#' This clutters the workspace with "loose parts", `sl` and `pw`. Very soon, you
#' are likely to forget what they are, which `Species` of `iris` they represent,
#' and what the relationship between them is.

# ----
#' ## Leave the data *in situ* and reveal intent in your code
#'
#' More verbose code conveys intent. Eliminating the Magic Numbers makes the
#' code less likely to be, or become, wrong.
#'
#' Here's one way to do same in a tidyverse style:
library(tidyverse)

ggplot(
  filter(iris, Species == "versicolor"),
  aes(x = Petal.Width, y = Sepal.Length)
) + geom_point()

#' Another tidyverse approach, this time using the pipe operator, `%>%`
iris %>%
  filter(Species == "versicolor") %>%
  ggplot(aes(x = Petal.Width, y = Sepal.Length)) + ## <--- NOTE the `+` sign!!
  geom_point()

#' A base solution that still follows the principles of
#'
#'   * leave the data in data frame
#'   * convey intent
plot(
  Sepal.Length ~ Petal.Width,
  data = subset(iris, subset = Species == "versicolor")
)
