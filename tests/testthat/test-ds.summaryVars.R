test_that("ds.summaryVars errors when datasources is not a list of DSConnection objects", {
  expect_error(ds.summaryVars(df = "D", datasources = "Server1"),
               "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
})

test_that("ds.summaryVars skips a character column so Study4 has no Weight row", {
  res <- ds.summaryVars(df = "D", datasources = conns[4])
  expect_named(res, "Server4")
  expect_equal(rownames(res[[1]]), c("ID", "Age"))
  expect_false("Weight" %in% rownames(res[[1]]))
  expect_false("Sex" %in% rownames(res[[1]]))
})

test_that("ds.summaryVars standard deviation for ID equals sqrt of ds.var for the same variable", {
  res <- ds.summaryVars(df = "D", datasources = conns[1])[[1]]
  expected_sd <- sqrt(ds.var("D$ID", datasources = conns[1])[["Variance.by.Study"]][1])
  expect_equal(as.numeric(res["ID", "Standard deviation"]), as.numeric(expected_sd))
  expect_equal(as.numeric(res["ID", "Standard deviation"]), sd(1:29))
})

test_that("ds.summaryVars with save=TRUE writes one csv file per server and prints a message", {
  old_wd <- setwd(tempdir())
  on.exit(setwd(old_wd), add = TRUE)
  if (file.exists("Server1_summary.csv")) file.remove("Server1_summary.csv")
  expect_output(res <- ds.summaryVars(df = "D", datasources = conns[1], save = TRUE),
                "Server1_summary.csv")
  expect_true(file.exists("Server1_summary.csv"))
  written <- read.csv("Server1_summary.csv", row.names = 1, check.names = FALSE)
  expect_equal(rownames(written), c("ID", "Age", "Weight"))
  expect_equal(nrow(written), 3L)
  file.remove("Server1_summary.csv")
})

test_that("ds.summaryVars errors when the data.frame name does not exist on the server", {
  expect_error(ds.summaryVars(df = "NotThere", datasources = conns[1]))
})
