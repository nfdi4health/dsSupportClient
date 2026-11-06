#' @title Table function for categorical data
#' @description Builds frequency tables for every factor variable in a server-side data frame, across one or more connected studies. Variables that are entirely missing in every study are skipped.
#' @details The function first determines variable classes with a wrapper around ds.class, keeps those classified as "factor", then for each one calls dsBaseClient::ds.numNA and dsBaseClient::ds.length to check for completeness before tabulating. Server function called: ds.table, run with useNA = "always" for each categorical variable. Results from each variable are combined locally into a single data frame with dplyr::bind_rows.
#' @param df specifies the  df that was assigned in the login, default is "D"
#' @param datasources A list of DSConnection-class objects, typically produced by DSI::datashield.login, indicating the studies to query. If NULL, the function uses DSI::datashield.connections_find() to find the currently open connections.
#' @return A data frame combining, for each categorical variable found (with row names prefixed by the variable name), the per-study and pooled frequency counts returned by ds.table; variables with only missing values across all studies are omitted. No disclosure-control filtering is applied beyond what ds.table itself enforces server-side.
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


  classes <- ds.wrapper(df = df, ds_function = "ds.class", datasources = datasources)

  classes <- classes %>%
    dplyr::filter_all(all_vars(.=="factor"))

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





