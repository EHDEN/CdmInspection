# CdmInspection
R Package to support quality control inspection of an OMOP-CDM instance

# Introduction
The European Health Data and Evidence Network (EHDEN) project has multiple yearly Open Calls for financial support for data partners to map their data to the OMOP-CDM, for more information see the [EHDEN](https://www.ehden.eu/open-calls/process-overview/) website. In additon, EHDEN is training Small and Medium-sized Enterprises in Europe to provide services to the data partners to map their data to the OMOP-CDM. A large number of these SMEs are now active all over Europe as shown in the {SME Catalogue]( https://www.ehden.eu/business-directory/). 

Quality control of the mapping is clearly important and therefore a procedure has been developed called SME Inspection in which a certified SME performs a series of tests on the CDM and produces a report that is send to the EHDEN Team for review. The template for this report can be found here TO BE ADDED. The goal of the inspection report is to provide insight into the completeness, transparency and quality of the performed Extraction Transform, and Load (ETL) process and the readiness of the data partner to be onboarded in the EHDEN and OHDSI data networks and participate in research studies. If the SME that is performing the inspection was not involved in the ETL implementation we advise to use a two-stage inspection process. A first inspection report can be made to provide recommendations to the Data Partner on how to improve the ETL and processes, if necessary. Ideally, this includes a site visit of the SME after providing instructions on the content of the report. The Data Partner can share this draft report with EHDEN to obtain additional input. Once the improvements have been made the final report can be created by the SME and sent to EHDEN for approval.  

The CdmInspection R Package is part of this SME Inspection procedure and performs the following checks on top of the required [Data Quality Dashboard](https://github.com/OHDSI/DataQualityDashboard) step:

# Features

**Vocabulary Checks**  
1. For all custom mapped vocabularies extract the top 50 codes order by frequency from the source_to_concept map. The SME has to approve these top 50 codes. All custom mappings will be extracted as well as part of the package output. Note if the source_to_concept map is not used in the ETL process this information still has to be provided manually for the inspection.
2. For each domain generate statistics on the number of unmapped codes and and unmapped records.
3. Extract the vocabulary table and check if all the required vocabularies are present.

**Technical Infrastructure Checks**
1. Execution of short and longer running queries to test the performance of the system. This information is useful for the SME to provide further guidance on optimizing the infrastructure.
2. Checks on the number of CPUs, memory available in R.
3. Extract the versions of all installed R packages, checks if core [HADES](https://ohdsi.github.io/Hades/) packages are installed.
4. Check if ATLAS is installed and WebAPI is running
5. Check if Achilles results are available in ATLAS.
6. Check if CatalogueExport package can execute correctly.
7. Extraction of CDM_Source table

Technology
==========
The CdmInspection package is an R package.

System Requirements
===================
Requires R. Some of the packages used by CdmInspection require Java.

Installation
=============

1. See the instructions [here](https://ohdsi.github.io/Hades/rSetup.html) for configuring your R environment, including Java.

2. In R, use the following commands to download and install CdmInspection:

  ```r
  remotes::install.github("EHDEN/CdmInspection")
```

User Documentation
==================

PDF versions of the documentation are available:
* Package manual: 
* Vignette: 

Support
=======
* Developer questions/comments/feedback can be provided via the EHDEN service portal (TO BE ADDED)
* We use the <a href="https://github.com/EHDEN/CdmInspectionm/issues">GitHub issue tracker</a> for all bugs/issues/enhancements

Contributing
============
This package is maintained by the EHDEN consortium as part of its quality control procedures. Additions are welcome through pull requests. We suggest to first create an issue and discuss with the maintainer before implementing additional functionality.

License
=======
CdmInspection is licensed under Apache License 2.0

Development
===========
CdmInspection is being developed in R Studio.

### Development status

Under development by the EHDEN consortium do not use!
