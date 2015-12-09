library(shiny)
library(ggplot2)

ui <- fluidPage(
  plotOutput("plot")
)

server <- function(input, output, session) {
  mydata <- reactive({
    head(25, cars)
  })
  
  output$plot <- renderPlot({
    ggplot(mydata(), aes(speed, dist)) + geom_point()
  })
}

shinyApp(ui, server)