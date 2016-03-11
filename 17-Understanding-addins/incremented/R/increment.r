
# This function does the core add-in work.
increment <- function(delta) {
  # Get information about the current document
  context <- rstudioapi::getActiveDocumentContext()

  # Loop over all of the selected text regions in the document
  for (sel in context$selection) {

    # Attempt to coerce the selected text to a number; skip if it's not a 
    # number.
    suppressWarnings(int <- as.integer(sel$text))
    if (is.na(int)) next

    # Replace the selection with the the updated number.
    rstudioapi::modifyRange(sel$range,
                            as.character(int+delta),
                            context$id)
    break
  }
}

# This is an exposed add-in function; it increments the selected number by 1.
incrementr <- function() {
  increment(1)
}

# This is an exposed add-in function; it decrements the selected number by 1.
decrementr <- function() {
  increment(-1)
}

