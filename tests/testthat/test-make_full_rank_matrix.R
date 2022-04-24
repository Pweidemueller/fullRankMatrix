test_that("removing rows as expected", {
  set.seed(1000)
  c1 <- rbinom(10, 1, .4)
  c2 <- 1-c1
  c3 <- rnorm(10)
  c4 <- 10*c3
  c5 <- c1
  c6 <- integer(10)
  c7 <- rep(1,10)
  mat <- as.matrix(data.frame(c1, c2, c3, c4, c5, c6, c7))
  mat_empty <- as.matrix(data.frame(c1, c2, c3, c4, c5, c7))

  mat2 <- remove_empty_columns(mat)
  expect_equal(mat2, mat_empty)
})
