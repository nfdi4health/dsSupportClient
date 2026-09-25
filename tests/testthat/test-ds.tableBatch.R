test_that("ds.tableBatch throws an error when datasources is not a list of DSConnection objects", {
  expect_error(ds.tableBatch(df = "D", datasources = "not_a_connection"), "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
})

test_that("ds.tableBatch throws an error when datasources is a list containing non-DSConnection objects", {
  expect_error(ds.tableBatch(df = "D", datasources = list(1, 2)), "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
})

test_that("ds.tableBatch returns a data.frame when called on the default table with valid connections", {
  result <- ds.tableBatch(df = "D", datasources = conns)
  expect_true(is.data.frame(result))
})

test_that("ds.tableBatch uses datashield.connections_find when datasources is NULL", {
  result_null <- ds.tableBatch(df = "D", datasources = NULL)
  result_explicit <- ds.tableBatch(df = "D", datasources = conns)
  expect_equal(dim(result_null), dim(result_explicit))
})

test_that("ds.tableBatch returns row names combining variable and factor level labels for factor variables", {
  result <- ds.tableBatch(df = "D", datasources = conns)
  if (nrow(result) > 0) { expect_true(all(grepl("_", rownames(result)))) }
})
