#' @name pairwised
#' @title pairing up observations of variables
#' @description
#' Function for pairing up observations in panel data setting according to built in or user specified formula.h
#' @usage
#' pairwised( data, measure = c("sum", "sumabs", "absdiff", "diffabs", "prod",
#'            "prodabs", "absprod", "abslogdiff", "abslogsum", "logdiffabs",
#'            "logsumabs", "if1", "if2", "custom"), exp.multiplier = 0,
#'            multiplier = 1, no.messages = FALSE,
#'            save.as = NULL, sep=";", dec="," )
#' @param data a data.frame, list or path to the input file in csv, xlsx or xls format.
#' @param exp.multiplier default value set to 0. Changes the decimal mark in all the observations in the input file. Useful in cases when, for example, natural logarithm must be taken
#'        from a number that is very close to 0.
#' @param multiplier default value set 1. Multiplies all the observations in the input file.
#' @param measure operation that should be applied to every pair of observations. Built in options contains (x denotes first observation and y denotes the second observation):
#' \itemize{
#'        \item "sum": x+y,
#'        \item "sumabs": |x|+|y|,
#'        \item "absdiff": |x-y|,
#'        \item "diffabs": |x|+|y|,
#'        \item "prod": x*y,
#'        \item "prodabs": |x|*|y|,
#'        \item "absprod": |x*y|,
#'        \item "abslogdiff": |ln(xC7y)|,
#'        \item "abslogsum": |ln(x*y)|,
#'        \item "logdiffabs": ln(|x|C7|y|),
#'        \item "logsumabs": ln(|x|*|y|),
#'        \item "if1": (x+y=1)->1 and (x+y<>1)->0,
#'        \item "if2": (x+y=2)->1 and (x+y<>2)->0.
#'        \item Moreover, option "custom" allows the user to specify any function of x and y.
#'}
#' @param save.as in this argument, user can specify: path for the destination folder, name of the file and desired format. Argument is given in the following form: "path/name.format". For example: "C:/Myfiles/Rfiles/pairwised_data.csv". If the argument is not specified default is set as "current R directory/name_of_the_input_file_paiwise_result.format_of_input_file". User can specify csv, xls and xlsx as the output format. If user does not specify the file format, the format will be the same as of the input format or xlsx in the case of data.frame/list input. If argument is equal to "none", output file is not generated.
#' @param no.messages efault value is FALSE. If FALSE, the package will show messages: about finishing the calculations, destination file, potential error and wrong format of the input file.
#' @param sep symbol to be used for values separator in the input csv file (works only if input file is set to be a csv file). Default value is ";"
#' @param dec symbol to be used for decimal separator in the input file. Default value is ","
#'
#' @return function returns its result as data.frame object.
#'
#' @examples
#'pairwised(data=GDPgrowth, multiplier = 1, exp.multiplier = 0, no.messages = TRUE,
#'         measure = c("sum","sumabs","logdiffabs","if1","abs(abs(x^3)-abs(y^3))"),
#'         save.as = "GDPgrowthRESULTS.csv")

