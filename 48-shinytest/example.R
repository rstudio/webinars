library(shiny)
runApp("drinkr/shiny_app")


library(shinytest)
recordTest("drinkr/shiny_app")


testApp("drinkr/shiny_app")
