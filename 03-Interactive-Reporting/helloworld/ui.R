library(shiny)

# Define UI for application that draws a histogram
shinyUI(pageWithSidebar(

  # Application title
  h1("Hello Shiny!"),

  # Sidebar with a slider input for the number of bins
  sidebarPanel(
    sliderInput("bins",
                "Number of bins:",
                min = 1,
                max = 50,
                value = 30)
  ),

  # Show a plot of the generated distribution
  mainPanel(
    plotOutput("distPlot")
  )
))
