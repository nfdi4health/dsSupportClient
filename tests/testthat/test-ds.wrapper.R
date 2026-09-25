


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
})

test_that("ds.wrapper with a single datasource returns one column named Server1.class with the 4 variable rows", {
  res <- ds.wrapper(df = "D", ds_function = ds.class, datasources = conns[1])
  expect_equal(dim(res), c(4L, 1L))
  expect_equal(colnames(res), "Server1.class")
  expect_equal(rownames(res), c("ID", "Sex", "Age", "Weight"))
  expect_equal(res[["Server1.class"]], c("integer", "factor", "integer", "numeric"))
})

test_that("ds.wrapper uses datashield.connections_find() when datasources is NULL, covering all 4 servers", {
  res <- ds.wrapper(df = "D", ds_function = ds.class)
  expect_equal(dim(res), c(4L, 4L))
  expect_equal(colnames(res), c("Server1.class", "Server2.class", "Server3.class", "Server4.class"))
  expect_equal(rownames(res), c("ID", "Sex", "Age", "Weight"))
  expect_equal(res["Weight", "Server4.class"], "character")
})

test_that("ds.wrapper with save = TRUE writes ds.class_overview.csv containing the summary and prints a message", {
  old_wd <- setwd(tempdir())
  on.exit(setwd(old_wd), add = TRUE)
  file_name <- "ds.class_overview.csv"
  if (file.exists(file_name)) file.remove(file_name)
  expect_output(res <- ds.wrapper(df = "D", ds_function = ds.class, datasources = conns[1:2], save = TRUE),
                "ds.class_overview.csv", fixed = TRUE)
  expect_true(file.exists(file_name))
  written <- utils::read.csv(file_name, row.names = 1)
  expect_equal(dim(written), c(4L, 2L))
  expect_equal(rownames(written), c("ID", "Sex", "Age", "Weight"))
  expect_equal(written[["Server1.class"]], c("integer", "factor", "integer", "numeric"))
  file.remove(file_name)
})
