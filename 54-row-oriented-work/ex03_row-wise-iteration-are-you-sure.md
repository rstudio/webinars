Are you absolutely sure that you, personally, need to iterate over rows?
================
Jenny Bryan
2018-04-02

``` r
library(tidyverse)
```

## Function to give my example data frame

``` r
new_df <- function() {
  tribble(
    ~ name, ~ age,
    "Reed", 14,
    "Wesley", 12,
    "Eli", 12,
    "Toby", 1
  )
}
```

## Single-row example can cause tunnel vision

Sometimes it’s easy to fixate on one (unfavorable) way of accomplishing
something, because it feels like a natural extension of a successful
small-scale experiment.

Let’s create a string from row 1 of the data frame.

``` r
df <- new_df()
paste(df$name[1], "is", df$age[1], "years old")
#> [1] "Reed is 14 years old"
```

I want to scale up, therefore I obviously must … loop over all rows\!

``` r
n <- nrow(df)
s <- vector(mode = "character", length = n)
for (i in seq_len(n)) {
  s[i] <- paste(df$name[i], "is", df$age[i], "years old")
}
s
#> [1] "Reed is 14 years old"   "Wesley is 12 years old"
#> [3] "Eli is 12 years old"    "Toby is 1 years old"
```

HOLD ON. What if I told you `paste()` is already vectorized over its
arguments?

``` r
paste(df$name, "is", df$age, "years old")
#> [1] "Reed is 14 years old"   "Wesley is 12 years old"
#> [3] "Eli is 12 years old"    "Toby is 1 years old"
```

A surprising number of “iterate over rows” problems can be eliminated by
exploiting functions that are already vectorized and by making your own
functions vectorized over the primary argument.

Writing an explicit loop in your code is not necessarily bad, but it
should always give you pause. Has someone already written this loop for
you? Ideally in C or C++ and inside a package that’s being regularly
checked, with high test coverage. That is usually the better choice.

## Don’t forget to work “inside the box”

For this string interpolation task, we can even work with a vectorized
function that is happy to do lookup inside a data frame. The [glue
package](https://glue.tidyverse.org) is doing the work under the hood
here, but its Greatest Functions are now re-exported by stringr, which
we already attached via `library(tidyverse)`.

``` r
str_glue_data(df, "{name} is {age} years old")
#> Reed is 14 years old
#> Wesley is 12 years old
#> Eli is 12 years old
#> Toby is 1 years old
```

You can use the simpler form, `str_glue()`, inside `dplyr::mutate()`,
because the other variables in `df` are automatically available for use.

``` r
df %>%
  mutate(sentence = str_glue("{name} is {age} years old"))
#> # A tibble: 4 x 3
#>   name     age sentence              
#>   <chr>  <dbl> <S3: glue>            
#> 1 Reed     14. Reed is 14 years old  
#> 2 Wesley   12. Wesley is 12 years old
#> 3 Eli      12. Eli is 12 years old   
#> 4 Toby      1. Toby is 1 years old
```

The tidyverse style is to manage data holistically in a data frame and
provide a user interface that encourages self-explaining code with low
“syntactical noise”.
