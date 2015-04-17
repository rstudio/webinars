library(shinydashboard)
library(leaflet)
library(ggplot2)

source("load_data.R", local = TRUE)
source("utils.R", local = TRUE)

# -----------------------------------------------------------------------------
# Dashboard UI
# -----------------------------------------------------------------------------
ui <- dashboardPage(
  dashboardHeader(
    title = "Activity tracker"
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Location history", tabName = "history", icon = icon("database")),
      menuItem("Current location", tabName = "current", icon = icon("crosshairs")),
      menuItem("Calories", tabName = "calories", icon = icon("fire"))
    ),
    div(style = "padding-left: 30px; padding-top: 20px;",
      actionButton(class = "btn-sm", "refresh",
        tagList(icon("refresh"), "Refresh location data")
      )
    ),
    div(style = "padding-left: 15px; padding-top: 40px;",
      p(class = "small", "Made with ",
        a("R", href = "http://www.r-project.org/"),
        ", ",
        a("Shiny", href = "http://shiny.rstudio.com/"),
        ", ",
        a("shinydashboard", href = "http://rstudio.github.io/shinydashboard/"),
        ", ",
        a("ggplot2", href = "http://ggplot2.org/"),
        ", & leaflet",
        a("(1)", href = "http://leafletjs.com/"),
        " ",
        a("(2)", href = "http://rstudio.github.io/leaflet/")


      ),
      p(class = "small", "Data courtesy of ",
        a("PiLR Health", href="http://www.pilrhealth.com/")
      ),
      p(class = "small",
        a("Source code", href = "https://github.com/rstudio/webinars/tree/master/2015-04")
      )
    )
  ),
  dashboardBody(
    tabItems(
      # Current location ------------------------------------------------------
      tabItem(tabName = "current",
        fluidRow(
          infoBoxOutput("dist_today"),
          infoBoxOutput("nearest_venue"),
          infoBoxOutput("dist_venue")
        ),
        fluidRow(
          box(width = 12, title = "Travel today",
            leafletOutput("current_map", height = 500)
          )
        )
      ),
      # Location history ------------------------------------------------------
      tabItem(tabName = "history",
        fluidRow(
          box(width = 8,
            leafletOutput("history_map")
          ),
          box(width = 4, title = "Filter data", status = "warning", solidHeader = TRUE,
            uiOutput("venue_select"),
            uiOutput("venue_dist_slider")
          )
        ),
        fluidRow(box(width = 12,
          plotOutput("distance", height = "150px",
            brush = brushOpts(id = "dist_brush", direction = "x"))
        ))
      ),
      # Calories --------------------------------------------------------------
      tabItem(tabName = "calories",
        fluidRow(box(width = 12,
          plotOutput("vo2", height = "150px"),
          plotOutput("vco2", height = "150px"),
          plotOutput("activity", height = "150px")
        )),
        fluidRow(
          box(width = 6, plotOutput("vo2_vco2", height = "300px")),
          box(width = 6, plotOutput("activity_vo2", height = "300px"))
        ),
        fluidRow(
          box(width = 6, plotOutput("vo2_hist", height = "200px"))
        )
      )
    )
  )
)


