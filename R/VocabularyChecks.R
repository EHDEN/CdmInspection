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
#' @param smallCellCount                   To avoid patient identifiability, cells with small counts (<= smallCellCount) are deleted. Set to NULL if you don't want any deletions.
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
                           smallCellCount = 5,
                           sourceName = "",
                           sqlOnly = FALSE,
                           outputFolder = "output",
                           verboseMode = TRUE) {

  ## run all queries
  mappingCompleteness <- executeQuery(outputFolder,"mapping_completeness.sql", "Mapping Completeness query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema)
  colnames(mappingCompleteness$result) <- c("Domain","#Codes Source","#Codes Mapped","%Codes Mapped","#Records Source","#Records Mapped","%Records Mapped")

  drugMapping  <- executeQuery(outputFolder,"mapping_levels_drugs.sql", "Drug Level Mapping query executed successfully", connectionDetails, sqlOnly,  cdmDatabaseSchema, vocabDatabaseSchema)
  unmappedDrugs<- executeQuery(outputFolder,"unmapped_drugs.sql", "Unmapped drugs query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema, smallCellCount)
  unmappedConditions<- executeQuery(outputFolder,"unmapped_conditions.sql", "Unmapped conditions query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema, smallCellCount)
  unmappedMeasurements<- executeQuery(outputFolder,"unmapped_measurements.sql", "Unmapped measurements query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema, smallCellCount)
  unmappedObservations<- executeQuery(outputFolder,"unmapped_observations.sql", "Unmapped observations query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema, smallCellCount)
  unmappedProcedures<- executeQuery(outputFolder,"unmapped_procedures.sql", "Unmapped procedures query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema, smallCellCount)
  unmappedDevices<- executeQuery(outputFolder,"unmapped_devices.sql", "Unmapped devices query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema, smallCellCount)
  mappedDrugs<- executeQuery(outputFolder,"mapped_drugs.sql", "Mapped drugs query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema, smallCellCount)
  mappedConditions<- executeQuery(outputFolder,"mapped_conditions.sql", "Mapped conditions query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema, smallCellCount)
  mappedMeasurements<- executeQuery(outputFolder,"mapped_measurements.sql", "Mapped measurements query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema, smallCellCount)
  mappedObservations<- executeQuery(outputFolder,"mapped_observations.sql", "Mapped observations query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema, smallCellCount)
  mappedProcedures<- executeQuery(outputFolder,"mapped_procedures.sql", "Mapped procedures query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema, smallCellCount)
  mappedDevices<- executeQuery(outputFolder,"mapped_devices.sql", "Mapped devices query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema, smallCellCount)
  conceptCounts <- executeQuery(outputFolder,"concept_counts_by_vocabulary.sql", "Concept counts by vocabulary query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema, smallCellCount)
  vocabularyCounts <- executeQuery(outputFolder,"vocabulary_tables_count.sql", "Count on vocabulary tables query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema)
  sourceConceptFrequency <- executeQuery(outputFolder,"source_to_concept_map_frequency.sql", "Source to concept map breakdown query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema)
  sourceConceptMap <- executeQuery(outputFolder,"get_source_to_concept_map.sql", "Source to concept map query executed successfully", connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema)

  version <- conceptCounts$result[conceptCounts$result$ID=='None',]$VERSION

  results <- list(version=version,
                  mappingCompleteness=mappingCompleteness,
                  drugMapping=drugMapping,
                  unmappedDrugs=unmappedDrugs,
                  unmappedConditions=unmappedConditions,
                  unmappedMeasurements=unmappedMeasurements,
                  unmappedObservations=unmappedObservations,
                  unmappedProcedures=unmappedProcedures,
                  unmappedDevices=unmappedDevices,
                  mappedDrugs=mappedDrugs,
                  mappedConditions=mappedConditions,
                  mappedMeasurements=mappedMeasurements,
                  mappedObservations=mappedObservations,
                  mappedProcedures=mappedProcedures,
                  mappedDevices=mappedDevices,
                  conceptCounts=conceptCounts,
                  vocabularyCounts=vocabularyCounts,
                  sourceConceptFrequency=sourceConceptFrequency,
                  sourceConceptMap=sourceConceptMap)
  return(results)
}



