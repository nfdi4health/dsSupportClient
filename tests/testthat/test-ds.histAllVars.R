test_that("ds.histAllVars errors when datasources is not a list of DSConnection objects", {
  expect_error(ds.histAllVars(datasources = list("not a connection")),
               "The 'datasources' were expected to be a list of DSConnection-class objects",
               fixed = TRUE)
  expect_error(ds.histAllVars(datasources = "Server1"),
               "The 'datasources' were expected to be a list of DSConnection-class objects",
               fixed = TRUE)
})

test_that("ds.histAllVars warns and reuses the histograms directory when it already exists", {
  tmp <- file.path(tempdir(), paste0("histAllVars2_", as.integer(runif(1, 1, 1e6))))
  dir.create(tmp)
  old_wd <- getwd()
  setwd(tmp)
  dir.create(file.path(tmp, "histograms"))
  on.exit({setwd(old_wd); unlink(tmp, recursive = TRUE)}, add = TRUE)
  expect_warning(invisible(capture.output(try(ds.histAllVars(datasources = conns[1]), silent = TRUE))),
                 "already exists")
  expect_true(dir.exists(file.path(tmp, "histograms", "Server1")))
})
