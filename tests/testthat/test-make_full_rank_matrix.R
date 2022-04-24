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
