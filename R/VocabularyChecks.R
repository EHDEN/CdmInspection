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


#' The vocabulary checks (for v5.x)
#'
#' @description
#' \code{CdmInspection} runs a list of checks on the vocabulary as part of the CDM inspection procedure
#'
#' @details
#' \code{CdmInspection} runs a list of checks on the vocabulary as part of the CDM inspection procedure
#'
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema    	           Fully qualified name of database schema that contains OMOP CDM schema.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_instance.dbo'.
#' @param resultsDatabaseSchema		         Fully qualified name of database schema that we can write final results to. Default is cdmDatabaseSchema.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' @param vocabDatabaseSchema		           String name of database schema that contains OMOP Vocabulary. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, so for example 'results.dbo'.
#' @param oracleTempSchema                 For Oracle only: the name of the database schema where you want all temporary tables to be managed. Requires create/insert permissions to this database.
#' @param sourceName		                   String name of the data source name. If blank, CDM_SOURCE table will be queried to try to obtain this.
#' @param sqlOnly                          Boolean to determine if Achilles should be fully executed. TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' @param outputFolder                     Path to store logs and SQL files
#' @param verboseMode                      Boolean to determine if the console will show all execution steps. Default = TRUE
#' @return                                 An object of type \code{achillesResults} containing details for connecting to the database containing the results
#' @export
vocabularyChecks <- function (connectionDetails,
                           cdmDatabaseSchema,
                           resultsDatabaseSchema = cdmDatabaseSchema,
                           vocabDatabaseSchema = cdmDatabaseSchema,
                           oracleTempSchema = resultsDatabaseSchema,
                           sourceName = "",
                           sqlOnly = FALSE,
                           outputFolder = "output",
                           verboseMode = TRUE) {

  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "mapping_completeness.sql",
                                           packageName = "CdmInspection",
                                           dbms = connectionDetails$dbms,
                                           warnOnMissingParameters = FALSE,
                                           cdmDatabaseSchema = cdmDatabaseSchema)
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, "mapping_completeness.sql"))
  } else {
    tryCatch({
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
      mappingCompleteness<- DatabaseConnector::querySql(connection = connection, sql = sql, errorReportFile = file.path(outputFolder, "mappingCompletenessError.txt"))
      ParallelLogger::logInfo("> Mapping Completeness query executed successfully")
    },
    error = function (e) {
      ParallelLogger::logError(paste0("> Mapping Completeness query did not execute, see ",file.path(outputFolder,"validateSchemaError.txt")," for more details"))
    }, finally = {
      DatabaseConnector::disconnect(connection = connection)
      rm(connection)
    })
  }

  colnames(mappingCompleteness) <- c("Domain","#Codes Source","#Codes Mapped","%Codes Mapped","#Records Source","#Records Mapped","%Records Mapped")


  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "get_vocabulary_table.sql",
                                           packageName = "CdmInspection",
                                           dbms = connectionDetails$dbms,
                                           warnOnMissingParameters = FALSE,
                                           vocabDatabaseSchema = vocabDatabaseSchema)
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, "get_vocabulary_table.sql"))
  } else {
    tryCatch({
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
      vocabularies<- DatabaseConnector::querySql(connection = connection, sql = sql, errorReportFile = file.path(outputFolder, "vocabulariesError.txt"))
      ParallelLogger::logInfo("> Vocabulary table successfully extracted")
    },
    error = function (e) {
      ParallelLogger::logError(paste0("> Vocabulary table could not be extracted, see ",file.path(outputFolder,"vocabulariesError.txt")," for more details"))
    }, finally = {
      DatabaseConnector::disconnect(connection = connection)
      rm(connection)
    })
  }
  version = vocabularies[vocabularies$VOCABULARY_ID=='None',]$VOCABULARY_VERSION

  colnames(vocabularies) <- c("ID","Name","Reference","Version","Concept_ID")

  results <- list(version=version,vocabularies=vocabularies,mappingCompleteness=mappingCompleteness)
  return(results)
}

prettyHr <- function(x) {
  result <- sprintf("%.2f", x)
  result[is.na(x)] <- "NA"
  result <- suppressWarnings(format(as.numeric(result), big.mark=",")) # add thousands separator
  return(result)
}
