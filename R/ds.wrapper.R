#'
#' @title Wrapper function for DataSHIELD analysts
#' @description The function summarises the outcome of variable-level aggregate DataSHIELD functions.
#' @details ds.wrapper wraps around DataSHIELD functions and creates summaries for all variables in a data.frame, providing an improved overview for the DataSHIELD analyst.
#' @param ds_function The aggregate DataSHIELD function you want to run to receive information (e.g. ds.class, ds.numNA).
#' @param datasources A list of \code{\link{DSConnection-class}} objects obtained after login.
#' If the \code{datasources} argument is not specified the default set of connections will be
#' used: see \code{\link{datashield.connections_default}}.
#' @param df A data.frame on the server-side. Default is "D".
#' @param save If TRUE, the output is saved in the working directory as a csv file. Default is FALSE
#' @return A table with the output of the function. If more than one study is connected, they are joined in one table.
#' @author Sofia Siampani (Max-Delbrueck-Center, Berlin), Florian Schwarz (German Institute of Human Nutrition, Potsdam-Rehbruecke)
#' @import dplyr
#' @import purrr
#' @importFrom utils write.csv
#' @examples
#' \dontrun{
#'
#'
#' # Version 1.0
#' # Connecting to Opal Servers
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
#' ds.wrapper(df = "D", ds_function = ds.class)
#'
#'
#' # Retrieving information on how many NAs are present in each variable in the specified data.frame
#' ds.wrapper(df = "D", ds_function = ds.numNA)
#'
#'
#' # Clear the Datashield R sessions and logout
#' datashield.logout(connections)
#'
#' }
#' @export
#'


ds.wrapper <- function(df = "D", ds_function = NULL, datasources = NULL,  save = FALSE){


  if(is.null(datasources)){
    datasources <- DSI::datashield.connections_find()
  }


  if(!(is.list(datasources) && all(unlist(lapply(datasources, function(d) {methods::is(d,"DSConnection")}))))){
    stop("The 'datasources' were expected to be a list of DSConnection-class objects", call.=FALSE)
  }


  if(is.null(ds_function)){
    stop("You need to specify an aggregate DataSHIELD function.")
  }


  #Check whether object are present in all datasources: waiting for function to be exported in dsBaseClient, otherwise R CMD Check failure
  #defined <- dsBaseClient:::isDefined(datasources, df)


  summary <- data.frame()
  join    <- list()

  for (p in 1:length(datasources)){

    colNames <- paste0(datasources[[p]]@name,".",(strsplit(as.character(substitute(ds_function)), ".",fixed =TRUE))[[1]][2])


    y <- data.frame()


    for(i in dsBaseClient::ds.colnames(df,datasources = datasources[p])[[1]]) {

      variable <- paste0(df,"$",i)
      y[i,colNames] <- ds_function(variable, datasources= datasources[p])[1]


    }
    y$rn <- rownames(y)
    join[[p]] <- y

  }


  summary <- purrr::reduce(join, full_join, by = "rn")


  rownames(summary) <- summary$rn
  summary$rn <- NULL


  if (save == TRUE){
    utils::write.csv(summary, file = paste0(as.character(substitute(ds_function)),"_overview.csv"), row.names = TRUE)
    print(paste0("The overview file ", paste0("'",as.character(substitute(ds_function)),"_overview.csv'")," has been saved at ",getwd(), "."))
  }

  return(summary)
}

