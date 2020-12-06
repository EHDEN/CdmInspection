-- Unmapped devices

SELECT *
FROM (
	select ROW_NUMBER() OVER(ORDER BY count_big(device_exposure_id) DESC) AS ROW_NUM,
       device_source_value as "Source Value",
       count_big(device_exposure_id) as "#Records",
       count_big(distinct person_id) as "#Subjects"
       from @cdmDatabaseSchema.device_exposure where device_concept_id = 0
group by device_source_value
having count_big(device_exposure_id)>10
) z
WHERE z.ROW_NUM <= 25
ORDER BY z.ROW_NUM
