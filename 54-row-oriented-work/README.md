# Row-oriented workflows in R with the tidyverse

Materials for [RStudio webinar](https://www.rstudio.com/resources/webinars/):

Thinking inside the box: you can do that inside a data frame?!  
Jenny Bryan  
Wednesday, April 11 at 1:00pm ET / 10:00am PT  

PDF of slides:

  * Here in this repo: [2018-04-11_row-oriented-work-rstudio-webinar.pdf](2018-04-11_row-oriented-work-rstudio-webinar.pdf)
  * On [SpeakerDeck](https://speakerdeck.com/jennybc/row-oriented-workflows-in-r-with-the-tidyverse)

*Note: this is a static copy of materials taken from this repo: <https://github.com/jennybc/row-oriented-workflows>*

## Abstract

The data frame is a crucial data structure in R and, especially, in the tidyverse. Working on a column or a variable is a very natural operation, which is great. But what about row-oriented work? That also comes up frequently and is more awkward. In this webinar I’ll work through concrete code examples, exploring patterns that arise in data analysis. We’ll discuss the general notion of "split-apply-combine", row-wise work in a data frame, splitting vs. nesting, and list-columns.

## Code examples

Beginner --> intermediate --> advanced  
Not all are used in webinar

  * **Leave your data in that big, beautiful data frame.** [`ex01_leave-it-in-the-data-frame`](ex01_leave-it-in-the-data-frame.md) Show the evil of creating copies of certain rows of certain variables, using Magic Numbers and cryptic names, just to save some typing.
  * **Adding or modifying variables.** [`ex02_create-or-mutate-in-place`](ex02_create-or-mutate-in-place.md) `df$var <- ...` versus `dplyr::mutate()`. Recycling/safety, `df`'s as data mask, aesthetics.
  * **Are you SURE you need to iterate over rows?** [`ex03_row-wise-iteration-are-you-sure`](ex03_row-wise-iteration-are-you-sure.md) Don't fixate on most obvious generalization of your pilot example and risk overlooking a vectorized solution. Features a `paste()` example, then goes out with some glue glory.
  * **Working with non-vectorized functions.** [`ex04_map-example`](ex04_map-example.md) Small example using `purrr::map()` to apply `nrow()` to list of data frames.
  * **Row-wise thinking vs. column-wise thinking.** [`ex05_attack-via-rows-or-columns`](ex05_attack-via-rows-or-columns.md) Data rectangling example. Both are possible, but I find building a tibble column-by-column is less aggravating than building rows, then row binding.
  * **Iterate over rows of a data frame.** [`iterate-over-rows`](iterate-over-rows.md) Empirical study of reshaping a data frame into this form: a list with one component per row. Revisiting a study originally done by Winston Chang. Run times for different number of [rows](row-benchmark.png) or [columns](col-benchmark.png).
  * **Generate data from different distributions via `purrr::pmap()`.** [`ex06_runif-via-pmap`](ex06_runif-via-pmap.md) Use `purrr::pmap()` to generate U[min, max] data for various combinations of (n, min, max), stored as rows of a data frame.
  * **Are you SURE you need to iterate over groups?** [`ex07_group-by-summarise`](ex07_group-by-summarise.md) Use `dplyr::group_by()` and `dplyr::summarise()` to compute group-wise summaries, without explicitly splitting up the data frame and re-combining the results. Use `list()` to package multivariate summaries into something `summarise()` can handle, creating a list-column.
  * **Group-and-nest.** [`ex08_nesting-is-good`](ex08_nesting-is-good.md) How to explicitly work on groups of rows via nesting (our recommendation) vs splitting.

## More tips and links

Big thanks to everyone who weighed in on the related [twitter thread](https://twitter.com/JennyBryan/status/980905136468910080). This was very helpful for planning content.

45 minutes is not enough! A few notes about more special functions and patterns for row-driven work. Maybe we need to do a follow up ...

`tibble::enframe()` and `deframe()` are handy for getting into and out of the data frame state.

`map()` and `map2()` are useful for working with list-columns inside `mutate()`.

`tibble::add_row()` handy for adding a single row at an arbitrary position in data frame.

`imap()` handy for iterating over something and its names or integer indices at the same time.

When you have multiple values for a single unit in one row (e.g. repeated measures), consider reshaping for easier computation. That turns a row-oriented problem into `group_by()` + `summarise()`, which is usually easier.

`dplyr::case_when()` helps you get rid of hairy, nested `if () {...} else {...}` statements.

Great resource on the "why?" of functional programming approaches (such as `map()`): <https://github.com/getify/Functional-Light-JS/blob/master/manuscript/ch1.md/>
