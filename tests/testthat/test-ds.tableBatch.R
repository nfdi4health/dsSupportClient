test_that("ds.tableBatch errors when datasources is not a list of DSConnection objects", {
  expect_error(ds.tableBatch(df = "D", datasources = "Server1"),
               "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
})

test_that("ds.tableBatch only reports factor columns and ignores ID, Age and Weight", {
  res <- ds.tableBatch(df = "D", datasources = conns[1])
  expect_equal(nrow(res), 3L)
  expect_false(any(grepl("^ID_", rownames(res))))
  expect_false(any(grepl("^Age_", rownames(res))))
  expect_false(any(grepl("^Weight_", rownames(res))))
})

test_that("ds.tableBatch errors when the data.frame name does not exist on the server", {
  expect_error(ds.tableBatch(df = "NotThere", datasources = conns[1]))
})
