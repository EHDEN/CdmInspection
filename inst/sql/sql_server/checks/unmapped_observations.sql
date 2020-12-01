-- Unmapped observations

select top 25
       observation_source_value as "Source Value",
       count_big(observation_id) as "#Records",
       count_big(distinct person_id) as "#Subjects"
       from @cdmDatabaseSchema.observation where observation_concept_id = 0
group by observation_source_value
having count_big(observation_id)>10
order by count_big(observation_id) DESC
