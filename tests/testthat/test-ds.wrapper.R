


test_that("ds.wrapper Errors", {

  case1 <- ds.wrapper(df = "D", ds_function = ds.class, datasources=conns[1:3])

  df_comparison <- data.frame(Server1.class = c("integer", "factor", "integer", "numeric"),
                              Server2.class = c("integer", "factor", "integer", "numeric"),
                              Server3.class = c("integer", "factor", "integer", "numeric"))

  row.names(df_comparison) <- c("ID", "Sex", "Age", "Weight")

  expect_equal(case1, df_comparison)

  ## Case 2: there is a problem with the coding somewhere?
  case2 <- ds.wrapper(df = "D", ds_function = ds.class, datasources = conns[c(1:4)])

  df_comparison2 <- data.frame(Server1.class = c("integer", "factor", "integer", "numeric"),
                               Server2.class = c("integer", "factor", "integer", "numeric"),
                               Server3.class = c("integer", "factor", "integer", "numeric"),
                               Server4.class = c("integer", "factor", "integer", "character"))

  row.names(df_comparison2) <- c("ID", "Sex", "Age", "Weight")

  expect_equal(case2, df_comparison2)


  #case3 <- ds.wrapper(df = "D", ds_function = ds.numNA)

  #### Not true, since the class difference comes to play
  #expect_silent(case3)






})

test_that("ds.wrapper errors when ds_function is NULL", {
  expect_error(ds.wrapper(df = "D", ds_function = NULL, datasources = conns[1]),
               "You need to specify an aggregate DataSHIELD function.", fixed = TRUE)
})

test_that("ds.wrapper errors when datasources is not a list of DSConnection objects", {
  expect_error(ds.wrapper(df = "D", ds_function = ds.class, datasources = "Server1"),
               "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
  expect_error(ds.wrapper(df = "D", ds_function = ds.class, datasources = list(1, 2)),
               "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
})

test_that("ds.wrapper with a single datasource returns a one-column data.frame of variable classes", {
  res <- ds.wrapper(df = "D", ds_function = ds.class, datasources = conns[1])
  expect_equal(dim(res), c(4L, 1L))
  expect_equal(colnames(res), "Server1.class")
  expect_equal(rownames(res), c("ID", "Sex", "Age", "Weight"))
  expect_equal(res$Server1.class, c("integer", "factor", "integer", "numeric"))
})

test_that("ds.wrapper with ds.numNA returns the number of missing values per variable for all four servers", {
  res <- ds.wrapper(df = "D", ds_function = ds.numNA, datasources = conns)
  expect_equal(dim(res), c(4L, 4L))
  expect_equal(colnames(res), c("Server1.numNA", "Server2.numNA", "Server3.numNA", "Server4.numNA"))
  expect_equal(rownames(res), c("ID", "Sex", "Age", "Weight"))
  expect_equal(res$Server1.numNA, c(0, 2, 1, 2))
  expect_equal(res$Server2.numNA, c(0, 3, 0, 3))
  expect_equal(res$Server3.numNA, c(0, 0, 0, 3))
  expect_equal(res$Server4.numNA, c(0, 0, 0, 0))
})

test_that("ds.wrapper with save = TRUE writes a csv overview file containing the summary", {
  old_wd <- setwd(tempdir())
  on.exit(setwd(old_wd), add = TRUE)
  if (file.exists("ds.class_overview.csv")) file.remove("ds.class_overview.csv")
  res <- ds.wrapper(df = "D", ds_function = ds.class, datasources = conns[1:2], save = TRUE)
  expect_true(file.exists("ds.class_overview.csv"))
  written <- read.csv("ds.class_overview.csv", row.names = 1)
  expect_equal(dim(written), c(4L, 2L))
  expect_equal(rownames(written), c("ID", "Sex", "Age", "Weight"))
  expect_equal(written$Server1.class, c("integer", "factor", "integer", "numeric"))
  expect_equal(written$Server2.class, c("integer", "factor", "integer", "numeric"))
  expect_equal(res, written)
  file.remove("ds.class_overview.csv")
})

test_that("ds.wrapper column order follows the order of the supplied datasources", {
  res <- ds.wrapper(df = "D", ds_function = ds.class, datasources = conns[c(4, 1)])
  expect_equal(colnames(res), c("Server4.class", "Server1.class"))
  expect_equal(res$Server4.class, c("integer", "factor", "integer", "character"))
  expect_equal(res$Server1.class, c("integer", "factor", "integer", "numeric"))
  expect_equal(rownames(res), c("ID", "Sex", "Age", "Weight"))
})

test_that("ds.wrapper errors when the data.frame name does not exist on the server", {
  expect_error(ds.wrapper(df = "NotThere", ds_function = ds.class, datasources = conns[1]))
})
