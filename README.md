
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dsSupportClient

<!-- badges: start -->

[![R-CMD-check](https://github.com/sofiasiamp/dsSupportClient/actions/workflows/github-actions.yml/badge.svg)](https://github.com/sofiasiamp/dsSupportClient/actions/workflows/github-actions.yml)
[![codecov](https://codecov.io/gh/sofiasiamp/dsSupportClient/graph/badge.svg?token=JIMQK79E0H)](https://codecov.io/gh/sofiasiamp/dsSupportClient)
<!-- badges: end -->

The `dsSupportClient` package offers a set of client-side functions that
wrap around DataSHIELD functions from `dsBase`. It is designed to
streamline the production of descriptive statistics across multiple
harmonized datasets. Some functions are still in development and may be
refined based on user feedback.

## Installation

First, you need to install the “remotes” package from CRAN:

``` r
install.packages("remotes")
library(remotes)
```

And then install this Github repository

``` r
remotes::install_github("sofiasiamp/dsSupportClient")
```


## Connecting to the servers

`dsSupportClient` works with the connections you pass to its functions,
whatever the server type. Logging in needs the DataSHIELD driver for
your servers, which you install and load yourself, in your login script:

| Servers            | Driver package        | In the login                 |
|--------------------|-----------------------|------------------------------|
| Opal               | `DSOpal`              | `driver = "OpalDriver"`      |
| Armadillo          | `DSMolgenisArmadillo` | `driver = "ArmadilloDriver"` |
| Local test servers | `DSLite`              | `driver = "DSLiteDriver"`    |

``` r
install.packages("DSOpal")
library(DSOpal)
```

The drivers are optional dependencies (`Suggests`), so installing
`dsSupportClient` doesn’t install them.

## Example

This is a basic example on how to use it:

``` r
library(dsSupportClient)
ds.wrapper(ds_function = ds.class, datasources = connections, df = "D")
```
