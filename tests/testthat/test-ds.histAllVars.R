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

test_that("ds.histAllVars writes per-study PNGs under path, passes method to both calls and keeps the working directory", {
  skip_if_not(exists("conns"))
  out <- paste0("histtest_", basename(tempfile()))
  on.exit(unlink(here::here(out), recursive = TRUE), add = TRUE)
  wd <- getwd()
  methods_used <- character()
  fake_hist <- function(x, ..., method = "none") {
    methods_used <<- c(methods_used, method)
    invisible(NULL)
  }
  testthat::local_mocked_bindings(ds.histogram = fake_hist, .package = "dsBaseClient")
  expect_output(ds.histAllVars(datasources = conns["Server1"], method = "probabilistic", path = out))
  expect_true(dir.exists(here::here(out, "Server1")))
  expect_true(length(methods_used) > 0)
  expect_true(all(methods_used == "probabilistic"))
  expect_equal(getwd(), wd)
})

test_that("ds.histAllVars leaves the working directory unchanged after an error", {
  wd <- getwd()
  expect_error(ds.histAllVars(datasources = list(1)))
  expect_equal(getwd(), wd)
})
