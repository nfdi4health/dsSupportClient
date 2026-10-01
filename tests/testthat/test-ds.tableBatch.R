test_that("ds.tableBatch errors when datasources is not a list of DSConnection objects", {
  expect_error(ds.tableBatch(df = "D", datasources = "not_a_connection"),
               "The 'datasources' were expected to be a list of DSConnection-class objects",
               fixed = TRUE)
})
