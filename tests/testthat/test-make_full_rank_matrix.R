test_that("check that a full rank matrix is returned unchanged", {
  
  df <- data.frame(col = sample(letters[1:3], 10, replace = 20))
  mat <- model.matrix(~ col - 1, data = df)  
  mat2 <- make_full_rank_matrix(mat)
  expect_equal(mat, mat2)
  
})


test_that("removing empty columns as expected", {
  set.seed(1000)
  c1 <- rbinom(10, 1, .4)
  c2 <- 1-c1
  c3 <- integer(10)
  mat <- as.matrix(data.frame(c1, c2, c3))
  mat_empty <- as.matrix(data.frame(c1, c2))
  mat2 <- remove_empty_columns(mat)
  expect_equal(mat2, mat_empty)
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
})

test_that("remove linear dependent columns as expected", {
  set.seed(1000)
  c1 <- rbinom(10, 1, .4)
  c2 <- 1-c1
  c3 <- integer(10)
  c4 <- c1
  mat <- as.matrix(data.frame(c1, c2, c3, c4))
  mat_linind <- as.matrix(data.frame(c1, c2))
  colnames(mat_linind) <- c('c1_OR_(c4)', 'c2')
  mat2 <- find_lindependent_coef(mat)
  expect_equal(mat2, mat_linind)
})

test_that("make full rank column as expected", {
  c1 <- rbinom(10, 1, .4)
  c2 <- 1-c1
  c3 <- rnorm(10)
  c4 <- 10*c3
  c5 <- c1
  c6 <- integer(10)
  c7 <- rep(1,10)
  mat <- as.matrix(data.frame(c1, c2, c3, c4, c5, c6, c7))

  mat_fullrank <- as.matrix(data.frame(c1, c2, c3))
  colnames(mat_fullrank) <- c("(c1_AND_c5)_OR_(c7_COMB_c2)", "c2_OR_(c7_COMB_(c1_AND_c5))", "c3_OR_(c4)")
  mat2 <- make_full_rank_matrix(mat)
  expect_equal(mat2, mat_fullrank)
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

test_that("find_lindependent_coef() errors if input is not of type matrix", {
  set.seed(1000)
  c1 <- rbinom(10, 1, .4)
  c2 <- 1-c1
  c3 <- integer(10)
  c4 <- c1
  mat <- data.frame(c1, c2, c3, c4)
  expect_error(find_lindependent_coef(mat))
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
