test_that("ds.histAllVars errors when datasources is not a list of DSConnection objects", {
  expect_error(ds.histAllVars(datasources = "Server1"),
               "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
})

test_that("ds.histAllVars errors when datasources is a list of non-connection objects", {
  expect_error(ds.histAllVars(datasources = list(1, 2)),
               "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
})
