ui <- basicPage(
  plotOutput("plot1", click = "plot_click", width = 400),
  verbatimTextOutput("info")
)

server <- function(input, output) {
  output$plot1 <- renderPlot({
    plot(mtcars$wt, mtcars$mpg)
  })

  output$info <- renderText({
    paste0("x=", input$plot_click$x, "\n",
           "y=", input$plot_click$y)
  })
}

shinyApp(ui, server)
