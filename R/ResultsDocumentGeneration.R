library(officer)
library(magrittr)


#' @export
generateResultsDocument<- function(results, outputFolder, docTemplate="EHDEN",smeName="TO ADD", author = "TO ADD", silent=FALSE) {

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
    body_add_par(value = paste0("Author: ", author), style = "Centered") %>%
    body_add_break()

  ## add Table of content
  doc<-doc %>%
    officer::body_add_par(value = "Table of content", style = "heading 1") %>%
    officer::body_add_toc(level = 2) %>%
    body_add_break()


  ## add introduction section
  doc<-doc %>%
    officer::body_add_par(value = "Executive Summary", style = "heading 1") %>%
    officer::body_add_par(value = paste0("This inspection report has been created for the ",
            databaseName, " database",
            " as part of the inspection task performed by ", smeName, ".")) %>%
  officer::body_add_par(value = "The goal of the inspection report is to provide insight into the completeness, transparency and quality of the performed Extraction Transform, and Load (ETL) process and the readiness of the data partner to be onboarded in the EHDEN and OHDSI data networks and participate in research studies.")

  ## add the analysis name as Section to the doc
  results$mappingCompleteness$'%Codes Mapped' <- prettyHr(results$mappingCompleteness$'%Codes Mapped')
  results$mappingCompleteness$'%Records Mapped' <- prettyHr(results$mappingCompleteness$'%Records Mapped')

  doc<-doc %>%
    officer::body_add_par(value = "Mapping Completeness", style = "heading 1") %>%
    officer::body_add_par("Table 1. Shows the percentage of codes that are mapped to the standardized vocabularies as well as the percentage of records.") %>%
    officer::body_add_table(value = results$mappingCompleteness, style = "DefaultTable") %>%
    body_add_break()

  doc <- doc %>% officer::body_end_section_portrait()

  #vocabularies
  doc<-doc %>%

    officer::body_add_par(value = "Vocabularies", style = "heading 1") %>%
    officer::body_add_par(paste0("Vocabulary version: ",results$vocabversion)) %>%
    officer::body_add_par("Table 2. The vocabularies available in the CDM") %>%
    officer::body_add_table(value = results$vocabularies, style = "DefaultTable") %>%
    body_end_section_landscape()

  #installed packages
  doc<-doc %>%

    officer::body_add_par(value = "HADES packages", style = "heading 1") %>%
    officer::body_add_par("Table 3. Versions of all installed HADES R packages") %>%
    officer::body_add_table(value = results$hadesPackageVersions, style = "DefaultTable")

  #system detail
  doc<-doc %>%

    officer::body_add_par(value = "Technical Infrastructure", style = "heading 1") %>%
    officer::body_add_par("Table 4. cdm_source table content") %>%
    officer::body_add_table(value =results$cdmSource, style = "DefaultTable") %>%
    officer::body_add_par(" ") %>%
    officer::body_add_par(paste0("Installed R version: ",results$sys_details$r_version$version.string)) %>%
    officer::body_add_par(paste0("System CPU vendor: ",results$sys_details$cpu$vendor_id)) %>%
    officer::body_add_par(paste0("System CPU model: ",results$sys_details$cpu$model_name)) %>%
    officer::body_add_par(paste0("System CPU number of cores: ",results$sys_details$cpu$no_of_cores)) %>%
    officer::body_add_par(paste0("System RAM: ",prettyunits::pretty_bytes(as.numeric(results$sys_details$ram)))) %>%
    officer::body_add_par(paste0("DBMS: ",results$dms)) %>%
    officer::body_add_par(paste0("WebAPI version: ",results$webAPIversion)) %>%
    officer::body_add_par(paste0("Schema Check: ",results$schemaValid)) %>%
    officer::body_add_par(" ") %>%

    officer::body_add_par(paste0("Add relavant information about the local infrastructure here, such as backup facilities, specifications webserver hosting ATLAS, testing environment if available etc."), style="Highlight")



  ## save the doc as a word file
  writeLines(paste0("Saving doc to ",outputFolder,"/",results$databaseId,"-results.docx"))
  print(doc, target = paste(outputFolder,"/",results$databaseId,"-results.docx",sep = ""))
}



