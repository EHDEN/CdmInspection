# @file CdmInspection
#
# Copyright 2020 European Health Data and Evidence Network (EHDEN)
#
# This file is part of CdmInspection
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author European Health Data and Evidence Network
# @author Peter Rijnbeek


#' The main CdmInspection analyses (for v5.x)
#'
#' @description
#' \code{CdmInspection} runs a list of checks as part of the CDM inspection procedure
#'
#' @details
#' \code{CdmInspection} runs a list of checks as part of the CDM inspection procedure
#'
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema    	           Fully qualified name of database schema that contains OMOP CDM schema.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_instance.dbo'.
#' @param resultsDatabaseSchema		         Fully qualified name of database schema that we can write final results to. Default is cdmDatabaseSchema.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' @param scratchDatabaseSchema            Fully qualified name of database schema that we can write temporary tables to. Default is resultsDatabaseSchema.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_scratch.dbo'.
#' @param vocabDatabaseSchema		           String name of database schema that contains OMOP Vocabulary. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, so for example 'results.dbo'.
#' @param oracleTempSchema                 For Oracle only: the name of the database schema where you want all temporary tables to be managed. Requires create/insert permissions to this database.
#' @param databaseId                       ID of your database, this will be used as subfolder for the results.
#' @param databaseName		                 String name of the database name. If blank, CDM_SOURCE table will be queried to try to obtain this.
#' @param databaseDescription              Provide a short description of the database.
#' @param analysisIds                      Analyses to run
#' @param smallCellCount                   To avoid patient identifiability, cells with small counts (<= smallCellCount) are deleted. Set to NULL if you don't want any deletions.
#' @param runVocabularyChecks              Boolean to determine if vocabulary checks need to be run. Default = TRUE
#' @param runDataTablesChecks              Boolean to determine if table checks need to be run. Default = TRUE
#' @param runWebAPIChecks                  Boolean to determine if WebAPI checks need to be run. Default = TRUE
#' @param baseUrl                          WebAPI url, example: http://server.org:80/WebAPI
#' @param runPerformanceChecks             Boolean to determine if performance checks need to be run. Default = TRUE
#' @param sqlOnly                          Boolean to determine if Achilles should be fully executed. TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' @param outputFolder                     Path to store logs and SQL files
#' @param verboseMode                      Boolean to determine if the console will show all execution steps. Default = TRUE
#' @return                                 An object of type \code{achillesResults} containing details for connecting to the database containing the results
#' @export
cdmInspection <- function (connectionDetails,
                             cdmDatabaseSchema,
                             resultsDatabaseSchema = cdmDatabaseSchema,
                             scratchDatabaseSchema = resultsDatabaseSchema,
                             vocabDatabaseSchema = cdmDatabaseSchema,
                             oracleTempSchema = resultsDatabaseSchema,
                             databaseName = "",
                             databaseId = "",
                             databaseDescription = "",
                             analysisIds = "",
                             smallCellCount = 5,
                             runVocabularyChecks = TRUE,
                             runDataTablesChecks = TRUE,
                             runPerformanceChecks = TRUE,
                             runWebAPIChecks = TRUE,
                             baseUrl,
                             sqlOnly = FALSE,
                             outputFolder = "output",
                             verboseMode = TRUE) {


  # Log execution -----------------------------------------------------------------------------------------------------------------
  ParallelLogger::clearLoggers()
  if(!dir.exists(outputFolder)){dir.create(outputFolder,recursive=T)}

  logFileName <-"log_cdmInspection.txt"

  if (verboseMode) {
    appenders <- list(ParallelLogger::createConsoleAppender(),
                      ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel,
                                                         fileName = file.path(outputFolder, logFileName)))
  } else {
    appenders <- list(ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel,
                                                         fileName = file.path(outputFolder, logFileName)))
  }

  logger <- ParallelLogger::createLogger(name = "cdmInspection",
                                         threshold = "INFO",
                                         appenders = appenders)
  ParallelLogger::registerLogger(logger)

  start_time <- Sys.time()

  cdmVersion <- .getCdmVersion(connectionDetails, cdmDatabaseSchema)

  cdmVersion <- as.character(cdmVersion)

  # Check CDM version is valid ---------------------------------------------------------------------------------------------------
  if (compareVersion(a = as.character(cdmVersion), b = "5") < 0) {
    ParallelLogger::logError("Not possible to execute the check, this function is only for v5 and above.")
    ParallelLogger::logError("Is the CDM version available in the cdm_source table?")
    return(NULL)
  }

  # Check whether Achilles output is available
  if (!sqlOnly && !.checkAchillesTablesExist(connectionDetails, resultsDatabaseSchema)) {
    ParallelLogger::logError(paste("The output from Achilles is required. Please run Achilles first and make sure the result tables are in the", resultsDatabaseSchema, "schema"))
    return(NULL)
  }

  # Establish folder paths --------------------------------------------------------------------------------------------------------

  if (!dir.exists(outputFolder)) {
    dir.create(path = outputFolder, recursive = TRUE)
  }

  # Get source name if none provided ----------------------------------------------------------------------------------------------

  if (missing(databaseName) & !sqlOnly) {
    databaseName <- .getDatabaseName(connectionDetails, cdmDatabaseSchema)
  }

  # Logging
  ParallelLogger::logInfo(paste0("CDM Inspection of database ",databaseName, " started (cdm_version=",cdmVersion,")"))

  # run all the checks ------------------------------------------------------------------------------------------------------------
  dataTablesResults <- NULL
  cdmSource<-NULL

  if (runDataTablesChecks) {
    ParallelLogger::logInfo(paste0("Running Data Table Checks"))
    dataTablesResults <- dataTablesChecks(connectionDetails = connectionDetails,
                                  cdmDatabaseSchema = cdmDatabaseSchema,
                                  resultsDatabaseSchema = resultsDatabaseSchema,
                                  outputFolder = outputFolder,
                                  sqlOnly = sqlOnly)
    cdmSource<- .getCdmSource(connectionDetails, cdmDatabaseSchema,sqlOnly,outputFolder)
    temp <- cdmSource
    temp$CDM_RELEASE_DATE <- as.character(cdmSource$CDM_RELEASE_DATE)
    temp$SOURCE_RELEASE_DATE <- as.character(cdmSource$SOURCE_RELEASE_DATE)
    cdmSource <- temp
  }


  vocabularyResults <- NULL
  if (runVocabularyChecks) {
    ParallelLogger::logInfo(paste0("Running Vocabulary Checks"))
    vocabularyResults<-vocabularyChecks(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     vocabDatabaseSchema = vocabDatabaseSchema,
                     resultsDatabaseSchema = resultsDatabaseSchema,
                     smallCellCount = smallCellCount,
                     oracleTempSchema = oracleTempSchema,
                     sqlOnly = sqlOnly,
                     outputFolder = outputFolder)
  }
  packinfo <- NULL
  sys_details <- NULL
  hadesPackageVersions <- NULL
  performanceResults <- NULL
  missingPackages <- NULL
  if (runPerformanceChecks) {

    ParallelLogger::logInfo(paste0("Check installed R Packages"))
    # packageListUrl <- "https://raw.githubusercontent.com/OHDSI/Hades/main/extras/packages.csv"
    # hadesPackageList <- read.table(packageListUrl, sep = ",", header = TRUE)
    # packages <- hadesPackageList$name
    # dump("packages", "")
    packages <- c("CohortMethod", "SelfControlledCaseSeries", "SelfControlledCohort",
                  "EvidenceSynthesis", "PatientLevelPrediction", "EnsemblePatientLevelPrediction",
                  "Capr", "CirceR", "CohortGenerator", "PhenotypeLibrary", "EmpiricalCalibration",
                  "MethodEvaluation", "CohortDiagnostics", "Andromeda", "BigKnn",
                  "Cyclops", "DatabaseConnector", "Eunomia", "FeatureExtraction",
                  "Hydra", "OhdsiSharing", "ParallelLogger", "ROhdsiWebApi", "SqlRender")
    diffPackages <- setdiff(packages, rownames(installed.packages()))
    missingPackages <- paste(diffPackages, collapse=', ')

    if (length(diffPackages)>0){
      ParallelLogger::logInfo(paste0("Not all the HADES packages are installed, see https://ohdsi.github.io/Hades/installingHades.html for more information"))
      ParallelLogger::logInfo(paste0("Missing:", missingPackages))
    } else
      ParallelLogger::logInfo(paste0("> All HADES packages are installed"))

    packinfo <- installed.packages(fields = c("Package", "Version"))
    hades<-packinfo[,c("Package", "Version")]
    hadesPackageVersions <- as.data.frame(hades[row.names(hades) %in% packages,])

    sys_details <- benchmarkme::get_sys_details(sys_info=FALSE)
    ParallelLogger::logInfo(paste0("Running Performance Checks on ", sys_details$cpu$model_name, " cpu with ", sys_details$cpu$no_of_cores, " cores, and ", prettyunits::pretty_bytes(as.numeric(sys_details$ram)), " ram."))
   # benchmark <- benchmark_std()

    ParallelLogger::logInfo(paste0("Running Performance Checks SQL"))
    performanceResults <- performanceChecks(connectionDetails = connectionDetails,
                      cdmDatabaseSchema = cdmDatabaseSchema,
                      resultsDatabaseSchema = resultsDatabaseSchema,
                      oracleTempSchema = oracleTempSchema,
                      sqlOnly = sqlOnly,
                      outputFolder = outputFolder)



  }

  webAPIversion <- "unknown"
  if (runWebAPIChecks){
    ParallelLogger::logInfo(paste0("Running WebAPIChecks"))

    tryCatch({
      webAPIversion <- ROhdsiWebApi::getWebApiVersion(baseUrl = baseUrl)
      ParallelLogger::logInfo(sprintf("> Connected successfully to %s", baseUrl))
      ParallelLogger::logInfo(sprintf("> WebAPI version: %s", webAPIversion))},
             error = function (e) {
               ParallelLogger::logError(paste0("Could not connect to the WebAPI: ", baseUrl))
               webAPIversion <- "Failed"
      })
  }


  ParallelLogger::logInfo(paste0("Done."))

  duration <- as.numeric(difftime(Sys.time(),start_time), units="mins")
  ParallelLogger::logInfo(paste("Complete CdmInspection took ", sprintf("%.2f", duration)," minutes"))
  # save results  ------------------------------------------------------------------------------------------------------------

  results<-list(executionDate = date(),
                executionDuration = as.numeric(difftime(Sys.time(),start_time), units="secs"),
                databaseName = databaseName,
                databaseId = databaseId,
                databaseDescription = databaseDescription,
                vocabularyResults = vocabularyResults,
                dataTablesResults = dataTablesResults,
                packinfo=packinfo,
                hadesPackageVersions = hadesPackageVersions,
                missingPackages = missingPackages,
                performanceResults = performanceResults,
                sys_details= sys_details,
                webAPIversion = webAPIversion,
                cdmSource = cdmSource,
                dms=connectionDetails$dbms)



  saveRDS(results, file.path(outputFolder,"inspection_results.rds"))
  ParallelLogger::logInfo(sprintf("The cdm inspection results have been exported to: %s", outputFolder))
  bundledResultsLocation <- bundleResults(outputFolder, databaseId)
  ParallelLogger::logInfo(paste("All cdm inspection results are bundled for sharing at: ", bundledResultsLocation))
  ParallelLogger::logInfo("Next step: generate and complete the inspection report and share this together with the zip file.")

  duration <- as.numeric(difftime(Sys.time(),start_time), units="secs")
  ParallelLogger::logInfo(paste("CdmInspection run took", sprintf("%.2f", duration),"secs"))
  return(results)
}

