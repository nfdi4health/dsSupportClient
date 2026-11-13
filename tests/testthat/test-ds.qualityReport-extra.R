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

test_that("histogram_html redraws a histogram with suppressed bins, marking them", {
  html <- histogram_html("D$Age", conns[1])
  expect_match(html, "<img", fixed = TRUE)
})

test_that("the study section lists an entirely missing variable", {
  classes <- data.frame(Server1.class = c("integer", "factor"), row.names = c("Age", "Sex"))
  numNA <- data.frame(Server1.numNA = c(29, 2), row.names = c("Age", "Sex"))
  html <- paste(quality_report_section("D", conns[1], c(29, 2), classes, numNA,
                                       list(Server1 = data.frame())), collapse = "")
  expect_match(html, "entirely missing", fixed = TRUE)
})

test_that("the study section does not fail for a study without rows", {
  classes <- data.frame(Server1.class = "integer", row.names = "Age")
  numNA <- data.frame(Server1.numNA = 0, row.names = "Age")
  html <- paste(quality_report_section("D", conns[1], c(0, 1), classes, numNA,
                                       list(Server1 = data.frame())), collapse = "")
  expect_match(html, "not available", fixed = TRUE)
  expect_no_match(html, "NaN", fixed = TRUE)
})
