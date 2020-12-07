-- Levels at which drugs are mapped

select concept_class_id as "Class",
       count_big( drug_exposure_id) as "#Records",
       count_big(distinct person_id) as "#Patients",
       count_big(distinct drug_source_value) as "#Source Codes"
from @cdmDatabaseSchema.drug_exposure
join @vocabDatabaseSchema.concept on drug_concept_id=concept_id
group by concept_class_id
order by "#Source Codes" DESC
