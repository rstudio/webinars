
# Use dev version of rlang
source("https://install-github.me/tidyverse/rlang")

# We'll soon have a tidyeval package!
library("rlang")

library("tidyverse")



#  Quoting functions: what and why? ----------------------------------

### Data masking

# transmute() is a quoting function
transmute(starwars, height / mass)

# Allows you to refer to data objects directly
height / mass
starwars$height / starwars$mass


### quote() and eval()

# Quoting an expression is a bit like quoting a string
quote(height / mass)
"height / mass"

# But it's R code that you can evaluate
x <- quote(height / mass)
eval(x)

# With a data mask it works!
eval(x, starwars)

# That's just how transmute() works
transmute(starwars, height / mass)



#  Why do we need tidy eval? -----------------------------------------

### Constants and variables  ---  cement()

cement <- function(...) {
  vars <- ensyms(...)
  vars <- map(vars, as.character)
  paste(vars, collapse = " ")
}

# cement() is sort of a quoting version of paste()
paste("bernard", "bianca")
cement(bernard, bianca)


mouse3 <- "fievel"

# `mouse3` is taken as a constant!
cement(bernard, bianca, mouse3)

# Just like it would in a quoted string:
"bernard mouse3"

# That's not a problem for regular functions:
paste("bernard", mouse3)


### Unquoting with the !! operator

# With !! you can refer to variables inside a quoted expression
cement(bernard, bianca, !!mouse3)

# Use qq_show() to debug the unquoting
qq_show(
  cement(bernard, bianca, !!mouse3)
)



#  First example: Working with column names --------------------------

### Goal: Compute average on different column names

# Here is a simple pipeline:
starwars %>%
  summarise(avg = mean(height, na.rm = TRUE))

# Let's try to reuse it on these column names
cols <- c("height", "mass")


### Naive attempt with !!

col <- cols[[1]]

# oh no!
starwars %>%
  summarise(avg = mean(!!col, na.rm = TRUE))

# We've unquoted a string... mean("string") doesn't compute
qq_show(
  starwars %>%
    summarise(avg = mean(!!col, na.rm = TRUE))
)


### Creating symbols

# Use sym() to create a symbol from a string
col <- sym(cols[[1]])

# Looks about right!
qq_show(
  starwars %>%
    summarise(avg = mean(!!col, na.rm = TRUE))
)

starwars %>%
  summarise(avg = mean(!!col, na.rm = TRUE))


### Using !! in a loop

cols

dfs <- vector("list", length(cols))

for (i in seq_along(cols)) {
  col <- sym(cols[[i]])
  dfs[[i]] <- starwars %>%
    summarise(avg = mean(!!col, na.rm = TRUE))
}

dfs


### Using !! in a function

summarise_avg <- function(data, col) {
  col <- sym(col)
  data %>%
    summarise(avg = mean(!!col, na.rm = TRUE))
}

summarise_avg(starwars, "height")
summarise_avg(starwars, "mass")

map(cols, summarise_avg, data = starwars)


# Doesn't look too great in a pipe because it's not a quoting function
starwars %>%
  group_by(species) %>%
  summarise_avg("height")



#  Second example:  Our own quoting function -------------------------

summarise_avg <- function(data, col) {
  col <- sym(col)
  data %>%
    summarise(avg = mean(!!col, na.rm = TRUE))
}



### Introducing enquo()

# A small change: switch from sym() to enquo()
summarise_avg <- function(data, col) {
  col <- enquo(col)
  data %>%
    summarise(avg = mean(!!col, na.rm = TRUE))
}

summarise_avg(starwars, height)
summarise_avg(starwars, mass)



### Mapping symbols

sym("foo")
syms(cols)

map(syms(cols), summarise_avg, data = starwars)



### Note on quosures

# A quosure wraps a quoted expression and its original environment
quote(mass / height)
quo(mass / height)


mice <- c("bernard", "bianca", "fievel")

set.seed(1)
make_mouse <- function() {
  mouse <- sample(mice, 1)
  quo(mouse)
}

q1 <- make_mouse()
q2 <- make_mouse()

# `mouse` refers to different objects:
q1
q2

