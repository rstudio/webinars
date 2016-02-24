ui <- basicPage(
  plotOutput("plot1", width = 400,
    brush = "plot_brush"
  ),
  verbatimTextOutput("info")
)

server <- function(input, output) {
  output$plot1 <- renderPlot({
    ggplot(mtcars, aes(wt, mpg)) + geom_point()
  })

  output$info <- renderPrint({
    rows <- brushedPoints(mtcars, input$plot_brush)
    cat("Brushed points:\n")
    print(rows)
  })
}

shinyApp(ui, server)
