library(officer)
library(magrittr)


#' @export
generateResultsDocument<- function(results, outputFolder, docTemplate="EHDEN", authors = "Author Names", databaseDescription, databaseName, databaseId,silent=FALSE) {

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
    body_add_par(value = paste0("Package Version: ", packageVersion("cdmInspection")), style = "Centered") %>%
    body_add_par(value = paste0("Date: ", date()), style = "Centered") %>%
    body_add_par(value = paste0("Authors: ", authors), style = "Centered") %>%
    body_add_break()





  ## add Table of content
  doc<-doc %>%
    officer::body_add_par(value = "Table of content", style = "heading 1") %>%
    officer::body_add_toc(level = 2) %>%
    body_add_break()

  ## add preample

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
  ft <- qflextable(preample)
  ft<-set_table_properties(ft, width = 1, layout = "fixed")
  ft <- bold(ft, bold = TRUE, part = "header")
  border_v = fp_border(color="gray")
  border_h = fp_border(color="gray")
  ft<-border_inner_v(ft, part="all", border = border_v )

  doc<-doc %>%
    officer::body_add_par(value = "General Information", style = "heading 1") %>%

    officer::body_add_par(value = "The goal of the inspection report is to provide insight into the completeness, transparency and quality of the performed Extraction Transform, and Load (ETL) process and the readiness of the data source to be onboarded in the data network to participate in research studies.") %>%

    officer::body_add_par(value = "Contact Details", style = "heading 2") %>%
    body_add_par(value = "Fill in the table below",style="Highlight") %>%

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

    body_add_par(value = "Describe the involvement of the SME in the ETL Delopment process",style="Highlight") %>%
    body_add_break()


  doc<-doc %>%
    officer::body_add_par(value = "Vocabulary Checks", style = "heading 1") %>%
    officer::body_add_par(paste0("In this section the results of the vocabulary checks are discussed."))

  vocabResults <-results$vocabularyResults
  #vocabularies table
  doc<-doc %>%

    officer::body_add_par(value = "Vocabularies", style = "heading 2") %>%
    officer::body_add_par(paste0("Vocabulary version: ",results$vocabularyResults$version)) %>%
    officer::body_add_par("Table 1. The vocabularies available in the CDM") %>%
    my_body_add_table(value = vocabResults$vocabularies$result, style = "EHDEN") %>%
    officer::body_add_par(" ") %>%
    officer::body_add_par(paste("Query executed in ",sprintf("%.2f", vocabResults$vocabularies$duration),"secs"))
  ##%>% body_end_section_landscape()

  ## add Concept counts

  doc<-doc %>%
    officer::body_add_par(value = "Concept counts", style = "heading 2") %>%
    officer::body_add_par("Table 2. Shows the content of the concept table") %>%
    my_body_add_table(value = vocabResults$conceptCounts$result, style = "EHDEN") %>%
    officer::body_add_par(" ") %>%
    officer::body_add_par(paste("Query executed in ",sprintf("%.2f", vocabResults$conceptCounts$duration),"secs"))

  ## add vocabulary table counts

  doc<-doc %>%
    officer::body_add_par(value = "Table counts", style = "heading 2") %>%
    officer::body_add_par("Table 3. Shows the number of records in all vocabulary tables") %>%
    my_body_add_table(value = vocabResults$vocabularyCounts$result, style = "EHDEN") %>%
    officer::body_add_par(" ") %>%
    officer::body_add_par(paste("Query executed in ",sprintf("%.2f", vocabResults$vocabularyCounts$duration),"secs"))

  ## add Mapping Completeness
  vocabResults$mappingCompleteness$result$'%Codes Mapped' <- prettyHr(vocabResults$mappingCompleteness$result$'%Codes Mapped')
  vocabResults$mappingCompleteness$result$'%Records Mapped' <- prettyHr(vocabResults$mappingCompleteness$result$'%Records Mapped')

  doc<-doc %>%
    officer::body_add_par(value = "Mapping Completeness", style = "heading 2") %>%
    officer::body_add_par("Table 4. Shows the percentage of codes that are mapped to the standardized vocabularies as well as the percentage of records.") %>%
    my_body_add_table(value = vocabResults$mappingCompleteness$result, style = "EHDEN") %>%
    officer::body_add_par(" ") %>%
    officer::body_add_par(paste("Query executed in ",sprintf("%.2f", vocabResults$mappingCompleteness$duration),"secs")) %>%
    body_add_break()

  ## add Drug Level Mappings
  doc<-doc %>%
    officer::body_add_par(value = "Drug Mappings", style = "heading 2") %>%
    officer::body_add_par("Table 5. The level of the drug mappings") %>%
    my_body_add_table(value = vocabResults$drugMapping$result, style = "EHDEN") %>%
    officer::body_add_par(" ") %>%
    officer::body_add_par(paste("Query executed in ",sprintf("%.2f", vocabResults$drugMapping$duration),"secs")) %>%
    body_add_break()

 ## doc <- doc %>% officer::body_end_section_portrait()

  doc<-doc %>%
    officer::body_add_par(value = "Infrastructure Checks", style = "heading 1")

  #installed packages
  doc<-doc %>%

    officer::body_add_par(value = "HADES packages", style = "heading 2") %>%
    officer::body_add_par("Table 6. Versions of all installed HADES R packages") %>%
    my_body_add_table(value = results$hadesPackageVersions, style = "EHDEN")

  #system detail
  t_cdmSource <- transpose(results$cdmSource)
  colnames(t_cdmSource) <- rownames(results$cdmSource)
  field <- colnames(results$cdmSource)
  t_cdmSource <- cbind(field, t_cdmSource)
  doc<-doc %>%

    officer::body_add_par(value = "CDM Source Table", style = "heading 2") %>%
    officer::body_add_par("Table 7. cdm_source table content") %>%
    my_body_add_table(value =t_cdmSource, style = "EHDEN",)

  doc<-doc %>%
    officer::body_add_par(value = "System Information", style = "heading 2") %>%
    officer::body_add_par(paste0("Installed R version: ",results$sys_details$r_version$version.string)) %>%
    officer::body_add_par(paste0("System CPU vendor: ",results$sys_details$cpu$vendor_id)) %>%
    officer::body_add_par(paste0("System CPU model: ",results$sys_details$cpu$model_name)) %>%
    officer::body_add_par(paste0("System CPU number of cores: ",results$sys_details$cpu$no_of_cores)) %>%
    officer::body_add_par(paste0("System RAM: ",prettyunits::pretty_bytes(as.numeric(results$sys_details$ram)))) %>%
    officer::body_add_par(paste0("DBMS: ",results$dms)) %>%
    officer::body_add_par(paste0("WebAPI version: ",results$webAPIversion)) %>%
    officer::body_add_par(paste0("Schema Check: ",results$schemaValid)) %>%
    officer::body_add_par(" ")

  doc<-doc %>%
    officer::body_add_par(value = "Vocabulary Query Performance", style = "heading 2") %>%
    officer::body_add_par(paste0("The number of 'Maps To' relations is equal to ", results$performanceResults$performanceBenchmark$result,
                                 ". This query was executed in ",sprintf("%.2f", results$performanceResults$performanceBenchmark$duration)," secs"))

    doc<-doc %>%
    officer::body_add_par(value = "Catalogue Export Query Performance", style = "heading 2") %>%
    officer::body_add_par("Table 8. Execution time of queries of the CatalogExport R-Package") %>%
    my_body_add_table(value =results$performanceResults$catalogueExportTiming$result, style = "EHDEN") %>%
    officer::body_add_par(" ") %>%
    officer::body_add_par(paste("Query executed in ",sprintf("%.2f", results$performanceResults$catalogueExportTiming$duration)," secs"))

    doc<-doc %>%
    officer::body_add_par(value = "Additional Details", style = "heading 2") %>%
    officer::body_add_par(paste0("Add additional relevant information about the local infrastructure here, such as backup facilities, specifications webserver hosting ATLAS, testing environment if available etc."), style="Highlight")

    doc<-doc %>%
      officer::body_add_par(value = "Scientific Preparedness", style = "heading 1") %>%
      officer::body_add_par(paste0("This section contains several items related to the interaction with the EHDEN/OHDSI community and training after the mapping process."))

    doc<-doc %>%
      officer::body_add_par(value = "Staff training", style = "heading 2") %>%
      officer::body_add_par(paste0("Describe how the Data Partner will train and educate the different users of the system in their organizaton and what the current status is of the expertise in the team. "), style="Highlight")

    doc<-doc %>%
      officer::body_add_par(value = "Study execution", style = "heading 2") %>%
      officer::body_add_par(paste0("Describe if the Data Partner will be able to execute the ongoing OHDSI/EHDEN network studies, e.g. are there governance issues, lack of resources, etc."), style="Highlight") %>%
      officer::body_add_par(paste0("Are there plans to initiate research studies?"), style="Highlight") %>%
      officer::body_add_par(paste0("Are there plans to participate in OHDSI Working Groups?"), style="Highlight")


    doc <-  doc %>%
      body_add_par('Checklist', style = "heading 1") %>%
      body_add_par("Check that all the items mentioned below are shared with EHDEN in addition to this inspection report. If items cannot be shared, add an explanation in the comments section.", style = "Normal") %>%
      addCheckListItem("ETL Documentation") %>%
      addCheckListItem("DQD dashboard json file") %>%
      addCheckListItem("White Rabbit output") %>%
      addCheckListItem("Source_to_concept map") %>%
      addCheckListItem("CdmInspection results.zip ") %>%
      body_add_par("Comments:", style = "Normal")


  ## save the doc as a word file
  writeLines(paste0("Saving doc to ",outputFolder,"/",results$databaseId,"-results.docx"))
  print(doc, target = paste(outputFolder,"/",results$databaseId,"-results.docx",sep = ""))
}



