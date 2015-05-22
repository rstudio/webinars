library(ggplot2)
library(scales)
library(lubridate)
library(nasaweather)

storm_plot <- function(name1) {
  
  df <- subset(storms, name == name1)
  df$date <- ymd_hms(paste0(df$year, "-", df$month, "-", df$day, 
                  " ", df$hour, ":00:00"))
  x1 <- min(df$date)
  x2 <- max(df$date)
  xm <- mean(c(x1, x2)) 
  a <- 1.5
  label.adj <- 2
  
  
  ggplot(df, aes(date, wind)) +
    annotate("rect", ymin = 35, ymax = 64, xmin = x1, xmax = x2, 
              fill = "grey90") +
    annotate("rect", ymin = 64, ymax = 83, xmin = x1, xmax = x2, 
              fill = "grey80") +
    annotate("rect", ymin = 83, ymax = 96, xmin = x1, xmax = x2, 
              fill = "grey65") +
    annotate("rect", ymin = 96, ymax = 113, xmin = x1, xmax = x2, 
              fill = "grey50") +
    annotate("rect", ymin = 113, ymax = 137, xmin = x1, xmax = x2, 
              fill = "grey35") +
    annotate("rect", ymin = 137, ymax = 160, xmin = x1, xmax = x2, 
              fill = "grey20") +
    annotate("text", label = "Tropical Depression", x = xm, y = 17 + label.adj,
              size = 4, hjust = -1 + a, color = "grey90") +
    annotate("text", label = "Tropical Storm", x = xm, y = 37 + label.adj,
              size = 4, hjust = -1 + a, color = "white") +
    annotate("text", label = "Category 1", x = xm, y = 66 + label.adj,
              size = 4, hjust = -1 + a, color = "grey90") +
    annotate("text", label = "Category 2", x = xm, y = 85 + label.adj,
              size = 4, hjust = -1 + a, color = "grey80") +
    annotate("text", label = "Category 3", x = xm, y = 98 + label.adj,
              size = 4, hjust = -1 + a, color = "grey70") +
    annotate("text", label = "Category 4", x = xm, y = 115 + label.adj,
              size = 4, hjust = -1 + a, color = "grey60") +
    annotate("text", label = "Category 5", x = xm, y = 139 + label.adj,
              size = 4, hjust = -1 + a, color = "grey50") +
    geom_line(color = "blue") +
    theme_bw() +
    scale_y_continuous("Windspeed (knots)") +
    coord_cartesian(ylim = c(15, 160), xlim = c(x1, x2)) +
    ggtitle(df$name[1])
}