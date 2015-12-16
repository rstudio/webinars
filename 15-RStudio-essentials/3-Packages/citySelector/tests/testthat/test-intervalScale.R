context("intervalScale")

test_that("intervalScale handles vectors of positive numbers", {
  expect_equal(intervalScale(0:5), seq(0, 1, by = 0.2))
  expect_equal(intervalScale(0:10), seq(0, 1, by = 0.1))
  expect_equal(intervalScale(11:19), seq(0, 1, by = 0.125))
  expect_equal(intervalScale(2:22), seq(0, 1, by = 0.05))
  expect_error(intervalScale(5), "x must contain two or more values")
})

test_that("intervalScale handles vectors of positive numbers", {
  expect_equal(intervalScale(-5:0), seq(0, 1, by = 0.2))
  expect_equal(intervalScale(-10:0), seq(0, 1, by = 0.1))
  expect_equal(intervalScale(-19:-11), seq(0, 1, by = 0.125))
  expect_equal(intervalScale(-22:-2), seq(0, 1, by = 0.05))
  expect_error(intervalScale(-5), "x must contain two or more values")
})

test_that("intervalScale handles vectors of positive and negative numbers", {
  expect_equal(intervalScale(-5:5), seq(0, 1, by = 0.1))
  expect_equal(intervalScale(-1:1), seq(0, 1, by = 0.5))
  expect_equal(intervalScale(-10:10), seq(0, 1, by = 0.05))
  expect_equal(intervalScale(-2:2), seq(0, 1, by = 0.25))
  expect_equal(intervalScale(-11:5), seq(0, 1, by = 0.0625))
})
