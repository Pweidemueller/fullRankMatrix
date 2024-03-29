test_that("check that a full rank matrix is returned unchanged", {

  df <- data.frame(col = sample(letters[1:3], 10, replace = 20))
  mat <- model.matrix(~ col - 1, data = df)
  mat2 <- make_full_rank_matrix(mat)
  expect_equal(mat, mat2, ignore_attr = TRUE)

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
  red_mat <- make_full_rank_matrix(mat)
  expect_equal(ncol(red_mat), 3)
  expect_equal(qr(red_mat)$rank, 3)
  expect_equal(colnames(red_mat), c("SPACE(intercept,(c1_AND_c5),c2)_AXIS1", "SPACE(intercept,(c1_AND_c5),c2)_AXIS2","SPACE(c3,c4)_AXIS1"))

  mat <- as.matrix(data.frame(c1, c2, c3, c4, c5, c6))
  red_mat <- make_full_rank_matrix(mat)
  expect_equal(ncol(red_mat), 3)
  expect_equal(qr(red_mat)$rank, 3)
  expect_equal(colnames(red_mat), c("(c1_AND_c5)", "c2", "SPACE(c3,c4)_AXIS1"))
})

test_that("merge_duplicated() errors if input is not of type matrix", {
  set.seed(1000)
  c1 <- rbinom(10, 1, .4)
  c2 <- 1-c1
  c3 <- integer(10)
  c4 <- c1
  mat <- data.frame(c1, c2, c3, c4)
  expect_error(merge_duplicated(mat))
})

test_that("find_linear_dependent_columns() errors if input is not of type matrix", {
  set.seed(1000)
  c1 <- rbinom(10, 1, .4)
  c2 <- 1-c1
  c3 <- integer(10)
  c4 <- c1
  mat <- data.frame(c1, c2, c3, c4)
  expect_error(find_linear_dependent_columns(mat))
})


test_that("collapse_linearly_dependent_columns works", {

  mat <- matrix(rnorm(n = 10 * 4), nrow = 10, ncol = 4, dimnames = list(character(0L), paste0("col_", 1:4)))
  mat <- cbind(mat, comb_12 = mat[,1] + 2 * mat[,2], col_6 = rnorm(10))
  red_mat <- collapse_linearly_dependent_columns(mat)
  expect_equal(ncol(red_mat), 5)
  expect_equal(qr(red_mat)$rank, 5)
  expect_equal(colnames(red_mat), c("col_3", "col_4", "col_6", "SPACE(col_1,col_2,comb_12)_AXIS1", "SPACE(col_1,col_2,comb_12)_AXIS2"))

  mat <- cbind(mat, comb_34 = 0.3 * mat[,3] + 0.4 * mat[,4], col_8 = rnorm(10))
  red_mat <- collapse_linearly_dependent_columns(mat)
  expect_equal(ncol(red_mat), 6)
  expect_equal(qr(red_mat)$rank, 6)
  expect_equal(colnames(red_mat), c("col_6", "col_8", "SPACE(col_1,col_2,comb_12)_AXIS1", "SPACE(col_1,col_2,comb_12)_AXIS2", "SPACE(col_3,col_4,comb_34)_AXIS1", "SPACE(col_3,col_4,comb_34)_AXIS2"))

  mat <- cbind(mat, comb_14 = 2 * mat[,1] + 4 * mat[,4])
  red_mat <- collapse_linearly_dependent_columns(mat)
  expect_equal(ncol(red_mat), 6)
  expect_equal(qr(red_mat)$rank, 6)
})
