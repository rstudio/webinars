library(shiny)

ui <- fluidPage(
  tags$img(height = 100, 
           width = 100, 
           src = "bigorb.png")
)

server <- function(input, output){}
shinyApp(ui = ui, server = server)