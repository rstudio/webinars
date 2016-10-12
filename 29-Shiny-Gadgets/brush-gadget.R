library(shiny)
library(miniUI)
library(ggplot2)

pick_points <- function(data, x, y) {
  ui <- miniPage(
    gadgetTitleBar(paste("Select points")),
    miniContentPanel(padding = 0,
      plotOutput("plot1", height = "100%", brush = "brush")
    ),
    miniButtonBlock(
      actionButton("add", "", icon = icon("thumbs-up")),
      actionButton("sub", "", icon = icon("thumbs-down")),
      actionButton("none", "" , icon = icon("ban")),
      actionButton("all", "", icon = icon("refresh"))
    )
  )

  server <- function(input, output) {
    # For storing selected points
    vals <- reactiveValues(keep = rep(TRUE, nrow(data)))

    output$plot1 <- renderPlot({
      # Plot the kept and excluded points as two separate data sets
      keep    <- data[ vals$keep, , drop = FALSE]
      exclude <- data[!vals$keep, , drop = FALSE]

      ggplot(keep, aes_(x, y)) +
        geom_point(data = exclude, color = "grey80") +
        geom_point()
    })

    # Update selected points
    selected <- reactive({
      brushedPoints(data, input$brush, allRows = TRUE)$selected_
    })
    observeEvent(input$add,  vals$keep <- vals$keep | selected())
    observeEvent(input$sub,  vals$keep <- vals$keep & !selected())
    observeEvent(input$all,  vals$keep <- rep(TRUE, nrow(data)))
    observeEvent(input$none, vals$keep <- rep(FALSE, nrow(data)))

    observeEvent(input$done, {
      stopApp(vals$keep)
    })
    observeEvent(input$cancel, {
      stopApp(NULL)
    })

  }

  runGadget(ui, server)
}
# pick_points(mtcars, ~wt, ~mpg)
# pick_points(ggplot2::mpg, aes(displ, hwy))
