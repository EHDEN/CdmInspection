-- Top 25 unmapped visita

SELECT *
FROM (
	select ROW_NUMBER() OVER(ORDER BY count_big(*) DESC) AS ROW_NUM,
       visit_source_value as source_value,
       floor((count_big(*)+99)/100)*100 as n_records,
       floor((count_big(distinct person_id)+99)/100)*100 as n_subjects
  from @cdmDatabaseSchema.visit_occurrence
  where visit_concept_id = 0
  group by visit_source_value
  having count_big(*)>@smallCellCount
) z
WHERE z.ROW_NUM <= 25
ORDER BY z.ROW_NUM
