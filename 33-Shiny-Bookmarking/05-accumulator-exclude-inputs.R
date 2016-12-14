ui <- function(request) {
  fluidPage(
    sidebarPanel(
      sliderInput("n", "Value to add", min = 0, max = 100, value = 50),
      actionButton("add", "Add"), br(), br(),
      bookmarkButton()
    ),
    mainPanel(
      h4("Sum:", textOutput("sum"))
    )
  )
}
server <- function(input, output, session) {
  vals <- reactiveValues(sum = 0)
  
  onBookmark(function(state) {
    state$values$currentSum <- vals$sum
  })
  onRestore(function(state) {
    vals$sum <- state$values$currentSum
  })
  setBookmarkExclude("add")
  
  observeEvent(input$add, {
    vals$sum <- vals$sum + input$n
  })
  output$sum <- renderText({
    vals$sum
  })
}

shinyApp(ui, server, enableBookmarking = "url")