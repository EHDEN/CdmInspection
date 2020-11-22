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
#' @param runSchemaChecks                   Boolean to determine if CDM Schema Validation should be run. Default = TRUE
#' @param runVocabularyChecks              Boolean to determine if vocabulary checks need to be run. Default = TRUE
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
                             runSchemaChecks = TRUE,
                             runVocabularyChecks = TRUE,
                             runPerformanceChecks = TRUE,
                             sqlOnly = FALSE,
                             outputFolder = "output",
                             verboseMode = TRUE) {


  # Log execution -----------------------------------------------------------------------------------------------------------------
  ParallelLogger::clearLoggers()
  if(!dir.exists(outputFolder)){dir.create(outputFolder,recursive=T)}

  logFileName <-"log_cdmInspection.txt"
  unlink(hadesPackageVersions)

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
      .getSourceName(connectionDetails, cdmDatabaseSchema)
    }

    # Logging
    ParallelLogger::logInfo(paste0("CDM Inspection of database ",sourceName, " started (cdm_version=",cdmVersion,")"))

    # run all the checks ------------------------------------------------------------------------------------------------------------
    schemaValid <- FALSE

    if (runSchemaChecks) {
      ParallelLogger::logInfo(paste0("Running Schema Checks"))
      schemaValid <- validateSchema(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     resultsDatabaseSchema = resultsDatabaseSchema,
                     runCostAnalysis = FALSE,
                     cdmVersion = cdmVersion,
                     outputFolder = outputFolder,
                     sqlOnly = sqlOnly)
      ParallelLogger::logInfo(paste0("Done."))
    }

    if (runVocabularyChecks) {
      ParallelLogger::logInfo(paste0("Running Vocabulary Checks"))
      vocabularyChecks(connectionDetails = connectionDetails,
                       cdmDatabaseSchema = cdmDatabaseSchema,
                       resultsDatabaseSchema = resultsDatabaseSchema,
                       oracleTempSchema = roracleTempSchema,
                       sqlOnly = sqlOnly,
                       outputFolder = outputFolder)
      ParallelLogger::logInfo(paste0("Done."))
    }

    if (runPerformanceChecks) {

      ParallelLogger::logInfo(paste0("Check installed R Packages"))
      packages <- c("SqlRender", "DatabaseConnector", "DatabaseConnectorJars", "PatientLevelPrediction", "CohortDiagnostics", "CohortMethod", "rJava","Cyclops","ParallelLogger","FeatureExtraction","Andromeda",
                    "ROhdsiWebApi","OhdsiSharing","Hydra","Eunomia","EmpiricalCalibration","MethodEvaluation","EvidenceSynthesis","SelfControlledCaseSeries","SelfControlledCohort")
      diffPackages <- setdiff(packages, rownames(installed.packages()))

      if (length(diffPackages)>0){
        ParallelLogger::logInfo(paste0("Not all the HADES packages are installed, see https://ohdsi.github.io/Hades/installingHades.html for more information"))
        ParallelLogger::logInfo(paste0("Missing:", paste(diffPackages, collapse=', ')))
      } else
        ParallelLogger::logInfo(paste0("All HADES packages are installed"))

      packinfo <- installed.packages(fields = c("Package", "Version"))
      hades<-packinfo[,c("Package", "Version")]
      hadesPackageVersions <- hades[row.names(hades) %in% packages,]
      row.names(hadesPackageVersions) <- NULL
      write.csv(hadesPackageVersions,file.path(outputFolder,"OhdsiPackageVersions.csv"))



      ParallelLogger::logInfo(paste0("Done."))
      sys_details <- benchmarkme::get_sys_details(sys_info=FALSE)
      ParallelLogger::logInfo(paste0("Running Performance Checks on ", sys_details$cpu$model_name, " cpu with ", sys_details$cpu$no_of_cores, " cores, and ", prettyunits::pretty_bytes(as.numeric(sys_details$ram)), " ram."))
     # benchmark <- benchmark_std()
      ParallelLogger::logInfo(paste0("Done."))

      ParallelLogger::logInfo(paste0("Running Performance Checks SQL"))
      performanceChecks(connectionDetails = connectionDetails,
                        cdmDatabaseSchema = cdmDatabaseSchema,
                        resultsDatabaseSchema = resultsDatabaseSchema,
                        oracleTempSchema = roracleTempSchema,
                        sqlOnly = sqlOnly,
                        outputFolder = outputFolder)
      ParallelLogger::logInfo(paste0("Done."))


    }

    ParallelLogger::logInfo(sprintf("The cdm inspection results have been exported to: %s", outputFolder))

    results<-list(packinfo=packinfo, hadesPackageVersions = hadesPackageVersions, sys_details= sys_details)
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

#' Validate the CDM schema
#'
#' @details
#' Runs a validation script to ensure the CDM is valid based on v5.x
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

  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "validate_schema.sql",
                                           packageName = "CdmInspection",
                                           dbms = connectionDetails$dbms,
                                           warnOnMissingParameters = FALSE,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           runCostAnalysis = FALSE,
                                           cdmVersion = cdmVersion)
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, "ValidateSchema.sql"))
  } else {
    tryCatch({
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
      tables <- DatabaseConnector::querySql(connection = connection, sql = sql, errorReportFile = file.path(outputFolder, "validateSchemaError.txt"))
      ParallelLogger::logInfo("CDM Schema is valid")
    },
    error = function (e) {
      ParallelLogger::logError(paste0("The CDM Schema is not valid or a table does not contain data to allow schema check, see ",file.path(outputFolder,"validateSchemaError.txt")," for more details"))
    }, finally = {
      DatabaseConnector::disconnect(connection = connection)
      rm(connection)
      return(FALSE)
    })
  }
  invisible(TRUE)
}
