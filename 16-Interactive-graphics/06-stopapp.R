ui <- basicPage(
  plotOutput("plot1", click = "plot_click", width = 400),
  actionButton("done", "Done")
)

server <- function(input, output, session) {
  vals <- reactiveValues(mtc = mtcars[, c("wt", "mpg")])

  observeEvent(input$plot_click, {
    vals$mtc <- rbind(vals$mtc,
      data.frame(wt = input$plot_click$x, mpg = input$plot_click$y)
    )
  })

  output$plot1 <- renderPlot({
    plot(vals$mtc$wt, vals$mtc$mpg)
  })

  observeEvent(input$done, {
    stopApp(vals$mtc)
  })
}
app <- shinyApp(ui, server)

value <- runApp(app)
