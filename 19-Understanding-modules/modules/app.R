library(shiny)
library(dplyr)
source("data.R")
source("gapModule.R")

ui <- fluidPage(
  tags$style(type="text/css", ".recalculating { opacity: 1.0; }"),
  titlePanel("Gapminder"),
  tabsetPanel(id = "continent", 
    tabPanel("All", gapModuleUI("all")),
    tabPanel("Africa", gapModuleUI("africa")),
    tabPanel("Americas", gapModuleUI("americas")),
    tabPanel("Asia", gapModuleUI("asia")),
    tabPanel("Europe", gapModuleUI("europe")),
    tabPanel("Oceania", gapModuleUI("oceania"))
  )
)

server <- function(input, output) {
  callModule(gapModule, "all", all_data)
  callModule(gapModule, "africa", africa_data)
  callModule(gapModule, "americas", americas_data)
  callModule(gapModule, "asia", asia_data)
  callModule(gapModule, "europe", europe_data)
  callModule(gapModule, "oceania", oceania_data)    
}

# Run the application 
shinyApp(ui = ui, server = server)

