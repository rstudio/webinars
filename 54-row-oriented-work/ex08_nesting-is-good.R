#' ---
#' title: "Why nesting is worth the awkwardness"
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
library(gapminder)
library(tidyverse)

# ----
#' gapminder data for Asia only
gap <- gapminder %>%
  filter(continent == "Asia") %>%
  mutate(yr1952 = year - 1952)

#+ alpha-order
ggplot(gap, aes(x = lifeExp, y = country)) +
  geom_point()

#' Countries are in alphabetical order.
#'
#' Set factor levels with intent. Example: order based on life expectancy in
#' 2007, the last year in this dataset. Imagine you want this to persist across
#' an entire analysis.
gap <- gap %>%
  mutate(country = fct_reorder2(country, x = year, y = lifeExp))

#+ principled-order
ggplot(gap, aes(x = lifeExp, y = country)) +
  geom_point()


#' Much better!
#'
#' Now imagine we want to fit a model to each country and look at dot plots of
#' slope and intercept.
#'
#' `dplyr::group_by()` + `tidyr::nest()` created a *nested data frame* and is an
#' alternative to splitting into country-specific data frames. Those data frames
#' end up, instead, in a list-column. The `country` variable remains as a normal
#' factor.
gap_nested <- gap %>%
  group_by(country) %>%
  nest()

gap_nested
gap_nested$data[[1]]

gap_fitted <- gap_nested %>%
  mutate(fit = map(data, ~ lm(lifeExp ~ yr1952, data = .x)))
gap_fitted
gap_fitted$fit[[1]]

gap_fitted <- gap_fitted %>%
  mutate(
    intercept = map_dbl(fit, ~ coef(.x)[["(Intercept)"]]),
    slope = map_dbl(fit, ~ coef(.x)[["yr1952"]])
  )
gap_fitted

#+ principled-order-coef-ests
ggplot(gap_fitted, aes(x = intercept, y = country)) +
  geom_point()

ggplot(gap_fitted, aes(x = slope, y = country)) +
  geom_point()

#' The `split()` + `lapply()` + `do.call(rbind, ...)` approach.
#'
#' Split gap into many data frames, one per country.
gap_split <- split(gap, gap$country)

#' Fit a model to each country.
gap_split_fits <- lapply(
  gap_split,
  function(df) {
    lm(lifeExp ~ yr1952, data = df)
  }
)
#' Oops ... the unused levels of country are a problem (empty data frames in our
#' list).
#'
#' Drop unused levels in country and split.
gap_split <- split(droplevels(gap), droplevels(gap)$country)
head(gap_split, 2)

#' Fit model to each country and get `coefs()`.
gap_split_coefs <- lapply(
  gap_split,
  function(df) {
    coef(lm(lifeExp ~ yr1952, data = df))
  }
)
head(gap_split_coefs, 2)

#' Now we need to put everything back togethers. Row bind the list of coefs.
#' Coerce from matrix back to data frame.
gap_split_coefs <- as.data.frame(do.call(rbind, gap_split_coefs))

#' Restore `country` variable from row names.
gap_split_coefs$country <- rownames(gap_split_coefs)
str(gap_split_coefs)

#+ revert-to-alphabetical
ggplot(gap_split_coefs, aes(x = `(Intercept)`, y = country)) +
  geom_point()
#' Uh-oh, we lost the order of the `country` factor, due to coercion from factor
#' to character (list and then row names).
#'
#' The `nest()` approach allows you to keep data as data vs. in attributes, such
#' as list or row names. Preserves factors and their levels or integer
#' variables. Designs away various opportunities for different pieces of the
#' dataset to get "out of sync" with each other, by leaving them in a data frame
#' at all times.
#'
#' First in an interesting series of blog posts exploring these patterns and
#' asking whether the tidyverse still needs a way to include the nesting
#' variable in the nested data:
#' <https://coolbutuseless.bitbucket.io/2018/03/03/split-apply-combine-my-search-for-a-replacement-for-group_by---do/>
