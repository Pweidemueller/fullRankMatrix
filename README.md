
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

When using linear models you should check if any of the columns in your
model matrix are linearly dependent. If they are this will alter the
interpretation of the model fit. Here is a very constructed example
where we are interested in identifying the factors that make fruit
sweet. We can classify fruit into what fruit they are and also at what
season they are harvested.

``` r
library(fullRankMatrix)
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
#> -4.358e-01  4.358e-01 -1.071e+00  1.071e+00 -7.789e-01  7.789e-01  5.551e-16 
#>          8          9         10 
#> -1.431e-01  1.155e-01  2.762e-02 
#> 
#> Coefficients: (1 not defined because of singularities)
#>               Estimate Std. Error t value Pr(>|t|)    
#> matstrawberry   8.6538     0.6262  13.819 3.56e-05 ***
#> matapple        6.7142     0.6262  10.722 0.000122 ***
#> matpear         2.5017     1.1991   2.086 0.091325 .  
#> matspring       2.6993     0.8856   3.048 0.028489 *  
#> matsummer           NA         NA      NA       NA    
#> matfall        -1.5640     1.0846  -1.442 0.208889    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.8856 on 5 degrees of freedom
#> Multiple R-squared:  0.9926, Adjusted R-squared:  0.9852 
#> F-statistic: 134.4 on 5 and 5 DF,  p-value: 2.528e-05
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
dependencies clear.

``` r
mat_fullrank <- make_full_rank_matrix(mat)
fit <- lm(sweetness ~ mat_fullrank + 0)
print(summary(fit))
#> 
#> Call:
#> lm(formula = sweetness ~ mat_fullrank + 0)
#> 
#> Residuals:
#>          1          2          3          4          5          6          7 
#> -4.358e-01  4.358e-01 -1.071e+00  1.071e+00 -7.789e-01  7.789e-01  5.551e-16 
#>          8          9         10 
#> -1.431e-01  1.155e-01  2.762e-02 
#> 
#> Coefficients:
#>                                               Estimate Std. Error t value
#> mat_fullrankstrawberry_OR_(summer_COMB_apple)   8.6538     0.6262  13.819
#> mat_fullrankapple_OR_(summer_COMB_strawberry)   6.7142     0.6262  10.722
#> mat_fullrankpear                                2.5017     1.1991   2.086
#> mat_fullrankspring                              2.6993     0.8856   3.048
#> mat_fullrankfall                               -1.5640     1.0846  -1.442
#>                                               Pr(>|t|)    
#> mat_fullrankstrawberry_OR_(summer_COMB_apple) 3.56e-05 ***
#> mat_fullrankapple_OR_(summer_COMB_strawberry) 0.000122 ***
#> mat_fullrankpear                              0.091325 .  
#> mat_fullrankspring                            0.028489 *  
#> mat_fullrankfall                              0.208889    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 0.8856 on 5 degrees of freedom
#> Multiple R-squared:  0.9926, Adjusted R-squared:  0.9852 
#> F-statistic: 134.4 on 5 and 5 DF,  p-value: 2.528e-05
```

You can see that there are no more undefined coefficients, since the
coefficient `summer` was removed. Coefficient `strawberry` was renamed
to indicate that either `strawberry` could make the fruit sweet or it
could be a combination of `apple` in `summer`
(`strawberry_OR_(summer_COMB_apple)`). Vice versa `apple` was renamed to
`apple_OR_(summer_COMB_strawberry)` to indicate this dependency.
