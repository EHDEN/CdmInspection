# @file CdmInspection
#
# Copyright 2020 European Health Data and Evidence Network (EHDEN)
#
# This file is part of CatalogueExport
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
#' @param vocabDatabaseSchema		           String name of database schema that contains OMOP Vocabulary. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, so for example 'results.dbo'.
#' @param oracleTempSchema                 For Oracle only: the name of the database schema where you want all temporary tables to be managed. Requires create/insert permissions to this database.
#' @param sourceName		                   String name of the data source name. If blank, CDM_SOURCE table will be queried to try to obtain this.
#' @param smallCellCount                   To avoid patient identifiability, cells with small counts (<= smallCellCount) are deleted. Set to NULL if you don't want any deletions.
#' @param runSchemaChecks                 Boolean to determine if CDM Schema Validation should be run. Default = TRUE
#' @param runVocabularyChecks              Boolean to determine if vocabulary checks need to be run. Default = TRUE
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
                             sourceName = "",
                             analysisIds = "",
                             createTable = TRUE,
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
  } else {
    # Establish folder paths --------------------------------------------------------------------------------------------------------

    if (!dir.exists(outputFolder)) {
      dir.create(path = outputFolder, recursive = TRUE)
    }

    # Get source name if none provided ----------------------------------------------------------------------------------------------

    if (missing(sourceName) & !sqlOnly) {
      sourceName <- .getSourceName(connectionDetails, cdmDatabaseSchema)
    }

    # Logging
    ParallelLogger::logInfo(paste0("CDM Inspection of database ",sourceName, " started (cdm_version=",cdmVersion,")"))

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
      cdmSource<- .getCdmSource(connectionDetails, cdmDatabaseSchema,sqlOnly)
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
                       oracleTempSchema = roracleTempSchema,
                       sqlOnly = sqlOnly,
                       outputFolder = outputFolder)

      write.csv(vocabularyResults$mappingCompleteness$data,file.path(outputFolder,"mappingCompleteness.csv"))
      write.csv(vocabularyResults$vocabularies$data,file.path(outputFolder,"vocabularies.csv"))

      # vocabularies <- data.frame(VocabularyName=c("None", "RxNorm", "CC"))
      # diffVocabularies <- setdiff(vocabularies, vocabularyResults$vocabularies) #TODO: does not work
      #
      # if (length(Vocabularies)>0){
      #   ParallelLogger::logInfo(paste0("Not all the required standard vocabularies are found"))
      #   ParallelLogger::logInfo(paste0("Missing:", paste(diffVocabularies, collapse=', ')))
      # } else
      #   ParallelLogger::logInfo(paste0("> All required standard vocabularies are found"))

    }
    packinfo <- NULL
    sys_details <- NULL
    hadesPackageVersions <- NULL
    performanceResults <- NULL
    if (runPerformanceChecks) {

      ParallelLogger::logInfo(paste0("Check installed R Packages"))
      packages <- c("SqlRender", "DatabaseConnector", "DatabaseConnectorJars", "PatientLevelPrediction", "CohortDiagnostics", "CohortMethod", "Cyclops","ParallelLogger","FeatureExtraction","Andromeda",
                    "ROhdsiWebApi","OhdsiSharing","Hydra","Eunomia","EmpiricalCalibration","MethodEvaluation","EvidenceSynthesis","SelfControlledCaseSeries","SelfControlledCohort")
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
                        oracleTempSchema = roracleTempSchema,
                        sqlOnly = sqlOnly,
                        outputFolder = outputFolder)



    }

    webAPIversion <- "unknown"
    if (runWebAPIChecks){
      ParallelLogger::logInfo(paste0("Running WebAPIChecks"))

      tryCatch({
        webAPIversion <- getWebApiVersion(baseUrl = baseUrl)
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

    duration <- as.numeric(difftime(Sys.time(),start_time), units="secs")
    ParallelLogger::logInfo(paste("CdmInspection run took", sprintf("%.2f", duration),"secs"))
    return(results)

  }

}

.getSourceName <- function(connectionDetails,
                           cdmDatabaseSchema) {
  sql <- SqlRender::render(sql = "select cdm_source_name from @cdmDatabaseSchema.cdm_source",
                           cdmDatabaseSchema = cdmDatabaseSchema)
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  sourceName <- tryCatch({
    s <- DatabaseConnector::querySql(connection = connection, sql = sql)
    s[1,]
  }, error = function (e) {
    ""
  }, finally = {
    DatabaseConnector::disconnect(connection = connection)
    rm(connection)
  })
  sourceName
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
                           cdmDatabaseSchema,sqlOnly) {
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = file.path("checks","get_cdm_source_table.sql"),
                                           packageName = "CdmInspection",
                                           dbms = connectionDetails$dbms,
                                           warnOnMissingParameters = FALSE,
                                           cdmDatabaseSchema = cdmDatabaseSchema)
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, "get_cdm_source_table.sql"))
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
  }
  cdmSource
}

#' Validate the CDM schema
#'
#' @details
#' Runs a validation script to ensure the CDM is valid based on v5.x (NOT USED CURRENTLY)
#'
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema    	           string name of database schema that contains OMOP CDM. On SQL Server, this should specifiy both the database and the schema, so for example 'cdm_instance.dbo'.
#' @param resultsDatabaseSchema		         Fully qualified name of database schema that the cohort table is written to. Default is cdmDatabaseSchema.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' @param cdmVersion                       Define the OMOP CDM version used:  currently supports v5 and above. Use major release number or minor number only (e.g. 5, 5.3)
#' @param runCostAnalysis                  Boolean to determine if cost analysis should be run. Note: only works on CDM v5 and v5.1.0+ style cost tables.
#' @param outputFolder                     Path to store logs and SQL files
#' @param sqlOnly                          TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' @param verboseMode                      Boolean to determine if the console will show all execution steps. Default = TRUE
#'
#' @export
validateSchema <- function(connectionDetails,
                           cdmDatabaseSchema,
                           resultsDatabaseSchema = cdmDatabaseSchema,
                           cdmVersion,
                           runCostAnalysis,
                           outputFolder,
                           sqlOnly = FALSE,
                           verboseMode = TRUE) {


  majorVersions <- lapply(c("5", "5.1", "5.2", "5.3"), function(majorVersion) {
    if (compareVersion(a = as.character(cdmVersion), b = majorVersion) >= 0) {
      majorVersion
    } else {
      0
    }
  })

  cdmVersion <- max(unlist(majorVersions))

  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = file.path("checks","validate_schema.sql"),
                                           packageName = "CdmInspection",
                                           dbms = connectionDetails$dbms,
                                           warnOnMissingParameters = FALSE,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           runCostAnalysis = FALSE,
                                           cdmVersion = cdmVersion)
  schemaValid <- FALSE
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, "ValidateSchema.sql"))
  } else {
    tryCatch({
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
      tables <- DatabaseConnector::querySql(connection = connection, sql = sql, errorReportFile = file.path(outputFolder, "validateSchemaError.txt"))
      ParallelLogger::logInfo("CDM Schema is valid")
      schemaValid <- TRUE
    },
    error = function (e) {
      ParallelLogger::logError(paste0("The CDM Schema is not valid or a table does not contain data to allow schema check, see ",file.path(outputFolder,"validateSchemaError.txt")," for more details"))
    }, finally = {
      DatabaseConnector::disconnect(connection = connection)
      rm(connection)
    })
  }
  return(schemaValid)
}
