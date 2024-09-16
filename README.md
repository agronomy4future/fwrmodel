
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fwrmodel

<!-- badges: start -->
<!-- badges: end -->

The goal of fwrmodel is to calculate slope for genotypes across environments to suggest stability (or adaptability) using Finlay-Wilkinson Regression Model.

□ Code summary: https://github.com/agronomy4future/r_code/blob/main/R_package_fwrmodel.ipynb

□ Code explained: https://agronomy4future.org/archives/22961

## Installation

You can install the development version of fwrmodel like so:

Before installing, please download Rtools (https://cran.r-project.org/bin/windows/Rtools)

``` r
if(!require(remotes)) install.packages("remotes")
library(remotes)

remotes::install_github("agronomy4future/fwrmodel")
library(fwrmodel)
```

## Example

This is a basic code to calculate environmental index:

``` r
# to calculate environmental index
stability= fwrmodel(data, env_cols= c("E1", "E2", "E3"), 
           genotype_col= "Genotype", yield_cols = c("Y1","Y2","Y3"))

env_index_calculated= stability$env_index


# to output coefficients 
coefficient_Y1= as.data.frame(stability$regression$Y1)
coefficient_Y2= as.data.frame(stability$regression$Y2)
coefficient_Y3= as.data.frame(stability$regression$Y3)
```

## Let’s practice with actual dataset

``` r
# to uplaod data
if(!require(readr)) install.packages("readr")
library(readr)
github="https://raw.githubusercontent.com/agronomy4future/raw_data_practice/main/fwrm_package_data_practice.csv"
df= data.frame(read_csv(url(github), show_col_types=FALSE))

set.seed(100)
df[sample(nrow(df),5),]
    year variety nitrogen location   AGW   KN      GY
202 2023     cv2       N0 Nebraska 318.6 3764 11864.8
112 2024     cv2       N1     Iowa 313.6 4570 14177.8
206 2023     cv2       N0 Nebraska 338.9 3764 12619.8
4   2023     cv1       N1     Iowa 311.7 3476 10721.4
98  2024     cv1       N1     Iowa 263.9 5618 14669.2
.
.
.

# to calculate stability
stability= fwrmodel(df, env_cols = c("year", "nitrogen", "location"), 
                    genotype_col= "variety", yield_cols = c("AGW","GY","KN"))

env_index_calculated= stability$env_index
set.seed(100)
env_index_calculated[sample(nrow(env_index_calculated),5),]

      variety year nitrogen location     Environments Env_index_AGW   AGW Env_index_GY      GY Env_index_KN   KN
20170     cv2 2023       N0 Nebraska 2023_N0_Nebraska      3.443333 318.6    -435.7763 11810.8    -214.5600 3488
16887     cv1 2023       N0 Illinois 2023_N0_Illinois     -1.523333 307.0   -2300.4197  8130.4    -786.9267 2742
3430      cv2 2023       N1     Iowa     2023_N1_Iowa    -22.023333 337.4    -202.7063 11931.9     195.4400 3721
3696      cv2 2023       N1     Iowa     2023_N1_Iowa    -22.023333 289.0    -202.7063 10474.6     195.4400 3411
20474     cv2 2023       N0 Nebraska 2023_N0_Nebraska      3.443333 348.8    -435.7763 10947.9    -214.5600 3672
.
.
.


# to output coefficients 
coefficient_AGW= as.data.frame(stability$regression$AGW)
coefficient_KN= as.data.frame(stability$regression$KN)
coefficient_GY= as.data.frame(stability$regression$GY)

coefficient_AGW
  variety          term    estimate  std.error  statistic       p.value
1     cv1   (Intercept) 297.9520000 3.95194803  75.393704  1.368777e-88
2     cv1 Env_index_AGW   0.7523172 0.14292608   5.263681  8.336224e-07
3     cv2   (Intercept) 318.8220000 2.58702388 123.238909 2.795793e-109
4     cv2 Env_index_AGW   0.8862399 0.09356226   9.472194  1.693111e-15
5     cv3   (Intercept) 312.6860000 2.64794053 118.086489 1.787034e-107
6     cv3 Env_index_AGW   1.3614429 0.09576537  14.216443  1.487695e-25
.
.
.
```
