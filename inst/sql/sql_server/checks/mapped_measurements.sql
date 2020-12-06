-- top 25 mapped devices

select top 25
       Cr.concept_name as "Concept Name",
       ceiling(count_big(measurement_id)/100)*100 as "#Records",
       ceiling(count_big(distinct person_id)/100)*100 as "#Subjects"
       from @cdmDatabaseSchema.measurement C
JOIN @vocabDatabaseSchema.CONCEPT CR
ON C.measurement_concept_id = CR.CONCEPT_ID
where c. measurement_concept_id != 0
group by CR.concept_name
having count_big(measurement_id)>10
order by count_big(measuremente_id) DESC
