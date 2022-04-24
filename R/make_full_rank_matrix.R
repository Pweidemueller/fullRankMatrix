#' Create a full rank matrix. The function first removes empty columns. The it discovers linear dependent columns, then renames and removes columns to make the matrix full rank.
#'
#' @param mat A matrix.
#'
#' @return A matrix of full rank.
#' @export
#'
#' @examples
#' c1 <- rbinom(10, 1, .4)
#' c2 <- 1-c1
#' c3 <- integer(10)
#' mat <- as.matrix(data.frame(c1, c2, c3))
#' make_full_rank_matrix(mat)

make_full_rank_matrix <- function(mat){
  mat_mod <- remove_empty_columns(mat)
  return(mat_mod)
}

remove_empty_columns <- function(mat) {
  emptry_col <- apply(mat, MARGIN = 2, FUN = function(x) {all(x==0)})
  return(mat[, !emptry_col])
}
