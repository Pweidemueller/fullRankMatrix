% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make_full_rank_matrix.R
\name{make_full_rank_matrix}
\alias{make_full_rank_matrix}
\title{Create a full rank matrix}
\usage{
make_full_rank_matrix(mat, verbose = FALSE)
}
\arguments{
\item{mat}{A matrix.}

\item{verbose}{Print how column numbers change with each operation.}
}
\value{
A matrix of full rank. Column headers will be renamed to reflect how columns depend on each other.
\itemize{
\item \code{(c1_AND_c2)} If multiple columns are exactly identical, only a single instance is retained.
Its column name lists the names of the columns that were collapsed into one.
}
}
\description{
This function first removes empty columns. Then it discovers linear dependent columns, then removes and renames columns to make the matrix full rank.
}
\examples{
c1 <- rbinom(10, 1, .4)
c2 <- 1-c1
c3 <- integer(10)
c4 <- c1
c5 <- 2*c2
c6 <- rbinom(10, 1, .8)
c7 <- c5+c6
mat <- as.matrix(data.frame(c1, c2, c3, c4, c5, c6, c7))
make_full_rank_matrix(mat)
mat_full <- make_full_rank_matrix(mat, verbose=TRUE)
}
