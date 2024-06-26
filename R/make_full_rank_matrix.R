#' Create a full rank matrix
#'
#' First remove empty columns. Then discover linear dependent columns. For each set of linearly dependent columns, create orthogonal vectors that span the space. Add these vectors as columns to the final matrix to replace the linearly dependent columns.
#'
#' @param mat A matrix.
#' @param verbose Print how column numbers change with each operation.
#'
#' @return a list containing:
#'    * `matrix`: A matrix of full rank. Column headers will be renamed to reflect how columns depend on each other.
#'        * `(c1_AND_c2)` If multiple columns are exactly identical, only a single instance is retained.
#'        * `SPACE_<i>_AXIS<j>` For each set of linearly dependent columns, a space `i` with `max(j)` dimensions was created using orthogonal axes to replace the original columns.
#'    * `space_list`: A named list where each element corresponds to a space and contains the names of the original linearly dependent columns that are contained within that space.
#'
#' @export
#'
#' @examples
#' # Create a 1-hot encoded (zero/one) matrix
#' c1 <- rbinom(10, 1, .4)
#' c2 <- 1-c1
#' c3 <- integer(10)
#' c4 <- c1
#' c5 <- 2*c2
#' c6 <- rbinom(10, 1, .8)
#' c7 <- c5+c6
#' # Turn into matrix
#' mat <- cbind(c1, c2, c3, c4, c5, c6, c7)
#' # Turn the matrix into full rank, this will:
#' # 1. remove empty columns (all zero)
#' # 2. merge columns with the same entries (duplicates)
#' # 3. identify linearly dependent columns
#' # 4. replace them with orthogonal vectors that span the same space
#' result <- make_full_rank_matrix(mat)
#' # verbose=TRUE will give details on how many columns are removed in every step
#' result <- make_full_rank_matrix(mat, verbose=TRUE)
#' # look at the create full rank matrix
#' mat_full <- result$matrix
#' # check which linearly dependent columns spanned the identified spaces
#' spaces <- result$space_list

make_full_rank_matrix <- function(mat, verbose=FALSE){

  if (!is.matrix(mat)) {
    stop("The input is not a matrix.")
  }
  if (any(is.na(mat))) {
    stop("Error: The matrix contains NA values.")
  }

  validate_column_names(colnames(mat))
  if (verbose){
    message(sprintf("The original matrix contains %i rows and %i columns. The matrix has rank %i.",
                  dim(mat)[1], dim(mat)[2], qr(mat)$rank))
  }
  mat_mod <- remove_empty_columns(mat, verbose=verbose)
  mat_mod <- merge_duplicated(mat_mod, verbose=verbose)
  result <- collapse_linearly_dependent_columns(mat_mod, verbose=verbose)
  mat_mod <- result$matrix

  if (ncol(mat_mod) > qr(mat)$rank){
    stop(message("The modified matrix still has more columns than implied by rank. Check manually why modified matrix is not full rank after applying make_full_rank_matrix()."))
  }
  if (verbose){
    message("The matrix is now full rank.")
  }
  return(result)
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
    message(sprintf("%i empty columns were removed. After removing empty columns the matrix contains %i columns.",
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
  if (any(is.na(mat))) {
    stop("Error: The matrix contains NA values.")
  }

  mat_unique <- unique(mat, MARGIN = 2)
  colnames_unique <- colnames(mat_unique)
  colnames_duplicated <- find_duplicated_columns(mat)
  if (length(colnames_duplicated) > tol){
    for (c in seq_len(length(colnames_duplicated))){
      keep <- which(duplicated(cbind(mat[, colnames_duplicated[c], drop=FALSE], mat_unique), MARGIN = 2))-1
      if (length(keep) > 1){
        stop(message("More than one matching column detected. Something is wrong with this algorithm."))
      }
      if (grepl("_AND_", colnames_unique[keep], fixed=TRUE)){
        colnames_unique[keep] <- gsub('[()]', '', colnames_unique[keep])
      }
      colnames_unique[keep] <- paste0("(", colnames_unique[keep], "_AND_", colnames_duplicated[c], ")")
    }
    colnames(mat_unique) <- colnames_unique
    mat <- mat_unique
  }
  if (verbose){
    message(sprintf("%i duplicated columns were detected. After merging duplicated columns the matrix contains %i columns.",
                  length(colnames_duplicated), ncol(mat)))
  }
  return(mat)
}

collapse_linearly_dependent_columns <- function(mat, tol = 1e-12, verbose = FALSE){
  stopifnot(is.matrix(mat))
  if (any(is.na(mat))) {
    stop("Error: The matrix contains NA values.")
  }
  validate_column_names(colnames(mat))

  linear_dependencies <- find_linear_dependent_columns(mat, tol = tol)

  space_counter <- 1
  space_list <- list()

  while(length(linear_dependencies) > 0){
    dependent_set <- linear_dependencies[[1]]
    dependent_columns <- mat[,dependent_set,drop=FALSE]
    mat <- mat[,-dependent_set,drop=FALSE]
    qr_space <- qr(dependent_columns)
    rank_of_set <- qr_space$rank
    new_space <- qr.Q(qr_space)[,seq_len(rank_of_set),drop=FALSE]

    # Handle names
    # if a lot of linearly dependencies exist, adding the original column names to the new column names might get prohibitively large
    # instead label each new space by a number and save which original columns it was composed of in a corresponding file
    space_name <- paste0("SPACE_", space_counter)
    space_list[[space_name]] <- colnames(dependent_columns)

    new_names <- paste0("SPACE_", space_counter, "_AXIS", seq_len(rank_of_set))

    colnames(new_space) <- new_names
    mat <- cbind(mat, new_space)

    # Changing the matrix could introduce new dependencies
    linear_dependencies <- find_linear_dependent_columns(mat, tol = tol)
    space_counter <- space_counter + 1
  }
  if (verbose){
        message(sprintf("The matrix after collapsing linearly dependent columns contains %i rows and %i columns.",
                      nrow(mat), ncol(mat)))
      }
  list(matrix = mat, space_list = space_list)
}

