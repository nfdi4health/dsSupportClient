test_that("ds.rse returns NULL when type is neither 'split' nor 'combine'", {
  expect_null(ds.rse(formula = "Weight~Age", data = "D", type = "neither", datasources = conns[1]))
})

test_that("ds.rse with type='split' errors when the data.frame does not exist on the server", {
  expect_error(ds.rse(formula = "Weight~Age", data = "NotThere", type = "split", datasources = conns[1]))
})