eval_tidy(q1)
eval_tidy(q2)

# We can create complex quoted expressions from different quosures:
q3 <- quo(list(!!q1, !!q2))
q3

# The `mouse` objects are still resolved correctly because the
# quosures know about their original environment:
eval_tidy(q3)

# If ever confused about the way a quosure looks, use quo_squash() to
# flatten it to a bare expression:
quo_squash(q3)



#  Third example:  Capturing ... arguments ---------------------------

### Goal: Partition a dataframe with select() inputs

# Taken from https://stackoverflow.com/questions/46828296/dplyr-deselecting-columns-given-by/

partition(starwars, name:mass, films)

# E.g. dplyr selections
dplyr::select(starwars, name:mass, films)


=>

list(
  select(starwars, name:mass, films),
  select(starwars, -(name:mass), -films)
)


# If we only had to return the first data frame, partition() would be
# very easy to write --- unlike named arguments, dots can be passed to
# quoting functions without issue:
partition <- function(data, ...) {
  list(
    select(data, ...),
    NULL  # TODO
  )
}


# But we'll need to negate the selection to create the second data
# frame. So we need to capture the dots with enquos()
partition <- function(data, ...) {
  dots <- enquos(...)

  list(
    select(data, !!dots),
    NULL  # TODO
  )
}

partition(starwars, name:mass)


# enquos() returns user inputs as a list of quosures. Let's create one here:
dots <- quos(name:mass, films)
dots

# Unquoting this list does not work because select() doesn't take lists:
qq_show(select(starwars, !!dots))



### The !!! splice-unquote operator

qq_show(select(starwars, !!!dots))

select(starwars, !!!dots)

# Let's fix partition() with our captured dots
partition <- function(data, ...) {
  dots <- enquos(...)

  list(
    select(data, !!!dots),
    NULL  # TODO
  )
}
partition(starwars, films, name:height)



### Expanding expressions with !!

# Create function calls by unquoting variable parts.
# Here is a call to list():
quo(list(!!dots[[1]]))

# And here is a call to minus:
q <- quo(-!!dots[[1]])
q

# It looks a bit funny but squash the quosure to convince yourself
# that it's the right negated expression:
quo_squash(q)



### Using purrr to manipulate a list of expression

map(dots, function(dot) quo(-!!dot))

partition <- function(data, ...) {
  dots <- enquos(...)
  neg_dots <- map(dots, function(dot) quo(-!!dot))

  list(
    select(data, !!!dots),
    select(data, !!!neg_dots)
  )
}
partition(starwars, films, name:height)



#  Advanced use of !!  -  Bypassing the data mask --------------------

multiply_height <- function(data, amount) {
  transmute(data, height * amount)
}

# oh no! The `amount` column has priority because of the data mask:
starwars %>%
  mutate(amount = 0) %>%
  multiply_height(100)

# Unquoting `amount` bypasses the data mask
multiply_height <- function(data, amount) {
  transmute(data, height * !!amount)
}



#  Questions ---------------------------------------------------------

### What's the difference between quo() and enquo()?

# quo() is to quote _your_ expression while enquo() quotes the
# expression supplied by the _user_ of your function

quo(my_expr)

quoting_fn <- function(arg1) {
  list(arg1, enquo(arg2))
}

# Second arg is quoted here
quoting_fn(1 + 10, 1 + 10)



### Can you unquote column indices to refer to data objects?

# It depends on the function, e.g. select() vs mutate()
# select() handles column positions just fine:
select(starwars, 2, 3)

idx <- c(1, 3)

qq_show(
  select(starwars, !!! idx)
)

# mutate() creates a new column by recycling the numbers:
mutate(starwars[1:5], 1, 2)

qq_show(
  mutate(starwars[1:5], !!! idx)
)

# So create symbols to refer to columns:
nms <- names(starwars)[idx]
cols <- syms(nms)

qq_show(
  mutate(starwars[1:5], !!! cols)
)



### Is evaluating a symbol the same as get()

# Pretty much

x <- sym("letters")
eval(x, envir = baseenv())

get("letters", envir = baseenv())
