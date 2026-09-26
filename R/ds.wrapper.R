#' @title Summarise a variable-level DataSHIELD function across variables
#' @description Runs a variable-level DataSHIELD aggregate function (e.g. ds.class, ds.numNA) over every column of a server-side data.frame and collates the results into one table.
#' @details The function retrieves the column names of the server-side data.frame via dsBaseClient::ds.colnames for each connected study, then calls the supplied ds_function once per variable per study, building one data.frame of results per study. These per-study tables are then combined by row name using dplyr::full_join inside purrr::reduce. There is no single fixed server function called: ds.wrapper dispatches whichever DataSHIELD client aggregate function is passed via ds_function, and that function issues its own server-side call(s).
#' @param df String naming the server-side data.frame to summarise (must exist on each connected server); defaults to "D".
#' @param ds_function The DataSHIELD client aggregate function to apply to each variable of df (e.g. ds.class, ds.numNA); must be supplied as a bare function name/object (not a quoted string), since its name is extracted internally via substitute() to build column and file names.
#' @param datasources A list of DSConnection-class objects obtained after login. If not specified, the default set of connections is used, as returned by datashield.connections_find.
#' @param save Logical; if TRUE the resulting summary table is written to a CSV file in the current working directory. Defaults to FALSE.
#' @return Returns a data.frame to the caller, with one row per variable in df (row names set to variable names) and one column per connected study (named "<study name>.<function suffix>"), holding the per-variable, per-study output of ds_function; if save = TRUE this same table is also written as a CSV file named "<ds_function>_overview.csv" in the current working directory as a side effect. Because the table only assembles values already returned by the (disclosure-controlled) ds_function calls, ds.wrapper itself performs no additional disclosure filtering.
#' @author Sofia Siampani (Max-Delbrueck-Center, Berlin), Florian Schwarz (German Institute of Human Nutrition, Potsdam-Rehbruecke)
#' @import dplyr
#' @import purrr
#' @importFrom utils write.csv
#' @examples
#' \dontrun{
#' require('DSI')
#' require('DSOpal')
#' require('dsSupportClient')
#'
#'
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
#' # Retrieving information on variable classes in the specified data.frame
#' ds.wrapper(df = "D", ds_function = ds.class)
#'
#' # Retrieving information on how many NAs are present in each variable
#' ds.wrapper(df = "D", ds_function = ds.numNA)
#'
#' datashield.logout(connections)
#' }
#' @export


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

