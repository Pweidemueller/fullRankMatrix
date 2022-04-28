#' Create a full rank matrix
#'
#' This function first removes empty columns. Then it discovers linear dependent columns, then removes and renames columns to make the matrix full rank.
#'
#' @param mat A matrix.
#' @param verbose Print how column numbers change with each operation.
#'
#' @return A matrix of full rank. Column headers will be renamed to reflect how columns depend on each other.
#'    * `(c1_AND_c2)`: column `c2` was removed because it was the same as column `c1`. Former `c1` was renamed to `(c1_AND_c2)`
#'    * `c1_OR_(c2)`: column `c2` was removed because it was linearly dependent with `c1` (e.g. multiple of). Former `c1` was renamed to `c1_OR_(c2)`
#'    * `c1_OR_(c3_COMB_c2)`: columns `c1`, `c2` and `c3` are linearly dependent of each other. In this example `c3` was removed and former `c1`, `c2` were renamed to `c1_OR_(c3_COMB_c2)` and `c2_OR_(c3_COMB_c1)`, respectively.
#' @export
#'
#' @examples
#' c1 <- rbinom(10, 1, .4)
#' c2 <- 1-c1
#' c3 <- integer(10)
#' c4 <- c1
#' c5 <- 2*c2
#' c6 <- rbinom(10, 1, .8)
#' c7 <- c5+c6
#' mat <- as.matrix(data.frame(c1, c2, c3, c4, c5, c6, c7))
#' make_full_rank_matrix(mat)
#' mat_full <- make_full_rank_matrix(mat, verbose=TRUE)

make_full_rank_matrix <- function(mat, verbose=FALSE){
  if (verbose){
    print(sprintf("The original matrix contains %i rows and %i columns. The matrix has rank %i.",
                  dim(mat)[1], dim(mat)[2], qr(mat)$rank))
  }
  mat_mod <- remove_empty_columns(mat, verbose=verbose)
  mat_mod <- merge_duplicated(mat_mod, verbose=verbose)
  mat_mod <- find_lindependent_coef(mat_mod, verbose=verbose)
  if (ncol(mat_mod) > qr(mat)$rank){
    stop(print("The modified matrix still has more columns than implied by rank. Check manually why modified matrix is not full rank after applying make_full_rank_matrix()."))
  }
  if (verbose){
    print("The matrix is full rank now.")
  }
  return(mat_mod)
}

remove_empty_columns <- function(mat, verbose=FALSE) {
  emptry_col <- apply(mat, MARGIN = 2, FUN = function(x) {all(x==0)})
  mat_red <- mat[, !emptry_col]
  if (verbose){
    print(sprintf("The matrix after removing empty columns contains %i rows and %i columns",
                  nrow(mat_red), ncol(mat_red)))

  }
  return(mat_red)
}

merge_duplicated <- function(mat, verbose=FALSE) {
  if (is.matrix(mat)==FALSE){
    stop(print("Input matrix has to be of type matrix. If your matrix is stored as a dataframe, convert like so: `mat <- as.matrix(mat)`."))
  }
  mat_unique <- unique(mat, MARGIN = 2)
  mat_duplicated <- mat[, duplicated(mat, MARGIN = 2), drop=FALSE]
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
  if (verbose){
    print(sprintf("The matrix after merging duplicate columns contains %i rows and %i columns.",
                  nrow(mat_unique), ncol(mat_unique)))
  }
  return(mat_unique)
}

find_lindependent_coef <- function(mat, verbose=FALSE) {
  if (is.matrix(mat)==FALSE){
    stop(print("Input matrix has to be of type matrix. If your matrix is stored as a dataframe, convert like so: `mat <- as.matrix(mat)`."))
  }
  linear_combs <- caret::findLinearCombos(mat)[c("linearCombos", "remove")]
  colnames_matr <- colnames(mat)
  new_colnames <- colnames_matr
  for (ncombo in seq_len(length(linear_combs$linearCombos))){
    combo <- linear_combs$linearCombos[[ncombo]]
    remove <- linear_combs$remove[[ncombo]]
    keep <- combo[combo!=remove]
    for (keep_col in keep){
      add_names <- c(colnames_matr[remove], colnames_matr[keep[keep!=keep_col]])
      add_names <- paste(add_names, collapse="_COMB_")
      new_colnames[keep_col] = paste0(new_colnames[keep_col], "_OR_(", add_names, ")")
    }
  }
  colnames(mat) <- new_colnames
  mat_red <- mat[, -linear_combs$remove, drop=FALSE]
  if (verbose){
    print(sprintf("The matrix after finding linearly dependent columns contains %i rows and %i columns.",
                  nrow(mat_red), ncol(mat_red)))
  }
  return(mat_red)
}
