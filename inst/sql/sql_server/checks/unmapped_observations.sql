-- Unmapped observations

select top 25
       observation_source_value as "Source Value",
       count(observation_id) as "#Records",
       count(distinct person_id) as "#Subjects"
       from @cdmDatabaseSchema.observation where observation_concept_id = 0
group by observation_source_value
having count(observation_id)>10
order by count(observation_id) DESC
