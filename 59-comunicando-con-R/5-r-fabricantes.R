library(tidyverse)
library(rmarkdown)

load("datos/millas.rda")

fabricantes <- unique(millas$fabricante)

# map() para correr la misma funcion por cada valor
map(fabricantes, ~print(.x))

# render() para crear un nuevo reporte
render("4-rmarkdown-fabricante.Rmd", params = list(fabricante = "audi"))

# map() y render() son una poderosa combinacion 
map(fabricantes, ~ 
    render(
      "4-rmarkdown-fabricante.Rmd", 
      params = list(fabricante = .x),
      output_file = paste0(.x, ".html"),
      output_dir = "reportes-fabricantes",
      quiet = TRUE
      )
)

