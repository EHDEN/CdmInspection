-- Query 1 Levels at which drugs are mapped
select concept_class_id,count( drug_exposure_id)as count_records,count(distinct person_id) as count_patients, count(distinct drug_source_value) as count_source_codes
from drug_exposure
join concept on drug_concept_id=concept_id
group by concept_class_id





--Query 2 Completeness of Mappings per Entity
select 'Condition' as domain, count(distinct source_value) as num_source_concepts,
       sum(case when is_mapped > 0 then 1 else 0 end) as num_mapped_codes,
       1.0*sum(case when is_mapped > 0 then 1 else 0 end) / count(distinct source_value) as pct_mapped_codes,
       sum(num_records) as num_records,
       sum(case when is_mapped > 0 then num_records else 0 end) as num_mapped_records,
       1.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records) as pct_mapped_records
from
(
select condition_source_value as source_value, case when condition_concept_id > 0 then 1 else 0 end as is_mapped, count(person_id) as num_records
from condition_occurrence
group by condition_source_value, case when condition_concept_id > 0 then 1 else 0 end
) t1

union

select 'procedure' as domain, count(distinct source_value) as num_source_concepts,
       sum(case when is_mapped > 0 then 1 else 0 end) as num_mapped_codes,
       1.0*sum(case when is_mapped > 0 then 1 else 0 end) / count(distinct source_value) as pct_mapped_codes,
       sum(num_records) as num_records,
       sum(case when is_mapped > 0 then num_records else 0 end) as num_mapped_records,
       1.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records) as pct_mapped_records
from
(
select procedure_source_value as source_value, case when procedure_concept_id > 0 then 1 else 0 end as is_mapped, count(person_id) as num_records
from procedure_occurrence
group by procedure_source_value, case when procedure_concept_id > 0 then 1 else 0 end
) t1


union

select 'drug' as domain, count(distinct source_value) as num_source_concepts,
       sum(case when is_mapped > 0 then 1 else 0 end) as num_mapped_codes,
       1.0*sum(case when is_mapped > 0 then 1 else 0 end) / count(distinct source_value) as pct_mapped_codes,
       sum(num_records) as num_records,
       sum(case when is_mapped > 0 then num_records else 0 end) as num_mapped_records,
       1.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records) as pct_mapped_records
from
(
select drug_source_value as source_value, case when drug_concept_id > 0 then 1 else 0 end as is_mapped, count(person_id) as num_records
from drug_exposure
group by drug_source_value, case when drug_concept_id > 0 then 1 else 0 end
) t1



union

select 'observation' as domain, count(distinct source_value) as num_source_concepts,
       sum(case when is_mapped > 0 then 1 else 0 end) as num_mapped_codes,
       1.0*sum(case when is_mapped > 0 then 1 else 0 end) / count(distinct source_value) as pct_mapped_codes,
       sum(num_records) as num_records,
       sum(case when is_mapped > 0 then num_records else 0 end) as num_mapped_records,
       1.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records) as pct_mapped_records
from
(
select observation_source_value as source_value, case when observation_concept_id > 0 then 1 else 0 end as is_mapped, count(person_id) as num_records
from observation
group by observation_source_value, case when observation_concept_id > 0 then 1 else 0 end
) t1



union

select 'measurement' as domain, count(distinct source_value) as num_source_concepts,
       sum(case when is_mapped > 0 then 1 else 0 end) as num_mapped_codes,
       1.0*sum(case when is_mapped > 0 then 1 else 0 end) / count(distinct source_value) as pct_mapped_codes,
       sum(num_records) as num_records,
       sum(case when is_mapped > 0 then num_records else 0 end) as num_mapped_records,
       1.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records) as pct_mapped_records
from
(
select measurement_source_value as source_value, case when measurement_concept_id > 0 then 1 else 0 end as is_mapped, count(person_id) as num_records
from measurement
group by measurement_source_value, case when measurement_concept_id > 0 then 1 else 0 end
) t1






--Query 3 Unmapped drugs

select drug_source_value,count(drug_exposure_id) as count_records,count(distinct person_id) as count_subjects from drug_exposure where drug_concept_id = 0
group by drug_source_value
having count(drug_exposure_id)>10
order by count(drug_exposure_id) DESC
