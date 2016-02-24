ui <- basicPage(
  plotOutput("zoom", height = "350px"),
  plotOutput("overall", height = "150px",
    brush =  brushOpts(id = "brush", direction = "x")
  )
)

server <- function(input, output) {
  ss <- data.frame(
    n = as.numeric(sunspots),
    year = rep(1749:1983, each = 12) + (0:11)/12
  )

  p <- ggplot(ss, aes(year, n)) +
    geom_line() +
    theme_bw(base_size = 16)

  output$zoom <- renderPlot({
    if (!is.null(input$brush)) {
      p <- p + xlim(input$brush$xmin, input$brush$xmax)
    }
    p
  })

  output$overall <- renderPlot(p)
}

shinyApp(ui, server)
