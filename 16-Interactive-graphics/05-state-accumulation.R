ui <- basicPage(
  plotOutput("plot1", click = "plot_click", width = 400)
)

server <- function(input, output) {
  vals <- reactiveValues(mtc = mtcars[, c("wt", "mpg")])

  observeEvent(input$plot_click, {
    vals$mtc <- rbind(vals$mtc,
      data.frame(wt = input$plot_click$x, mpg = input$plot_click$y)
    )
  })

  output$plot1 <- renderPlot({
    plot(vals$mtc$wt, vals$mtc$mpg)
  })
}

shinyApp(ui, server)
