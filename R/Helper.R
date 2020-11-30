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

executeQuery <- function(outputFolder,sqlFileName, successMessage, connectionDetails, sqlOnly, cmdDatabaseSchema, vocabDatabaseSchema=NULL, resultsDatabaseSchema=NULL){
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = file.path("checks",sqlFileName),
                                           packageName = "CdmInspection",
                                           dbms = connectionDetails$dbms,
                                           warnOnMissingParameters = FALSE,
                                           vocabDatabaseSchema = vocabDatabaseSchema,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           resultsDatabaseSchema = resultsDatabaseSchema)

  duration = -1
  result = NULL
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, sqlFileName))
  } else {

    tryCatch({
      start_time <- Sys.time()
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails,)
      result<- DatabaseConnector::querySql(connection = connection, sql = sql, errorReportFile = file.path(outputFolder, paste0(tools::file_path_sans_ext(sqlFileName),"Err.txt")))
      duration <- Sys.time() -  start_time
      ParallelLogger::logInfo(paste("> ",successMessage, "in", sprintf("%.2f", duration),"secs"))
    },
    error = function (e) {
      ParallelLogger::logError(paste0("> Failed see ",file.path(outputFolder,paste0(tools::file_path_sans_ext(sqlFileName),"Err.txt"))," for more details"))
    }, finally = {
      DatabaseConnector::disconnect(connection = connection)
      rm(connection)
    })

  }


  return(list(result=result,duration=duration))
}
prettyHr <- function(x) {
  result <- sprintf("%.2f", x)
  result[is.na(x)] <- "NA"
  result <- suppressWarnings(format(as.numeric(result), big.mark=",")) # add thousands separator
  return(result)
}
