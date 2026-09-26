


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

test_that("ds.wrapper errors when ds_function is not supplied", {
  expect_error(ds.wrapper(df = "D", datasources = conns[1]),
               "You need to specify an aggregate DataSHIELD function.", fixed = TRUE)
})

test_that("ds.wrapper errors when datasources is not a list of DSConnection objects", {
  expect_error(ds.wrapper(df = "D", ds_function = ds.class, datasources = "Server1"),
               "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
})

test_that("ds.wrapper with ds.numNA returns the per-variable NA counts for a single study", {
  res <- ds.wrapper(df = "D", ds_function = ds.numNA, datasources = conns[1])
  expect_equal(dim(res), c(4L, 1L))
  expect_equal(colnames(res), "Server1.numNA")
  expect_equal(rownames(res), c("ID", "Sex", "Age", "Weight"))
  expect_equal(res[["Server1.numNA"]], c(0, 2, 1, 2))
})

test_that("ds.wrapper with ds.numNA combines NA counts of all four studies into one table", {
  res <- ds.wrapper(df = "D", ds_function = ds.numNA, datasources = conns)
  expect_equal(dim(res), c(4L, 4L))
  expect_equal(colnames(res), c("Server1.numNA", "Server2.numNA", "Server3.numNA", "Server4.numNA"))
  expect_equal(rownames(res), c("ID", "Sex", "Age", "Weight"))
  expect_equal(res[["Server1.numNA"]], c(0, 2, 1, 2))
  expect_equal(res[["Server2.numNA"]], c(0, 3, 0, 3))
  expect_equal(res[["Server3.numNA"]], c(0, 0, 0, 3))
  expect_equal(res[["Server4.numNA"]], c(0, 0, 0, 0))
})

test_that("ds.wrapper with a single connection returns a one-column data.frame of classes", {
  res <- ds.wrapper(df = "D", ds_function = ds.class, datasources = conns[2])
  expect_s3_class(res, "data.frame")
  expect_equal(dim(res), c(4L, 1L))
  expect_equal(colnames(res), "Server2.class")
  expect_equal(res[["Server2.class"]], c("integer", "factor", "integer", "numeric"))
  expect_equal(rownames(res), c("ID", "Sex", "Age", "Weight"))
})

test_that("ds.wrapper with save = TRUE writes ds.class_overview.csv containing the summary table", {
  old_wd <- getwd()
  tmp <- tempfile()
  dir.create(tmp)
  setwd(tmp)
  on.exit({setwd(old_wd); unlink(tmp, recursive = TRUE)}, add = TRUE)
  res <- expect_output(ds.wrapper(df = "D", ds_function = ds.class, datasources = conns[1], save = TRUE))
  expect_true(file.exists("ds.class_overview.csv"))
  written <- utils::read.csv("ds.class_overview.csv", row.names = 1)
  expect_equal(dim(written), c(4L, 1L))
  expect_equal(rownames(written), c("ID", "Sex", "Age", "Weight"))
  expect_equal(written[["Server1.class"]], c("integer", "factor", "integer", "numeric"))
})
