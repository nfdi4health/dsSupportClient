#' @title DataSHIELD helper function for histograms
#' @description Generates and saves histogram plots for all numeric or integer variables across one or more DataSHIELD-connected studies.
#' @details For each study connection, this retrieves variable names via dsBaseClient::ds.colnames, checks each variable's class with ds.class and a crude suitability condition using ds.numNA, ds.length and ds.mean, and for variables passing these checks builds a histogram. Server function called: ds.histogram, once to print a disclosure-controlled summary and once (without a method, so using its server-side default) to render the plot captured into a local PNG file. Plots are written under a "histograms" working directory with one subdirectory per study, named after each study's DSConnection name; note the PNG file path is hardcoded to "~/histograms/..." rather than the directory just created.
#' @param datasources A list of DSConnection-class objects as created by DSI::datashield.login(); if NULL (the default), the function looks for existing connections via DSI::datashield.connections_find().
#' @param method A string naming the histogram-building method to pass to dsBaseClient::ds.histogram (e.g. "deterministic" or "probabilistic"); defaults to "deterministic".
#' @return Returns NULL invisibly; the function's purpose is entirely the side effect of writing a "histograms" directory tree of PNG histogram images to the working directory (or home directory, per the hardcoded path), while only the textual summary printed via ds.histogram is subject to DataSHIELD disclosure control.
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
#' ds.histAllVars(datasources = connections)
#' 
#' datashield.logout(connections)
#' }
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
