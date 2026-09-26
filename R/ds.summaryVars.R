#'
#' @title Executes ds.summary function for variables in a data.frame
#' @description The function executes the ds.summary function for all numeric or integer variables of a data.frame.
#' @details ds.summaryVars analyses the classes of variables of a server-side data.frame and executes the ds.summary
#' function for all variables which are of type 'numeric' or 'integer'. Additionally, it also provides the standard deviation
#' for those variables.
#' @param datasources A list of \code{\link{DSConnection-class}} objects obtained after login.
#' If the \code{datasources} argument is not specified the default set of connections will be
#' used: see \code{\link{datashield.connections_default}}.
#' @param df A data.frame on the server-side.
#' @param save if TRUE, the output is saved in the working directory as a csv fil. Default is FALSE.
#' It runs the datashield function ds.summary()and calculates the standard deviation in all numeric and integer variables of each OpalConnection
#' @return a list with the summary of each variable
#' @author Sofia Siampani (Max-Delbrueck-Center, Berlin), Florian Schwarz (German Institute of Human Nutrition, Potsdam-Rehbruecke)
#' @importFrom utils write.csv
#' @import methods
#' @examples
#' \dontrun{
#'
#' # Version 1.0
#' # Connecting to Opal Servers
#'
#'
#'
#' # loading necessary packages
#' require("DSI")
#' require("DSOpal")
#' require("dsBaseClient")
#' require("dsSupportClient")
#'
#' builder <- DSI::newDSLoginBuilder()
#' builder$append(server = "study1",
#'                url = "http://192.168.56.100:8080/",
#'                user = "administrator", password = "datashield_test&",
#'                table = "CNSIM.CNSIM1", driver = "OpalDriver")
#' builder$append(server = "study2",
#'                url = "http://192.168.56.100:8080/",
#'                user = "administrator", password = "datashield_test&",
#'                table = "CNSIM.CNSIM2", driver = "OpalDriver")
#' builder$append(server = "study3",
#'                url = "http://192.168.56.100:8080/",
#'                user = "administrator", password = "datashield_test&",
#'                table = "CNSIM.CNSIM3", driver = "OpalDriver")
#'
#' logindata <- builder$build()
#'
#' # Log onto the remote Opal training servers
#' connections <- DSI::datashield.login(logins = logindata, assign = TRUE, symbol = "D")
#'
#' # Retrieving information on variable classes in the specified data.frame
#' ds.summaryVars(df = "D", save = TRUE)
#'
#' # Clear the Datashield R sessions and logout
#' datashield.logout(connections)
#'
#' }
#' @export
#'

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
