#' @title Table function for categorical data
#' @description Builds a table of counts (with NAs) for every factor variable in a server-side data frame, across all connected studies.
#' @details Uses ds.class (via an internal wrapper) to identify factor variables in the server-side data frame, then for each one calls ds.numNA and ds.length to skip variables that are entirely missing, and finally calls ds.table with useNA = "always" to tabulate. Server function called: ds.table (from dsBaseClient), with supporting calls to ds.class, ds.numNA, and ds.length. Results for each variable are combined into a single data.frame using dplyr::bind_rows.
#' @param df String giving the name of the server-side data frame or table (as assigned during login/assign, e.g. "D") whose factor variables will be tabulated; defaults to "D".
#' @param datasources A list of DSConnection-class objects, as returned by DSI::datashield.login(); if NULL (the default), the function uses DSI::datashield.connections_find() to locate existing connections.
#' @return Returns a data.frame (built with dplyr::bind_rows) with one row block per categorical variable, containing the cross-tabulated counts (including NA counts) across studies as computed by ds.table; variables that are entirely missing across all studies are silently omitted from the result.
#' @import dplyr
#' @import dsBaseClient
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
#' ds.tableBatch(df = "D", datasources = connections)
#' 
#' datashield.logout(connections)
#' }
#' @export

ds.tableBatch <- function(df = "D", datasources = NULL){


  if(is.null(datasources)){
    datasources <- DSI::datashield.connections_find()
  }


  if(!(is.list(datasources) && all(unlist(lapply(datasources, function(d) {methods::is(d,"DSConnection")}))))){
    stop("The 'datasources' were expected to be a list of DSConnection-class objects", call.=FALSE)
  }


  classes <- ds.wrapper(df = df, ds_function = ds.class, datasources = datasources)

  classes <- classes %>%
    dplyr::filter_all(all_vars("factor"))

  variables <- rownames(classes)

  y = data.frame()

  for (i in variables){

    var <- paste0(df,"$",i)

    numNA <- dsBaseClient::ds.numNA(var, datasources = datasources)

    length <- dsBaseClient::ds.length(var, datasources = datasources)

    length <- length[length(length)]


    a <- 0

    for (k in 1:length(numNA)){

      a <- a + numNA[[k]]

    }

    if (length == a) {
      next
    }

    b <- dsBaseClient::ds.table(var, datasources = datasources, useNA = "always")

    b[["output.list"]][["TABLE_rvar.by.study_row.props"]] <- NULL

    b <- as.data.frame(b[1])

    rownames(b) <- paste(i,rownames(b), sep="_")

    y <- dplyr::bind_rows(y,b)

  }

  return(y)

}





