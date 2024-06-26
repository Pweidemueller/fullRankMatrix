test_that("check that a full rank matrix is returned unchanged", {

  df <- data.frame(col = sample(letters[1:3], 10, replace = 20))
  mat <- model.matrix(~ col - 1, data = df)
  result <- make_full_rank_matrix(mat)
  mat2 <- result$matrix
  expect_equal(mat, mat2, ignore_attr = TRUE)
  expect_equal(length(result$space_list), 0)

})


test_that("removing empty columns as expected", {
  set.seed(1000)
  c1 <- rbinom(10, 1, .4)
  c2 <- 1-c1
  c3 <- integer(10)
  c4 <- integer(10)
  mat <- as.matrix(data.frame(c1, c2, c3, c4))
  mat_empty <- as.matrix(data.frame(c1, c2))
  mat2 <- remove_empty_columns(mat)
  expect_equal(mat2, mat_empty)

  mat <- as.matrix(data.frame(c1, c2))
  mat2 <- remove_empty_columns(mat)
  expect_equal(mat2, mat)


})

test_that("returning names of empty columns", {
  set.seed(1000)
  c1 <- rbinom(10, 1, .4)
  c2 <- 1-c1
  c3 <- integer(10)
  c4 <- integer(10)
  mat <- as.matrix(data.frame(c1, c2, c3, c4))
  empty_cols <- find_empty_columns(mat, return_names=TRUE)
  expect_equal(empty_cols, c("c3", "c4"))

  mat <- as.matrix(data.frame(c1, c2))
  mat2 <- remove_empty_columns(mat)
  expect_equal(mat2, mat)
})

test_that("merging duplicated columns as expected", {
  set.seed(1000)
  c1 <- rbinom(10, 1, .4)
  c2 <- 1-c1
  c3 <- integer(10)
  c4 <- c1
  mat <- as.matrix(data.frame(c1, c2, c3, c4))
  mat_dedupl <- as.matrix(data.frame(c1, c2, c3))
  colnames(mat_dedupl) <- c('(c1_AND_c4)', 'c2', 'c3')
  mat2 <- merge_duplicated(mat)
  expect_equal(mat2, mat_dedupl)

  mat <- as.matrix(data.frame(c1, c2))
  mat2 <- merge_duplicated(mat)
  expect_equal(mat2, mat)
})

test_that("make full rank column as expected", {
  intercept <- rep(1,10)
  c1 <- rbinom(10, 1, .4)
  c2 <- 1-c1
  c3 <- rnorm(10)
  c4 <- 10*c3
  c5 <- c1
  c6 <- integer(10)

  mat <- as.matrix(data.frame(intercept, c1, c2, c3, c4, c5, c6))
  result <- make_full_rank_matrix(mat)
  red_mat <- result$matrix
  space_list <- result$space_list
  expect_equal(ncol(red_mat), 3)
  expect_equal(qr(red_mat)$rank, 3)
  expect_equal(colnames(red_mat), c("SPACE_1_AXIS1", "SPACE_1_AXIS2", "SPACE_2_AXIS1"))
  expect_equal(length(space_list), 2)
  expect_equal(space_list$SPACE_1, c("intercept", "(c1_AND_c5)", "c2"))
  expect_equal(space_list$SPACE_2, c("c3", "c4"))

  mat <- as.matrix(data.frame(c1, c2, c3, c4, c5, c6))
  result <- make_full_rank_matrix(mat)
  red_mat <- result$matrix
  space_list <- result$space_list
  expect_equal(ncol(red_mat), 3)
  expect_equal(qr(red_mat)$rank, 3)
  expect_equal(colnames(red_mat), c("(c1_AND_c5)", "c2", "SPACE_1_AXIS1"))
})

test_that("merge_duplicated errors if input is not of type matrix", {
  set.seed(1000)
  c1 <- rbinom(10, 1, .4)
  c2 <- 1-c1
  c3 <- integer(10)
  c4 <- c1
  mat <- data.frame(c1, c2, c3, c4)
  expect_error(merge_duplicated(mat))
})

test_that("collapse_linearly_dependent_columns works", {

  mat <- matrix(rnorm(n = 10 * 4), nrow = 10, ncol = 4, dimnames = list(character(0L), paste0("col_", 1:4)))
  mat <- cbind(mat, comb_12 = mat[,1] + 2 * mat[,2], col_6 = rnorm(10))
  result <- collapse_linearly_dependent_columns(mat)
  red_mat <- result$matrix
  space_list <- result$space_list
  expect_equal(ncol(red_mat), 5)
  expect_equal(qr(red_mat)$rank, 5)
  expect_equal(colnames(red_mat), c("col_3", "col_4", "col_6", "SPACE_1_AXIS1", "SPACE_1_AXIS2"))
  expect_equal(length(space_list), 1)
  expect_equal(space_list[[1]], c("col_1", "col_2", "comb_12"))

  mat <- cbind(mat, comb_34 = 0.3 * mat[,3] + 0.4 * mat[,4], col_8 = rnorm(10))
  result <- collapse_linearly_dependent_columns(mat)
  red_mat <- result$matrix
  space_list <- result$space_list
  expect_equal(ncol(red_mat), 6)
  expect_equal(qr(red_mat)$rank, 6)
  expect_equal(colnames(red_mat), c("col_6", "col_8", "SPACE_1_AXIS1", "SPACE_1_AXIS2", "SPACE_2_AXIS1", "SPACE_2_AXIS2"))

  c1 <- rbinom(10, 1, .4)
  c2 <- c1*2
  c3 <- c1*3
  c4 <- c1*0.5
  mat <- cbind(c1,c2,c3,c4)
  result <- make_full_rank_matrix(mat)
  red_mat <- result$matrix
  space_list <- result$space_list
  expect_equal(colnames(red_mat), c("SPACE_1_AXIS1"))
  expect_equal(space_list$SPACE_1, c("c1","c2","c3","c4"))

})
