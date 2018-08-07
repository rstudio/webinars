library(shiny)
source("helper_functions.R")

is_testmode <- function() {
  isTRUE(getOption("shiny.testmode"))
}


shinyServer(function(input, output, session) {
  
  drink_info <- read.csv("drink_info.csv", stringsAsFactors=FALSE)
  drinks <- data.frame(name = character(0), vol = numeric(0), alc_prop = numeric(0), time = numeric(0), stringsAsFactors = FALSE)
  makeReactiveBinding("drinks")
  
  # The time at the client when the shiny app was started as a POSIXct object. 
  # ("using" the UTC time zone, but that's just because some time zone has to be set)
  client_start_time <- reactive({
    if (is_testmode()) {
      return(as.POSIXct("2017-10-04 10:30:00 CDT", origin="1970-01-01", tz = "UTC"))
    }

    isolate({
      client_time_UTC <- as.numeric(input$client_time) / 1000 # in s
    })
    as.POSIXct(client_time_UTC - time_zone_offset(), origin="1970-01-01", tz = "UTC")
  })
  
  time_zone_offset <- reactive({
    if (is_testmode()) {
      return(0)
    }
    as.numeric(input$client_time_zone_offset) * 60 # in s 
  })
  
  
  ### The BAC graph ###
  
  timed_update <- reactiveTimer(1000 * 20, session)
  output$bac_plot <- renderPlot({
    if (!is_testmode()) {
      timed_update()
    }

    # Doing some conversion from the UI units to the units used
    # by the BAC script
    height <- input$height / 100 # cm to m
    weight <- input$weight
    sex <- input$sex
    absorption_halflife <- input$halflife * 60 # from min to sec
    beta <- input$elimination / 100 / (60 * 60) # bac / sec, converted to proportion from percentage and from hour to second

    if (is_testmode()) {
      time_now <- as.POSIXct("2017-10-04 10:30:00 CDT", origin="1970-01-01", tz = "UTC") - time_zone_offset()
    } else {
      time_now <- as.POSIXct(as.numeric(Sys.time()), origin="1970-01-01", tz = "UTC") - time_zone_offset()
    }

    if(nrow(drinks) > 0) {
      start_time = min(drinks$time, as.integer(time_now))
      end_time = max(drinks$time) + 60 * 60 * 24
    } else {
      start_time <- as.integer(time_now)
      end_time <- start_time + 60L * 60L * 24L
    }
    bac_ts <- calc_bac_ts(drinks, height, weight, sex, absorption_halflife, beta, start_time, end_time)
    
    plot_bac_ts(bac_ts, drinks, time_now, drink_info = drink_info)
  })
  
  
  ### The parameters governing the BAC calculation ###
  
  output$height_text <- renderText({
    cms <- as.numeric(input$height)
    feet <- floor(0.03281 * cms)
    inches <- round(((0.03281 * cms) %% 1) * 12) 
    paste0("Height in cm (" , cms, " cm = ", feet, "'", inches, "'')")
  })
  
  output$weight_text <- renderText({
    kgs <- as.numeric(input$weight)
    pounds <- round(kgs * 2.20462)
    paste0("Weight in kg (" , kgs, " kg = ", pounds, " lb)")
  })
  
  ### The drink inputs ###
  
  output$drink_time_input <- renderUI({
    # Rounding to the next 10 minute mark
    rounded_time <- client_start_time() + 10 * 60 - as.numeric( client_start_time() ) %% (10 * 60)
    drink_times <- rounded_time + seq(-12*60*60, 12*60*60, by = 10*60)
    time_names <- format(drink_times, format="%H:%M")
    drink_times <- as.numeric(drink_times)
    names(drink_times) <- time_names
    selectInput("drink_time", "Drink time", drink_times, selected=as.numeric(rounded_time))
  })
  
  output$drink_type_input <- renderUI({
    selectInput("drink_type", "Drink type", drink_info$drink, selected = drink_info$drink[1])
  })
  
  observe({
    drink <- input$drink_type
      if(! is.null(drink)) {
        updateSliderInput(session, "volume", value = drink_info$volume[drink_info$drink == drink])
        updateSliderInput(session, "alc_perc", value = round(drink_info$alc_prop[drink_info$drink == drink] * 100))
     }
   })
  
  observe({
    isolate(drink <- input$drink_type)
    if(!is.null(drink) & !is.null(input$volume)) {
      drink_info$volume[ drink_info$drink == drink] <<- input$volume
    }
  })
    
  output$volume_input <- renderUI({
    sliderInput("volume", step = 1, "", min = 1, max = 120, value = drink_info$volume[1])
  })
  
  output$volume_text <- renderText({
    cls <- as.numeric(input$volume)
    fluid_ounces <- round(cls * 0.338140227, 1)
    paste0("Volume in cl (" , cls, " cl = ", fluid_ounces, " fl oz)")
  })
  
  observe({
    isolate(drink <- input$drink_type)
    if(!is.null(drink) & !is.null(input$alc_perc)) {
      drink_info$alc_prop[ drink_info$drink == drink] <<- input$alc_perc / 100
    }
  })
  
  output$alc_perc_input <- renderUI({
    sliderInput("alc_perc", "Percent alcohol", min = 0, max = 100, value = drink_info$alc_prop[1] * 100)
  })
  
  # Add the drink when the "Add drink" button is pressed
  observe({
    input$add_drink
    isolate({
      drink_type <- input$drink_type
      volume <- as.numeric(input$volume) / 100 # from cl to liter
      alc_prop <- as.numeric(input$alc_perc) / 100 # from % to prop
      drink_time <- as.numeric(input$drink_time)
      drinks <<- rbind(drinks, data.frame(name = drink_type, vol = volume, alc_prop = alc_prop, time=drink_time, stringsAsFactors = FALSE))
      drinks <<- drinks[order(drinks$time),]
    })
  })

  ### The list of drunken drinks ###
  
  output$drunken_drinks_input <- renderUI({
    if(nrow(drinks) > 0) { 
      drink_labels <- paste(format(as.POSIXct(drinks$time, origin="1970-01-01", tz = "UTC"), tz = "UTC", format="%H:%M"),
                            " ", drinks$name, " (", round(drinks$vol * 100), " cl, ", round(drinks$alc_prop * 100), "%)", sep="")
      drink_id <- seq_len(nrow(drinks))
      names(drink_id) <- drink_labels 
      selectInput("drunken_drinks", "Drunken drinks",drink_id)
    } else {
      "" 
    }
  })
  
  output$remove_drink_input <- renderUI({
    if(nrow(drinks) > 0) {
      actionButton("remove_drink", "Remove drink", icon = icon("trash-o"))
    } else {
      ""
    }
  })
  
  observe({
    input$remove_drink
    isolate({
      drink_to_remove <- as.numeric(input$drunken_drinks)
      drinks_local <- drinks
      
      if(!is.null(input$remove_drink) && input$remove_drink > 0 && !is.null(drink_to_remove) && drink_to_remove %in% seq_len(nrow(drinks))) {
        drinks <<- drinks[-drink_to_remove, ]
      }
    })
  })
  
})

