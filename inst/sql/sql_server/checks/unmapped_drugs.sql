--Unmapped drugs

SELECT *
FROM (
	select ROW_NUMBER() OVER(ORDER BY count_big(drug_exposure_id) DESC) AS ROW_NUM,
       drug_source_value as "Source Value",
       count_big(drug_exposure_id) as "#Records",
       count_big(distinct person_id) as "#Subjects"
       from @cdmDatabaseSchema.drug_exposure where drug_concept_id = 0
group by drug_source_value
having count_big(drug_exposure_id)>10
) z
WHERE z.ROW_NUM <= 25
ORDER BY z.ROW_NUM
