# 02-tags.R

library(shiny)

ui <- fluidPage(
  h1("My Shiny App"),
  p(style = "font-family:Impact",
    "See other apps in the",
    a("Shiny Showcase",
      href = "http://www.rstudio.com/
      products/shiny/shiny-user-showcase/")
  )
)

server <- function(input, output){}

shinyApp(ui = ui, server = server)