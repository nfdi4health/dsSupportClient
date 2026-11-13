read_report_text <- function(file) paste(readLines(file, warn = FALSE), collapse = "\n")

test_that("ds.qualityReport returns the file path invisibly", {
  f <- withr::local_tempfile(fileext = ".html")
  expect_invisible(res <- ds.qualityReport(df = "D", datasources = conns[2], file = f))
  expect_equal(res, f)
})

test_that("ds.qualityReport shows a refused factor table as suppressed, not as counts", {
  f <- withr::local_tempfile(fileext = ".html")
  ds.qualityReport(df = "D", datasources = conns[4], file = f)
  expect_match(read_report_text(f), "<h4>Sex</h4><p class=\"flag\">suppressed</p>", fixed = TRUE)
})

test_that("ds.qualityReport flags suppressed histogram bins", {
  f <- withr::local_tempfile(fileext = ".html")
  ds.qualityReport(df = "D", datasources = conns[1], file = f)
  expect_match(read_report_text(f), "Some bins are suppressed", fixed = TRUE)
})
