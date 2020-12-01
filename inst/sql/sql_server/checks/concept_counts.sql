-- overview of concept table

select vocabulary_id as id, standard_concept as standard, count_big(*) as count
from @vocabDatabaseSchema.concept
group by vocabulary_id, standard_concept
order by vocabulary_id
