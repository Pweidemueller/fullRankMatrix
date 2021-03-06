
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
#> -2.458e+00  2.458e+00 -7.298e-01  7.298e-01 -1.851e+00  1.851e+00  4.441e-16 
#>          8          9         10 
#> -1.882e+00  4.121e-01  1.470e+00 
#> 
#> Coefficients: (1 not defined because of singularities)
#>               Estimate Std. Error t value Pr(>|t|)   
#> matstrawberry    8.021      1.608   4.986  0.00415 **
#> matapple         5.131      1.608   3.190  0.02427 * 
#> matpear          4.819      3.080   1.565  0.17841   
#> matspring        1.972      2.275   0.867  0.42555   
#> matsummer           NA         NA      NA       NA   
#> matfall         -2.002      2.786  -0.719  0.50454   
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 2.275 on 5 degrees of freedom
#> Multiple R-squared:  0.9413, Adjusted R-squared:  0.8825 
#> F-statistic: 16.03 on 5 and 5 DF,  p-value: 0.004259
```

As you can see `lm` realizes that there are linearly dependent columns
(`matsummer` is not defined) but it doesn’t indicate what columns it is
linearly dependent with.

So if you would just look at the columns and not consider the `NA`
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
#>       pear spring fall SPACE(strawberry,apple,summer)_AXIS1
#>  [1,]    0      1    0                                 -0.5
#>  [2,]    0      1    0                                 -0.5
#>  [3,]    0      0    0                                 -0.5
#>  [4,]    0      0    0                                 -0.5
#>  [5,]    0      0    0                                  0.0
#>  [6,]    0      0    0                                  0.0
#>  [7,]    0      0    1                                  0.0
#>  [8,]    1      0    1                                  0.0
#>  [9,]    1      0    1                                  0.0
#> [10,]    1      0    1                                  0.0
#>       SPACE(strawberry,apple,summer)_AXIS2
#>  [1,]                            0.0000000
#>  [2,]                            0.0000000
#>  [3,]                            0.0000000
#>  [4,]                            0.0000000
#>  [5,]                           -0.5773503
#>  [6,]                           -0.5773503
#>  [7,]                           -0.5773503
#>  [8,]                            0.0000000
#>  [9,]                            0.0000000
#> [10,]                            0.0000000
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
#> -2.458e+00  2.458e+00 -7.298e-01  7.298e-01 -1.851e+00  1.851e+00  8.882e-16 
#>          8          9         10 
#> -1.882e+00  4.121e-01  1.470e+00 
#> 
#> Coefficients:
#>                                            Estimate Std. Error t value Pr(>|t|)
#> mat_frpear                                    4.819      3.080   1.565  0.17841
#> mat_frspring                                  1.972      2.275   0.867  0.42555
#> mat_frfall                                   -2.002      2.786  -0.719  0.50454
#> mat_frSPACE(strawberry,apple,summer)_AXIS1  -16.041      3.217  -4.986  0.00415
#> mat_frSPACE(strawberry,apple,summer)_AXIS2   -8.887      2.786  -3.190  0.02427
#>                                              
#> mat_frpear                                   
#> mat_frspring                                 
#> mat_frfall                                   
#> mat_frSPACE(strawberry,apple,summer)_AXIS1 **
#> mat_frSPACE(strawberry,apple,summer)_AXIS2 * 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 2.275 on 5 degrees of freedom
#> Multiple R-squared:  0.9413, Adjusted R-squared:  0.8825 
#> F-statistic: 16.03 on 5 and 5 DF,  p-value: 0.004259
```

You can see that there are no more undefined columns, since the column
`summer` was removed. The three columns `strawberry`, `apple` and
`summer` have now been replaced with two orthogonal (linearly
independent) columns called `SPACE(strawberry,apple,summer)_AXIS1` and
`SPACE(strawberry,apple,summer)_AXIS2` to indicate that a combination of
all three variables (`strawberry`, `apple`, `summer`) could make the
fruit sweet. A further resolution which of the three variables is most
strongly associated with `sweetness` is not possible with the given
number of observations, but there is definitely an association of
`sweetness` with the space spanned by the three variables.

### Other available packages that detect linear dependent columns

There are already a few other packages out there that offer functions to
detect linear dependent columns. Here are the ones we are aware of:

**`caret::findLinearCombos()`**:
<https://rdrr.io/cran/caret/man/findLinearCombos.html>

This function identifies which columns are linearly dependent and
suggests which columns to remove.

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
#>       (c1_AND_c4) SPACE(c6,c7,SPACE(c2,c5)_AXIS1)_AXIS1
#>  [1,]           1                            -0.3333333
#>  [2,]           1                            -0.3333333
#>  [3,]           0                            -0.3333333
#>  [4,]           0                            -0.3333333
#>  [5,]           0                            -0.3333333
#>  [6,]           0                             0.0000000
#>  [7,]           0                            -0.3333333
#>  [8,]           0                            -0.3333333
#>  [9,]           1                            -0.3333333
#> [10,]           1                            -0.3333333
#>       SPACE(c6,c7,SPACE(c2,c5)_AXIS1)_AXIS2
#>  [1,]                            -0.3094922
#>  [2,]                            -0.3094922
#>  [3,]                             0.2475938
#>  [4,]                             0.2475938
#>  [5,]                             0.2475938
#>  [6,]                             0.5570860
#>  [7,]                             0.2475938
#>  [8,]                             0.2475938
#>  [9,]                            -0.3094922
#> [10,]                            -0.3094922
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
