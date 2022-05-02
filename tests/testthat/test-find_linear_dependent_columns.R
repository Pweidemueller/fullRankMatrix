test_that("find_linear_dependent_columns works", {
  
  mat <- matrix(rnorm(n = 10 * 4), nrow = 10, ncol = 4)
  mat <- cbind(mat, mat[,1] + 2 * mat[,2], rnorm(10))  
  expect_equal(find_linear_dependent_columns(mat), list(c(1,2,5)))

  mat <- cbind(mat, 0.3 * mat[,3] + 0.4 * mat[,4], rnorm(10))  
  expect_equal(find_linear_dependent_columns(mat), list(c(1,2,5), c(3,4,7)))
  
  mat <- cbind(mat, 2 * mat[,1] + 4 * mat[,4])  
  expect_equal(find_linear_dependent_columns(mat), list(c(1,2,5), c(3,4,7), c(1,4,9)))
      
})
