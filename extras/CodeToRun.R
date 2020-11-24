# *******************************************************
# -----------------INSTRUCTIONS -------------------------
# *******************************************************
#
#-----------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------
# This CodeToRun.R is provided as an example of how to run this package.
# Below you will find 2 sections: the 1st is for installing the dependencies
# required to run the package and the 2nd for running the package.
#
# The code below makes use of R environment variables (denoted by "Sys.getenv(<setting>)") to
# allow for protection of sensitive information. If you'd like to use R environment variables stored
# in an external file, this can be done by creating an .Renviron file in the root of the folder
# where you have cloned this code. For more information on setting environment variables please refer to:
# https://stat.ethz.ch/R-manual/R-devel/library/base/html/readRenviron.html
#
#
# Below is an example .Renviron file's contents: (please remove)
# the "#" below as these too are interprted as comments in the .Renviron file:
#
#    DBMS = "postgresql"
#    DB_SERVER = "database.server.com"
#    DB_PORT = 5432
#    DB_USER = "database_user_name_goes_here"
#    DB_PASSWORD = "your_secret_password"
#    FFTEMP_DIR = "E:/fftemp"
#
# The following describes the settings
#    DBMS, DB_SERVER, DB_PORT, DB_USER, DB_PASSWORD := These are the details used to connect
#    to your database server. For more information on how these are set, please refer to:
#    http://ohdsi.github.io/DatabaseConnector/
#
#    FFTEMP_DIR = A directory where temporary files used by the FF package are stored while running.
#.
#
# Once you have established an .Renviron file, you must restart your R session for R to pick up these new
# variables.
#
# In section 2 below, you will also need to update the code to use your site specific values. Please scroll
# down for specific instructions.
#-----------------------------------------------------------------------------------------------
#
#
# *******************************************************
# SECTION 1: Make sure to install all dependencies (not needed if already done) -------------------------------
# *******************************************************
#
# Prevents errors due to packages being built for other R versions:
Sys.setenv("R_REMOTES_NO_ERRORS_FROM_WARNINGS" = TRUE)
#
# First, it probably is best to make sure you are up-to-date on all existing packages.
# Important: This code is best run in R, not RStudio, as RStudio may have some libraries
# (like 'rlang') in use.
#update.packages(ask = "graphics")

# When asked to update packages, select '1' ('update all') (could be multiple times)
# When asked whether to install from source, select 'No' (could be multiple times)
#install.packages("devtools")
#devtools::install_github("EHDEN/CdmInspection.R")

# *******************************************************
# SECTION 2: Running the package -------------------------------------------------------------------------------
# *******************************************************
library(CdmInspection)

# Optional: specify where the temporary files (used by the ff package) will be created:
fftempdir <- if (Sys.getenv("FFTEMP_DIR") == "") "~/fftemp" else Sys.getenv("FFTEMP_DIR")
options(fftempdir = fftempdir)

# Details for connecting to the server:
dbms = Sys.getenv("DBMS")
user <- if (Sys.getenv("DB_USER") == "") NULL else Sys.getenv("DB_USER")
password <- if (Sys.getenv("DB_PASSWORD") == "") NULL else Sys.getenv("DB_PASSWORD")
server = Sys.getenv("DB_SERVER")
port = Sys.getenv("DB_PORT")
connectionString = Sys.getenv("CONNECTION_STRING")
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = password,
                                                                port = port)

# Azure connection
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = password,
                                                                connectionString = connectionString )
#conn <- DatabaseConnector::connect(dbms = dbms,connectionDetails = connectionDetails)

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

# Details specific to the database:
databaseId <- "IPCI"
databaseName <- "Integrated Primary Care Information"
databaseDescription <- "The IPCI database started in 1992 and is collected from EHR records of patients registered with their GPs throughout the Netherlands. The selection of 640 practices, of which 422 are currently still actively contributing, is representative for the entire country. The database contains records from in total 2.6 million patients (approximately 1.4 million are still active) out of a Dutch population of 17M. The observation period for a patient is determined by the date of registration at the GP and the date of leave/death. The observation period start date is refined by many quality indicators, e.g. exclusion of peaks of conditions when registering at the GP. All data before the observation period is kept as history data. Drugs are captured as prescription records with product, quantity, dosing directions, strength and indication. The duration of the drug exposure is determined for all drugs by: 1. The amount and dose extracted from the signature or if instruction is “see product instructions” we use the DDD and quantity; 2. Duration available in the record; 3. If option 1 and 2 is not possible we use the DDD derived duration, or default to 30 days otherwise. Drugs not prescribed in the GP setting might be underreported. Indications are available as diagnoses by the GPs and, indirectly, from secondary care providers but the latter might not be complete"

# Details for connecting to the CDM and storing the results
outputFolder <- file.path(getwd(), "results",databaseId)
cdmDatabaseSchema <- "synpuf"
resultsDatabaseSchema <- "prijnbeek"
vocabDatabaseSchema = "synpuf"

smallCellCount <- 5
verboseMode <- TRUE


results<-cdmInspection(connectionDetails,
                cdmDatabaseSchema = cdmDatabaseSchema,
                resultsDatabaseSchema = resultsDatabaseSchema,
                vocabDatabaseSchema = vocabDatabaseSchema,
                oracleTempSchema = oracleTempSchema,
                sourceName = databaseName,
                smallCellCount = smallCellCount,
                runSchemaChecks = TRUE,
                runVocabularyChecks = TRUE,
                runPerformanceChecks = TRUE,
                runWebAPIChecks = TRUE,
                baseUrl = "http://atlas-demo.ohdsi.org/WebAPI",
                sqlOnly = FALSE,
                outputFolder = outputFolder,
                verboseMode = verboseMode)


