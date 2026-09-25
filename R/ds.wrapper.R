#' @title Summarise a variable-level DataSHIELD function across variables
#' @description Runs a variable-level DataSHIELD aggregate function (e.g. ds.class, ds.numNA) over every column of a server-side data.frame and collates the results into one table.
#' @details For each connected study, the function retrieves the column names of the server-side data.frame via dsBaseClient::ds.colnames, then calls ds_function once per variable (as df$variable) at that study only. Per-study results are stored as data.frames keyed by rowname and combined across studies with purrr::reduce(join, full_join, by = "rn"). Column names in the output are built from the study name and a fragment of the deparsed ds_function name (split on "."), so ds_function must be supplied as an unquoted function reference such as ds.class rather than a string. This function does not itself call one fixed server-side function; it dispatches whichever DataSHIELD aggregate function is passed in via ds_function, and that function issues its own server-side call(s).
#' @param df String naming the server-side data.frame to summarise (must exist on each connected server); defaults to "D".
#' @param ds_function An unquoted DataSHIELD client aggregate function reference (e.g. ds.class, ds.numNA) applied to each variable of df; its deparsed name is parsed internally, so it cannot be passed as a character string.
#' @param datasources A list of DSConnection-class objects obtained after login. If not specified, the default set of connections is used, as returned by datashield.connections_find.
#' @param save Logical; if TRUE the resulting summary table is written to a CSV file in the current working directory. Defaults to FALSE.
#' @return Returns a data.frame to the caller, with one row per variable in df and one column per connected study (columns named from the study and the parsed ds_function name), containing the per-variable, per-study output of ds_function; if save = TRUE the same table is also written as a CSV file in the current working directory. No additional disclosure control is applied by this function itself, since it only combines values already returned by the (disclosure-controlled) ds_function calls.
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

