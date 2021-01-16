-- Unmapped procedures

SELECT *
FROM (
	select ROW_NUMBER() OVER(ORDER BY count_big(procedure_occurrence_id) DESC) AS ROW_NUM,
       procedure_source_value as "Source Value",
       floor((count_big(procedure_occurrence_id)+99)/100)*100 as "#Records",
       floor((count_big(distinct person_id)+99)/100)*100 as "#Subjects"
       from @cdmDatabaseSchema.procedure_occurrence where procedure_concept_id = 0
group by procedure_source_value
having count_big(procedure_occurrence_id)>@smallCellCount
) z
WHERE z.ROW_NUM <= 25
ORDER BY z.ROW_NUM
