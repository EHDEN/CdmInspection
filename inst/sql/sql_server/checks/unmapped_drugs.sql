--Unmapped drugs

select top 25 drug_source_value as "Source Value",
       count_big(drug_exposure_id) as "#Records",
       count_big(distinct person_id) as "#Subjects"
       from @cdmDatabaseSchema.drug_exposure where drug_concept_id = 0
group by drug_source_value
having count_big(drug_exposure_id)>10
order by count_big(drug_exposure_id) DESC
