#' mapVis
#'
#' Plots an interactive leaflet map that displays each row as a circle marker in
#' the map. Designed to work with the \code{\link{cfl}} data set.
#'
#' @param x A data frame with \code{lat} (latitude) and \code{long} (longitude)
#'   columns.
#' @param radius Expression to map circle marker radius to. Can use column names
#'   from \code{x}.
#' @param color Color of circle markers, as character sting
#'
#' @return A leaflet map visualization
#' @export
mapVis <- function(x, radius = ~10, color = "Blue") {
  leaflet(x) %>%
    setView(lng = -81.3754, lat = 28.616, zoom = 9) %>%
    addTiles() %>%
    addCircleMarkers(radius = radius,
      color = color,
      popup = ~htmltools::htmlEscape(name))
}

#' intervalScale
#'
#' Scales a vector to the 0-1 interval. The minimum value will be scaled to
#' zero, the maximum to 1, and the remaining values will be spaced
#' proportionately between.
#'
#' @param x A numeric vector
#'
#' @return A numeric vector
#' @export
#'
#' @examples
#' intervalScale(-5:5)
intervalScale <- function(x) {
  if (length(x) <= 1) stop("x must contain two or more values")
  if (all(x[!is.na(x)] == 0)) return(x)
  y <- x - min(x, na.rm = TRUE)
  y / max(y, na.rm = TRUE)
}
