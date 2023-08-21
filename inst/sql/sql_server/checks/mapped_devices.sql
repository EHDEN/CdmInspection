-- top 25 mapped devices

SELECT *
FROM (
	select ROW_NUMBER() OVER(ORDER BY count_big(device_exposure_id) DESC) AS ROW_NUM,
       Cr.concept_name as concept_name,
       floor((count_big(device_exposure_id)+99)/100)*100 as n_records,
       floor((count_big(distinct person_id)+99)/100)*100 as n_subjects
       from @cdmDatabaseSchema.device_exposure C
JOIN @vocabDatabaseSchema.CONCEPT CR
ON C.device_concept_id = CR.CONCEPT_ID
where c. device_concept_id != 0
group by CR.concept_name
having count_big(device_exposure_id)>@smallCellCount
) z
WHERE z.ROW_NUM <= 25
ORDER BY z.ROW_NUM
