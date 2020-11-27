--Query 2 Completeness of Mappings per Entity
select 'condition' as domain, count(distinct source_value) as num_source_concepts,
       sum(case when is_mapped > 0 then 1 else 0 end) as num_mapped_codes,
       1.0*sum(case when is_mapped > 0 then 1 else 0 end) / count(distinct source_value) as pct_mapped_codes,
       sum(num_records) as num_records,
       sum(case when is_mapped > 0 then num_records else 0 end) as num_mapped_records,
       1.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records) as pct_mapped_records
from
(
select condition_source_value as source_value, case when condition_concept_id > 0 then 1 else 0 end as is_mapped, count(person_id) as num_records
from @cdmDatabaseSchema.condition_occurrence
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
from @cdmDatabaseSchema.procedure_occurrence
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
from @cdmDatabaseSchema.drug_exposure
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
from @cdmDatabaseSchema.observation
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
from @cdmDatabaseSchema.measurement
group by measurement_source_value, case when measurement_concept_id > 0 then 1 else 0 end
) t1


union

select 'measurement-unit' as domain, count(distinct source_value) as num_source_concepts,
       sum(case when is_mapped > 0 then 1 else 0 end) as num_mapped_codes,
       1.0*sum(case when is_mapped > 0 then 1 else 0 end) / count(distinct source_value) as pct_mapped_codes,
       sum(num_records) as num_records,
       sum(case when is_mapped > 0 then num_records else 0 end) as num_mapped_records,
       1.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records) as pct_mapped_records
from
(
    select unit_source_value as source_value, case when unit_concept_id > 0 then 1 else 0 end as is_mapped, count(person_id) as num_records
    from @cdmDatabaseSchema.measurement
    where unit_concept_id IS NOT NULL
    group by unit_source_value, case when unit_concept_id > 0 then 1 else 0 end
) t1

union

select 'observation-unit' as domain, count(distinct source_value) as num_source_concepts,
       sum(case when is_mapped > 0 then 1 else 0 end) as num_mapped_codes,
       1.0*sum(case when is_mapped > 0 then 1 else 0 end) / count(distinct source_value) as pct_mapped_codes,
       sum(num_records) as num_records,
       sum(case when is_mapped > 0 then num_records else 0 end) as num_mapped_records,
       1.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records) as pct_mapped_records
from
(
    select unit_source_value as source_value, case when unit_concept_id > 0 then 1 else 0 end as is_mapped, count(person_id) as num_records
    from @cdmDatabaseSchema.observation
    where unit_concept_id IS NOT NULL
    group by unit_source_value, case when unit_concept_id > 0 then 1 else 0 end
) t1

union

select 'measurement-value' as domain, count(distinct source_value) as num_source_concepts,
       sum(case when is_mapped > 0 then 1 else 0 end) as num_mapped_codes,
       1.0*sum(case when is_mapped > 0 then 1 else 0 end) / count(distinct source_value) as pct_mapped_codes,
       sum(num_records) as num_records,
       sum(case when is_mapped > 0 then num_records else 0 end) as num_mapped_records,
       1.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records) as pct_mapped_records
from
(
    select value_source_value as source_value, case when value_as_concept_id > 0 then 1 else 0 end as is_mapped, count(person_id) as num_records
    from @cdmDatabaseSchema.measurement
    where value_as_concept_id IS NOT NULL
    group by value_source_value, case when value_as_concept_id > 0 then 1 else 0 end
) t1

union

select 'observation-value' as domain, count(distinct source_value) as num_source_concepts,
       sum(case when is_mapped > 0 then 1 else 0 end) as num_mapped_codes,
       1.0*sum(case when is_mapped > 0 then 1 else 0 end) / count(distinct source_value) as pct_mapped_codes,
       sum(num_records) as num_records,
       sum(case when is_mapped > 0 then num_records else 0 end) as num_mapped_records,
       1.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records) as pct_mapped_records
from
(
    select '' as source_value, case when value_as_concept_id > 0 then 1 else 0 end as is_mapped, count(person_id) as num_records
    from @cdmDatabaseSchema.observation
    where value_as_concept_id IS NOT NULL
    group by case when value_as_concept_id > 0 then 1 else 0 end
) t1