######################################################
#' @importFrom xlsx write.xlsx
#' @importFrom openxlsx read.xlsx
#' @importFrom utils combn read.csv setTxtProgressBar txtProgressBar write.csv
#' @export
pairwised<-function( data, measure = c("sum", "sumabs", "absdiff", "diffabs", "prod", "prodabs", "absprod", "abslogdiff", "abslogsum", "logdiffabs", "logsumabs", "if1", "if2", "custom"), exp.multiplier = 0, multiplier = 1, no.messages = FALSE, save.as = NULL, sep=";", dec=",") {
  if (typeof(data) == "character" ){
    # dane typu znakowego traktuje jako sciezke pliku
    if ( regexpr( ".XLS",  toupper( data) ) > 0 ) {
      #Excel file
      aData <- openxlsx::read.xlsx( xlsxFile=data, sheet =  1)

      if ( is.null( save.as ) ) {
        save.as= gsub(".XLSX","", toupper( data ) )
        save.as= gsub(".XLS","", save.as )
        save.as= gsub(" ","_", save.as )
        save.as= paste( save.as, "_pairwised_result.xlsx", sep="" )
      }
    } else if ( regexpr( ".CSV",  toupper( data ) ) > 0 ) {
      #CSV
      aData = read.csv( data ,header=TRUE,sep=as.list(match.fun("pairwised"))$sep,dec=as.list(match.fun("pairwised"))$dec )
      if ( is.null( save.as ) ) {
        save.as= gsub(".CSV","", toupper( data ) )
        save.as= paste( save.as, "_pairwised_result.csv")
      }
    } else {
      if ( !no.messages) {
        cat( paste("Data file type is not supported. Execution is interrupted!",sep="") )
      }
      stop()
    }
  } else if ( typeof(data) == 'list' ) {
    aData <- data
    if ( is.null( save.as ) ) {
      save.as= "pairwised_result.xlsx"
    }
  }

  # Setting smeasure default value (SUM)
  if ( ! exists( "measure" ) ){
    measure = "SUM"
  }

  aAlg<- NULL
  for (nI1 in 1:length(measure) )
  {
    sCurrmeasure = tolower( measure[ nI1 ] )
    if ( sCurrmeasure== "sum" ){
      aAlg= c( aAlg,"x+y")
    }
    else if ( sCurrmeasure == "sumabs") {
      aAlg= c( aAlg,"abs(x)+abs(y)" )
    }
    else if ( sCurrmeasure == "absdiff" ) {
      aAlg= c( aAlg,"abs(x-y)" )
    }
    else if ( sCurrmeasure == "diffabs" ) {
      aAlg= c( aAlg,"abs(x)-abs(y)" )
    }
    else if ( sCurrmeasure == "prod" ) {
      aAlg= c( aAlg,"x*y" )
    }
    else if ( sCurrmeasure == "prodabs" ) {
      aAlg= c( aAlg,"abs(x)*abs(y)" )
    }
    else if ( sCurrmeasure == "prodabs" ) {
      aAlg= c( aAlg,"abs(x)*abs(y)" )
    }
    else if ( sCurrmeasure == "absprod" ) {
      aAlg= c( aAlg,"abs(x*y)" )
    }
    else if ( sCurrmeasure == "abslogdiff" ) {
      aAlg= c( aAlg,"abs(log(x/y))" )
    }
    else if ( sCurrmeasure == "abslogsum" ) {
      sAlg= "abs(log(x*y))"
    }
    else if ( sCurrmeasure == "logdiffabs" ) {
      aAlg= c( aAlg,"log(abs(x)/abs(y))" )
    }
    else if ( sCurrmeasure == "logsumabs" ) {
      aAlg= c( aAlg,"log(abs(x)*abs(y))" )
    }
    else if ( sCurrmeasure == "if1" ) {
      aAlg= c( aAlg,"as.numeric(x+y==1)" )
    }
    else if ( sCurrmeasure == "if2" ) {
      aAlg= c( aAlg,"as.numeric(x+y==2)" )
    }
    else {
      aAlg= c( aAlg, sCurrmeasure )
    }
  }

  aPeriods = unlist( aData[ 1 ] )
  aPeriods = aPeriods[ !is.na(aPeriods ) ]

  aItems= unlist(dimnames(aData)[2])[-1]
  aResult = list()
  nCounter = 0

  aCombnList <- combn( aItems, 2 )
  nLast<- length( aCombnList ) / 2
  oProgressbar = txtProgressBar( 0, length( aPeriods  ) * nLast )

  for ( nI1 in 1:length(aPeriods)) {
    for ( nI2 in 1:nLast) {
      sPeriod <- aPeriods[ nI1 ]

      aSubResult<- c(period=toString( aPeriods[ nI1 ] ), ID=paste( aCombnList[1,nI2],aCombnList[2,nI2],sep="-"))
      x <- as.numeric( chartr(",",".", as.vector( eval(parse(text = paste( "aData$",aCombnList[,nI2][1],"[",nI1,"]" , sep="") ) ) ) ) ) * 10^exp.multiplier * multiplier
      y <- as.numeric( chartr(",",".", as.vector( eval(parse(text = paste( "aData$",aCombnList[,nI2][2],"[",nI1,"]" , sep="") ) ) ) ) ) * 10^exp.multiplier * multiplier
      aSubResult <- eval(parse(text=paste( "c(aSubResult,unit_1='",aCombnList[1,nI2],"')",sep="")))
      aSubResult <- eval(parse(text=paste( "c(aSubResult,unit_2='",aCombnList[2,nI2],"')",sep="")))
      for ( nI3 in 1:length( aAlg ) ) {
        aSubResult <- eval(parse(text=paste( "c(aSubResult,data_",nI3,"=",aAlg[ nI3 ],")",sep="")))
      }
      aResult[[ length( aResult ) + 1 ]] = aSubResult

      nCounter = nCounter  + 1
      setTxtProgressBar( oProgressbar, nCounter)

    }
  }
  aResult= do.call( rbind.data.frame, aResult )
  colnames( aResult)[[1]]<- "period"
  colnames( aResult)[[2]]<- "identification"
  colnames( aResult)[[3]]<- "id 1"
  colnames( aResult)[[4]]<- "id 2"
  for (nI1 in 5:length( colnames( aResult ) ) ) {
    colnames( aResult)[[nI1]] <- aAlg[ nI1 - 4 ]
  }

  if ( ! toupper( save.as ) == "NONE" ) {
    if (regexpr( ".XLS", toupper( save.as ) ) > 0 ) {
      #Excel
      save.as= gsub(".XLSX","", toupper( save.as ) )
      save.as= gsub(".XLS","", toupper( save.as ) )
      save.as= tolower( paste( save.as, ".xlsx",sep="") )
      cat( paste( "\n saving result to: ", save.as, sep="") )
      xlsx::write.xlsx(x=aResult, file = path.expand( save.as ) )

    } else if (  regexpr( ".CSV", toupper( save.as ) ) > 0 ) {
      #CSV file
      cat( paste( "\n saving result to: \n", save.as , sep="") )
      write.csv(x = aResult, path.expand( save.as) )
    }

    if ( !no.messages ) {
      cat( paste("\n Result of pairwised() is saved in ",save.as,".",sep="") )
    }
  }

  return( aResult )
}


