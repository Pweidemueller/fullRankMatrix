
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fullRankMatrix

<!-- badges: start -->
<!-- badges: end -->

The goal of `fullRankMatrix` is to remove empty columns (contain only
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

When using linear models you should check if any of the columns in your
model matrix are linearly dependent. If they are this will alter the
interpretation of the model fit. Here is a rather constructed example
where we are interested in identifying the factors that make fruit
sweet. We can classify fruit into what fruit they are and also at what
season they are harvested.

``` r
# let's say we have 10 fruits and can classify them into strawberries, apples or pears
# in addition we classify them by the season they are harvested in
strawberry <- c(1,1,1,1,0,0,0,0,0,0)
apple <- c(0,0,0,0,1,1,1,0,0,0)
pear <- c(0,0,0,0,0,0,0,1,1,1)
spring <- c(1,1,0,0,0,0,0,0,0,0)
summer <- c(1,1,1,1,1,1,1,0,0,0)
fall <- c(0,0,0,0,0,0,1,1,1,1)

# let's pretend we know how each factor influences the sweetness of a fruit
strawberry_sweet <- strawberry * rnorm(10, 4)
apple_sweet <- apple * rnorm(10, 1)
pear_sweet <- pear * rnorm(10, 0.5)
spring_sweet <- spring * rnorm(10, 2)
summer_sweet <- summer * rnorm(10, 5)
fall_sweet <- fall * rnorm(10, 1)

sweetness <- strawberry_sweet + apple_sweet + pear_sweet +
  spring_sweet + summer_sweet + fall_sweet

mat <- as.matrix(data.frame(strawberry,apple,pear,spring,summer,fall))

fit <- lm(sweetness ~ mat + 0)
print(summary(fit))
#> 
#> Call:
#> lm(formula = sweetness ~ mat + 0)
#> 
#> Residuals:
#>          1          2          3          4          5          6          7 
#>  2.602e+00 -2.602e+00  1.304e+00 -1.304e+00  1.012e+00 -1.012e+00 -4.441e-16 
#>          8          9         10 
#>  8.907e-01  8.004e-01 -1.691e+00 
#> 
#> Coefficients: (1 not defined because of singularities)
#>               Estimate Std. Error t value Pr(>|t|)   
#> matstrawberry   10.010      1.526   6.560  0.00123 **
#> matapple         5.088      1.526   3.334  0.02068 * 
#> matpear         -1.571      2.922  -0.537  0.61398   
#> matspring        1.760      2.158   0.816  0.45172   
#> matsummer           NA         NA      NA       NA   
#> matfall          2.955      2.643   1.118  0.31431   
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 2.158 on 5 degrees of freedom
#> Multiple R-squared:  0.9626, Adjusted R-squared:  0.9252 
#> F-statistic: 25.76 on 5 and 5 DF,  p-value: 0.001409
```

As you can see `lm` realizes that there are linearly dependent columns
(`matsummer` is not defined) but it doesn’t indicate what columns it is
linearly dependent with.

So if you would just look at the coefficients and not consider the `NA`
further, you would interpret that `strawberry`, `apple` and `spring`
make fruit sweet.

However, when you look at the model matrix you can see that `summer` is
a linear combination of `strawberry` and `apple`. So truly any of the
three factors could contribute to the sweetness of a fruit, the linear
model has no way of recovering which one given these 10 examples.

To make such cases more obvious we wrote `fullRankMatrix`, it removes
linearly dependent columns and renames the remaining columns to make the
dependencies clear using the `make_full_rank_matrix()` function.

``` r
library(fullRankMatrix)
mat_fr <- make_full_rank_matrix(mat)
mat_fr
#>       strawberry_OR_(summer_COMB_apple) apple_OR_(summer_COMB_strawberry) pear
#>  [1,]                                 1                                 0    0
#>  [2,]                                 1                                 0    0
#>  [3,]                                 1                                 0    0
#>  [4,]                                 1                                 0    0
#>  [5,]                                 0                                 1    0
#>  [6,]                                 0                                 1    0
#>  [7,]                                 0                                 1    0
#>  [8,]                                 0                                 0    1
#>  [9,]                                 0                                 0    1
#> [10,]                                 0                                 0    1
#>       spring fall
#>  [1,]      1    0
#>  [2,]      1    0
#>  [3,]      0    0
#>  [4,]      0    0
#>  [5,]      0    0
#>  [6,]      0    0
#>  [7,]      0    1
#>  [8,]      0    1
#>  [9,]      0    1
#> [10,]      0    1
```

``` r
fit <- lm(sweetness ~ mat_fr + 0)
print(summary(fit))
#> 
#> Call:
#> lm(formula = sweetness ~ mat_fr + 0)
#> 
#> Residuals:
#>          1          2          3          4          5          6          7 
#>  2.602e+00 -2.602e+00  1.304e+00 -1.304e+00  1.012e+00 -1.012e+00 -4.441e-16 
#>          8          9         10 
#>  8.907e-01  8.004e-01 -1.691e+00 
#> 
#> Coefficients:
#>                                         Estimate Std. Error t value Pr(>|t|)   
#> mat_frstrawberry_OR_(summer_COMB_apple)   10.010      1.526   6.560  0.00123 **
#> mat_frapple_OR_(summer_COMB_strawberry)    5.088      1.526   3.334  0.02068 * 
#> mat_frpear                                -1.571      2.922  -0.537  0.61398   
#> mat_frspring                               1.760      2.158   0.816  0.45172   
#> mat_frfall                                 2.955      2.643   1.118  0.31431   
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 2.158 on 5 degrees of freedom
#> Multiple R-squared:  0.9626, Adjusted R-squared:  0.9252 
#> F-statistic: 25.76 on 5 and 5 DF,  p-value: 0.001409
```

You can see that there are no more undefined coefficients, since the
coefficient `summer` was removed. Coefficient `strawberry` was renamed
to indicate that either `strawberry` could make the fruit sweet or it
could be a combination of `apple` in `summer`
(`strawberry_OR_(summer_COMB_apple)`). Vice versa `apple` was renamed to
`apple_OR_(summer_COMB_strawberry)` to indicate this dependency.

### Other available packages that detect linear dependent columns

There are already a few other packages out there that offer functions to
detect linear dependent columns. Here are the ones we are aware of:

**`caret::findLinearCombos()`**:
<https://rdrr.io/cran/caret/man/findLinearCombos.html>

This function is used by `fullRankMatrix` as it identifies which columns
are linearly dependent and suggests which columns to remove.

``` r
caret::findLinearCombos(mat)
#> $linearCombos
#> $linearCombos[[1]]
#> [1] 5 1 2
#> 
#> 
#> $remove
#> [1] 5
```

**`WeightIt::make_full_rank()`**:
<https://rdrr.io/cran/WeightIt/man/make_full_rank.html>

This function removes linearly dependent columns, but doesn’t rename the
remaining columns accordingly.

``` r
WeightIt::make_full_rank(mat, with.intercept = FALSE)
#>       strawberry apple pear spring fall
#>  [1,]          1     0    0      1    0
#>  [2,]          1     0    0      1    0
#>  [3,]          1     0    0      0    0
#>  [4,]          1     0    0      0    0
#>  [5,]          0     1    0      0    0
#>  [6,]          0     1    0      0    0
#>  [7,]          0     1    0      0    1
#>  [8,]          0     0    1      0    1
#>  [9,]          0     0    1      0    1
#> [10,]          0     0    1      0    1
```

**`plm::detect.lindep()`:**
<https://rdrr.io/cran/plm/man/detect.lindep.html>

The function returns which columns are potentially linearly dependent.

``` r
plm::detect.lindep(mat)
#> [1] "Suspicious column number(s): 1, 2, 5"
#> [1] "Suspicious column name(s):   strawberry, apple, summer"
```

However it doesn’t capture all cases. For example here
`plm::detect.lindep()` says there are no dependent columns, while there
are several:

``` r
c1 <- rbinom(10, 1, .4)
c2 <- 1-c1
c3 <- integer(10)
c4 <- c1
c5 <- 2*c2
c6 <- rbinom(10, 1, .8)
c7 <- c5+c6
mat_test <- as.matrix(data.frame(c1,c2,c3,c4,c5,c6,c7))

plm::detect.lindep(mat_test)
#> [1] "No linear dependent column(s) detected."
```

`fullRankMatrix` captures these cases:

``` r
make_full_rank_matrix(mat_test)
#>       (c1_AND_c4) c2_OR_(c5)_OR_(c7_COMB_c6) c6_OR_(c7_COMB_c2)
#>  [1,]           0                          1                  1
#>  [2,]           1                          0                  1
#>  [3,]           1                          0                  1
#>  [4,]           0                          1                  1
#>  [5,]           0                          1                  1
#>  [6,]           0                          1                  0
#>  [7,]           1                          0                  1
#>  [8,]           1                          0                  1
#>  [9,]           0                          1                  0
#> [10,]           1                          0                  1
```

**`Smisc::findDepMat()`**:
<https://rdrr.io/cran/Smisc/man/findDepMat.html>

This function indicates linearly dependent rows/columns, but it doesn’t
state which rows/columns are linearly dependent with each other.

-   However, this function seems to not work well for one-hot encoded
    matrices and the package doesn’t seem to be updated anymore (s. this
    issue: <https://github.com/pnnl/Smisc/issues/24>).

``` r
# example provided by Smisc documentation
Y <- matrix(c(1, 3, 4,
              2, 6, 8,
              7, 2, 9,
              4, 1, 7,
              3.5, 1, 4.5), byrow = TRUE, ncol = 3)
Smisc::findDepMat(t(Y), rows = FALSE)
#> [1] FALSE  TRUE FALSE FALSE  TRUE
```

Trying with the model matrix from our example above:

``` r
Smisc::findDepMat(mat, rows=FALSE)
#> Error in if (!depends[j]) { : missing value where TRUE/FALSE needed
```
