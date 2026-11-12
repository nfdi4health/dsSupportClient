#' @title Builds a per-study summary table for numeric variables
#' @description Computes summary statistics (via ds.summary and ds.var) for all numeric or integer variables of a server-side data.frame, separately for each connected study, and optionally saves each study's table to a CSV file.
#' @details ds.summaryVars loops over each connected study separately: for each one it retrieves the column names of the server-side data.frame named by df via dsBaseClient::ds.colnames, determines each variable's class via dsBaseClient::ds.class, and for numeric or integer variables with at least one non-missing value (checked via dsBaseClient::ds.numNA and dsBaseClient::ds.length) it calls dsBaseClient::ds.summary and dsBaseClient::ds.var to build a per-study data.frame augmented with the standard deviation. Server function called: ds.summary and ds.var (via dsBaseClient).
#' @param df A character string giving the name of a data.frame object on the server-side (as assigned via datashield.assign); defaults to "D".
#' @param datasources A list of \code{\link[DSI:DSConnection-class]{DSConnection-class}} objects obtained after login.
#' If the \code{datasources} argument is not specified the default set of connections will be
#' used: see \code{\link[DSI]{datashield.connections_default}}.
#' @param save Logical; if TRUE, the per-study summary table is additionally written to a CSV file named '<study>_summary.csv' in the current working directory via utils::write.csv. Default is FALSE.
#' @return A named list with one element per connected study (named by the study/connection name), each a data.frame of summary statistics (one row per qualifying numeric/integer variable) augmented with a standard deviation column; if save is TRUE, each study's data.frame is additionally written as a CSV file as a side effect.
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
#' ds.summaryVars(df = "D", save = TRUE)
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
