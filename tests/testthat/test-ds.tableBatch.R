test_that("ds.tableBatch errors when datasources is not a list of DSConnection objects", {
  expect_error(ds.tableBatch(df = "D", datasources = "Server1"),
               "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
})

test_that("ds.tableBatch errors when the data.frame does not exist on the server", {
  expect_error(ds.tableBatch(df = "NotThere", datasources = conns[1]))
})
