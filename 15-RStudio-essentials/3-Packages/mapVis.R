library(leaflet)
library(dplyr)
library(htmltools)


mapVis <- function(x, radius = ~10, color = "Blue") {
  leaflet(x) %>% 
    setView(lng = -81.3754, lat = 28.616, zoom = 9) %>% 
    addTiles() %>%
    addCircleMarkers(radius = radius, 
      color = color,
      popup = ~htmltools::htmlEscape(name))
}

intervalScale <- function(x) {
  if (length(x) <= 1) stop("x must contain two or more values")
  if (all(x[!is.na(x)] == 0)) return(x)
  y <- x - min(x, na.rm = TRUE)
  y / max(y, na.rm = TRUE)
}
