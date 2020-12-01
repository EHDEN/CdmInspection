-- Unmapped measurements

select top 25
       measurement_source_value as "Source Value",
       count(measurement_id) as "#Records",
       count(distinct person_id) as "#Subjects"
       from @cdmDatabaseSchema.measurement where measurement_concept_id = 0
group by measurement_source_value
having count(measurement_id)>10
order by count(measurement_id) DESC
