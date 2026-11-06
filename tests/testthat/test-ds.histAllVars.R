test_that("ds.histAllVars errors when datasources is not a list of DSConnection objects", {
  expect_error(ds.histAllVars(datasources = "Server1"),
               "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
})

test_that("ds.histAllVars errors on a list of non-DSConnection elements without creating a histograms directory", {
  old_wd <- setwd(tempdir())
  on.exit(setwd(old_wd), add = TRUE)
  if (dir.exists("histograms")) unlink("histograms", recursive = TRUE)
  expect_error(ds.histAllVars(datasources = list(1, 2)),
               "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
  expect_false(dir.exists("histograms"))
  expect_equal(normalizePath(getwd()), normalizePath(tempdir()))
})
