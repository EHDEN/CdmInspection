-- Unmapped observations

SELECT *
FROM (
	select ROW_NUMBER() OVER(ORDER BY count_big(observation_id) DESC) AS ROW_NUM,
       observation_source_value as "Source Value",
       floor((count_big(observation_id)+99)/100)*100 as "#Records",
       floor((count_big(distinct person_id)+99)/100)*100 as "#Subjects"
       from @cdmDatabaseSchema.observation where observation_concept_id = 0
group by observation_source_value
having count_big(observation_id)>@smallCellCount
) z
WHERE z.ROW_NUM <= 25
ORDER BY z.ROW_NUM
