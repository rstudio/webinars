# Example usage:
# lmGadget(mtcars, "wt", "mpg")
#
# Returns a list with two items:
#   $data: Data with excluded rows removed.
#   $model: lm (model) object.
lmGadget <- function(data, xvar, yvar) {
  library(shiny)
  library(miniUI)
  library(ggplot2)

  ui <- miniPage(
    gadgetTitleBar("Interactive lm"),
    miniContentPanel(
      fillRow(flex = c(NA, 1),
        fillCol(width = "100px",
          selectInput("degree", "Polynomial degree", c(1, 2, 3, 4))
        ),
        plotOutput("plot1",
          height = "100%",
          click = "plot1_click",
          brush = brushOpts(
            id = "plot1_brush"
          )
        )
      )
    ),
    miniButtonBlock(
      actionButton("exclude_toggle", "Toggle points"),
      actionButton("exclude_reset", "Reset")
    )
  )

  server <- function(input, output) {
    # For storing which rows have been excluded
    vals <- reactiveValues(
      keeprows = rep(TRUE, nrow(data))
    )

    output$plot1 <- renderPlot({
      req(input$degree)
      formula <- as.formula(paste0("y ~ poly(x, degree = ", input$degree, ")"))

      # Plot the kept and excluded points as two separate data sets
      keep    <- data[ vals$keeprows, , drop = FALSE]
      exclude <- data[!vals$keeprows, , drop = FALSE]

      ggplot(keep, aes_string(xvar, yvar)) +
        geom_point(size = 3) +
        geom_smooth(method = lm, formula = formula, fullrange = TRUE, color = "gray50") +
        geom_point(data = exclude, fill = NA, color = "black", size = 3, alpha = 0.25) +
        coord_cartesian(xlim = range(data[[xvar]]), ylim = range(data[[yvar]])) +
        theme_bw(base_size = 14)
    })

    # Toggle points that are clicked
    observeEvent(input$plot1_click, {
      res <- nearPoints(data, input$plot1_click, allRows = TRUE)

      vals$keeprows <- xor(vals$keeprows, res$selected_)
    })

    # Toggle points that are brushed, when button is clicked
    observeEvent(input$exclude_toggle, {
      res <- brushedPoints(data, input$plot1_brush, allRows = TRUE)

      vals$keeprows <- xor(vals$keeprows, res$selected_)
    })

    # Reset all points
    observeEvent(input$exclude_reset, {
      vals$keeprows <- rep(TRUE, nrow(data))
    })

    # Handle the Done button being pressed.
    observeEvent(input$done, {
      # Replace x and y in the formula with the values in xvar and yvar
      formula <- as.formula(paste0(yvar, " ~ poly(", xvar, ", degree = ", input$degree, ")"))
      keep_data <- data[vals$keeprows, , drop = FALSE]

      # Return the kept points.
      stopApp(
        list(
          data = keep_data,
          model = lm(formula, keep_data)
        )
      )
    })

  }

  runGadget(ui, server)
}
