-- Levels at which drugs are mapped

select concept_class_id as "Class",
       count( drug_exposure_id) as "#Records",
       count(distinct person_id) as "#Patients",
       count(distinct drug_source_value) as "#Source Codes"
from @cdmDatabaseSchema.drug_exposure
join @cdmDatabaseSchema.concept on drug_concept_id=concept_id
group by concept_class_id
order by "#Source Codes" DESC
