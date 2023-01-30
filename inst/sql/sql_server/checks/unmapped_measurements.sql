-- Unmapped measurements

SELECT *
FROM (
	select ROW_NUMBER() OVER(ORDER BY count_big(measurement_id) DESC) AS ROW_NUM,
       measurement_source_value as source_value,
       floor((count_big(measurement_id)+99)/100)*100 as n_records,
       floor((count_big(distinct person_id)+99)/100)*100 as n_subjects
       from @cdmDatabaseSchema.measurement where measurement_concept_id = 0
group by measurement_source_value
having count_big(measurement_id)>@smallCellCount
) z
WHERE z.ROW_NUM <= 25
ORDER BY z.ROW_NUM
