--Unmapped conditions

SELECT *
FROM (
	select ROW_NUMBER() OVER(ORDER BY count_big(condition_occurrence_id) DESC) AS ROW_NUM,
       condition_source_value as "Source Value",
       count_big(condition_occurrence_id) as "#Records",
       count_big(distinct person_id) as "#Subjects"
       from @cdmDatabaseSchema.condition_occurrence where condition_concept_id = 0
group by condition_source_value
having count_big(condition_occurrence_id)>10
) z
WHERE z.ROW_NUM <= 25
ORDER BY z.ROW_NUM
