#' @title DataSHIELD helper function for histograms
#' @description Loops over all variables in one or more server-side tables and saves a histogram plot to disk for each numeric or integer variable with valid, non-missing data.
#' @details For each connection in datasources, this calls dsBaseClient::ds.colnames, ds.class, ds.numNA, ds.length and ds.mean to identify eligible numeric/integer variables, then calls dsBaseClient::ds.histogram (server function called: ds.histogram) to compute and plot each histogram. Plots are written locally as PNG files using grDevices::png/dev.off, organised into a 'histograms' directory with one subdirectory per study name, created via dir.create in the current working directory.
#' @param datasources Optional list of DSConnection-class objects representing the server connections to use; if NULL (the default), the function attempts to find open connections via DSI::datashield.connections_find().
#' @param method Character string giving the histogram computation method to pass through to dsBaseClient::ds.histogram (e.g. 'deterministic', the default); controls how the server computes histogram bins/counts.
#' @return Returns nothing meaningful to the caller (the function's value is the result of setwd('..'), used only for its side effect); its real effect is writing histogram PNG files to disk under a newly created 'histograms' directory, with one subdirectory per study.
#' @import DSI
#' @import dsBaseClient
#' @import methods
#' @importFrom grDevices dev.off png
#' @export

ds.histAllVars<- function(datasources = NULL, method = "deterministic" ) {


  if(is.null(datasources)){
    datasources <- DSI::datashield.connections_find()
  }


  if(!(is.list(datasources) && all(unlist(lapply(datasources, function(d) {methods::is(d,"DSConnection")}))))){
    stop("The 'datasources' were expected to be a list of DSConnection-class objects", call.=FALSE)
  }

  dir.create("histograms")
  setwd("histograms")
  for (p in 1:length(datasources)){
    study <- datasources[p]
    col <- dsBaseClient::ds.colnames("D",study)
    studyName <- study[[1]]@name
    dir.create(studyName)
    for(i in col[[1]]) {
      var <- paste0("D$",i)
      a <- dsBaseClient::ds.class(var,study)
      if ((a== "numeric" || a== "integer") && dsBaseClient::ds.numNA(var,study)< dsBaseClient::ds.length(var, datasources = study)[[1]] && dsBaseClient::ds.mean(var, datasources = study)[[1]][1]){
        a <- dsBaseClient::ds.histogram(var, datasources = study, method = method)
        print(a)
        grDevices::png(filename=paste0("~/histograms/",studyName,"/",studyName,"_",i,".png"))
        dsBaseClient::ds.histogram(var, datasources = study)
        grDevices::dev.off()
      }
    }
  }
  setwd('..')
}
