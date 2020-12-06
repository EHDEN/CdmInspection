-- top 25 mapped devices

select top 25
       Cr.concept_name as "Concept Name",
       ceiling(count_big(procedure_occurrence_id)/100)*100 as "#Records",
       ceiling(count_big(distinct person_id)/100)*100 as "#Subjects"
       from @cdmDatabaseSchema.procedure_occurrence C
JOIN @vocabDatabaseSchema.CONCEPT CR
ON C.procedure_concept_id = CR.CONCEPT_ID
where c. procedure_concept_id != 0
group by CR.concept_name
having count_big(procedure_occurrence_id)>10
order by count_big(procedure_occurrence_id) DESC