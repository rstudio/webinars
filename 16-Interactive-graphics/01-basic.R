ui <- basicPage(
  plotOutput("plot"),
  sliderInput("bins", "Number of bins:", 1, 50, 20)
)

server <- function(input, output) {
  output$plot <- renderPlot({
    hist(faithful$waiting, breaks = input$bins)
  })
}

shinyApp(ui, server)
