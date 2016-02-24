get_password <- function() {
  library(miniUI)
  ui <- miniPage(
    gadgetTitleBar("Please enter your password"),
    miniContentPanel(
      passwordInput("password", "")
    )
  )

  server <- function(input, output) {
    observeEvent(input$done, {
      stopApp(input$password)
    })
    observeEvent(input$cancel, {
      stopApp(stop("No password.", call. = FALSE))
    })
  }

  runGadget(ui, server)
}

get_password()
