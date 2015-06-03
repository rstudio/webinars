# 03-layout.R

library(shiny)

ui <- fluidPage(
  fluidRow(
   column(3),
   column(5, sliderInput(inputId = "num", 
     label = "Choose a number", 
     value = 25, min = 1, max = 100))
  ),
  fluidRow(
    column(4, offset = 8,
      plotOutput("hist")
    )
  )
)

server <- function(input, output) {
  output$hist <- renderPlot({
    hist(rnorm(input$num))
  })
}

shinyApp(ui = ui, server = server)