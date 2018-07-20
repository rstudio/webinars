// [[Rcpp::depends(RcppParallel)]]
#include <Rcpp.h>
#include <RcppParallel.h>
using namespace Rcpp;

double product(double lhs, double rhs) {
  return lhs * rhs;
}

struct InnerProductWorker : public RcppParallel::Worker {
  RcppParallel::RVector<double> lhs_, rhs_;
  double output_;

  InnerProductWorker(const NumericVector& lhs, const NumericVector& rhs)
    : lhs_(lhs), rhs_(rhs), output_(0) {}

  InnerProductWorker(const InnerProductWorker& self, RcppParallel::Split)
    : lhs_(self.lhs_), rhs_(self.rhs_), output_(0) {}

  void operator()(std::size_t begin, std::size_t end)
  {
    output_ += std::inner_product(
      lhs_.begin() + begin,
      lhs_.begin() + end,
      rhs_.begin() + begin,
      0.0
    );
  }

  double value() const { return output_; }

  void join(const InnerProductWorker& worker) {
    output_ += worker.output_;
  }

};

//' Parallel Inner Product
//'
//' Compute the inner product of two numeric vectors.
//'
//' @param lhs,rhs Numeric vectors.
//' @export
// [[Rcpp::export]]
double parallelInnerProduct(NumericVector lhs, NumericVector rhs) {
  InnerProductWorker worker(lhs, rhs);
  RcppParallel::parallelReduce(0, lhs.size(), worker);
  return worker.value();
  return worker.value();
}

/*** R
n <- 1E6
lhs <- rnorm(n)
rhs <- rnorm(n)
all.equal(sum(lhs * rhs), parallelInnerProduct(lhs, rhs))

library(microbenchmark)
microbenchmark(
  R = sum(lhs * rhs),
  RcppParallel = parallelInnerProduct(lhs, rhs),
  times = 10
)

# demonstrate we really are using multiple cores
if (FALSE) {
  repeat parallelInnerProduct(lhs, rhs)
}
*/
