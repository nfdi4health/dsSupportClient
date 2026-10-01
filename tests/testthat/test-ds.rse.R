test_that("ds.rse with type='combine' returns a 7-column data.frame with one row per coefficient and Nvalid equal to the pooled ds.glm Nvalid", {
  res <- ds.rse(formula = "Weight~Age", datasources = conns[1:2], type = "combine", data = "D")
  mod <- ds.glm(formula = "Weight~Age", data = "D", family = "gaussian", datasources = conns[1:2])
  expect_s3_class(res, "data.frame")
  expect_equal(dim(res), c(2L, 7L))
  expect_equal(colnames(res), c("Beta", "Robust SE", "Robust Z", "Robust P", "Robust LCI", "Robust UCI", "Nvalid"))
  expect_equal(rownames(res), c("(Intercept)", "Age"))
  expect_equal(res$Beta, as.numeric(mod$coefficients[, 1]))
  expect_equal(unique(res$Nvalid), mod$Nvalid)
})

test_that("ds.rse with type='combine' derives Z, P and confidence intervals consistently from Beta and Robust SE", {
  res <- ds.rse(formula = "Weight~Age", datasources = conns[1:3], type = "combine", data = "D")
  expect_equal(nrow(res), 2)
  expect_true(all(res$`Robust SE` > 0))
  expect_equal(res$`Robust Z`, res$Beta / res$`Robust SE`)
  expect_equal(res$`Robust P`, 2 * pnorm(abs(res$`Robust Z`), lower.tail = FALSE))
  expect_equal(res$`Robust LCI`, res$Beta - res$`Robust SE` * qnorm(0.975))
  expect_equal(res$`Robust UCI`, res$Beta + res$`Robust SE` * qnorm(0.975))
  expect_true(all(res$`Robust LCI` < res$`Robust UCI`))
})

test_that("ds.rse returns NULL when type is neither 'split' nor 'combine'", {
  expect_null(ds.rse(formula = "Weight~Age", datasources = conns[1], type = "nonsense", data = "D"))
})

test_that("ds.rse with type='split' errors when the outcome variable does not exist on the server", {
  expect_error(ds.rse(formula = "NotAVar~Age", datasources = conns[1], type = "split", data = "D"))
})
