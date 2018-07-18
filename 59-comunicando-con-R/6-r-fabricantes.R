library(tidyverse)
library(rmarkdown)

load("datos/millas.rda")

fabricantes <- unique(millas$fabricante)

map(fabricantes, ~ 
    render(
      "5-rmarkdown-fabricante.Rmd", 
      params = list(fabricante = .x),
      output_file = paste0(.x, ".html"),
      output_dir = "reportes-fabricantes",
      quiet = TRUE
      )
)

