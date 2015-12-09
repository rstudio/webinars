# Extract nth (from left) digit of a number
get_digit <- function(num, n) {
  # remove numbers on left, then numbers on right
  (num %% (10 ^ n)) %/% (10 ^ n)
}

# Indicate whether a positive number is a palindrome
palindrome <- function(num) {
  digits <- floor(log(num, 10)) + 1
  for (x in 1:((digits %/% 2))) {
    digit1 <- get_digit(num, x)
    digit2 <- get_digit(num, (digits + 1) - x)
    if (digit1 != digit2)
      return(FALSE)
  }
  return(TRUE)
}

# Find the largest palindrome that is the product of two 3-digit numbers
biggest_palindrome <- function() {
  best <- 0
  for (x in 100:999) {
    for (y in x:999) {
      candidate <- x * y
      if (candidate > best && palindrome(candidate)) {
        best <- candidate
      }
    }
  }
  best
}