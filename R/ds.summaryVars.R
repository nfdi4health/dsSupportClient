#' @title Executes ds.summary function for variables in a data.frame
#' @description Computes summary statistics, including standard deviation, for all numeric or integer variables of a server-side data.frame, for each connected study.
#' @details For each study in datasources, the function retrieves column names via ds.colnames, determines each variable's class via ds.class, and for numeric or integer variables with at least one non-missing value (checked via ds.numNA and ds.length) calls ds.summary and ds.var to build a per-variable summary table with an added standard deviation column. Server functions called: ds.colnames, ds.class, ds.numNA, ds.length, ds.summary, and ds.var (all from dsBaseClient).
#' @param df Character string giving the name of the data.frame on the server (default "D"), not a local R data.frame object.
#' @param datasources A list of DSConnection-class objects, typically obtained from DSI::datashield.login(); if NULL, the function uses DSI::datashield.connections_find() to locate the default connections.
#' @param save Logical; if TRUE, saves each study's summary table as a CSV file named '<study>_summary.csv' in the current working directory. Default is FALSE.
#' @return Returns a named list, one element per study (named using each connection's name), where each element is a data.frame with one row per numeric/integer variable containing the ds.summary statistics plus a standard deviation column; if save is TRUE, a CSV file per study is also written to the current working directory as a side effect.
#' @author Sofia Siampani (Max-Delbrueck-Center, Berlin), Florian Schwarz (German Institute of Human Nutrition, Potsdam-Rehbruecke)
#' @import methods
#' @importFrom utils write.csv
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
#' ds.summaryVars(df = "D", datasources = connections, save = FALSE)
#' 
#' datashield.logout(connections)
#' }
#' @export

ds.summaryVars<- function(df = "D", datasources = NULL, save = FALSE){


  if(is.null(datasources)){
    datasources <- DSI::datashield.connections_find()
  }


  if(!(is.list(datasources) && all(unlist(lapply(datasources, function(d) {methods::is(d,"DSConnection")}))))){
    stop("The 'datasources' were expected to be a list of DSConnection-class objects", call.=FALSE)
  }


  #Check whether object are present in all datasources: waiting for function to be exported in dsBaseClient, otherwise R CMD Check failure
  #defined <- dsBaseClient:::isDefined(datasources, df)



  summary <- list()

  for (p in 1:length(datasources)){


    y <- data.frame()
    study <- datasources[p]
    colNames <- ds.colnames(df,study)
    for (i in colNames[[1]]){

      variable <- paste0(df,"$",i)
      a <- dsBaseClient::ds.class(variable, study)

      if ((a == "numeric" || a == "integer") && dsBaseClient::ds.numNA(variable, study) < dsBaseClient::ds.length(variable, datasources=study)[[1]]){
        a <- unlist(dsBaseClient::ds.summary(variable, datasources=study))
        y[i, c(names(a),"Standard deviation")] <- c(a, sqrt(dsBaseClient::ds.var(variable, datasources=study)[["Variance.by.Study"]][1]))

      }
    }

    summary[[as.name(paste0(datasources[[p]]@name))]] <- y
    if (save == TRUE){
      utils::write.csv(as.matrix(y), paste0(datasources[[p]]@name,"_summary.csv"), row.names = TRUE)
      print(paste0("The summary file ", paste0("'",datasources[[p]]@name,"_summary.csv'")," has been saved at ",getwd(), "."))
    }
  }

  return(summary)
}
