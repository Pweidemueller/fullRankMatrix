
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fullRankMatrix

<!-- badges: start -->
<!-- badges: end -->

The goal of fullRankMatrix is to remove empty columns (contain only
0’s), merge duplicated columns and merge linearly dependent columns.
These operations will create a matrix of full rank. The changes made to
the columns are reflected in the column headers interpretability if the
matrix is used in e.g. a linear model fit.

## Installation

You can install the development version of fullRankMatrix from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Pweidemueller/fullRankMatrix")
```

## Example