.getDatabaseName <- function(connectionDetails,
                           cdmDatabaseSchema) {
  sql <- SqlRender::render(sql = "select cdm_source_name from @cdmDatabaseSchema.cdm_source",
                           cdmDatabaseSchema = cdmDatabaseSchema)
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  databaseName <- tryCatch({
    s <- DatabaseConnector::querySql(connection = connection, sql = sql)
    s[1,]
  }, error = function (e) {
    ""
  }, finally = {
    DatabaseConnector::disconnect(connection = connection)
    rm(connection)
  })
  databaseName
}

.getCdmVersion <- function(connectionDetails,
                           cdmDatabaseSchema) {
  sql <- SqlRender::render(sql = "select cdm_version from @cdmDatabaseSchema.cdm_source",
                           cdmDatabaseSchema = cdmDatabaseSchema)
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  cdmVersion <- tryCatch({
    c <- tolower((DatabaseConnector::querySql(connection = connection, sql = sql))[1,])
    gsub(pattern = "v", replacement = "", x = c)
  }, error = function (e) {
    ""
  }, finally = {
    DatabaseConnector::disconnect(connection = connection)
    rm(connection)
  })

  cdmVersion
}

.getCdmSource <- function(connectionDetails,
                           cdmDatabaseSchema,sqlOnly,outputFolder) {
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = file.path("checks","get_cdm_source_table.sql"),
                                           packageName = "CdmInspection",
                                           dbms = connectionDetails$dbms,
                                           warnOnMissingParameters = FALSE,
                                           cdmDatabaseSchema = cdmDatabaseSchema)
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, "get_cdm_source_table.sql"))
    return(NULL)
  } else {
    tryCatch({
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
      cdmSource<- DatabaseConnector::querySql(connection = connection, sql = sql, errorReportFile = file.path(outputFolder, "vocabulariesError.txt"))
      ParallelLogger::logInfo("> Vocabulary table successfully extracted")
    },
    error = function (e) {
      ParallelLogger::logError(paste0("> Vocabulary table could not be extracted, see ",file.path(outputFolder,"vocabulariesError.txt")," for more details"))
    }, finally = {
      DatabaseConnector::disconnect(connection = connection)
      rm(connection)
    })
    return(cdmSource)
  }
}

.checkAchillesTablesExist <- function(connectionDetails, resultsDatabaseSchema) {
  required_achilles_tables <- c("achilles_analysis", "achilles_results", "achilles_results_dist")
  achilles_tables_exist <- tryCatch({
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    for(x in required_achilles_tables) {
      sql <- SqlRender::translate(
        SqlRender::render(
          "SELECT * FROM @resultsDatabaseSchema.@table",
          resultsDatabaseSchema=resultsDatabaseSchema,
          table=x
        ),
        targetDialect = 'postgresql'
      )
      DatabaseConnector::executeSql(
        connection = connection,
        sql = sql,
        progressBar = F,
        reportOverallTime = F,
        errorReportFile = "errorAchillesExistsSql.txt"
      )
    }
    TRUE
  },
  error = function (e) {
    ParallelLogger::logWarn("Achilles Tables have not been found.")
    FALSE
  },
  finally = {
    DatabaseConnector::disconnect(connection = connection)
    rm(connection)
  })
  return(achilles_tables_exist)
}
