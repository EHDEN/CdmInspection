-- overview of concept table

select vocabulary_id as id, standard_concept as standard, count(*) as count
from synpuf.concept
group by vocabulary_id, standard_concept
order by vocabulary_id
