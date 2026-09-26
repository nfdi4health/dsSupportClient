test_that("ds.rse with type='combine' derives Z, p-value and confidence limits consistently from Beta and Robust SE", {
  res <- ds.rse(formula = "Weight~Age", datasources = conns[1:3], type = "combine", data = "D")
  expect_equal(res$`Robust Z`, res$Beta / res$`Robust SE`)
  expect_equal(res$`Robust P`, 2 * pnorm(abs(res$Beta / res$`Robust SE`), lower.tail = FALSE))
  expect_equal(res$`Robust LCI`, res$Beta - res$`Robust SE` * qnorm(0.975))
  expect_equal(res$`Robust UCI`, res$Beta + res$`Robust SE` * qnorm(0.975))
})

test_that("ds.rse with type='combine' reports the same Beta coefficients as ds.glm on the same formula", {
  res <- ds.rse(formula = "Weight~Age", datasources = conns[1:3], type = "combine", data = "D")
  mod <- ds.glm(formula = "Weight~Age", data = "D", family = "gaussian", datasources = conns[1:3])
  expect_equal(res$Beta, unname(mod$coefficients[, 1]))
  expect_equal(unique(res$Nvalid), mod$Nvalid)
})

test_that("ds.rse returns NULL when type is neither 'split' nor 'combine'", {
  expect_null(ds.rse(formula = "Weight~Age", datasources = conns[1:3], type = "nonsense", data = "D"))
})

test_that("ds.rse with type='combine' errors when the outcome variable does not exist on the servers", {
  expect_error(ds.rse(formula = "NotAVariable~Age", datasources = conns[1:3], type = "combine", data = "D"))
})

test_that("ds.rse with type='combine' handles a factor covariate by converting it and returns one row per variable in the formula", {
  res <- ds.rse(formula = "Weight~Age+Sex", datasources = conns[c(1, 3)], type = "combine", data = "D")
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 3)
  expect_equal(ncol(res), 7)
  expect_true(all(res$`Robust SE` > 0))
  expect_true(all(res$`Robust LCI` < res$`Robust UCI`))
})
