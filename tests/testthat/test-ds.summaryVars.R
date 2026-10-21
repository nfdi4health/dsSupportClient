test_that("ds.summaryVars errors when datasources is not a list of DSConnection objects", {
  expect_error(ds.summaryVars(df = "D", datasources = "Server1"),
               "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
})

test_that("ds.summaryVars returns one named data.frame per server when all four connections are used", {
  res <- ds.summaryVars(df = "D", datasources = conns)
  expect_length(res, 4)
  expect_named(res, c("Server1", "Server2", "Server3", "Server4"))
  expect_equal(sort(rownames(res[["Server1"]])), c("Age", "ID", "Weight"))
  expect_equal(sort(rownames(res[["Server4"]])), c("Age", "ID"))
})

test_that("ds.summaryVars excludes the character variable Weight of Study4 from the summary", {
  res <- ds.summaryVars(df = "D", datasources = conns[4])
  expect_named(res, "Server4")
  expect_false("Weight" %in% rownames(res[[1]]))
  expect_equal(nrow(res[[1]]), 2)
})

test_that("ds.summaryVars errors when the data.frame does not exist on the server", {
  expect_error(ds.summaryVars(df = "NotThere", datasources = conns[1]))
})
