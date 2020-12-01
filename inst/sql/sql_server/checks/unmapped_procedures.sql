-- Unmapped procedures

select top 25
       procedure_source_value as "Source Value",
       count_big(procedure_occurrence_id) as "#Records",
       count_big(distinct person_id) as "#Subjects"
       from @cdmDatabaseSchema.procedure_occurrence where procedure_concept_id = 0
group by procedure_source_value
having count_big(procedure_occurrence_id)>10
order by count_big(procedure_occurrence_id) DESC
