// [[Rcpp::depends(RcppParallel)]]
#include <RcppParallel.h>
#include <Rcpp.h>
using namespace Rcpp;

struct Log {
  double operator()(double value) { return log(value); }
};

struct LogWorker : public RcppParallel::Worker
{
  RcppParallel::RVector<double> input, output;

  // initialize inputs
  LogWorker(Rcpp::NumericVector input, Rcpp::NumericVector output)
    : input(input), output(output) {}

  // define work (accepts a range of items to work on)
  void operator()(std::size_t begin, std::size_t end) {
    std::transform(input.begin() + begin,
                   input.begin() + end,
                   output.begin() + begin,
                   Log());
  }
};

// [[Rcpp::export]]
NumericVector parallelLog(NumericVector input)
{
  // allocate our output vector
  NumericVector output = no_init(input.size());

  // construct our worker
  LogWorker worker(input, output);

  // give 'parallelFor' the range of values + our worker
  RcppParallel::parallelFor(0, input.size(), worker);

  // return to R
  return output;
}

/*** R
x <- as.numeric(1:1E7)
identical(log(x), parallelLog(x))

library(microbenchmark)
microbenchmark(
  R = log(x),
  RcppParallel = parallelLog(x),
  times = 10
)
*/
