test_that("ds.summaryVars errors when datasources is not a list of DSConnection objects", {
  expect_error(ds.summaryVars(df = "D", datasources = "not_a_connection"),
               "The 'datasources' were expected to be a list of DSConnection-class objects",
               fixed = TRUE)
})

test_that("ds.summaryVars returns one named data.frame per server with names matching the connection names", {
  res <- ds.summaryVars(df = "D", datasources = conns)
  expect_true(is.list(res))
  expect_equal(length(res), 4)
  expect_equal(names(res), c("Server1", "Server2", "Server3", "Server4"))
  expect_true(all(unlist(lapply(res, is.data.frame))))
})

test_that("ds.summaryVars summarises only numeric/integer columns, excluding the factor column Sex", {
  res <- ds.summaryVars(df = "D", datasources = conns)
  expect_equal(rownames(res[["Server1"]]), c("ID", "Age", "Weight"))
  expect_false("Sex" %in% rownames(res[["Server1"]]))
  expect_equal(rownames(res[["Server3"]]), c("ID", "Age", "Weight"))
})

test_that("ds.summaryVars excludes the character column Weight for Server4 and keeps ID and Age", {
  res <- ds.summaryVars(df = "D", datasources = conns)
  expect_equal(rownames(res[["Server4"]]), c("ID", "Age"))
  expect_false("Weight" %in% rownames(res[["Server4"]]))
})

test_that("ds.summaryVars works with a single connection and returns a one-element list named Server2", {
  res <- ds.summaryVars(df = "D", datasources = conns[2])
  expect_equal(length(res), 1)
  expect_equal(names(res), "Server2")
  expect_equal(rownames(res[["Server2"]]), c("ID", "Age", "Weight"))
})

test_that("ds.summaryVars writes one CSV per server when save = TRUE and prints a message", {
  old_wd <- getwd()
  tmp <- tempfile()
  dir.create(tmp)
  setwd(tmp)
  on.exit({setwd(old_wd); unlink(tmp, recursive = TRUE)}, add = TRUE)
  res <- ds.summaryVars(df = "D", datasources = conns[1], save = TRUE)
  expect_true(file.exists("Server1_summary.csv"))
  written <- read.csv("Server1_summary.csv", row.names = 1)
  expect_equal(rownames(written), c("ID", "Age", "Weight"))
  expect_equal(length(list.files(pattern = "_summary\\.csv$")), 1)
})

test_that("ds.summaryVars errors when the given data frame name does not exist on the server", {
  expect_error(ds.summaryVars(df = "nonexistent_df", datasources = conns))
})
