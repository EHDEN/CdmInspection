-- Unmapped devices

SELECT *
FROM (
	select ROW_NUMBER() OVER(ORDER BY count_big(device_exposure_id) DESC) AS ROW_NUM,
       device_source_value as source_value,
       floor((count_big(device_exposure_id)+99)/100)*100 as n_records,
       floor((count_big(distinct person_id)+99)/100)*100 as n_subjects
       from @cdmDatabaseSchema.device_exposure where device_concept_id = 0
group by device_source_value
having count_big(device_exposure_id)>@smallCellCount
) z
WHERE z.ROW_NUM <= 25
ORDER BY z.ROW_NUM
