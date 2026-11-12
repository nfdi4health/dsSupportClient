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

test_that("ds.rse with type='split' returns one named data.frame per datasource with the expected coefficient rows and columns", {
  res_split <- ds.rse(formula = "Weight~Age", data = "D", datasources = conns[1:2], type = "split")
  expect_type(res_split, "list")
  expect_equal(length(res_split), 2L)
  expect_equal(names(res_split), c("Server1", "Server2"))
  expect_s3_class(res_split[[1]], "data.frame")
  expect_equal(dim(res_split[[1]]), c(2L, 6L))
  expect_equal(colnames(res_split[[1]]), c("Beta", "Robust SE", "Robust Z", "Robust P", "Robust LCI", "Robust UCI"))
  expect_equal(rownames(res_split[[1]]), c("(Intercept)", "Age"))
  expect_equal(rownames(res_split[[2]]), c("(Intercept)", "Age"))
})

test_that("ds.rse type='split' derives Z, P and the 95% CIs from Beta and Robust SE", {
  res_split <- ds.rse(formula = "Weight~Age", data = "D", datasources = conns[1], type = "split")
  tab <- res_split[[1]]
  expect_equal(tab[, "Robust Z"], tab[, "Beta"] / tab[, "Robust SE"])
  expect_equal(tab[, "Robust P"], 2 * stats::pnorm(q = abs(tab[, "Robust Z"]), lower.tail = FALSE))
  expect_equal(tab[, "Robust LCI"], tab[, "Beta"] - tab[, "Robust SE"] * stats::qnorm(0.975))
  expect_equal(tab[, "Robust UCI"], tab[, "Beta"] + tab[, "Robust SE"] * stats::qnorm(0.975))
  expect_true(all(tab[, "Robust SE"] > 0))
})

test_that("ds.rse type='split' with a factor covariate returns a row per dummy level of Sex", {
  res_fac <- ds.rse(formula = "Weight~Age+Sex", data = "D", datasources = conns[3], type = "split")
  expect_equal(length(res_fac), 1L)
  expect_equal(names(res_fac), "Server3")
  expect_equal(dim(res_fac[[1]]), c(3L, 6L))
  expect_equal(rownames(res_fac[[1]]), c("(Intercept)", "Age", "Sex1"))
  expect_true(all(is.finite(res_fac[[1]][, "Robust SE"])))
})

test_that("ds.rse errors when a variable in the formula is not in the server-side data.frame", {
  expect_error(ds.rse(formula = "Weight~NotAVariable", data = "D", datasources = conns[1], type = "split"))
})
