

set.seed(1)
m <- matrix( sample(10,36,repl=TRUE) , ncol = 4 )
m <- cbind(m, m[,2])
m <- cbind(m, m[,4])
m <- cbind(m[,3]+1e-10, m)
get_duplicated_columns(m)
get_duplicated_columns(m, tol = 1e-6)

get_duplicated_columns <- function(mat, tol=1e-12){
  n <- seq_len(ncol(mat))
  id <- expand.grid(n,n)
  m_diff <- matrix(colSums((mat[, id[,1] ]-mat[, id[,2] ])>tol), ncol = length(n))
  # get which columns are unique and which ones are duplicates
  duplicates <- apply(m_diff, function(x){which(x < tol)}, MARGIN=2)
  unique_cols <- which(sapply(duplicates, function(x){length(x) == 1}))
  duplicated_cols <- duplicates[which(sapply(duplicates, function(x){length(x) > 1}))]
  for (i in seq_along(duplicated_cols)){
    # retain the first element
    keep_col <- duplicated_cols[[i]][1]
    if (!(keep_col %in% unique_cols)){
      unique_cols <- c(unique_cols, keep_col)
    }
  }
  duplicated_cols <- sort(setdiff(unlist(duplicated_cols), unique_cols))
  unique_cols <- sort(unique_cols)
  return(list(unique_cols=unique_cols, duplicated_cols=duplicated_cols))
}
