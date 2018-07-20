Attack via rows or columns?
================
Jenny Bryan
2018-04-02

**WARNING: half-baked**

``` r
library(tidyverse)
```

## If you must sweat, compare row-wise work vs. column-wise work

The approach you use in that first example is not always the one that
scales up the best.

``` r
x <- list(
  list(name = "sue", number = 1, veg = c("onion", "carrot")),
  list(name = "doug", number = 2, veg = c("potato", "beet"))
)

# row binding

# frustrating base attempts
rbind(x)
#>   [,1]   [,2]  
#> x List,3 List,3
do.call(rbind, x)
#>      name   number veg        
#> [1,] "sue"  1      Character,2
#> [2,] "doug" 2      Character,2
do.call(rbind, x) %>% str()
#> List of 6
#>  $ : chr "sue"
#>  $ : chr "doug"
#>  $ : num 1
#>  $ : num 2
#>  $ : chr [1:2] "onion" "carrot"
#>  $ : chr [1:2] "potato" "beet"
#>  - attr(*, "dim")= int [1:2] 2 3
#>  - attr(*, "dimnames")=List of 2
#>   ..$ : NULL
#>   ..$ : chr [1:3] "name" "number" "veg"

# tidyverse fail
bind_rows(x)
#> Error in bind_rows_(x, .id): Argument 3 must be length 1, not 2
map_dfr(x, ~ .x)
#> Error in bind_rows_(x, .id): Argument 3 must be length 1, not 2

map_dfr(x, ~ .x[c("name", "number")])
#> # A tibble: 2 x 2
#>   name  number
#>   <chr>  <dbl>
#> 1 sue       1.
#> 2 doug      2.

tibble(
  name = map_chr(x, "name"),
  number = map_dbl(x, "number"),
  veg = map(x, "veg")
)
#> # A tibble: 2 x 3
#>   name  number veg      
#>   <chr>  <dbl> <list>   
#> 1 sue       1. <chr [2]>
#> 2 doug      2. <chr [2]>
```
