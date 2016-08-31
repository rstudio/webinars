# RcppParallel
Kevin Ushey  
August 31st, 2016  

## Introduction

Parallel / concurrent programming is a reality of modern software development, and is necessary when developing high-performance scientific software.

> [...] the performance lunch isn't free any more [...] if you want your application to benefit from the continued exponential throughput advances in new processors, it will need to be a well-written concurrent (usually multithreaded) application.
>
> <footer>-- Herb Sutter, ["The Free Lunch is Over"](http://www.gotw.ca/publications/concurrency-ddj.htm)</footer>

This quote comes from an essay written in 2004 -- while processors and compilers continue to improve, clock speed has hit a brick wall.

## Parallel Programming with R

R provides a large number of packages that make it possible to run R code in parallel.

R users might be familiar with the `parallel` package, and its `mcapply` / `clusterApply` / `parApply` family of functions.

These functions allow one to run R code in separate R processes, all running in parallel, and then collect those results into the parent R process.

The [High-Performance and Parallel Computing with R](https://cran.r-project.org/web/views/HighPerformanceComputing.html) CRAN Task View enumerates R packages that help support different forms of parallel computing with R.

## Parallel Programming within R

For `RcppParallel`, the goal is not to execute R code in parallel, but to allow R to call lower-level C / C++ code that is executed in parallel.

Concurrent programming is _hard_:

> Some people, when confronted with a problem, think, "I know, I'll use threads." Now they havtwo erpoblesms.
>
> <footer>-- Ned Batchelder, ["Two Problems"](http://nedbatchelder.com/blog/201204/two_problems.html)</footer>

`RcppParallel` makes it easy to write safe, correct, and performant multi-threaded code using C++ / `Rcpp`, and link + use that code within an R session.

## RcppParallel: What it Bundles

`RcppParallel` bundles two C++ libraries:

- [Intel TBB](https://www.threadingbuildingblocks.org/) (v4.3), a C++ library for task parallelism with a wide variety of parallel algorithms and data structures (Windows, OS X, Linux, and Solaris x86 only).

- [TinyThread](http://tinythreadpp.bitsnbites.eu/), a C++ library for portable use of operating system threads.

These libraries do the 'higher level' job of work scheduling and work assignment, and distribute 'work' to separate threads / processes.

`RcppParallel` uses TBB by default on Windows, OS X and Linux, and falls back to TinyThread for other platforms where TBB is not supported.

## RcppParallel: What it Provides

`RcppParallel` provides two main functions as a top-level interface:

- `parallelFor()`: convert the work of a standard 'serial' `for` loop into a parallel one.

- `parallelReduce()`: compute and aggregate multiple values in parallel.

These functions wrap the underlying `TBB` machinery, and accept `Worker` objects that understand how to perform work on a slice of data.

## RcppParallel: How to Use It

The `parallelFor()` / `parallelReduce()` functions accept a _range of data_ to operate on, and an `Worker` object that understands how to do work with a particular slice of data.

For example, `parallelFor()` has the signature:

    parallelFor(std::size_t begin, std::size_t end, Worker worker)
    
Users implement their own workers by subclassing `RcppParallel::Worker`, and implementing the routines that do work for a particular slice of data.

The TBB / TinyThread machinery works behind the scenes to assign work to `Worker`s, and collect generated results as well.

## RcppParallel: Using a Worker {.smaller}

Let's see an example of how we might use `parallelFor()`. We'll look at how we might compute the `log()` of values in a vector, in parallel.

Before we dive into the worker implementation, let's see how we might construct the worker, and pass it to `parallelFor()`:


```cpp
// stub for our LogWorker class
struct LogWorker : public RcppParallel::Worker { /* ... */ };

// [[Rcpp::export]]
Rcpp::NumericVector parallelLog(Rcpp::NumericVector input) {
  Rcpp::NumericVector output = no_init(input.size());
  LogWorker worker(input, output);
  RcppParallel::parallelFor(0, input.size(), worker);
  return output;
}
```

We give `parallelFor()` a range of data, and provide it with a worker that understands how to operate on slices of that data. It will be the responsibility of workers to fill the `output` vector.

## RcppParallel: Implementing a Worker {.smaller}


```cpp
// [[Rcpp::depends(RcppParallel)]]
#include <RcppParallel.h>
#include <Rcpp.h>

// define a small functor that computes the logarithm of a value
struct Log { double operator()(double value) { return ::log(value); } };

// implement our worker (subclassing RcppParallel::Worker)
struct LogWorker : public RcppParallel::Worker {
  // initialize inputs + outputs
  RcppParallel::RVector<double> input, output;
  
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
```

## Comparing Performance

We'll use the `microbenchmark` package to compare the performance between R and `RcppParallel`:


```r
library(microbenchmark)
x <- as.numeric(1:1E7)
microbenchmark(R = log(x),
               RcppParallel = parallelLog(x),
               times = 10)
```

```
Unit: milliseconds
         expr      min       lq     mean   median       uq       max
            R 81.37983 83.40045 95.58450 97.02430 100.8047 112.74806
 RcppParallel 22.23553 22.44987 29.19451 24.31823  37.8509  40.38695
```

Our parallel solution runs ~3-4x times faster on average.

## Why is it Faster?

`RcppParallel` uses TBB, which comes with a highly optimized execution scheduler. The supervisor does some intelligent optimization around:

- Grain size (which affects locality of reference and therefore cache hit rates).
- Work stealing (detecting idle threads and pushing work to them)

Note that grain size can also be tuned directly per-application. In the case of TBB, high performance concurrent containers are available if necessary.

# Demo

## Learning More

You can download `RcppParallel` from CRAN with:

    install.packages("RcppParallel")

Learn more about using `RcppParallel` online:

- Visit the [RcppParallel Website](http://rcppcore.github.io/RcppParallel/).

- View articles on the [Rcpp Gallery](http://gallery.rcpp.org/tags/parallel/).

- Follow new `RcppParallel` developments [on GitHub](https://github.com/RcppCore/RcppParallel).

- See how [other packages](https://cran.r-project.org/web/packages/RcppParallel/index.html) are using `RcppParallel`.

<div style="position: absolute; bottom: 60px;">
Thanks for listening!
</footer>

