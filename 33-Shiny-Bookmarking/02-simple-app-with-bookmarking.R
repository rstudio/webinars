ui <- function(request) {
  fluidPage(
    textInput("txt", "Enter text"),
    verbatimTextOutput("out"),
    bookmarkButton()
  )
}
server <- function(input, output, session) {
  output$out <- renderText({
    input$txt
  })
}

shinyApp(ui, server, enableBookmarking = "url")
