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

test_that("invalid_cells reads the count from the ds.histogram warning only", {
  expect_equal(invalid_cells(c("Server1: 1 invalid cells", "something else", "Server2: 2 invalid cells")), 3)
  expect_equal(invalid_cells("Server1: 0 invalid cells"), 0)
  expect_equal(invalid_cells(character()), 0)
})

test_that("draw_histogram leaves zero bins without a bar only when cells are invalid", {
  png(withr::local_tempfile(fileext = ".png"))
  on.exit(dev.off())
  counts <- c(3, 10, 4, 9, 0)
  breaks <- c(0, 10, 20, 30, 40, 50)
  mids <- breaks[-1] - 5
  expect_equal(draw_histogram(counts, breaks, mids, invalid = 1), c(FALSE, FALSE, FALSE, FALSE, TRUE))
  expect_false(any(draw_histogram(counts, breaks, mids, invalid = 0)))
})

test_that("histogram_html redraws a histogram whose server marks a bin invalid", {
  # D$Age in Server1 with 5 breaks: ds.histogram warns "1 invalid cells"
  messages <- character()
  withCallingHandlers(
    dsBaseClient::ds.histogram("D$Age", num.breaks = 5, datasources = conns[1]),
    warning = function(w) {
      messages <<- c(messages, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  expect_gt(invalid_cells(messages), 0)

  plain <- withr::local_tempfile(fileext = ".png")
  png(plain)
  suppressWarnings(dsBaseClient::ds.histogram("D$Age", num.breaks = 5, datasources = conns[1]))
  dev.off()
  redrawn <- histogram_html("D$Age", conns[1])
  expect_match(redrawn, "<img", fixed = TRUE)
  expect_false(grepl(base64enc::base64encode(plain), redrawn, fixed = TRUE))
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
