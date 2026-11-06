test_that("ds.rse with an unsupported type returns NULL without computing anything", {
  expect_null(ds.rse(formula = "Weight~Age", data = "D", datasources = conns[1], type = "neither"))
})

test_that("ds.rse with type='combine' returns a single data.frame with an Nvalid column repeated for every coefficient", {
  expect_message(res_comb <- ds.rse(formula = "Weight~Age", data = "D", datasources = conns[1:3], type = "combine"),
                 "The entire analysis took")
  expect_s3_class(res_comb, "data.frame")
  expect_equal(dim(res_comb), c(2L, 7L))
  expect_equal(colnames(res_comb), c("Beta", "Robust SE", "Robust Z", "Robust P", "Robust LCI", "Robust UCI", "Nvalid"))
  expect_equal(rownames(res_comb), c("(Intercept)", "Age"))
  expect_equal(length(unique(res_comb$Nvalid)), 1L)
  expect_equal(res_comb[, "Robust Z"], res_comb[, "Beta"] / res_comb[, "Robust SE"])
  expect_equal(res_comb[, "Robust LCI"], res_comb[, "Beta"] - res_comb[, "Robust SE"] * qnorm(0.975))
  expect_equal(res_comb[, "Robust UCI"], res_comb[, "Beta"] + res_comb[, "Robust SE"] * qnorm(0.975))
})

test_that("ds.rse errors when the data.frame name does not exist on the server", {
  expect_error(ds.rse(formula = "Weight~Age", data = "NotThere", datasources = conns[1], type = "split"))
})
