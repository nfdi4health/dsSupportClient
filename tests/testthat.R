# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
# * https://testthat.r-lib.org/articles/special-files.html

#### Necessary Installations for DSLite to work locally
#### In order to check for dsSupportClient to work with multiple dsBase versions, adaptation might be necessary
#remotes::install_github("datashield/dsBase", ref = "6.3.0", dependencies=TRUE)
for (pkg in c("DSLite", "DSOpal")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    remotes::install_github(paste0("datashield/", pkg))
  }
}



library(testthat)
library(dsBaseClient)
library(dsBase)
library(DSLite)
library(DSOpal)
library(DSI)
library(dsSupportClient)

test_check("dsSupportClient")
