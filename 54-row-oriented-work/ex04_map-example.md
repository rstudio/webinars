Small demo of purrr::map()
================
Jenny Bryan
2018-04-10

## `purrr::map()` can be used to work with functions that aren’t vectorized.

``` r
df_list <- list(
  iris = head(iris, 2),
  mtcars = head(mtcars, 3)
)
df_list
#> $iris
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 
#> $mtcars
#>                mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4     21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> Mazda RX4 Wag 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> Datsun 710    22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
```

This does not work. `nrow()` expects a single data frame as input.

``` r
nrow(df_list)
#> NULL
```

`purrr::map()` applies `nrow()` to each element of `df_list`.

``` r
library(purrr)

map(df_list, nrow)
#> $iris
#> [1] 2
#> 
#> $mtcars
#> [1] 3
```

Different calling styles make sense in more complicated situations. Hard
to justify in this simple example.

``` r
map(df_list, ~ nrow(.x))
#> $iris
#> [1] 2
#> 
#> $mtcars
#> [1] 3

df_list %>%
  map(nrow)
#> $iris
#> [1] 2
#> 
#> $mtcars
#> [1] 3
```

If you know what the return type is (or *should* be), use a
type-specific variant of `map()`.

``` r
map_int(df_list, ~ nrow(.x))
#>   iris mtcars 
#>      2      3
```

More on coverage of `map()` and friends:
<https://jennybc.github.io/purrr-tutorial/>.
