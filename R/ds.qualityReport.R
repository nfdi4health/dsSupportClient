#' @title Data quality report for all connected studies
#' @description Runs the usual data quality checks on a server-side data.frame for every connected study and writes them to one HTML report with a section per study.
#' @details Each study section starts with an overview (rows, variables, share of missing cells) and then shows the variable classes and the number of missing values, the numeric summaries, the frequency tables of the factor variables and a histogram of every numeric variable. The report is built only from what existing functions return: dsBaseClient::ds.dim (server function dimDS), ds.wrapper with ds.class and ds.numNA, ds.summaryVars, ds.tableBatch (server function ds.table is run with useNA = "always") and dsBaseClient::ds.histogram. The per-study parts are requested one study at a time, so that a disclosure failure in one study does not hide the results of the others. No new server function is used. A variable with only missing values in a study is listed as entirely missing and is left out of the summaries, tables and histograms. A frequency table or histogram that the server refuses to return because of disclosure control (e.g. a cell count below nfilter.tab) is labelled as suppressed in the report, never shown as 0. ds.histogram is tried with 10, 5 and then 3 breaks, because the server refuses too many breaks for few observations; if the server marks any bin as invalid (it comes back with a count of 0), the histogram is redrawn without a bar for those bins, which are labelled "suppressed", so a suppressed bin is never drawn as 0. The histograms are embedded as PNG images, so the report is a single self-contained file.
#' @param df A character string giving the name of the server-side data.frame to report on (must exist in every study); defaults to "D".
#' @param datasources A list of DSConnection-class objects obtained after login. If NULL, the open connections are found with DSI::datashield.connections_find().
#' @param file A character string giving the path of the HTML report to write; defaults to "quality_report.html".
#' @return Returns the path of the report file invisibly. The report is written as a side effect.
#' @author Sofia Siampani (Max-Delbrueck-Center, Berlin), Florian Schwarz (German Institute of Human Nutrition, Potsdam-Rehbruecke)
#' @import DSI
#' @import dsBaseClient
#' @import methods
#' @importFrom grDevices dev.off png
#' @examples
#' \dontrun{
#' require('DSI')
#' require('DSOpal')
#' require('dsSupportClient')
#'
#' builder <- DSI::newDSLoginBuilder()
#' builder$append(server = "study1",
#'                url = "https://opal-demo.obiba.org/",
#'                user = "dsuser", password = "P@ssw0rd",
#'                table = "CNSIM.CNSIM1", driver = "OpalDriver")
#' builder$append(server = "study2",
#'                url = "https://opal-demo.obiba.org/",
#'                user = "dsuser", password = "P@ssw0rd",
#'                table = "CNSIM.CNSIM2", driver = "OpalDriver")
#' builder$append(server = "study3",
#'                url = "https://opal-demo.obiba.org/",
#'                user = "dsuser", password = "P@ssw0rd",
#'                table = "CNSIM.CNSIM3", driver = "OpalDriver")
#' logindata <- builder$build()
#' connections <- DSI::datashield.login(logins = logindata, assign = TRUE, symbol = "D")
#'
#' ds.qualityReport(df = "D", datasources = connections, file = "quality_report.html")
#'
#' datashield.logout(connections)
#' }
#' @export

ds.qualityReport <- function(df = "D", datasources = NULL, file = "quality_report.html") {

  if (is.null(datasources)) {
    datasources <- DSI::datashield.connections_find()
  }

  if (!(is.list(datasources) && all(unlist(lapply(datasources, function(d) methods::is(d, "DSConnection")))))) {
    stop("The 'datasources' were expected to be a list of DSConnection-class objects", call. = FALSE)
  }

  # fails here if df does not exist
  dims <- dsBaseClient::ds.dim(df, type = "split", datasources = datasources)
  classes <- ds.wrapper(df = df, ds_function = "ds.class", datasources = datasources)
  numNA <- ds.wrapper(df = df, ds_function = "ds.numNA", datasources = datasources)
  summaries <- ds.summaryVars(df = df, datasources = datasources)

  sections <- lapply(seq_along(datasources), function(p) {
    quality_report_section(df, datasources[p], dims[[p]], classes, numNA, summaries)
  })

  html <- c(
    "<!DOCTYPE html>",
    "<html><head><meta charset=\"utf-8\">",
    paste0("<title>Data quality report: ", htmltools::htmlEscape(df), "</title>"),
    "<style>body{font-family:sans-serif;margin:2em}table{border-collapse:collapse;margin-bottom:1em}",
    "td,th{border:1px solid #bbb;padding:2px 8px;text-align:right}th{background:#eee}",
    ".flag{color:#a00;font-weight:bold}</style></head><body>",
    paste0("<h1>Data quality report: ", htmltools::htmlEscape(df), "</h1>"),
    unlist(sections),
    "</body></html>"
  )
  writeLines(html, file)

  invisible(file)
}

