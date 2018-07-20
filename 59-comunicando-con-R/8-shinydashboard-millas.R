library(shiny)
library(shinydashboard)
library(tidyverse)
library(DT)

load("datos/millas.rda")
load("modelo.rds")

pred <- predict(modelo, millas)

df <- millas %>%
  mutate(
    pred = round(pred),
    anio = as.character(anio)
  )

fabricantes <- unique(millas$fabricante)

ui <- dashboardPage(
  dashboardHeader(title = "Millas"),
  dashboardSidebar(
    selectInput("fabricante", label = "Fabricante",
                choices = fabricantes)
  ),
  dashboardBody(
    plotOutput("resultados")
  )
)

server <- function(input, output) {
  output$resultados <-  renderPlot({
    df %>%
      filter(fabricante == input$fabricante) %>%
      mutate(
        id = row_number(),
        anio = as.character(anio)
      ) %>%
      ggplot() +
      geom_col(aes(id, autopista, fill = anio), alpha = 0.5) +
      geom_col(aes(id, pred, fill = anio), color = "darkgray", alpha = 0) +
      geom_text(aes(id, 0.1, label = modelo), size = 2.5, hjust = 0) +
      geom_text(aes(id, autopista, label = autopista), size = 2, hjust = 1) +
      geom_text(aes(id, pred, label = pred), size = 2.5, hjust = 0) +
      coord_flip() +
      theme_void() +
      labs(fill = "Autopista")  
  })
  

}

shinyApp(ui, server)