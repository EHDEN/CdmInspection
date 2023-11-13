-- Levels at which drugs are mapped

select concept_class_id as class,
       count_big(drug_exposure_id) as n_records,
       count_big(distinct person_id) as n_patients,
       count_big(distinct drug_source_value) as n_source_codes
from @cdmDatabaseSchema.drug_exposure
join @vocabDatabaseSchema.concept on drug_concept_id=concept_id
where concept.domain_id = 'Drug'
group by concept_class_id
order by n_records DESC
