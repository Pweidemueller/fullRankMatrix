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
#' c4 <- c1
#' mat <- as.matrix(data.frame(c1, c2, c3, c4))
#' make_full_rank_matrix(mat)

make_full_rank_matrix <- function(mat){
  mat_mod <- remove_empty_columns(mat)
  mat_mod <- merge_duplicated(mat_mod)
  return(mat_mod)
}

remove_empty_columns <- function(mat) {
  emptry_col <- apply(mat, MARGIN = 2, FUN = function(x) {all(x==0)})
  return(mat[, !emptry_col])
}

merge_duplicated <- function(mat) {
  if (is.matrix(mat)==FALSE){
    stop(print("Input matrix has to be of type matrix. If your matrix is stored as a dataframe, convert like so: `mat <- as.matrix(mat)`."))
  }
  mat_unique <- unique(mat, MARGIN = 2)
  mat_duplicated <- mat[, duplicated(mat, MARGIN = 2),drop=FALSE]
  colnames_unique <- colnames(mat_unique)
  colnames_duplicated <- colnames(mat_duplicated)
  for (c in seq_len(ncol(mat_duplicated))){
    keep <- which(duplicated(cbind(mat_duplicated[, c], mat_unique), MARGIN = 2))-1
    if (length(keep) > 1){
      stop(print("More than one matching column detected. Something is wrong with this algorithm."))
    }
    if (grepl("AND", colnames_unique[keep], fixed=TRUE)){
      colnames_unique[keep] <- gsub('[()]', '', colnames_unique[keep])
    }
    colnames_unique[keep] <- paste0("(", colnames_unique[keep], "_AND_", colnames_duplicated[c], ")")
  }
  colnames(mat_unique) <- colnames_unique
  return(mat_unique)
}
