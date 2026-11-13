# Tests for ds.qualityReport (issue #95). Test data: 4 studies, each 29 rows x
# 4 variables (ID, Sex, Age, Weight). Missing cells per study, counted in plain R
# on testsets/Study*.csv: Study1 5, Study2 6, Study3 3, Study4 0.
# Study4 has a Sex level "2" with a single observation (below nfilter.tab = 3).

read_report <- function(file) paste(readLines(file, warn = FALSE), collapse = "\n")

test_that("ds.qualityReport writes one HTML file at the given path", {
  f <- withr::local_tempfile(fileext = ".html")
  ds.qualityReport(df = "D", datasources = conns, file = f)
  expect_true(file.exists(f))
  expect_gt(file.size(f), 0)
  expect_match(read_report(f), "<html", ignore.case = TRUE)
})

test_that("ds.qualityReport has one section per connected study", {
  f <- withr::local_tempfile(fileext = ".html")
  ds.qualityReport(df = "D", datasources = conns, file = f)
  txt <- read_report(f)
  for (s in names(conns)) {
    expect_equal(lengths(regmatches(txt, gregexpr(s, txt, fixed = TRUE)))[[1]] >= 1, TRUE)
  }
  # a single study gives a report without the others
  f1 <- withr::local_tempfile(fileext = ".html")
  ds.qualityReport(df = "D", datasources = conns[2], file = f1)
  txt1 <- read_report(f1)
  expect_match(txt1, "Server2", fixed = TRUE)
  expect_false(grepl("Server1", txt1, fixed = TRUE))
  expect_false(grepl("Server3", txt1, fixed = TRUE))
})

test_that("ds.qualityReport overview shows rows, variables and share missing", {
  f <- withr::local_tempfile(fileext = ".html")
  ds.qualityReport(df = "D", datasources = conns[1], file = f)
  txt <- read_report(f)
  expect_match(txt, "29")               # rows
  expect_match(txt, "\\b4\\b")          # variables
  # 5 missing of 29 * 4 = 116 cells = 4.31 %
  expect_match(txt, "4\\.3")
})

test_that("ds.qualityReport shows classes, missing values, summaries, tables, histograms", {
  f <- withr::local_tempfile(fileext = ".html")
  ds.qualityReport(df = "D", datasources = conns[1], file = f)
  txt <- read_report(f)
  expect_match(txt, "factor", fixed = TRUE)     # class of Sex
  expect_match(txt, "Weight", fixed = TRUE)
  expect_match(txt, "Age", fixed = TRUE)
  expect_match(txt, "Sex", fixed = TRUE)
  expect_match(txt, "<img|<svg|<canvas", ignore.case = TRUE)  # histograms
  # Study1 Sex frequencies computed in plain R: 13 / 14 / 2 NA
  expect_match(txt, "13")
  expect_match(txt, "14")
})

test_that("ds.qualityReport lists an entirely missing variable and does not fail", {
  dsBaseClient::ds.make("D$Age * NA", "allna", datasources = conns)
  dsBaseClient::ds.dataFrame(c("D$ID", "D$Sex", "allna"), newobj = "Dmiss",
                             datasources = conns)
  withr::defer(dsBaseClient::ds.rm(c("allna", "Dmiss"), datasources = conns))
  f <- withr::local_tempfile(fileext = ".html")
  expect_no_error(ds.qualityReport(df = "Dmiss", datasources = conns, file = f))
  txt <- read_report(f)
  expect_match(txt, "allna", fixed = TRUE)
  expect_match(txt, "entirely missing", ignore.case = TRUE)
})

test_that("ds.qualityReport labels suppressed cells as suppressed", {
  # Study4: Sex level 2 has 1 observation, below nfilter.tab
  f <- withr::local_tempfile(fileext = ".html")
  ds.qualityReport(df = "D", datasources = conns[4], file = f)
  txt <- read_report(f)
  expect_match(txt, "suppressed", ignore.case = TRUE)
})

test_that("ds.qualityReport finds open connections when datasources is NULL", {
  f <- withr::local_tempfile(fileext = ".html")
  ds.qualityReport(df = "D", datasources = NULL, file = f)
  txt <- read_report(f)
  for (s in names(conns)) expect_match(txt, s, fixed = TRUE)
})

test_that("ds.qualityReport errors for a data frame that does not exist", {
  f <- withr::local_tempfile(fileext = ".html")
  expect_error(ds.qualityReport(df = "NotThere", datasources = conns, file = f))
})
