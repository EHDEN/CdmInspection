# @file Helper.R
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

executeQuery <- function(outputFolder,sqlFileName, successMessage, connectionDetails, sqlOnly, cdmDatabaseSchema, vocabDatabaseSchema=NULL, resultsDatabaseSchema=NULL, smallCellCount = 5){
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = file.path("checks",sqlFileName),
                                           packageName = "CdmInspection",
                                           dbms = connectionDetails$dbms,
                                           warnOnMissingParameters = FALSE,
                                           vocabDatabaseSchema = vocabDatabaseSchema,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           smallCellCount = smallCellCount)

  duration = -1
  result = NULL
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, sqlFileName))
  } else {

    tryCatch({
      start_time <- Sys.time()
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails,)
      result<- DatabaseConnector::querySql(connection = connection, sql = sql, errorReportFile = file.path(outputFolder, paste0(tools::file_path_sans_ext(sqlFileName),"Err.txt")))
      duration <- as.numeric(difftime(Sys.time(),start_time), units="secs")
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



my_body_add_table <- function (x, value, style = NULL, pos = "after", header = TRUE,
          alignment = NULL, stylenames = table_stylenames(), first_row = TRUE,
          first_column = FALSE, last_row = FALSE, last_column = FALSE,
          no_hband = FALSE, no_vband = TRUE, align = "left")
{
  pt <- officer::prop_table(style = style, layout = table_layout(),
                   width = table_width(), stylenames = stylenames,
                   tcf = table_conditional_formatting(first_row = first_row,
                                                      first_column = first_column, last_row = last_row,
                                                      last_column = last_column, no_hband = no_hband, no_vband = no_vband),
                   align = align)

  # Align left if no alignment is given
  if (is.null(alignment)) {
    alignment <- rep('l', ncol(value))
  }

  # Formatting numeric columns: align right and add thousands separator.
  for (i in 1:ncol(value)) {
    if (is.numeric(value[,i])) {
      value[,i] <- format(value[,i], big.mark=",")
      alignment[i] <- 'r'
    }
  }

  bt <- officer::block_table(x = value, header = header, properties = pt,
                    alignment = alignment)
  xml_elt <- officer::to_wml(bt, add_ns = TRUE, base_document = x)
  officer::body_add_xml(x = x, str = xml_elt, pos = pos)
}


my_source_value_count_section <- function (x, data, table_number, domain, kind,smallCellCount) {
  n <- nrow(data$result)

  msg <- paste0("Counts are rounded up to the nearest hundred. Values with a record count <=",smallCellCount," are omitted.")
  if (n == 0) {
    officer::body_add_par(x,paste0("Table ", table_number, " omitted because no ", kind, " ", domain, " were found."))
  } else if (n < 25) {
    officer::body_add_par(x,paste0("Table ", table_number, ". All ", n, " ", kind, " ", domain, ". ", msg))
  } else {
    officer::body_add_par(x,paste0("Table ", table_number, ". Top 25 of ", kind, " ", domain, ". ", msg))
  }

  if (n>0) {
    my_body_add_table(x, value = data$result, style = "EHDEN")
  }

  officer::body_add_par(x, paste0("Query executed in ", sprintf("%.2f", data$duration), " secs"))
}

my_unmapped_section <- function(x, data, table_number, domain, smallCellCount) {
  my_source_value_count_section(x, data, table_number, domain, "unmapped", smallCellCount)
}

my_mapped_section <- function(x, data, table_number, domain, smallCellCount) {
  my_source_value_count_section(x, data, table_number, domain, "mapped", smallCellCount)
}


recordsCountPlot <- function(results){
  temp <- results %>%
    dplyr::rename(Date=X_CALENDAR_MONTH,Domain=SERIES_NAME, Count=Y_RECORD_COUNT) %>%
    dplyr::mutate(Date=lubridate::parse_date_time(Date, "ym"))
  plot <- ggplot2::ggplot(temp, aes(x = Date, y = Count)) + geom_line(aes(color = Domain))
}

#' Bundles the results in a zip file
#'
#' @description
#' \code{bundleResults} creates a zip file with results in the outputFolder
#' @param outputFolder  Folder to store the results
#' @param databaseId    ID of your database, this will be used as subfolder for the results.
#' @export
bundleResults <- function(outputFolder, databaseId) {
  zipName <- file.path(outputFolder, paste0("Results_Inspection_", databaseId, ".zip"))
  files <- list.files(outputFolder, "*.*", full.names = TRUE, recursive = TRUE)
  oldWd <- setwd(outputFolder)
  on.exit(setwd(oldWd), add = TRUE)
  DatabaseConnector::createZipFile(zipFile = zipName, files = files)
  return(zipName)
}
