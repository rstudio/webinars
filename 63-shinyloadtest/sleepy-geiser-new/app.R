library(shiny)

ui <- fluidPage(
   
   titlePanel("(Sleepy) Old Faithful Geyser Data"),
   
   sidebarLayout(
      sidebarPanel(
         sliderInput("bins",
                     "Number of bins:",
                     min = 1,
                     max = 50,
                     value = 30)
      ),
      
      
      mainPanel(
         plotOutput("distPlot")
      )
   )
)

# Simulates retrieving dataset from some slow network resource (database, network drive)
get_faithful_data <- function() {
  Sys.sleep(1)
  faithful
}

my_data <- get_faithful_data()[,2]

server <- function(input, output) {
   
   output$distPlot <- renderPlot({
      x    <- my_data
      bins <- seq(min(x), max(x), length.out = input$bins + 1)
      hist(x, breaks = bins, col = 'darkgray', border = 'white')
   })
}

shinyApp(ui = ui, server = server)

