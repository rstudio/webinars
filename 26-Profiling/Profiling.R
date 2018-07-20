# ---------------------------------------------------------------------
# Normalizing columns
# First generate data with 400000 rows and 150 cols
data <- as.data.frame(
  matrix(rnorm(4e5 * 150, mean = 5), ncol = 150)
)

normCols <- function(d) {
  # Get vector of column means
  means <- apply(d, 2, mean)

  # Subtract mean from each column
  for (i in seq_along(means)) {
    d[, i] <- d[, i] - means[i]
  }
  d
}

# Run, but don't print output
invisible(normCols(data))


# ---------------------------------------------------------------------
# With timing:
system.time({
  normCols <- function(d) {
    # Get vector of column means
    means <- apply(d, 2, mean)

    # Subtract mean from each column
    for (i in seq_along(means)) {
      d[, i] <- d[, i] - means[i]
    }
    d
  }

  normCols(data)
})


# ---------------------------------------------------------------------
# With profiling:
library(profvis)
profvis({
  normCols <- function(d) {
    means <- apply(d, 2, mean)

    for (i in seq_along(means)) {
      d[, i] <- d[, i] - means[i]
    }
    d
  }

  normCols(data)
})


# ---------------------------------------------------------------------
# Four different ways of getting column means
profvis({
  means <- apply(data, 2, mean)
  means <- colMeans(data)
  means <- lapply(data, mean)
  means <- vapply(data, mean, numeric(1))
})


# ---------------------------------------------------------------------
# Faster version
profvis({
  d <- data
  means <- vapply(d, mean, numeric(1))

  for (i in seq_along(means)) {
    d[, i] <- d[, i] - means[i]
  }
})


# ---------------------------------------------------------------------
# Text processing
profvis({
  lines <- readLines("output.prof")

  proc_lines <- list()

  for (i in seq_along(lines)) {
    line <- lines[i]
    line <- strsplit(line, " ")[[1]]

    linedata <- data.frame(
      row = i,
      col = rev(seq_along(line)),
      label = line
    )

    proc_lines[[i]] <- linedata
  }

  # rbind all the data frames together
  proc_data <- do.call(rbind, proc_lines)
})


# ---------------------------------------------------------------------
# Faster version, using lists instead of data frames:
profvis({
  lines <- readLines("output.prof")

  proc_lines <- list()

  for (i in seq_along(lines)) {
    line <- lines[i]
    line <- strsplit(line, " ")[[1]]

    # Put line data in a list instead of a data frame
    linedata <- list(
      row = rep(i, length(line)),
      col = rev(seq_along(line)),
      label = line
    )

    proc_lines[[i]] <- linedata
  }

  extract_vector <- function(x, name) {
    vecs <- lapply(x, `[[`, name)
    do.call(c, vecs)
  }

  proc_data <- data.frame(
    row   = extract_vector(proc_lines, "row"),
    col   = extract_vector(proc_lines, "col"),
    label = extract_vector(proc_lines, "label")
  )
})
