To install the packages used in this presentation, please run:

```R
install.packages(c("nycflights13", "dplyr", "ggvis", "lubridate"))
```

The `.R` files contains the code used in the presentations, and the `.Rmd` files are interactive Shiny docs, which can be opened and run in recent versions of the [RStudio IDE](http://www.rstudio.com/products/rstudio/download/).

As of 2014-07-30, the `4-linked-brush.Rmd` document requires the development version of ggvis. Installation of the development version of ggvis requires the devtools package. To install it, run:

```R
# Install devtools if needed:
# install.package("devtools")

devtools::install_github("rstudio/ggvis")
```
