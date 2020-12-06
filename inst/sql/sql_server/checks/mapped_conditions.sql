-- top 25 mapped conditions

select top 25
       Cr.concept_name as "Concept Name",
       ceiling(count_big(condition_occurrence_id)/100)*100 as "#Records",
       ceiling(count_big(distinct person_id)/100)*100 as "#Subjects"
       from @cdmDatabaseSchema.condition_occurrence C
JOIN @vocabDatabaseSchema.CONCEPT CR
ON C.condition_concept_id = CR.CONCEPT_ID
where c. condition_concept_id != 0
group by CR.concept_name
having count_big(condition_occurrence_id)>10
order by count_big(condition_occurrence_id) DESC
