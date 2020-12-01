-- Unmapped devices

select top 25
       device_source_value as "Source Value",
       count(device_exposure_id) as "#Records",
       count(distinct person_id) as "#Subjects"
       from @cdmDatabaseSchema.device_exposure where device_concept_id = 0
group by device_source_value
having count(device_exposure_id)>10
order by count(device_exposure_id) DESC
