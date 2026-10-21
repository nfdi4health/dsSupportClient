#' @title Table function for categorical data
#' @description Builds a combined frequency table for every categorical (factor) variable in a server-side data frame, pooling results across all connected studies. It skips variables that are entirely missing (NA) in every study.
#' @details For each factor variable identified via ds.wrapper and ds.class, this function calls dsBaseClient::ds.numNA and dsBaseClient::ds.length to check for all-missing variables, then builds a frequency table with dsBaseClient::ds.table (using useNA = "always"), discarding the row-proportions component. Server function called: `ds.table`. Results for all variables are row-bound into a single data.frame with dplyr::bind_rows.
#' @param df Character string giving the name of the data frame object already assigned on the server(s) (as created at login), not a local R data frame; defaults to "D".
#' @param datasources A list of DSConnection-class objects, as produced by DSI::datashield.login(); if NULL (the default) the connections are obtained via DSI::datashield.connections_find().
#' @return Returns a data.frame to the caller, combining frequency tables (one row block per retained categorical variable, row names prefixed with the variable name) pooled across all connected studies; variables that are entirely missing in every study are omitted, and no disclosure control is applied locally since the underlying values come from the server-side `ds.table` aggregate.
#' @import dplyr
#' @import dsBaseClient
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





