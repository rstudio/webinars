library(nycflights13)
library(dplyr)
library(ggvis)
library(lubridate)

# Summarize and join daily flight and weather data
daily <- flights %>%
  filter(origin == "EWR") %>%
  group_by(year, month, day) %>%
  summarise(
    delay = mean(dep_delay, na.rm = TRUE),
    cancelled = mean(is.na(dep_delay))
  )
daily_weather <- weather %>%
  filter(origin == "EWR") %>%
  group_by(year, month, day) %>%
  summarise(
    temp = mean(temp, na.rm = TRUE),
    wind = mean(wind_speed, na.rm = TRUE),
    precip = sum(precip, na.rm = TRUE)
  )
both <- daily %>%
  inner_join(daily_weather) %>%
  ungroup() %>%
  mutate(date = as.Date(ISOdate(year, month, day)))


# Scatter plot with smoothing line
both %>%
  ggvis(x = ~temp, y = ~delay) %>%
  layer_points() %>%
  layer_smooths()

# Mapping a variable to fill color
both %>%
  ggvis(~temp, ~delay, fill = ~precip) %>%
  layer_points()

# Histogram
both %>% ggvis(~delay) %>% layer_histograms()
both %>% ggvis(~delay)


# Reactive computation parameters
both %>%
  ggvis(~delay) %>%
  layer_histograms(binwidth = input_slider(1, 10, value = 5))

# Reactive properties
both %>%
  ggvis(~delay, ~precip) %>%
  layer_points(opacity := input_slider(0, 1))


# Reactive data sources --------------
dat <- data.frame(time = 1:10, value = runif(10))

# Create a reactive that returns a data frame, adding a new
# row every 2 seconds
ddat <- reactive({
  invalidateLater(2000, NULL)
  dat$time  <<- c(dat$time[-1], dat$time[length(dat$time)] + 1)
  dat$value <<- c(dat$value[-1], runif(1))
  dat
})

ddat %>% ggvis(x = ~time, y = ~value, key := ~time) %>%
  layer_points() %>%
  layer_paths()

# Extra stuff =========================================================

# Histogram of delays for each flight
flights %>% ggvis(~dep_delay) %>%
  layer_histograms(binwidth = input_slider(1, 10)) %>%
  scale_numeric("x",
                domain = input_slider(-100, 600, value = c(-100, 600)),
                clamp = TRUE)


## Reactive data source 2: grand tour
library(tourr)
aps <- 2
fps <- 30
mat <- rescale(as.matrix(flea[1:6]))
tour <- new_tour(mat, grand_tour(), NULL)
start <- tour(0)

proj_data <- reactive({
  invalidateLater(1000 / fps, NULL);
  step <- tour(aps / fps)
  data.frame(center(mat %*% step$proj), species = flea$species)
})

proj_data %>% ggvis(~X1, ~X2, fill = ~species) %>%
  layer_points() %>%
  scale_numeric("x", domain = c(-1, 1)) %>%
  scale_numeric("y", domain = c(-1, 1)) %>%
  add_axis("x", title = "") %>% add_axis("y", title = "") %>%
  set_options(duration = 0)
