


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

test_that("ds.wrapper errors when datasources is not a list of DSConnection objects", {
  expect_error(ds.wrapper(df = "D", ds_function = ds.class, datasources = "not_a_connection_list"), "The 'datasources' were expected to be a list of DSConnection-class objects", fixed = TRUE)
})

test_that("ds.wrapper errors when ds_function is NULL", {
  expect_error(ds.wrapper(df = "D", ds_function = NULL, datasources = conns[1:3]), "You need to specify an aggregate DataSHIELD function.", fixed = TRUE)
})

test_that("ds.wrapper errors when ds_function string does not resolve to an existing function", {
  expect_error(ds.wrapper(df = "D", ds_function = "ds.nonexistent_function_xyz", datasources = conns[1:3]), "Function 'ds.nonexistent_function_xyz' not found", fixed = TRUE)
})

test_that("ds.wrapper accepts ds_function passed as a function object and errors appropriately since ds_function must be a string", {
  expect_error(ds.wrapper(df = "D", ds_function = ds.colnames, datasources = conns[1:3]), "ds_function must be a single string")
})
