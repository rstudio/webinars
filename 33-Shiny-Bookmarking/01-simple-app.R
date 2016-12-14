ui <- fluidPage(
  textInput("txt", "Enter text"),
  verbatimTextOutput("out")
)
server <- function(input, output, session) {
  output$out <- renderText({
    input$txt
  })
}

shinyApp(ui, server)
