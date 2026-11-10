#' @title Build and save histograms for numeric variables per study
#' @description Generates and saves histogram plots for all numeric or integer variables across one or more DataSHIELD-connected studies.
#' @details For each study connection, this retrieves variable names via dsBaseClient::ds.colnames, checks each variable's type and missingness with ds.class, ds.numNA, ds.length and ds.mean, and for suitable numeric/integer variables builds a histogram. Server function called: ds.histogram, called first to obtain and print a disclosure-controlled summary object, then called again (without capturing its result) purely to render a plot that is captured into a PNG file. Both calls use the same \code{method}. Output goes to \code{<path>/<studyName>/<studyName>_<variable>.png}, with one subdirectory per study named after each study's connection name. \code{path} is resolved with \code{here::here()}, i.e. relative to the project root, not to the current working directory. The working directory is never changed.
#' @param datasources A list of DSConnection-class objects as created by DSI::datashield.login(); if NULL (the default), the function looks for existing connections via DSI::datashield.connections_find().
#' @param method A string naming the histogram-building method passed to dsBaseClient::ds.histogram in both calls, the disclosure-controlled summary and the plot rendered to PNG (e.g. "deterministic" or "probabilistic"); defaults to "deterministic".
#' @param path A string giving the output directory, relative to the project root as found by \code{here::here()}; defaults to "histograms". It is created if it does not exist.
#' @return Called for its side effects: it creates the directory \code{path} with a subdirectory for each study, containing PNG histograms of all suitable variables. The summary object of each histogram is printed.
#' @import DSI
#' @import dsBaseClient
#' @import methods
#' @importFrom grDevices dev.off png
#' @export

ds.histAllVars<- function(datasources = NULL, method = "deterministic", path = "histograms") {


  if(is.null(datasources)){
    datasources <- DSI::datashield.connections_find()
  }


  if(!(is.list(datasources) && all(unlist(lapply(datasources, function(d) {methods::is(d,"DSConnection")}))))){
    stop("The 'datasources' were expected to be a list of DSConnection-class objects", call.=FALSE)
  }

  outDir <- here::here(path)
  dir.create(outDir, showWarnings = FALSE, recursive = TRUE)
  for (p in 1:length(datasources)){
    study <- datasources[p]
    col <- dsBaseClient::ds.colnames("D",study)
    studyName <- study[[1]]@name
    studyDir <- file.path(outDir, studyName)
    dir.create(studyDir, showWarnings = FALSE)
    for(i in col[[1]]) {
      var <- paste0("D$",i)
      a <- dsBaseClient::ds.class(var,study)
      if ((a== "numeric" || a== "integer") && dsBaseClient::ds.numNA(var,study)< dsBaseClient::ds.length(var, datasources = study)[[1]] && dsBaseClient::ds.mean(var, datasources = study)[[1]][1]){
        a <- dsBaseClient::ds.histogram(var, datasources = study, method = method)
        print(a)
        grDevices::png(filename=file.path(studyDir, paste0(studyName,"_",i,".png")))
        dsBaseClient::ds.histogram(var, datasources = study, method = method)
        grDevices::dev.off()
      }
    }
  }
}
