--Unmapped conditions

select top 25
       condition_source_value as "Source Value",
       count(condition_occurrence_id) as "#Records",
       count(distinct person_id) as "#Subjects"
       from @cdmDatabaseSchema.condition_occurrence where condition_concept_id = 0
group by condition_source_value
having count(condition_occurrence_id)>10
order by count(condition_occurrence_id) DESC
