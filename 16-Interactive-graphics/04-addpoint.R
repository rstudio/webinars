ui <- basicPage(
  plotOutput("plot1", click = "plot_click", width = 400)
)

server <- function(input, output) {
  output$plot1 <- renderPlot({
    mtc <- mtcars[, c("wt", "mpg")]

    if (!is.null(input$plot_click)) {
      mtc <- rbind(mtc,
        data.frame(wt = input$plot_click$x, mpg = input$plot_click$y)
      )
    }

    plot(mtc$wt, mtc$mpg)
  })
}

shinyApp(ui, server)
