#'
#' @title Table function for categorical data
#' @param datasources An opal connection
#' @param df specifies the  df that was assigned in the login, default is "D"
#' @return runs the datashield function ds.table on all categorical variables of all studies and outputs a table with the outcome
#' @export
#' @import dplyr
#' @import dsBaseClient
#'

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





