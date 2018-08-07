library(shiny)

is_testmode <- function() {
  isTRUE(getOption("shiny.testmode"))
}

shinyUI(fluidPage(
  titlePanel("drinkR: Estimate your Blood Alcohol Concentration (BAC)"),
  
  fluidRow(
    column(3,
           helpText("Enter information about yourself below to make the estimate more accurate."),
      selectInput("sex", "Sex", selected = "unknown",
                  c("Male" = "male",
                    "Female" = "female",
                    "Unknown" = "unknown")),
      textOutput("height_text"),
      sliderInput("height", step = 1,
                  "",
                  min = 140,
                  max = 210,
                  value = 170),
      textOutput("weight_text"),
      sliderInput("weight", step = 1,
                  "",
                  min = 40,
                  max = 150,
                  value = 82),
      sliderInput("halflife", step = 1,
                  "Absorption halflife in min.",
                  min = 6,
                  max = 18,
                  value = 12),
      helpText("The time in minutes it takes to absorb half of the alcohol of a drink.",
               "If you are completely full it might take around 18 min and if you are completely starved it will be closer to 6 min."),
      sliderInput("elimination",
                  "Alcohol elimination",
                  step = 0.001,
                  min = 0.009,
                  max = 0.035,
                  value = 0.018),
      helpText("The amount of % BAC you eliminate each hour.",
               "Can vary from around 0.009 %/h to 0.035 %/h with 0.018 being average.")
    ),
    
    column(9,
      fluidRow(
        plotOutput("bac_plot")
      ),
      fluidRow(
        column(1),
        column(2, 
          uiOutput("drink_time_input"),
          uiOutput("drink_type_input")
        ),
        column(4,
          uiOutput("volume_text"),
          uiOutput("volume_input"),
          uiOutput("alc_perc_input"),
          actionButton("add_drink", "Add drink!", icon = icon("glass"))
        ),
        column(1),
        column(4,
          uiOutput("drunken_drinks_input"),
          uiOutput("remove_drink_input")
        )
      ), 
      fluidRow(
        column(12, offset = 0, 
          helpText(br(), br(), HTML('Coded by Rasmus Bååth (2014), licenced under the <a rel="license" href="https://github.com/rasmusab/drinkr/blob/master/LICENCE.txt">MIT License</a>.'),  
                   HTML("Find more info about this app <a href='http://www.sumsar.net/blog/2014/07/estimate-your-bac-using-drinkr/'>on my blog</a>."), br(), 
                   HTML("This app is intended for entertainment purposes and might be <b>extremely missleading</b>. Never use it for any serious purpose, please!"))    
        )
      )
    )
  ),
  
  HTML('<input type="text" id="client_time" name="client_time" style="display: none;"> '),
  HTML('<input type="text" id="client_time_zone_offset" name="client_time_zone_offset" style="display: none;"> '),
  
  if (!is_testmode()) {
    tags$script('
      $(function() {
        var time_now = new Date()
        $("input#client_time").val(time_now.getTime())
        $("input#client_time_zone_offset").val(time_now.getTimezoneOffset())
      });    
    ')
  }
  
))
