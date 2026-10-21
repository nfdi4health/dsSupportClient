#' @title DataSHIELD helper function for histograms
#' @details For each study connection, this retrieves variable names via dsBaseClient::ds.colnames, checks each variable's type and missingness with ds.class, ds.numNA, ds.length and ds.mean, and for suitable numeric/integer variables builds a histogram. Server function called: ds.histogram, once to print a disclosure-controlled summary and once to render the plot captured into a PNG file. Plots are written to a local "histograms" directory with one subdirectory per study, named after each study's connection name.
#' @param datasources A list of DSConnection-class objects as created by DSI::datashield.login(); if NULL (the default), the function looks for existing connections via DSI::datashield.connections_find().
#' @param method A string naming the histogram-building method to pass to dsBaseClient::ds.histogram (e.g. "deterministic" or "probabilistic"); defaults to "deterministic".
#' @return It creates a directory with subdirectories of each study, containing histograms of all variables
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
