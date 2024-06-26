% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/find_connected_components.R
\name{find_connected_components}
\alias{find_connected_components}
\title{Find connected components in a graph}
\usage{
find_connected_components(connections)
}
\arguments{
\item{connections}{a list where each element is a vector with connected nodes.
Each node must be either a character or an integer.}
}
\value{
a list where each element is a set of connected items.
}
\description{
The function performs a depths-first search to find all connected components.
}
\examples{
  find_connected_components(list(c(1,2), c(1,3), c(4,5)))


}
