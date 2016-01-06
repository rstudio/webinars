library(shiny)
library(datasets)

# Define UI for dataset viewer application
ui <- shinyUI(fluidPage(
  
  # Application title
  titlePanel("Data Viewer"),
  
  # Sidebar with controls to provide a caption, select a dataset,
  # and specify the number of observations to view. Note that
  # changes made to the caption in the textInput control are
  # updated in the output area immediately as you type
  sidebarLayout(
    sidebarPanel(
      
      selectInput("dataset", "Choose a dataset:", 
                  choices = c("pressure", "rock", "cars")),
      
      numericInput("obs", "Number of observations to view:", 4, 1, 10)
    ),
    
    
    # Show the caption, a summary of the dataset and an HTML 
    # table with the requested number of observations
    mainPanel(
      h3(textOutput("caption", container = span)),
      
      #verbatimTextOutput("summary"), 
      
      tableOutput("view")
    )
  )
))

# Define server logic required to summarize and view the selected
# dataset
server <- function(input, output) {
  
  # By declaring datasetInput as a reactive expression we ensure 
  # that:
  #
  #  1) It is only called when the inputs it depends on changes
  #  2) The computation and result are shared by all the callers 
  #	  (it only executes a single time)
  #
  datasetInput <- reactive({
    switch(input$dataset,
           "pressure" = pressure,
           "rock" = rock,
           "cars" = cars)
  })
  
  # The output$summary depends on the datasetInput reactive
  # expression, so will be re-executed whenever datasetInput is
  # invalidated
  # (i.e. whenever the input$dataset changes)
  output$summary <- renderPrint({
    dataset <- datasetInput()
    summary(dataset)
  })
  
  # The output$view depends on both the databaseInput reactive
  # expression and input$obs, so will be re-executed whenever
  # input$dataset or input$obs is changed. 
  output$view <- renderTable({
    head(datasetInput(), n = input$obs) #updated
  })
}

shinyApp(ui, server)