#' @name pairwised2
#' @title pairing up observations of variables
#' @description
#'    Function for creating measures form time ordered vectors of observations in
#'    panel data setting according to built in or user specified formula.D
#' @usage
#'    pairwised2(data, measure = c("cor", "cov", "absmeandiff", "diffabs", "absvardiff",
#'              "abssddiff",  "absvarcoefdiff", "custom"),  period.length="FULL",
#'              exp.multiplier = 0, multiplier = 1, no.messages = FALSE,
#'              save.as = NULL,
#'              sep=";", dec=",", overlap=TRUE )
#'
#' @param data a data.frame, list or path to the input file in csv, xlsx or xls format.
#' @param measure operation that should be applied to every pair of time ordered vectors of observations. Built in                 options contains (z denotes first observation vector and g denotes the second observation):
#' \itemize{
#'    \item "cor": cor(z,g),
#'    \item "cov": cov(z,g),
#'    \item "absmeandiff": |mean(z)-mean(g)|,
#'    \item "absvardiff": |var(z)-var(g)|,
#'    \item "abssddiff": |sd(z)-sd(g)|,
#'    \item "absvarcoefdiff": |sd(z)/mean(z)-sd(g)/mean(g)|
#'    \item Moreover, option "custom" allows the user to specify any function of z and g.
#'    }
#' @param period.length Here, user can specify the length of the of the time ordered
#'        vectors for which the measures are calculated. Default
#'        value is the full length of the sample period (period.length="FULL").
#' @param exp.multiplier default value set to 0. Changes the decimal mark in all the observations in the
#'        input file. Useful in cases when, for example, natural logarithm must be taken
#'        from a number that is very close to 0.
#' @param multiplier default value set 1. Multiplies all the observations in the input file.
#' @param no.messages default value is FALSE. If FALSE, the package will show messages: about finishing the
#'        calculations, destination file, potential error and wrong format of the input file.
#' @param save.as in this argument, user can specify: path for the destination folder, name of the file and desired format. Argument is given in the following form: "path/name.format". For example: "C:/Myfiles/Rfiles/pairwised_data.csv". If the argument is not specified default is set as "current R directory/name_of_the_input_file_paiwise_result.format_of_input_file". User can specify csv, xls and xlsx as the output format. If user does not specify the file format, the format will be the same as of the input format or xlsx in the case of data.frame/list input. If argument is equal to "none", output file is not generated.
#' @param sep symbol to be used for values separator in the input csv file (used if input file is set to be a csv file only). Default value is ";"
#' @param dec symbol to be used for decimal separator in the input file. Default value is ","
#' @param overlap  default is set at TRUE. If TRUE then values of the measures are calculated for overlapping moving
#'        windows trough time(ex. 1991-2005, 1992-2006,1993-2007,...etc.).FALSE can be set only if period.length
#'        is lower than FULL.In this instance function will be calculating measures only for non-overlaping
#'        windows (1991-1995,1996-2000,2001-2006,...etc.), which length is indicated in the parameter period.length.
#'
#' @return function returns its result as data.frame object.
#'
#' @examples
#'    pairwised2(data =  GDPgrowth, measure = c("cor","cov","abssddiff","var(z)+var(g)-cov(z,g)"),
#'              period.length = 9,  exp.multiplier = 0, multiplier = 1, no.messages = FALSE,
#'              save.as = "GDPgrowthRESULTS.csv")
######################################################################################################################################
#' @export
pairwised2<-function( data, measure = c("cor", "cov", "absmeandiff", "diffabs", "absvardiff", "abssddiff",  "absvarcoefdiff", "custom"), period.length = "FULL", exp.multiplier= 0, multiplier= 1, no.messages = FALSE, save.as = NULL, sep=";", dec=",", overlap =TRUE) {
  if (typeof(data) == "character" ){
    if (as.logical(regexpr( ".XLS", toupper(data)) == 0)) {
      #Excel file
      aData <- openxlsx::read.xlsx( xlsxFile=data, sheet =  1)

      if ( is.null( save.as ) ) {
        save.as= gsub(".XLSX","", toupper( data ) )
        save.as= gsub(".XLS","", save.as )
        save.as= gsub( " ","_", save.as )
        save.as= paste( save.as, "_pairwised2_result.xlsx", sep="")
      }
    } else if (  typeof( data ) == "character" & regexpr( ".CSV",  toupper( data ) ) > 0 ) {
      #CSV
      aData = read.csv( data ,header=T,sep=as.list(match.fun("pairwised2"))$sep,dec=as.list(match.fun("pairwised2"))$dec)
      if ( is.null( save.as ) ) {
        save.as= gsub(".CSV","", toupper( data ) )
        save.as= paste( save.as, "_pairwised2_result.csv")
      }
    } else {
      if ( !no.messages ) {
        cat( paste("Data file type is not supported. Execution is interrupted!",sep="") )
      }
      stop()
    }
  } else if ( typeof(data) == 'list' ) {
    aData <- data
    if ( is.null( save.as ) ) {
      save.as= "pairwised2_result.xlsx"
    }
  }

  if ( ! exists( "measure" ) ){
    measure = "COR"
  }

  aAlg<- NULL
  for (nI1 in 1:length(measure) )
  {
    sCurrmeasure = tolower( measure[ nI1 ] )

    if ( sCurrmeasure== "cor" ){
      aAlg= c( aAlg,"cor(z,g)")
    }
    else if ( sCurrmeasure == "cov") {
      aAlg= c( aAlg,"cov(z,g)" )
    }
    else if ( sCurrmeasure == "absmeandiff" ) {
      aAlg= c( aAlg,"abs(mean(z)-mean(g))" )
    }
    else if ( sCurrmeasure == "absvardiff" ) {
      aAlg= c( aAlg,"abs(var(z)-var(g))" )
    }
    else if ( sCurrmeasure == "abssddiff" ) {
      aAlg= c( aAlg,"abs(sd(z)-sd(g))" )
    }
    else if ( sCurrmeasure == "absvarcoeffdiff" ) {
      aAlg= c( aAlg,"abs((sd(z)/mean(z))-(sd(d)/mean(g)))" )
    }
    else {
      aAlg= c( aAlg, sCurrmeasure )
    }
  }

  aPeriods = unlist( aData[ 1 ] )
  aPeriods = aPeriods[ !is.na(aPeriods ) ]

  if (is.null( period.length) || toupper( period.length ) == "FULL" ){
    period.length= length( aPeriods )
  }
  aItems= unlist(dimnames(aData)[2])[-1]
  aResult = list()
  nCounter = 0

  aCombnList <- combn( aItems, 2 )
  nLast<- length( aCombnList ) / 2
  oProgressbar = txtProgressBar( 0, length( aPeriods  ) * nLast )
  nI1 = 1
  while (nI1 <= length(aPeriods))
  {

    for ( nI2 in 1:nLast) {
      sPeriod <- aPeriods[ nI1 ]

      if ( nI1 <= length(aPeriods) - period.length + 1 ){
        aSubResult<- c( period=paste( aPeriods[nI1],aPeriods[min( nI1 + period.length - 1 , length( aPeriods ) )] ,sep="-"),ID=paste( aCombnList[1,nI2],aCombnList[2,nI2] ,sep="-"))
        z <- as.numeric( chartr(",",".", as.vector( eval(parse(text = paste( "aData$",aCombnList[,nI2][1],"[",nI1,":",min( nI1 + period.length, length( aPeriods ) ),"]" , sep="") ) ) ) ) ) * 10^exp.multiplier * multiplier
        g <- as.numeric( chartr(",",".", as.vector( eval(parse(text = paste( "aData$",aCombnList[,nI2][2],"[",nI1,":",min( nI1 + period.length, length( aPeriods ) ),"]" , sep="") ) ) ) ) ) * 10^exp.multiplier * multiplier
        aSubResult <- eval(parse(text=paste( "c(aSubResult,unit_1='",aCombnList[1,nI2],"')",sep="")))
        aSubResult <- eval(parse(text=paste( "c(aSubResult,unit_2='",aCombnList[2,nI2],"')",sep="")))
        for ( nI3 in 1:length( aAlg ) ) {
          aSubResult <- eval(parse(text=paste( "c(aSubResult,data_",nI3,"=",aAlg[ nI3 ],")",sep="")))
        }
        aResult[[ length( aResult ) + 1 ]] = aSubResult
      }
      nCounter = nCounter + 1
      setTxtProgressBar( oProgressbar, nCounter)

    }

    if ( ! overlap && ! period.length == "FULL" ) {
      nI1 = nI1 + period.length }
    else {
      nI1 = nI1 + 1 }

  }

  aResult= do.call( rbind.data.frame, aResult )
  colnames( aResult)[[1]]<- "period"
  colnames( aResult)[[2]]<- "identification"
  colnames( aResult)[[3]]<- "id 1"
  colnames( aResult)[[4]]<- "id 2"
  for (nI1 in 5:length( colnames( aResult ) ) ) {
    colnames( aResult)[[nI1]] <- aAlg[ nI1 - 4 ]
  }

  if ( ! toupper( save.as ) == "NONE" ) {
    if (regexpr( ".XLS", toupper( save.as ) ) > 0 ) {
      #Excel
      save.as= gsub(".XLSX","", toupper( save.as ) )
      save.as= gsub(".XLS","", toupper( save.as ) )
      save.as= tolower( paste( save.as, ".xlsx",sep="") )
      cat( paste( "\n saving result to: ", save.as, sep="") )
      xlsx::write.xlsx(x=aResult, file = path.expand( save.as ) )

    } else if (  regexpr( ".CSV", toupper( save.as ) ) > 0 ) {
      #CSV file
      cat( paste( "\n saving result to: \n", save.as , sep="") )
      write.csv(x = aResult, path.expand( save.as) )
    }

    if ( !no.messages ) {
      cat( paste("\n Result of pairwised2() is saved in ",save.as,".",sep="") )
    }
  }

  return( aResult )
}