# -----------------------------------------------------------------------------
# Dashboard server code
# -----------------------------------------------------------------------------
server <- function(input, output) {

  # Current location ----------------------------------------------------------
  output$current_map <- renderLeaflet({
    today <- log_today()
    now <- log_now()
    venue <- venues()

    leaflet() %>%
      addTiles() %>%
      addPolylines(today$args.lon, today$args.lat) %>%
      addCircles(venue$trig_info.lon, venue$trig_info.lat,
                 venue$trig_info.radius,
                 popup = venue$name, color = '#ff0000') %>%
      addCircles(now$args.lon, now$args.lat, popup = "User", radius = 20) %>%
      fitBounds(min(today$args.lon), min(today$args.lat),
                max(today$args.lon), max(today$args.lat))
  })

  output$dist_today <- renderInfoBox({
    today <- log_today()

    # Calculate distance traveled today
    dists <- vapply(seq_len(nrow(today)-1), FUN.VALUE = numeric(1), function(i) {
      earthdist(
        today$args.lon[i], today$args.lat[i],
        today$args.lon[i+1], today$args.lat[i+1]
      )
    })

    total_dist <- round(sum(dists), 1)

    infoBox(
      "Distance today",
      color = "green",
      icon = icon("bicycle"),
      value = total_dist,
      "km"
    )
  })

  output$nearest_venue <- renderInfoBox({
    infoBox(
      "Nearest venue",
      icon = icon("compass"),
      value = log_now()$args.nearest_venue,
      "m"
    )
  })

  output$dist_venue <- renderInfoBox({
    infoBox(
      "Distance to venue",
      color = "yellow",
      icon = icon("arrows"),
      value = round(log_now()$venue_dist * 1000),
      "m"
    )
  })

  # Most recent data point
  log_now <- reactive({
    today <- log_today()

    # Keep only latest data point
    now <- today[today$local_time == max(today$local_time), ]
    # Make sure we have only one row
    now[1, ]
  })

  # Data from just today
  log_today <- reactive({
    data <- log()

    # Keep only data from latest day in data set
    today <- as.POSIXct((strptime(max(data$local_time), "%Y-%m-%d")))
    data[data$local_time >= today, ]
  })

  # Historical location -------------------------------------------------------
  output$history_map <- renderLeaflet({
    data <- log_dist()
    venue <- venues()

    if (is.null(data))
      return(NULL)

    # Filter by time range, if present
    tr <- timerange()
    if (!is.null(tr)) {
      data <- data[data$local_time >= tr$min & data$local_time <= tr$max, ]
    }

    # Filter by max distance
    if (!is.null(input$max_dist)) {
      data <- data[data$venue_dist <= input$max_dist, ]
    }

    leaflet() %>%
      addTiles() %>%
      addPolylines(data$args.lon, data$args.lat) %>%
      addCircles(venue$trig_info.lon, venue$trig_info.lat,
                 venue$trig_info.radius,
                 popup = venue$name, color = '#ff0000') %>%
      fitBounds(min(data$args.lon), min(data$args.lat),
                max(data$args.lon), max(data$args.lat))
  })

  # Line graph showing distance from known venues
  output$distance <- renderPlot({
    data <- log_dist()
    if (is.null(data))
      return(NULL)

    ggplot(data, aes(local_time, venue_dist)) + geom_line() + theme_bw() +
      geom_hline(yintercept = input$max_dist, colour = "orange",
                 linetype = "dashed") +
      xlab(NULL) + ylab("km") +
      ggtitle(paste("Distance from", input$venue))
  })

  # Select input to choose which venue
  output$venue_select <- renderUI({
    v <- venues()

    selectInput("venue", "Venue",
      choices = v$name,
      selected = v$name[1]
    )
  })

  # Slider to set threshold for distance from venue
  output$venue_dist_slider <- renderUI({
    data <- log_dist()
    if (is.null(data))
      return(NULL)

    # Round up to 10 km
    max_dist <- ceiling(max(data$venue_dist)/10) * 10

    sliderInput("max_dist", "Max. distance from venue (km)",
      min = 1, max = max_dist, value = max_dist
    )
  })

  # Calorimeter data ----------------------------------------------------------
  output$vco2 <- renderPlot({
    cal <- calories()

    ggplot(cal, aes(local_time, VCO2)) + geom_line() + xlab(NULL)
  })

  output$vo2 <- renderPlot({
    cal <- calories()
    ggplot(cal, aes(local_time, VO2)) + geom_line() + xlab(NULL)
  })

  output$activity <- renderPlot({
    cal <- calories()
    ggplot(cal, aes(local_time, Activity)) + geom_line() + xlab(NULL)
  })

  output$vo2_vco2 <- renderPlot({
    cal <- calories()
    ggplot(cal, aes(VO2, VCO2)) +
      geom_point(alpha = 0.5, size = 1.5) +
      geom_line(stat = "smooth", method = "lm", alpha = 0.3, colour = "red",
                se = FALSE)
  })

  output$activity_vo2 <- renderPlot({
    cal <- calories()
    ggplot(cal, aes(Activity, VO2)) +
      geom_point(alpha = 0.5, size = 1.5) +
      geom_line(stat = "smooth", method = "lm", alpha = 0.3, colour = "red",
                se = FALSE)
  })

  output$vo2_hist <- renderPlot({
    cal <- calories()
    ggplot(cal, aes(VO2)) + geom_histogram()
  })


  # Utility functions ---------------------------------------------------------

  # Reactive wrapper for location data. This caches the data, so we only fetch
  # when needed. Calculates distance to currently-selected venue.
  log <- reactive({
    # Reload when refresh button pressed
    input$refresh

    # Get data from the PiLR API
    data <- fetch_location_data()

    # Keep only select columns
    data <- data[, c("args.lat", "args.lon", "local_time", "args.nearest_venue")]
    # Drop any rows wth NA
    data[complete.cases(data), ]
  })

  # Location data with additional columns with distance from selected venue.
  log_dist <- reactive({
    data <- log()
    venue <- venues()

    if (is.null(input$venue))
      return(NULL)

    venue_lon <- venue$trig_info.lon[venue$name == input$venue]
    venue_lat <- venue$trig_info.lat[venue$name == input$venue]

    # Calculate distance to venue
    data$venue_dist <- earthdist(venue_lon, venue_lat, data$args.lon, data$args.lat)
    data
  })

  # Reactive wrapper for venues data. This caches the data, so we only fetch
  # when needed.
  venues <- reactive({
    fetch_venues_data()
  })

  calories <- reactive({
    fetch_calorimeter_data()
  })

  # Get the min and max time, converted to POSIXct
  timerange <- reactive({
    if (is.null(input$dist_brush) || is.null(input$dist_brush$xmin))
       return(NULL)

    # Times are returned as seconds since epoch; convert to POSIXct
    list(
      min = as.POSIXct(input$dist_brush$xmin, origin = "1970-01-01"),
      max = as.POSIXct(input$dist_brush$xmax, origin = "1970-01-01")
    )
  })
}


shinyApp(ui, server)
