#' @title Robust Standard Errors HC1
#' @description Fits a gaussian GLM on server-side data via ds.glm and computes heteroskedasticity-consistent (HC1) robust standard errors, confidence intervals, z-statistics and p-values for its coefficients.
#' @details This function chains multiple DataSHIELD assign/aggregate calls (ds.glm, ds.dataFrame, ds.completeCases, ds.asDataMatrix, ds.matrixMult, ds.matrixInvert, ds.matrixDiag, ds.make, ds.meanSdGp, among others) to reconstruct a sandwich-type HC1 variance-covariance matrix without transferring individual-level data off the servers. With type = "split" the whole pipeline (including a separate ds.glm fit) is repeated once per connection in datasources, giving one robust-SE table per study; with type = "combine" a single pooled ds.glm fit across all datasources is used and the cross-product matrices needed for the sandwich estimator are accumulated across studies before being combined locally in R. No single server function implements the robust-SE calculation itself; it is assembled client-side from many elementary server-side aggregate/assign operations.
#' @param formula A character string giving the model formula, e.g. "Age ~ Sex + Weight"; it is parsed by splitting on '~' and '+' to extract the outcome and covariate names, so it must be a string rather than an R formula object.
#' @param datasources A list of DSConnection-class objects, as returned by DSI::datashield.login, indicating which server-side data sources to use; there is no default, so this must always be supplied explicitly.
#' @param type A character string, either "split" (fit the model and compute robust SEs separately within each study, returning a list of tables) or "combine" (fit one pooled model across all datasources and compute a single combined robust-SE table); defaults to "split".
#' @param data A character string giving the name of the data frame on the server (in each connection's R session) that contains the variables referenced in formula.
#' @return If type = "split", a named list (one element per study, named after each connection) of data.frames with columns Beta, Robust SE, Robust Z, Robust P, Robust LCI and Robust UCI, one row per model term. If type = "combine", a single such data.frame pooled across all studies with an additional Nvalid column; a message reporting elapsed computation time is also printed as a side effect. No individual-level data is returned to the client; only these aggregated coefficient-level statistics come back from the server.
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
#' ds.rse(formula = "LAB_HDL ~ PM_BMI_CONTINUOUS + GENDER",
#'        datasources = connections,
#'        type = "combine",
#'        data = "D")
#' 
#' datashield.logout(connections)
#' }
#' @export
ds.rse <- function(formula, datasources, type = "split", data) {


  if (type =="split"){

    allStudies <- list()

    for (p in 1:length(datasources)){

      modDS1 <- ds.glm(formula = formula,
                       data=data,
                       family='gaussian',
                       datasources = datasources[p])

      numVar <- length(rownames(modDS1$coefficients))

      variables <- sapply(strsplit(formula, split = "[~+]"), function(x) gsub(" ","",as.character(x)))

      IPD_list<- list()

      for (i in 1:numVar){

        IPD_list[paste0(rownames(modDS1$coefficients))[i]] <- modDS1[["coefficients"]][i]

      }

      ds.cbind(paste0(data,"$", variables),newobj="vars",datasources = datasources[p])# df only with vars of interest


      ds.completeCases("vars", newobj="vars.complete", datasources = datasources[p]) # df wout missings


      newFormula <- list()

      for (i in 1:numVar){

        if(i==1){

          newFormula[i]<-IPD_list[i]
        }

        else if(ds.class(paste0("vars.complete$", gsub('[0-9]+', '', names(IPD_list)[i])), datasources = datasources[p])=="factor"){

          ds.asInteger(paste0("vars.complete$",gsub('[0-9]+', '', names(IPD_list)[i])),
                       paste0(gsub('[0-9]+', '', names(IPD_list)[i]),".int"),datasources=datasources[p])

          newFormula[i]<- paste0("+(",IPD_list[i],"*",(paste0(gsub('[0-9]+', '', names(IPD_list)[i]),".int")),")")
        }

        else {

            newFormula[i]<- paste0("+(",IPD_list[i],"*",(paste0("vars.complete$",gsub('[0-9]+', '', names(IPD_list)[i]))),")")
        }

      }

      newFormula2 <- (paste(newFormula, collapse = ""))

      ds.make(toAssign = newFormula2,

              newobj = "predicted.values.IPD",

              datasources = datasources[p]) #modify accord.to incl. studies


      ds.make(toAssign = paste0("vars.complete$",variables[1], " - predicted.values.IPD"),

              newobj = "residuals.IPD",

              datasources = datasources[p]) #modify accord.to incl. studies

      #N complete cases
      n_list <- ds.dim('vars.complete', datasources = datasources[p]) # list with number of observations (participants) and number of variables
      n <- n_list[[1]][[1]] # this exctracts only the number of participants (length of dataset with complete cases)

      # creating diagonal matrix
      ds.rep(1, times = n, source.x1 = 'c', source.times = 'c', datasources = datasources[p], newobj = 'intercept') #times = complete cases from all studies

      ds.dataFrame(c('intercept',
                     paste0("vars.complete$",variables[-1] )),
                   newobj= 'Xmat' ,
                  stringsAsFactors = FALSE,
                   datasources = datasources[p])

      ds.asDataMatrix(x.name='Xmat', newobj='Xmat', datasources = datasources[p])

      #ds.dim('Xmat', datasources = datasources[p])

      # transposing matrix
      ds.matrixTranspose(M1='Xmat', newobj='tXmat', datasources = datasources[p])

      ds.matrixMult(M1='tXmat', M2='Xmat', newobj='XTX', datasources=datasources[p])
      #ds.dim('XTX', datasources=datasources[p])

      ds.matrixInvert(M1='XTX', newobj='XTXinv', datasources = datasources[p])
      #ds.dim('XTXinv', datasources=datasources[p])


      ds.make(toAssign = paste0("(",n, "/(", n-3,'))*(residuals.IPD^2)'), newobj='hc1', datasources=datasources[p])


      ds.matrixDiag(x1='hc1', aim = "serverside.vector.2.matrix", nrows.scalar = n,  # n is for the length of the complete cases dataset
                    newobj='hc1diagN', datasources = datasources[p])
      #ds.dim('hc2diagN', datasources=datasources[p])

      ds.matrixMult(M1='tXmat', M2='hc1diagN', newobj='mm1', datasources=datasources[p])
      #ds.dim('mm1', datasources=datasources[p])

      ds.matrixMult(M1='mm1', M2='Xmat', newobj='mm2', datasources=datasources[p])
      #ds.dim('mm2', datasources=datasources[p])

      ds.matrixMult(M1='XTXinv', M2='mm2', newobj='mm3', datasources = datasources[p])
      #ds.dim('mm3', datasources=datasources[p])

      ds.matrixMult(M1='mm3', M2='XTXinv', newobj='mm4', datasources = datasources[p])
      #ds.dim('mm4', datasources=datasources[p])

      # calculate hc2 standard errors
      ds.matrixDiag(x1='mm4', aim='serverside.matrix.2.vector', newobj='hc1diagVCE', datasources = datasources[p])
      ds.length('hc1diagVCE', datasources=datasources[p])

      ds.rep(x1='hc1diagVCE', each=100, source.x1='s', source.each='c', newobj='hc1diagVCErep',
             datasources = datasources[p])

      ds.rep(x1=c(1:numVar), each=100, source.x1='c', source.each='c', newobj='variable',  # x1= number of covariates + intercept
             datasources = datasources[p])

      mean <- ds.meanSdGp(x = 'hc1diagVCErep', y = 'variable', datasources = datasources[p])

      robust_SE <- sqrt(mean$Mean_gp_study[,'COMBINE']) # WE GET THE ROBUST STANDARD ERRORS


      # Obtain the new 95% confidence intervals
      beta <- unlist(IPD_list)
      robust_LCI <- beta - (robust_SE*qnorm(0.975))
      robust_UCI <- beta + (robust_SE*qnorm(0.975))

      # Obtain test statistic z (= beta/SE)
      robust_z <- beta/robust_SE

      # Obtain new p value P = exp(−0.717×z − 0.416×z2)
      robust_p <- 2*pnorm(q=abs(robust_z),lower.tail=FALSE)

      # Put it all together (dataframe with all measures, for all variables and the intercept)

      IPD_robust <- data.frame(unlist(beta),unlist(robust_SE),unlist(robust_z),unlist(robust_p),unlist(robust_LCI),unlist(robust_UCI))

      rownames(IPD_robust)<- rownames(modDS1$coefficients)
      colnames(IPD_robust)<- c("Beta", "Robust SE", "Robust Z", "Robust P", "Robust LCI", "Robust UCI")
      allStudies[[datasources[[p]]@name]] <- IPD_robust

    }
    return(allStudies)
  }

  if (type=="combine"){
    start.time <- proc.time()[3]

    variables <- sapply(strsplit(formula, split = "[~+]"), function(x) gsub(" ","",as.character(x)))
    numVar <- length(variables)

    #converting categorical to numeric

    vector <- c()
    for (i in 1:numVar){
      if (sum(ds.class(paste0(data, "$", variables[i]), datasources = datasources)=="factor") == length(datasources)){
        ds.asNumeric(paste0(data, "$", variables[i]), datasources = datasources, newobj=variables[i])
        vector[i] <-  variables[i]
      }
      else{
        vector[i]<- paste0(data, "$", variables[i])
      }
    }


    ds.dataFrame(vector, completeCases = TRUE, newobj="Dcompl", datasources = datasources, stringsAsFactors = FALSE)

    mod <- ds.glm(formula = formula, data=data, family='gaussian', datasources = datasources)

    ds.make(toAssign = paste0(mod$coefficients[,1][1],
                              paste0("+((",mod$coefficients[,1][-1],")*Dcompl$",variables[-1],")", collapse=""  ) ),
            newobj='fv',
            datasources = datasources)

    ds.make(toAssign = paste0("Dcompl$",variables[1],'-fv'),
            newobj = 'resid',
            datasources = datasources)

    for (i in 1:length(datasources)){

      dim <- print(ds.dim('Dcompl', datasources = datasources[i],type = "split")[[1]][1])
      number <- (dim/(dim-numVar))
      ds.make(toAssign = paste0(number,'*(resid * resid)'), newobj='hc1omega', datasources=datasources[i])

    }


    variables_expansion <- expand.grid(variables,
                                       variables)

    variables_expansion$Var1 <- as.character(variables_expansion$Var1)
    variables_expansion$Var2 <- as.character(variables_expansion$Var2)

    variable_combinations_unique <- variables_expansion[!duplicated(t(apply(variables_expansion, 1, sort))),]
    variable_combinations_unique$ID <- 1:length(variable_combinations_unique$Var1)
    variable_combinations_unique <- variable_combinations_unique[,c(3,1,2)]

    for (i in 1:length(variable_combinations_unique$ID)){

      if (variable_combinations_unique$Var1[i] == variables[1] && variable_combinations_unique$Var2[i] == variables[1]){

        #### XTX
        variable_combinations_unique$XTXValue[i] <- ds.dim("Dcompl", datasources = datasources)[[length(datasources)+1]][1]

        #### XTOmegaX
        ds.dataFrame(rep(paste0("hc1omega"), 10), newobj = "hc1omega_df", stringsAsFactors = FALSE, datasources = datasources)
        ds.rowColCalc(x="hc1omega_df", operation='colSums', newobj="hc1omega_sum", datasources = datasources)
        var_mean <- ds.mean("hc1omega_sum", datasources = datasources)
        variable_combinations_unique$XTOmegaXValue[i] <- sum(var_mean[[1]][,1])

      } else if ((variable_combinations_unique$Var1[i] == variables[1]) | (variable_combinations_unique$Var2[i] == variables[1])){

        #### XTX
        vars_pair <- c(variable_combinations_unique$Var1[i], variable_combinations_unique$Var2[i])
        var_for_comp <- vars_pair[!(vars_pair %in% variables[1])]
        ds.dataFrame(rep(paste0("Dcompl$", var_for_comp), 10), newobj = paste0(var_for_comp,"_df"), stringsAsFactors = FALSE, datasources = datasources)
        ds.rowColCalc(x=paste0(var_for_comp,"_df"), operation='colSums', newobj=paste0(var_for_comp,"_sum"), datasources = datasources)
        var_mean <- ds.mean(paste0(var_for_comp,"_sum"), datasources = datasources)
        variable_combinations_unique$XTXValue[i] <- sum(var_mean[[1]][,1])

        #### XTOmegaX
        ds.make(toAssign = paste0('Dcompl$', var_for_comp,'*hc1omega'), newobj=paste0(var_for_comp,"_Xhc1"), datasources = datasources)
        ds.dataFrame(rep(paste0(var_for_comp,"_Xhc1"), 10), newobj = paste0(var_for_comp,"_Xhc1_df"), stringsAsFactors = FALSE, datasources = datasources)
        ds.rowColCalc(x=paste0(var_for_comp,"_Xhc1_df"), operation='colSums', newobj=paste0(var_for_comp,"_hc1sum"), datasources = datasources)
        var_mean <- ds.mean(paste0(var_for_comp,"_hc1sum"), datasources = datasources)
        variable_combinations_unique$XTOmegaXValue[i] <- sum(var_mean[[1]][,1])


      } else if (!(variable_combinations_unique$Var1[i] == variables[1]) && !(variable_combinations_unique$Var2[i] == variables[1])){

        #### XTX
        ds.make(toAssign = paste0("Dcompl$",variable_combinations_unique$Var1[i], "*Dcompl$", variable_combinations_unique$Var2[i]), newobj=paste0(variable_combinations_unique$Var1[i],"_x_", variable_combinations_unique$Var2[i]), datasources = datasources)
        ds.dataFrame(rep(paste0(variable_combinations_unique$Var1[i],"_x_", variable_combinations_unique$Var2[i]), 10), newobj = paste0(variable_combinations_unique$Var1[i],"_x_", variable_combinations_unique$Var2[i], "_df"), stringsAsFactors = FALSE, datasources = datasources)
        ds.rowColCalc(x=paste0(variable_combinations_unique$Var1[i],"_x_", variable_combinations_unique$Var2[i], "_df"), operation='colSums', newobj=paste0(variable_combinations_unique$Var1[i],"_x_", variable_combinations_unique$Var2[i], "_sum"), datasources = datasources)
        var_mean <- ds.mean(paste0(variable_combinations_unique$Var1[i],"_x_", variable_combinations_unique$Var2[i], "_sum"), datasources = datasources)
        variable_combinations_unique$XTXValue[i] <- sum(var_mean[[1]][,1])

        ####XTOmegaX
        ds.make(toAssign = paste0("Dcompl$",variable_combinations_unique$Var1[i], "*Dcompl$", variable_combinations_unique$Var2[i],"*hc1omega"), newobj=paste0(variable_combinations_unique$Var1[i],"_x_", variable_combinations_unique$Var2[i], "_Xhc1"), datasources = datasources)
        ds.dataFrame(rep(paste0(variable_combinations_unique$Var1[i],"_x_", variable_combinations_unique$Var2[i],"_Xhc1"), 10), newobj = paste0(variable_combinations_unique$Var1[i],"_x_", variable_combinations_unique$Var2[i], "_Xhc1df"), stringsAsFactors = FALSE, datasources = datasources)
        ds.rowColCalc(x=paste0(variable_combinations_unique$Var1[i],"_x_", variable_combinations_unique$Var2[i], "_Xhc1df"), operation='colSums', newobj=paste0(variable_combinations_unique$Var1[i],"_x_", variable_combinations_unique$Var2[i], "_Xhc1sum"), datasources = datasources)
        var_mean <- ds.mean(paste0(variable_combinations_unique$Var1[i],"_x_", variable_combinations_unique$Var2[i], "_Xhc1sum"), datasources = datasources)
        variable_combinations_unique$XTOmegaXValue[i] <- sum(var_mean[[1]][,1])

      }

    }

    for (z in 1:length(variable_combinations_unique$Var1)){
      variable_combinations_unique$Cell[z] <- list(sort(c(variable_combinations_unique$Var1[z], variable_combinations_unique$Var2[z])))
    }


    for (k in 1:length(variables_expansion$Var1)){
      variables_expansion$Cell[k] <- list(sort(c(variables_expansion$Var1[k], variables_expansion$Var2[k])))
    }

    XTX_Match <- dplyr::left_join(variables_expansion, variable_combinations_unique, by = "Cell")

    XTX <- matrix(XTX_Match$XTXValue, nrow=numVar, ncol=numVar)
    XTOmegaX <- matrix(XTX_Match$XTOmegaXValue, nrow=numVar, ncol=numVar)


    #### end of change for TXOmegaX

    vce_hc1 <- solve(XTX) %*% XTOmegaX %*% solve(XTX)
    robust_SE <- sqrt(diag(vce_hc1))

    # Obtain the new 95% confidence intervals
    beta <- mod$coefficients[,1]
    robust_LCI <- beta - (robust_SE*qnorm(0.975))
    robust_UCI <- beta + (robust_SE*qnorm(0.975))

    # Obtain test statistic z (= beta/SE)
    robust_z <- beta/robust_SE

    # Obtain new p value P = exp(−0.717×z − 0.416×z2)
    robust_p <- 2*pnorm(q=abs(robust_z),lower.tail=FALSE)

    robust_table <- data.frame(unlist(beta),unlist(robust_SE),unlist(robust_z),unlist(robust_p),unlist(robust_LCI),unlist(robust_UCI), rep(mod$Nvalid, numVar))

    colnames(robust_table)<- c("Beta", "Robust SE", "Robust Z", "Robust P", "Robust LCI", "Robust UCI", "Nvalid")

    totalTimeMins2 <- (proc.time()[3] - start.time) / 60
    message("The entire analysis took ", round(totalTimeMins2, 2), " minutes")

    return(robust_table)
  }
}
