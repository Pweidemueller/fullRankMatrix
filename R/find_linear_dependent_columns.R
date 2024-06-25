
#' Find linear dependent columns in a design matrix
#'
#' @importFrom stats lm.fit
#'
#' @param mat a matrix
#' @param tol a double that specifies the numeric tolerance
#'
#' @return a list with vectors containing the indices of linearly dependent columns
#'
#' @seealso
#' The algorithm and function is inspired by the `internalEnumLC`
#' function in the 'caret' package ([GitHub](https://github.com/topepo/caret/blob/679eabaac7e54f4e87efa6c3bff75659cb457d8b/pkg/caret/R/findLinearCombos.R#L33))
#'
#' @examples
#'   mat <- matrix(rnorm(3 * 10), nrow = 10, ncol = 3)
#'   mat <- cbind(mat, mat[,1] + 0.5 * mat[,3])
#'   find_linear_dependent_columns(mat)  # returns list(c(1,3,4))
#'
#' @export
find_linear_dependent_columns <- function(mat, tol = 1e-12){
  stopifnot(is.matrix(mat))
  stopifnot(is.numeric(tol), length(tol) == 1)
  qr_mat <- qr(mat)
  mat_rank <- qr_mat$rank

  if(mat_rank == ncol(mat)){
    # The matrix is full rank, so return immediately
    list()
  }else{
    # The QR decomposition arranges the values such that the first `#rank` columns are independent
    independent_columns <- seq_len(mat_rank)
    dependent_columns <- mat_rank + seq_len(ncol(mat) - mat_rank)
    # Solving `Bad_Matrix = Good_Matrix %*% coef`
    # Any place where `coef` is non-null, we have some linear dependency
    coef <- lm.fit(qr.R(qr_mat)[independent_columns,independent_columns,drop=FALSE], qr.R(qr_mat)[independent_columns,dependent_columns,drop=FALSE])$coef
    coef <- matrix(coef, ncol = length(dependent_columns))
    # The pivot relates columns in the QR decomposition object to the columns in the original matrix
    # The `sort` makes sure that the result looks good
    lindep_sets <- lapply(seq_along(dependent_columns), function(i) sort(c(qr_mat$pivot[mat_rank + i], qr_mat$pivot[which(abs(coef[,i]) > tol)])))

    connected_lindep_components <- find_connected_components(lindep_sets)
    connected_lindep_components
  }
}


