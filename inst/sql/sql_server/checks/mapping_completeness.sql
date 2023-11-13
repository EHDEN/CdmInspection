select  'Condition' as domain,
        count_big(*) as n_codes_source,
        sum(is_mapped) as n_codes_mapped,
        100.0*sum(is_mapped) / count_big(*) as p_codes_mapped,
        sum(num_records) as n_records_source,
        sum(case when is_mapped > 0 then num_records else 0 end) as n_records_mapped,
        100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records) as p_records_mapped
from
(
select condition_source_value, case when condition_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
from @cdmDatabaseSchema.condition_occurrence
group by condition_source_value, case when condition_concept_id > 0 then 1 else 0 end
) T

union

select 'Procedure', count_big(*),
        sum(is_mapped),
        100.0*sum(is_mapped) / count_big(*),
        sum(num_records),
        sum(case when is_mapped > 0 then num_records else 0 end),
        100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
select procedure_source_value, case when procedure_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
from @cdmDatabaseSchema.procedure_occurrence
group by procedure_source_value, case when procedure_concept_id > 0 then 1 else 0 end
) T

union

select 'Device', count_big(*),
        sum(is_mapped),
        100.0*sum(is_mapped) / count_big(*),
        sum(num_records),
        sum(case when is_mapped > 0 then num_records else 0 end),
        100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
select device_source_value, case when device_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
from @cdmDatabaseSchema.device_exposure
group by device_source_value, case when device_concept_id > 0 then 1 else 0 end
) T


union

select 'Drug', count_big(*),
        sum(is_mapped),
        100.0*sum(is_mapped) / count_big(*),
        sum(num_records),
        sum(case when is_mapped > 0 then num_records else 0 end),
        100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
select drug_source_value, case when drug_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
from @cdmDatabaseSchema.drug_exposure
group by drug_source_value, case when drug_concept_id > 0 then 1 else 0 end
) T



union

select 'Observation', count_big(*),
        sum(is_mapped),
        100.0*sum(is_mapped) / count_big(*),
        sum(num_records),
        sum(case when is_mapped > 0 then num_records else 0 end),
        100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
select observation_source_value, case when observation_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
from @cdmDatabaseSchema.observation
group by observation_source_value, case when observation_concept_id > 0 then 1 else 0 end
) T



union

select 'Measurement', count_big(*),
        sum(is_mapped),
        100.0*sum(is_mapped) / count_big(*),
        sum(num_records),
        sum(case when is_mapped > 0 then num_records else 0 end),
        100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
select measurement_source_value, case when measurement_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
from @cdmDatabaseSchema.measurement
group by measurement_source_value, case when measurement_concept_id > 0 then 1 else 0 end
) T

union

select 'Visit', count_big(*),
        sum(is_mapped),
        100.0*sum(is_mapped) / count_big(*),
        sum(num_records),
        sum(case when is_mapped > 0 then num_records else 0 end),
        100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
select visit_source_value, case when visit_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
from @cdmDatabaseSchema.visit_occurrence
group by visit_source_value, case when visit_concept_id > 0 then 1 else 0 end
) T

union

select 'Measurement unit', count_big(*),
      sum(is_mapped),
      100.0*sum(is_mapped) / count_big(*),
      sum(num_records),
      sum(case when is_mapped > 0 then num_records else 0 end),
      100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
   select unit_source_value, case when unit_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
   from @cdmDatabaseSchema.measurement
   where unit_concept_id IS NOT NULL
   group by unit_source_value, case when unit_concept_id > 0 then 1 else 0 end
) T

union

select 'Observation unit', count_big(*),
      sum(is_mapped),
      100.0*sum(is_mapped) / count_big(*),
      sum(num_records),
      sum(case when is_mapped > 0 then num_records else 0 end),
      100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
   select unit_source_value, case when unit_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
   from @cdmDatabaseSchema.observation
   where unit_concept_id IS NOT NULL
   group by unit_source_value, case when unit_concept_id > 0 then 1 else 0 end
) T

union

select 'Measurement value', count_big(*),
      sum(is_mapped),
      100.0*sum(is_mapped) / count_big(*),
      sum(num_records),
      sum(case when is_mapped > 0 then num_records else 0 end),
      100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
   select value_source_value, case when value_as_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
   from @cdmDatabaseSchema.measurement
   where value_as_concept_id IS NOT NULL
   group by value_source_value, case when value_as_concept_id > 0 then 1 else 0 end
) T

union

select 'Observation value', count_big(*),
      sum(is_mapped),
      100.0*sum(is_mapped) / count_big(*),
      sum(num_records),
      sum(case when is_mapped > 0 then num_records else 0 end),
      100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
   select '', case when value_as_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
   from @cdmDatabaseSchema.observation
   where value_as_concept_id IS NOT NULL
   group by case when value_as_concept_id > 0 then 1 else 0 end
) T

union

select 'Provider Specialty', count_big(*),
      sum(is_mapped),
      100.0*sum(is_mapped) / count_big(*),
      sum(num_records),
      sum(case when is_mapped > 0 then num_records else 0 end),
      100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
   select specialty_source_value, case when specialty_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
   from @cdmDatabaseSchema.provider
   where specialty_concept_id IS NOT NULL
   group by specialty_source_value, case when specialty_concept_id > 0 then 1 else 0 end
) T

union

select 'Specimen', count_big(*),
      sum(is_mapped),
      100.0*sum(is_mapped) / count_big(*),
      sum(num_records),
      sum(case when is_mapped > 0 then num_records else 0 end),
      100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
   select specimen_source_value, case when specimen_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
   from @cdmDatabaseSchema.specimen
   where specimen_concept_id IS NOT NULL
   group by specimen_source_value, case when specimen_concept_id > 0 then 1 else 0 end
) T

union

select 'Death cause', count_big(*),
      sum(is_mapped),
      100.0*sum(is_mapped) / count_big(*),
      sum(num_records),
      sum(case when is_mapped > 0 then num_records else 0 end),
      100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
   select cause_source_value, case when cause_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
   from @cdmDatabaseSchema.death
   where cause_concept_id IS NOT NULL
   group by cause_source_value, case when cause_concept_id > 0 then 1 else 0 end
) T

union

select 'Condition status', count_big(*),
      sum(is_mapped),
      100.0*sum(is_mapped) / count_big(*),
      sum(num_records),
      sum(case when is_mapped > 0 then num_records else 0 end),
      100.0*sum(case when is_mapped > 0 then num_records else 0 end)/sum(num_records)
from
(
   select condition_status_source_value, case when condition_status_concept_id > 0 then 1 else 0 end as is_mapped, count_big(*) as num_records
   from @cdmDatabaseSchema.condition_occurrence
   where condition_status_concept_id IS NOT NULL
   group by condition_status_source_value, case when condition_status_concept_id > 0 then 1 else 0 end
) T
