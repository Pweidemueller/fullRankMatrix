test_that("find_linear_dependent_columns works", {

  mat <- matrix(rnorm(n = 10 * 4), nrow = 10, ncol = 4)
  mat <- cbind(mat, mat[,1] + 2 * mat[,2], rnorm(10))
  expect_equal(find_linear_dependent_columns(mat), list(c(1,2,5)))

  mat <- cbind(mat, 0.3 * mat[,3] + 0.4 * mat[,4], rnorm(10))
  expect_equal(find_linear_dependent_columns(mat), list(c(1,2,5), c(3,4,7)))

  mat <- cbind(mat, 2 * mat[,1] + 4 * mat[,4])
  expect_equal(find_linear_dependent_columns(mat), list(c(1,2,3,4,5,7,9)))

})

test_that("find_linear_dependent_columns errors if input is not of type matrix", {
  set.seed(1000)
  c1 <- rbinom(10, 1, .4)
  c2 <- 1-c1
  c3 <- integer(10)
  c4 <- c1
  mat <- data.frame(c1, c2, c3, c4)
  expect_error(find_linear_dependent_columns(mat))
})
