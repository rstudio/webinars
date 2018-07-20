Generate data from different distributions via pmap()
================
Jenny Bryan
2018-04-10

## Uniform\[min, max\] via `runif()`

CONSIDER:

    runif(n, min = 0, max = 1)

Want to do this for several triples of (n, min, max).

Store each triple as a row in a data frame.

Now iterate over the rows.

``` r
library(tidyverse)
```

Notice how df’s variable names are same as runif’s argument names. Do
this when you can\!

``` r
df <- tribble(
  ~ n, ~ min, ~ max,
   1L,     0,     1,
   2L,    10,   100,
   3L,   100,  1000
)
df
#> # A tibble: 3 x 3
#>       n   min   max
#>   <int> <dbl> <dbl>
#> 1     1    0.    1.
#> 2     2   10.  100.
#> 3     3  100. 1000.
```

Set seed to make this repeatedly random.

Practice on single rows.

``` r
set.seed(123)
(x <- df[1, ])
#> # A tibble: 1 x 3
#>       n   min   max
#>   <int> <dbl> <dbl>
#> 1     1    0.    1.
runif(n = x$n, min = x$min, max = x$max)
#> [1] 0.2875775

x <- df[2, ]
runif(n = x$n, min = x$min, max = x$max)
#> [1] 80.94746 46.80792

x <- df[3, ]
runif(n = x$n, min = x$min, max = x$max)
#> [1] 894.7157 946.4206 141.0008
```

Think out loud in pseudo-code.

``` r
## x <- df[i, ]
## runif(n = x$n, min = x$min, max = x$max)

## runif(n = df$n[i], min = df$min[i], max = df$max[i])
## runif with all args from the i-th row of df
```

Just. Do. It. with `pmap()`.

``` r
set.seed(123)
pmap(df, runif)
#> [[1]]
#> [1] 0.2875775
#> 
#> [[2]]
#> [1] 80.94746 46.80792
#> 
#> [[3]]
#> [1] 894.7157 946.4206 141.0008
```

## Finessing variable and argument names

Q: What if you can’t arrange it so that variable names and arg names are
same?

``` r
foofy <- tibble(
  alpha = 1:3,            ## was: n
  beta = c(0, 10, 100),   ## was: min
  gamma = c(1, 100, 1000) ## was: max
)
foofy
#> # A tibble: 3 x 3
#>   alpha  beta gamma
#>   <int> <dbl> <dbl>
#> 1     1    0.    1.
#> 2     2   10.  100.
#> 3     3  100. 1000.
```

A: Rename the variables on-the-fly, on the way in.

``` r
set.seed(123)
foofy %>%
  rename(n = alpha, min = beta, max = gamma) %>%
  pmap(runif)
#> [[1]]
#> [1] 0.2875775
#> 
#> [[2]]
#> [1] 80.94746 46.80792
#> 
#> [[3]]
#> [1] 894.7157 946.4206 141.0008
```

A: Write a wrapper around `runif()` to say how df vars \<–\> runif args.

``` r
## wrapper option #1:
##   ARGNAME = l$VARNAME
my_runif <- function(...) {
  l <- list(...)
  runif(n = l$alpha, min = l$beta, max = l$gamma)
}
set.seed(123)
pmap(foofy, my_runif)
#> [[1]]
#> [1] 0.2875775
#> 
#> [[2]]
#> [1] 80.94746 46.80792
#> 
#> [[3]]
#> [1] 894.7157 946.4206 141.0008

## wrapper option #2:
my_runif <- function(alpha, beta, gamma, ...) {
  runif(n = alpha, min = beta, max = gamma)
}
set.seed(123)
pmap(foofy, my_runif)
#> [[1]]
#> [1] 0.2875775
#> 
#> [[2]]
#> [1] 80.94746 46.80792
#> 
#> [[3]]
#> [1] 894.7157 946.4206 141.0008
```

You can use `..i` to refer to input by position.

``` r
set.seed(123)
pmap(foofy, ~ runif(n = ..1, min = ..2, max = ..3))
#> [[1]]
#> [1] 0.2875775
#> 
#> [[2]]
#> [1] 80.94746 46.80792
#> 
#> [[3]]
#> [1] 894.7157 946.4206 141.0008
```

Use this with *extreme caution*. Easy to shoot yourself in the foot.

## Extra variables in the data frame

What if data frame includes variables that should not be passed to
`.f()`?

``` r
df_oops <- tibble(
  n = 1:3,
  min = c(0, 10, 100),
  max = c(1, 100, 1000),
  oops = c("please", "ignore", "me")
)
df_oops
#> # A tibble: 3 x 4
#>       n   min   max oops  
#>   <int> <dbl> <dbl> <chr> 
#> 1     1    0.    1. please
#> 2     2   10.  100. ignore
#> 3     3  100. 1000. me
```

This will not work\!

``` r
set.seed(123)
pmap(df_oops, runif)
#> Error in .f(n = .l[[c(1L, i)]], min = .l[[c(2L, i)]], max = .l[[c(3L, : unused argument (oops = .l[[c(4, i)]])
```

A: use `dplyr::select()` to limit the variables passed to `pmap()`.

``` r
set.seed(123)
df_oops %>%
  select(n, min, max) %>% ## if it's easier to say what to keep
  pmap(runif)
#> [[1]]
#> [1] 0.2875775
#> 
#> [[2]]
#> [1] 80.94746 46.80792
#> 
#> [[3]]
#> [1] 894.7157 946.4206 141.0008

set.seed(123)
df_oops %>%
  select(-oops) %>%       ## if it's easier to say what to omit
  pmap(runif)
#> [[1]]
#> [1] 0.2875775
#> 
#> [[2]]
#> [1] 80.94746 46.80792
#> 
#> [[3]]
#> [1] 894.7157 946.4206 141.0008
```

A: Use a custom wrapper and absorb extra variables with `...`.

``` r
my_runif <- function(n, min, max, ...) runif(n, min, max)

set.seed(123)
pmap(df_oops, my_runif)
#> [[1]]
#> [1] 0.2875775
#> 
#> [[2]]
#> [1] 80.94746 46.80792
#> 
#> [[3]]
#> [1] 894.7157 946.4206 141.0008
```

## Add the generated data to the data frame as a list-column

``` r
set.seed(123)
(df_aug <- df %>%
    mutate(data = pmap(., runif)))
#> # A tibble: 3 x 4
#>       n   min   max data     
#>   <int> <dbl> <dbl> <list>   
#> 1     1    0.    1. <dbl [1]>
#> 2     2   10.  100. <dbl [2]>
#> 3     3  100. 1000. <dbl [3]>
#View(df_aug)
```

## Review

What have we done?

  - Arranged inputs as rows in a data frame
  - Used `pmap()` to implement a loop over the rows.
  - Used dplyr verbs `rename()` and `select()` to manipulate data on the
    way into `pmap()`.
  - Wrote custom wrappers around `runif()` to deal with:
      - df var names \!= `.f()` arg names
      - df vars that aren’t formal args of `.f()`
  - Added generated data as a list-column
