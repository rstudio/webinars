library(RcppParallelExample)
library(microbenchmark)

# A simple R example for computation of the inner product.
innerProduct <- function(lhs, rhs) {
    sum(lhs * rhs)
}

# Generate 10 x 2 million random numbers, for a simple benchmark.
set.seed(123)
lhs <- rnorm(1E7)
rhs <- rnorm(1E7)

# Confirm that our R implementation, as well as our RcppParallel
# implementation, produce the same results.
all.equal(
    innerProduct(lhs, rhs),
    parallelInnerProduct(lhs, rhs)
)

# Compare performance!
microbenchmark(
    R = innerProduct(lhs, rhs),
    Rcpp = parallelInnerProduct(lhs, rhs)
)
