-- top 25 mapped devices

select top 25
       Cr.concept_name as "Concept Name",
       ceiling(count_big(device_expore_idd)/100)*100 as "#Records",
       ceiling(count_big(distinct person_id)/100)*100 as "#Subjects"
       from @cdmDatabaseSchema.device_exposure C
JOIN @vocabDatabaseSchema.CONCEPT CR
ON C.device_concept_id = CR.CONCEPT_ID
where c. device_concept_id != 0
group by CR.concept_name
having count_big(device_expore_id)>10
order by count_big(device_expore_id) DESC
