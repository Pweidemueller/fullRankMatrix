#' Create a full rank matrix
#'
#' This function first removes empty columns. Then it discovers linear dependent columns, then removes and renames columns to make the matrix full rank.
#'
#' @param mat A matrix.
#' @param verbose Print how column numbers change with each operation.
#'
#' @return A matrix of full rank. Column headers will be renamed to reflect how columns depend on each other.
#'    * `(c1_AND_c2)` If multiple columns are exactly identical, only a single instance is retained.
#'   Its column name lists the names of the columns that were collapsed into one.
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
  validate_column_names(colnames(mat))
  if (verbose){
    print(sprintf("The original matrix contains %i rows and %i columns. The matrix has rank %i.",
                  dim(mat)[1], dim(mat)[2], qr(mat)$rank))
  }
  mat_mod <- remove_empty_columns(mat, verbose=verbose)
  mat_mod <- merge_duplicated(mat_mod, verbose=verbose)
  mat_mod <- collapse_linearly_dependent_columns(mat_mod, verbose=verbose)
  if (ncol(mat_mod) > qr(mat)$rank){
    stop(print("The modified matrix still has more columns than implied by rank. Check manually why modified matrix is not full rank after applying make_full_rank_matrix()."))
  }
  if (verbose){
    print("The matrix is now full rank.")
  }
  return(mat_mod)
}

find_empty_columns <- function(mat, tol = 1e-12, return_names=FALSE){
  empty_col <- apply(mat, MARGIN = 2, FUN = function(x) {all(abs(x) < tol)})
  if (return_names){
    names(which(empty_col))
  }else{
    empty_col
  }
}

remove_empty_columns <- function(mat, tol = 1e-12, verbose=FALSE) {
  empty_col <- find_empty_columns(mat, tol)
  if (sum(empty_col) > tol){
    mat <- mat[, !empty_col, drop=FALSE]
  }
  if (verbose){
    print(sprintf("%i empty columns were removed. After removig empty columns the matrix contains %i columns.",
                  sum(empty_col, na.rm = TRUE), ncol(mat)))

  }
  return(mat)
}

find_duplicated_columns <- function(mat, verbose=FALSE) {
  stopifnot(is.matrix(mat))
  mat_duplicated <- mat[, duplicated(mat, MARGIN = 2), drop=FALSE]
  colnames(mat_duplicated)
}

merge_duplicated <- function(mat, tol = 1e-12, verbose=FALSE) {
  stopifnot(is.matrix(mat))
  mat_unique <- unique(mat, MARGIN = 2)
  colnames_unique <- colnames(mat_unique)
  colnames_duplicated <- find_duplicated_columns(mat)
  if (length(colnames_duplicated) > tol){
    for (c in seq_len(length(colnames_duplicated))){
      keep <- which(duplicated(cbind(mat[, colnames_duplicated[c], drop=FALSE], mat_unique), MARGIN = 2))-1
      if (length(keep) > 1){
        stop(print("More than one matching column detected. Something is wrong with this algorithm."))
      }
      if (grepl("AND", colnames_unique[keep], fixed=TRUE)){
        colnames_unique[keep] <- gsub('[()]', '', colnames_unique[keep])
      }
      colnames_unique[keep] <- paste0("(", colnames_unique[keep], "_AND_", colnames_duplicated[c], ")")
    }
    colnames(mat_unique) <- colnames_unique
    mat <- mat_unique
  }
  if (verbose){
    print(sprintf("%i duplicated columns were detected. After merging duplicated columns the matrix contains %i columns.",
                  length(colnames_duplicated), ncol(mat)))
  }
  return(mat)
}

collapse_linearly_dependent_columns <- function(mat, tol = 1e-12, verbose = FALSE){
  stopifnot(is.matrix(mat))
  validate_column_names(colnames(mat))

  linear_dependencies <- find_linear_dependent_columns(mat, tol = tol)
  while(length(linear_dependencies) != 0){
    dependent_set <- linear_dependencies[[1]]
    dependent_columns <- mat[,dependent_set,drop=FALSE]
    mat <- mat[,-dependent_set,drop=FALSE]
    qr_space <- qr(dependent_columns)
    rank_of_set <- qr_space$rank
    new_space <- qr.Q(qr_space)[,seq_len(rank_of_set),drop=FALSE]

    # Handle names
    new_names <- paste0("SPACE(", paste0(colnames(dependent_columns), collapse = ",") ,")_AXIS", seq_len(rank_of_set))
    colnames(new_space) <- new_names
    mat <- cbind(mat, new_space)

    # Changing the matrix could introduce new dependencies
    linear_dependencies <- find_linear_dependent_columns(mat, tol = tol)
  }
  if (verbose){
        print(sprintf("The matrix after collapsing linearly dependent columns contains %i rows and %i columns.",
                      nrow(mat), ncol(mat)))
      }
  mat
}