# HTML of the section of one study; `study` is a list holding one connection
quality_report_section <- function(df, study, dim, classes, numNA, summaries) {

  name <- study[[1]]@name
  vars <- rownames(classes)
  class_study <- classes[[paste0(name, ".class")]]
  na_study <- numNA[vars, paste0(name, ".numNA")]
  all_missing <- dim[1] > 0 & !is.na(na_study) & na_study == dim[1]

  overview <- data.frame(
    Rows = dim[1],
    Variables = dim[2],
    "Share missing" = if (prod(dim) > 0) {
      sprintf("%.1f %%", 100 * sum(na_study, na.rm = TRUE) / prod(dim))
    } else {
      "not available (no data)"
    },
    check.names = FALSE
  )

  variables <- data.frame(
    Class = class_study,
    "Missing values" = ifelse(all_missing, "entirely missing", na_study),
    row.names = vars,
    check.names = FALSE
  )

  summary_study <- summaries[[name]]
  summary_study[] <- lapply(summary_study, function(x) {
    x <- utils::type.convert(x, as.is = TRUE)
    if (is.numeric(x)) signif(x, 4) else x
  })

  factors <- vars[class_study %in% "factor" & !all_missing]
  tables <- if (length(factors) > 0) ds.tableBatch(df = df, datasources = study)
  table_html <- vapply(factors, function(v) {
    cells <- tables[startsWith(rownames(tables), paste0(v, "_")), , drop = FALSE]
    # ds.tableBatch returns a "validity.message" column when ds.table refused
    refused <- nrow(cells) == 0 || "validity.message" %in% names(cells)
    shown <- if (refused) "<p class=\"flag\">suppressed</p>" else html_table(cells)
    paste0("<h4>", htmltools::htmlEscape(v), "</h4>", shown)
  }, character(1))

  numerics <- vars[class_study %in% c("numeric", "integer") & !all_missing]
  histograms <- vapply(numerics, function(v) {
    paste0("<h4>", htmltools::htmlEscape(v), "</h4>", histogram_html(paste0(df, "$", v), study))
  }, character(1))

  c(
    paste0("<h2>", htmltools::htmlEscape(name), "</h2>"),
    "<h3>Overview</h3>", html_table(overview, row_names = FALSE),
    "<h3>Variable classes and missing values</h3>", html_table(variables),
    "<h3>Numeric summaries</h3>", html_table(summary_study),
    "<h3>Factor frequency tables</h3>", table_html,
    "<h3>Histograms</h3>", histograms
  )
}

# HTML table of a data.frame; NA cells are shown as suppressed
html_table <- function(x, row_names = TRUE) {

  cell <- function(v) ifelse(is.na(v), "suppressed", htmltools::htmlEscape(as.character(v)))
  header <- paste0("<th>", htmltools::htmlEscape(names(x)), "</th>", collapse = "")
  first <- if (row_names) paste0("<tr><th>", htmltools::htmlEscape(rownames(x)), "</th>") else "<tr>"
  rows <- do.call(paste0, c(list(first), lapply(x, function(col) paste0("<td>", cell(col), "</td>")), list("</tr>")))
  paste0("<table><tr>", if (row_names) "<th></th>", header, "</tr>", paste(rows, collapse = ""), "</table>")
}

# HTML <img> with an embedded PNG histogram, or a suppressed label. The server
# refuses a histogram with too many breaks for few observations, so fewer
# breaks are tried. Bins below the threshold are reported by ds.histogram as
# "invalid cells" with a count of 0; then no plot is shown, only the label.
histogram_html <- function(variable, study) {

  png_file <- tempfile(fileext = ".png")
  on.exit(unlink(png_file))
  grDevices::png(png_file)

  histogram <- NULL
  for (breaks in c(10, 5, 3)) {
    invalid <- character()
    histogram <- tryCatch(
      withCallingHandlers(
        dsBaseClient::ds.histogram(variable, num.breaks = breaks, datasources = study),
        warning = function(w) {
          invalid <<- c(invalid, conditionMessage(w))
          invokeRestart("muffleWarning")
        }
      ),
      error = function(e) NULL
    )
    if (!is.null(histogram)) {
      break
    }
  }
  grDevices::dev.off()

  if (is.null(histogram)) {
    return("<p class=\"flag\">suppressed</p>")
  }

  if (length(invalid) > 0) {
    # ds.histogram gives suppressed bins a count of 0: redraw without bars for
    # the zero bins and mark them, so that a suppressed bin is not shown as 0
    grDevices::png(png_file)
    suppressed <- histogram$counts == 0
    graphics::plot(range(histogram$breaks), c(0, max(histogram$counts, 1) * 1.1), type = "n",
                   xlab = "", ylab = "Frequency", main = "")
    graphics::rect(histogram$breaks[-length(histogram$breaks)][!suppressed], 0,
                   histogram$breaks[-1][!suppressed], histogram$counts[!suppressed])
    graphics::text(histogram$mids[suppressed], max(histogram$counts, 1) * 0.05, "suppressed",
                   srt = 90, adj = c(0, 0.5), col = "red")
    grDevices::dev.off()
  }
  paste0("<img alt=\"histogram\" src=\"data:image/png;base64,", base64enc::base64encode(png_file), "\">")
}
