

validate_column_names <- function(names){
  if(is.null(names)){
    stop("The column names must not be `NULL`.")
  }
  if(any(grepl("^$", names))){
    stop("The empty string `\"\"` is not a valid column name. See for example index: ", which(grepl("^$", names))[1])
  }
  if(any(is.na(names))){
    stop("None of the names must be `NA`.")
  }
  if(any(duplicated(names))){
    stop("The column names must be unique.")
  }
}

