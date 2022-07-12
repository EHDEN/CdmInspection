-- Top 25 mapped visits

SELECT *
FROM (
	select ROW_NUMBER() OVER(ORDER BY count_big(*) DESC) AS ROW_NUM,
       Cr.concept_name as "Concept Name",
       floor((count_big(*)+99)/100)*100 as "#Records",
       floor((count_big(distinct person_id)+99)/100)*100 as "#Subjects"
       from @cdmDatabaseSchema.visit_occurrence C
  JOIN @vocabDatabaseSchema.CONCEPT CR
    ON C.visit_occurrence_concept_id = CR.CONCEPT_ID
  where c.visit_occurrence_concept_id != 0
  group by CR.concept_name
  having count_big(*)>@smallCellCount
) z
WHERE z.ROW_NUM <= 25
ORDER BY z.ROW_NUM
