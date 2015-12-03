# Plot a bar chart
barchart <- function(z, z, width = 0.9) {
  require(ggplot2)

  counts <- table(z)
  df <- data.frame(
    value = names(counts),
    count = as.numeric(counts)
  )

  ggplot(df) +
    geom_bar(aes(z = value, y = count), stat = "identity", width = width)
}





# Select a comment and use Code -> Reflow or the keyboard shortcut Comment (Control + Shift +/) to make it tidy. Works nicely with rozygen2 when you are 
# documenting 
# functions for packages.
