Dynamic dashboards with Shiny
=============================

This directory contains the slides for the **Dynamic dashboards with Shiny** webinar with Winston Chang, and the code for two Shiny apps made with shinydashboard.

A live version of the activity dashboard is at: https://winston.shinyapps.io/activity-dashboard/


## Simple dashboard

This is a very basic dashboard made with Shiny and shinydashboard. To setup and run it:

```R
install.packages("shinydashboard")

library(shiny)
runApp("activity-dashboard/")
```


## Activity dashboard

This is an example of a data dashboard, using R, Shiny, shinydashboard, ggplot2, and leaflet.

**NOTE:** At this time we don't have data set that we can make available to the general public, for privacy reasons. For now this means that this app is not distributed with an API key (the API key would go in `load_data.R`). Hopefully we'll be able to provide a public data set in the future. 

### Setup

Install the various packages needed:

```R
# Make sure a package is at least some version (only installs from CRAN)
ensure_version <- function(pkg, ver = "0.0") {
  if (system.file(package = pkg)  == "" || packageVersion(pkg) < ver)
    install.packages(pkg)
}

ensure_version("devtools", "1.7.0")
ensure_version("jsonlite", "0.9.16")
ensure_version("shinydashboard", "0.4.0")

# Need latest devel versions of various packages
devtools::install_github("rstudio/shiny@interact-ggplot") # For ggplot2 interaction
devtools::install_github("rstudio/leaflet")

# PiLR API package
devtools::install_github("pilrhealth/pilr.api.r")
```

### Usage

Starting in this directory (the parent of `activity-dashboard/`), run:

```R
library(shiny)
runApp("activity-dashboard/")
```
