#' Validate Column Names
#'
#' This function checks a vector of column names to ensure they are valid. It performs the following checks:
#' - The column names must not be `NULL`.
#' - The column names must not contain empty strings.
#' - The column names must not contain `NA` values.
#' - The column names must be unique.
#'
#' @param names A character vector of column names to validate.
#'
#' @return Returns `TRUE` if all checks pass. If any check fails, the function stops and returns an error message.
#' @export
#'
#' @examples
#' validate_column_names(c("name", "age", "gender")) # Returns TRUE
#' validate_column_names(c("name", "age", "")) # Error: The empty string `""` is not a valid column name.
#' validate_column_names(c("name", "age", NA)) # Error: None of the names must be `NA`.
#' validate_column_names(c("name", "age", "age")) # Error: The column names must be unique.
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

