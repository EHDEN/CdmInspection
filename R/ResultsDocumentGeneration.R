
#' Generates the Results Document
#'
#' @description
#' \code{generateResultsDocument} creates a word document with results based on a template
#' @param results             Results object from \code{cdmInspection}
#'
#' @param outputFolder        Folder to store the results
#' @param docTemplate         Name of the document template (EHDEN)
#' @param authors             List of author names to be added in the document
#' @param databaseDescription Description of the database
#' @param databaseName        Name of the database
#' @param databaseId          Id of the database
#' @param smallCellCount      Date with less than this number of patients are removed
#' @param silent              Flag to not create output in the terminal (default = FALSE)
#' @export
generateResultsDocument<- function(results, outputFolder, docTemplate="EHDEN", authors = "Author Names", databaseDescription, databaseName, databaseId,smallCellCount,silent=FALSE) {

  if (docTemplate=="EHDEN"){
    docTemplate <- system.file("templates", "Template-EHDEN.docx", package="CdmInspection")
    logo <- system.file("templates", "pics", "ehden-logo.png", package="CdmInspection")
  }

  ## open a new doc from the doctemplate
  doc<-officer::read_docx(path = docTemplate)
  ## add Title Page
  doc<- doc %>%
    officer::body_add_img(logo,width=6.10,height=1.59, style = "Title") %>%
    officer::body_add_par(value = paste0("CDM Inspection report for the ",databaseName," database"), style = "Title") %>%
    #body_add_par(value = "Note", style = "heading 1") %>%
    officer::body_add_par(value = paste0("Package Version: ", packageVersion("CdmInspection")), style = "Centered") %>%
    officer::body_add_par(value = paste0("Date: ", date()), style = "Centered") %>%
    officer::body_add_par(value = paste0("Authors: ", authors), style = "Centered") %>%
    officer::body_add_break()

  ## add Table of content
  doc<-doc %>%
    officer::body_add_par(value = "Table of content", style = "heading 1") %>%
    officer::body_add_toc(level = 2) %>%
    officer::body_add_break()


  ## add genereal section

  items <- c("Data Partner",
                 "Database fullname",
                 "Database acronym",
                 "Contact Person",
                 "Email",
                 "SME",
                 "Contact Person",
                 "Email SME"
                 )
  answers <- c("",databaseName, databaseId,"","","","","")
  preample <- data.frame(items,answers)
  ft <- flextable::qflextable(preample)
  ft<-flextable::set_table_properties(ft, width = 1, layout = "fixed")
  ft <- flextable::bold(ft, bold = TRUE, part = "header")
  border_v = officer::fp_border(color="gray")
  border_h = officer::fp_border(color="gray")
  ft<-flextable::border_inner_v(ft, part="all", border = border_v )

  doc<-doc %>%
    officer::body_add_par(value = "General Information", style = "heading 1") %>%

    officer::body_add_par(value = "The goal of the inspection report is to provide insight into the completeness, transparency and quality of the performed Extraction Transform, and Load (ETL) process and the readiness of the data source to be onboarded in the data network to participate in research studies.") %>%

    officer::body_add_par(value = "Contact Details", style = "heading 2") %>%
    officer::body_add_par(value = "Fill in the table below",style="Highlight") %>%

    flextable::body_add_flextable(value = ft, align = "left")
  doc<-doc %>%
    officer::body_add_par(value = "Database Description", style = "heading 2")

    if (is.null(databaseDescription)){
      doc<-doc %>%
        officer::body_add_par(value = paste0("Provide a short description of the database"), style="Highlight")
    } else {
      doc<-doc %>%
        officer::body_add_par(value = databaseDescription)
    }

    doc<-doc %>% officer::body_add_par(value = "SME Role", style = "heading 2") %>%

    officer::body_add_par(value = "Describe the involvement of the SME in the ETL Delopment process",style="Highlight") %>%
    officer::body_add_break()


  ## ETL Development section

    doc<-doc %>%
      officer::body_add_par(value = "ETL Development General", style = "heading 1") %>%
      officer::body_add_par(paste0("This section decribes the ETL development steps and discusses the quality control steps performed by the SME")) %>%
      officer::body_add_par(value = "ETL Documentation", style = "heading 2") %>%
      officer::body_add_par("Perform the following checks and discuss the findings here:", style="Highlight") %>%

      officer::body_add_par("Approve the quality of the ETL documentation with respect to its completeness and level of detail per data domain. Ideally it is based on the Rabbit-in-a-Hat mapping definition document. If a staging table approach is used, its creation needs to be described in detail.", style="Highlight") %>%
      officer::body_add_par("Does it contain enough detail on the applied business rules and are the THEMIS rules followed?", style="Highlight") %>%
      officer::body_add_par("Compare the ETL documentation with the shared ETL code to make sure it is a correct representation of the implementation. Ideally, end-to-end tests using the Rabbit-in-a-hat testFramework.R is implemented and results are shared. If this is not available explain the quality control mechanism that is applied", style="Highlight") %>%
      officer::body_add_par("Is the ETL code executable fully automatically or are there manual steps? If there are manual steps these need to be explained.", style="Highlight") %>%
      officer::body_add_par(value = "ETL Implementation", style = "heading 2") %>%
      officer::body_add_par("Described the technology used for implementing the ETL (SQL,R, Python etc).", style="Highlight") %>%

      officer::body_add_par("Provide feedback on the level of commenting and code structure. The minimum level of commenting contains an explanation of the sql query, R function, etc. See also the guidance provided by OHDSI. Code structure refers to a logical structure of the SQL/R files. We recommend that the files are name as their target table and contain all code related to that domain, e.g. insert_person.sql, insert_condition_occurence.sql. If another method is applied provide there details.", style="Highlight") %>%

       officer::body_add_par("Is there a version control mechanism in place?", style="Highlight")


    ## add Concept counts
  if (!is.null(results$dataTablesResults)) {
    df_t1 <- results$dataTablesResults$dataTablesCounts$result
    doc<-doc %>%
      officer::body_add_par(value = "Record counts data tables", style = "heading 2") %>%
      officer::body_add_par("Table 1. Shows the number of records in all clinical data tables") %>%
      my_body_add_table(value = df_t1[order(df_t1$COUNT, decreasing=TRUE),], style = "EHDEN") %>%
      officer::body_add_par(" ") %>%
      officer::body_add_par(paste("Query executed in ",sprintf("%.2f", results$dataTablesResults$dataTablesCounts$duration),"secs"))

    plot <- recordsCountPlot(as.data.frame(results$dataTablesResults$totalRecords$result))
    doc<-doc %>% officer::body_add_break() %>%
      officer::body_add_par(value = "Data density plots", style = "heading 2") %>%
      officer::body_add_gg(plot, height=4) %>%
      officer::body_add_par("Figure 1. Total record count over time per data domain")

    plot <- recordsCountPlot(as.data.frame(results$dataTablesResults$recordsPerPerson$result))
    doc<-doc %>%
      officer::body_add_gg(plot, height=4) %>%
      officer::body_add_par("Figure 2. Number of records per person over time per data domain")

    colnames(results$dataTablesResults$conceptsPerPerson$result) <- c("Domain", "Min", "P10", "P25", "MEDIAN", "P75", "P90", "Max")
    doc<-doc %>% officer::body_add_break() %>%
      officer::body_add_par(value = "Distinct concepts per person", style = "heading 2") %>%
      officer::body_add_par("Table 2. Shows the number of distinct concepts per person for all data domains") %>%
      my_body_add_table(value = results$dataTablesResults$conceptsPerPerson$result, style = "EHDEN") %>%
      officer::body_add_par(" ")

  }


  ## Vocabulary checks section
  doc<-doc %>%
    officer::body_add_par(value = "Vocabulary Mapping", style = "heading 1") %>%
    officer::body_add_par(value = "Describe how the vocabulary mapping process was implemented, and what the quality control mechanism are.", style = "Highlight") %>%
    officer::body_add_par(value = "All the custom mappings need to be shared with the report as Excel file or as source_to_concept map, to allow for random checks. Ideally these lists are sorted descending by source code frequency.", style = "Highlight")

  vocabResults <-results$vocabularyResults
  if (!is.null(vocabResults)) {
    #vocabularies table
    doc<-doc %>%

      officer::body_add_par(value = "Vocabularies", style = "heading 2") %>%
      officer::body_add_par(paste0("Vocabulary version: ",results$vocabularyResults$version)) %>%
      officer::body_add_par("Table 3. The vocabularies available in the CDM with concept count. Note that this does not reflect which concepts are actually used in the clinical CDM tables. S=Standard, C=Classification and '-'=Non-standard") %>%
      my_body_add_table(value = vocabResults$conceptCounts$result, style = "EHDEN") %>%
      officer::body_add_par(" ") %>%
      officer::body_add_par(paste("Query executed in ",sprintf("%.2f", vocabResults$conceptCounts$duration),"secs"))
    ##%>% body_end_section_landscape()

    ## add vocabulary table counts

    doc<-doc %>%
      officer::body_add_par(value = "Table counts", style = "heading 2") %>%
      officer::body_add_par("Table 4. Shows the number of records in all vocabulary tables") %>%
      my_body_add_table(value = vocabResults$vocabularyCounts$result, style = "EHDEN") %>%
      officer::body_add_par(" ") %>%
      officer::body_add_par(paste("Query executed in ",sprintf("%.2f", vocabResults$vocabularyCounts$duration),"secs"))

    ## add Mapping Completeness
    vocabResults$mappingCompleteness$result$'%Codes Mapped' <- prettyHr(vocabResults$mappingCompleteness$result$'%Codes Mapped')
    vocabResults$mappingCompleteness$result$'%Records Mapped' <- prettyHr(vocabResults$mappingCompleteness$result$'%Records Mapped')

    doc<-doc %>%
      officer::body_add_par(value = "Mapping Completeness", style = "heading 2") %>%
      officer::body_add_par("Table 5. Shows the percentage of codes that are mapped to the standardized vocabularies as well as the percentage of records.") %>%
      my_body_add_table(value = vocabResults$mappingCompleteness$result, style = "EHDEN", alignment = c('l', rep('r',6))) %>%
      officer::body_add_par(" ") %>%
      officer::body_add_par(paste("Query executed in ",sprintf("%.2f", vocabResults$mappingCompleteness$duration),"secs")) %>%
      officer::body_add_break()

    ## add Drug Level Mappings
    doc<-doc %>%
      officer::body_add_par(value = "Drug Mappings", style = "heading 2") %>%
      officer::body_add_par("Table 6. The level of the drug mappings") %>%
      my_body_add_table(value = vocabResults$drugMapping$result, style = "EHDEN") %>%
      officer::body_add_par(" ") %>%
      officer::body_add_par(paste("Query executed in ",sprintf("%.2f", vocabResults$drugMapping$duration),"secs"))

    ## add Top 25 missing mappings
    doc<-doc %>%
      officer::body_add_par(value = "Unmapped Codes", style = "heading 2")
    my_unmapped_section(doc, vocabResults$unmappedDrugs, 7, "drugs", smallCellCount)
    my_unmapped_section(doc, vocabResults$unmappedConditions, 8, "conditions", smallCellCount)
    my_unmapped_section(doc, vocabResults$unmappedMeasurements, 9, "measurements", smallCellCount)
    my_unmapped_section(doc, vocabResults$unmappedObservations, 10, "observations",smallCellCount)
    my_unmapped_section(doc, vocabResults$unmappedProcedures, 11, "procedures", smallCellCount)
    my_unmapped_section(doc, vocabResults$unmappedDevices, 12, "devices", smallCellCount)

    ## add top 25 mapped codes
    doc<-doc %>%
      officer::body_add_par(value = "Mapped Codes", style = "heading 2")
    my_mapped_section(doc, vocabResults$mappedDrugs, 13, "drugs", smallCellCount)
    my_mapped_section(doc, vocabResults$mappedConditions, 14, "conditions", smallCellCount)
    my_mapped_section(doc, vocabResults$mappedMeasurements, 15, "measurements", smallCellCount)
    my_mapped_section(doc, vocabResults$mappedObservations, 16, "observations", smallCellCount)
    my_mapped_section(doc, vocabResults$mappedProcedures, 17, "procedures", smallCellCount)
    my_mapped_section(doc, vocabResults$mappedDevices, 18, "devices", smallCellCount)

    ## add source_to_concept_map breakdown
    doc<-doc %>%
      officer::body_add_par(value = "Source to concept map", style = "heading 2") %>%
      officer::body_add_par("If you did not use the source_to_concept_map table in the ETL the table below will be empty. In that case provide your custom mappings in an Excel file.", style="Highlight") %>%
      officer::body_add_par("Table 19. Source to concept map breakdown") %>%
      my_body_add_table(value = vocabResults$sourceConceptFrequency$result, style = "EHDEN") %>%
      officer::body_add_par(" ") %>%
      officer::body_add_par(paste("Query executed in ",sprintf("%.2f", vocabResults$sourceConceptFrequency$duration),"secs")) %>%
      officer::body_add_par("Note that the full source_to_concept_map table is added in the results.zip", style="Highlight")

  } else {
    doc<-doc %>%
    officer::body_add_par("Vocabulary checks have not been executed, runVocabularyChecks = FALSE?", style="Highlight") %>%
    officer::body_add_break()
  }

  doc<-doc %>%
    officer::body_add_par(value = "Technical Infrastructure", style = "heading 1") %>%
    officer::body_add_par("Check that the following tools are available and functional: ATLAS, ACHILLES report. Functionality needs to be tested by design of cohort in Atlas, generation of cohort counts in ATLAS, execution of a simple cohort characterisation in ATLAS.", style="Highlight") %>%
    officer::body_add_par("Is the data source added in the EHDEN Database Catalogue and has the CatalogUeExport results been uploaded for the visualizations? Also describe if a process has been agreed for updating this information regularly.", style="Highlight") %>%
    officer::body_add_par(paste0("Add additional relevant information about the local infrastructure here, such as backup facilities, specifications webserver hosting ATLAS, testing environment if available etc."), style="Highlight")

  if (!is.null(results$dataTablesResults)) {
    #cdm source
    t_cdmSource <- data.table::transpose(results$cdmSource)
    colnames(t_cdmSource) <- rownames(results$cdmSource)
    field <- colnames(results$cdmSource)
    t_cdmSource <- cbind(field, t_cdmSource)
    doc<-doc %>%
      officer::body_add_par(value = "CDM Source Table", style = "heading 2") %>%
      officer::body_add_par("Table 20. cdm_source table content") %>%
      my_body_add_table(value =t_cdmSource, style = "EHDEN")
  }

  if (!is.null(results$performanceResults)) {
    #installed packages
    doc<-doc %>%
      officer::body_add_par(value = "HADES packages", style = "heading 2") %>%
      officer::body_add_par("Table 21. Versions of all installed HADES R packages") %>%
      my_body_add_table(value = results$hadesPackageVersions, style = "EHDEN")

    if (results$missingPackage=="") {
      doc<-doc %>%
      officer::body_add_par("All HADES packages were available")
    } else {
      doc<-doc %>%
      officer::body_add_par(paste0("Missing HADES packages: ",results$missingPackages))
    }

    #system detail
    doc<-doc %>%
      officer::body_add_par(value = "System Information", style = "heading 2") %>%
      officer::body_add_par(paste0("Installed R version: ",results$sys_details$r_version$version.string)) %>%
      officer::body_add_par(paste0("System CPU vendor: ",results$sys_details$cpu$vendor_id)) %>%
      officer::body_add_par(paste0("System CPU model: ",results$sys_details$cpu$model_name)) %>%
      officer::body_add_par(paste0("System CPU number of cores: ",results$sys_details$cpu$no_of_cores)) %>%
      officer::body_add_par(paste0("System RAM: ",prettyunits::pretty_bytes(as.numeric(results$sys_details$ram)))) %>%
      officer::body_add_par(paste0("DBMS: ",results$dms)) %>%
      officer::body_add_par(paste0("WebAPI version: ",results$webAPIversion)) %>%
      officer::body_add_par(" ")


    doc<-doc %>%
      officer::body_add_par(value = "Vocabulary Query Performance", style = "heading 2") %>%
      officer::body_add_par(paste0("The number of 'Maps To' relations is equal to ", results$performanceResults$performanceBenchmark$result,
                                   ". This query was executed in ",sprintf("%.2f", results$performanceResults$performanceBenchmark$duration)," secs"))

    doc<-doc %>%
      officer::body_add_par(value = "Achilles Query Performance", style = "heading 2") %>%
      officer::body_add_par("Table 22. Execution time of queries of the Achilles R-Package")

    if (!is.null(results$performanceResults$achillesTiming$result)) {
      doc<-doc %>%
        my_body_add_table(value =results$performanceResults$achillesTiming$result, style = "EHDEN") %>%
        officer::body_add_par(" ") %>%
        officer::body_add_par(paste("Query executed in ",sprintf("%.2f", results$performanceResults$achillesTiming$duration)," secs"))
    } else {
      doc<-doc %>%
        officer::body_add_par("Query did not return results ", style="Highlight")
    }
  } else {
    doc<-doc %>%
      officer::body_add_par("Performance checks have not been executed, runPerformanceChecks = FALSE?", style="Highlight") %>%
      body_add_break()
  }
    doc<-doc %>%
      officer::body_add_par(value = "Scientific Preparedness", style = "heading 1") %>%
      officer::body_add_par(paste0("This section contains several items related to the interaction with the EHDEN/OHDSI community and training after the mapping process."))

    doc<-doc %>%
      officer::body_add_par(value = "Staff training", style = "heading 2") %>%
      officer::body_add_par(paste0("Describe how the Data Partner will train and educate the different users of the system in their organizaton and what the current status is of the expertise in the team. "), style="Highlight")

    doc<-doc %>%
      officer::body_add_par(value = "Study execution", style = "heading 2") %>%
      officer::body_add_par(paste0("Describe how the Data Partner will be able to execute the ongoing OHDSI/EHDEN network studies, e.g. are there governance issues, lack of resources, etc."), style="Highlight") %>%
      officer::body_add_par(paste0("Are there plans to initiate research studies?"), style="Highlight") %>%
      officer::body_add_par(paste0("Are there plans to participate in OHDSI Working Groups?"), style="Highlight")

    doc <-  doc %>%
      body_add_par('Quality Control', style = "heading 1") %>%
      officer::body_add_par("Show that the Data Quality Dashboard results are 100% and check if the thresholds have been changed by doing a diff with the default.", style="Highlight") %>%
      officer::body_add_par("Discuss with the Data Partner why the thresholds have been changed and share this information.", style="Highlight") %>%
      officer::body_add_par("Have the Achilles results been reviewed by the Data Partner?", style="Highlight") %>%
      officer::body_add_par("How is the ETL code tested? Discuss the quality controls steps or ideally share the code that executes this. Have all checks been passed? For example, is there a comparison available of the person count on the source and CDM and are the differences explained?", style="Highlight")

    doc <-  doc %>%
      body_add_par('Maintenance', style = "heading 1") %>%
      body_add_par("Describe briefly the process the Data Partner implemented to keep the data in the OMOP CDM up-to-date when new source data will become available, if the local coding systems are updated, or if new versions of the CDM will be released. Describe how versions of the CDM will be maintained over time.", style="Highlight") %>%
      body_add_par("Describe the maintenance process put in place by the data partner for the tool updates.", style="Highlight") %>%
      body_add_break()

    doc <-  doc %>%
      body_add_par('Checklist', style = "heading 1") %>%

      body_add_par("Have the following checks been performed?", style = "Normal") %>%
      body_add_par("[ ] ATLAS cohort creation, e.g. Type 2 Diabetes", style = "Normal") %>%
      body_add_par("[ ] Check of Achilles results", style = "Normal") %>%
      body_add_par("Comments:", style = "Normal") %>%

      body_add_par("Check that all the items mentioned below are shared with EHDEN in addition to this inspection report. If items cannot be shared, add an explanation in the comments section.", style = "Normal") %>%
      body_add_par("[ ] ETL Documentation", style = "Normal") %>%
      body_add_par("[ ] ETL Code", style = "Normal") %>%
      body_add_par("[ ] DQD dashboard json file", style = "Normal") %>%
      body_add_par("[ ] White Rabbit output", style = "Normal") %>%
      body_add_par("[ ] CdmInspection results.zip ", style = "Normal") %>%
      body_add_par("Comments:", style = "Normal")


  ## save the doc as a word file
  writeLines(paste0("Saving doc to ",outputFolder,"/",results$databaseId,"-results.docx"))
  print(doc, target = paste(outputFolder,"/",results$databaseId,"-results.docx",sep = ""))
}



