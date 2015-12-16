library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)

citySelector <- function() {
  df <- as.data.frame(scale(cfl[ , -c(1, 18:19)]))
  
  ui <- dashboardPage(
    dashboardHeader(title = "City Selector"),
    dashboardSidebar(disable = TRUE),
    dashboardBody(
      fluidRow(
        box(
          width = 8, status = "info", solidHeader = TRUE,
          title = "Cities Sized by Score",
          leafletOutput("cityMap")
        ),
        box(
          width = 4, status = "info",
          title = "Top Cities",
          tableOutput("cityTable"),
          actionButton("stop", "Get Scores")
        )
      ),
      fluidRow(
        box(width = 3,
          title = "Select Weights",
          sliderInput("col", "Cost of Living", -1, 1, 0, step = 0.1),
          sliderInput("hh_inc", "Median Household Income", -1, 1, 0, step = 0.1),
          sliderInput("h_price", "Median House Price", -1, 1, 0, step = 0.1)
        ),
        box(width = 3,
          title = "Select Weights",
          sliderInput("density", "Population Density", -1, 1, 0, step = 0.1),
          sliderInput("vcrime", "Violent Crime Rate", -1, 1, 0, step = 0.1),
          sliderInput("pcrime", "Property Crime Rate", -1, 1, 0, step = 0.1)
        ),
        box(width = 3,
          title = "Select Weights",
          sliderInput("age", "Median Age", -1, 1, 0, step = 0.1),
          sliderInput("hh_size", "Median Household Size", -1, 1, 0, step = 0.1),
          sliderInput("area", "Area", -1, 1, 0, step = 0.1)
        ),
        box(width = 3,
          title = "Select Weights",
          sliderInput("pop2000", "Population 2000", -1, 1, 0, step = 0.1),
          sliderInput("pop2014", "Population 2014", -1, 1, 0, step = 0.1),
          sliderInput("popchange", "% Population Change", -1, 1, 0, step = 0.1)
        )
      )
    )
  )
  
  server <- function(input, output) {
    score <- reactive({
      s <- df$hh_inc * input$hh_inc +
      df$age * input$age +
      df$pop2000 * input$pop2000 +
      df$area * input$area +
      df$density * input$density +
      df$col * input$col +
      df$pop2014 * input$pop2014 +
      df$popchange * input$popchange +
      df$hh_size * input$hh_size +
      df$h_price * input$h_price +
      df$vcrime * input$vcrime +
      df$pcrime * input$pcrime
      intervalScale(s)
    })
    
    output$cityMap <- renderLeaflet({
      radius <- score()
      if (all(radius == 0)) {
        mapVis(cfl, radius = 5, color = "Black")
      } else {
        mapVis(cfl, radius = radius^2 * 20)
      }
    })
    
    output$cityTable <- renderTable({
      df <- data.frame(name = cfl$name,
        score = round(score(), 2))
      arrange(df, desc(score))[1:10, ]
    })
  
    observeEvent(input$stop, {
      stopApp(returnValue = structure(round(score(), 2), names = cfl$name))
    })
  }
  
  runApp(shinyApp(ui, server))
}

