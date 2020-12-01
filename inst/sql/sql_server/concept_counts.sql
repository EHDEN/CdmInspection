-- overview of concept table

select vocabulary_id, standard_concept, count(*) from synpuf.concept group by vocabulary_id, standard_concept
