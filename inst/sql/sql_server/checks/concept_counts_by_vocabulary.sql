-- overview of vocabulary table
-- S=Standard concepts
-- C=Classification concepts
-- '-'=Non-standard and non-classification. Can be represented by empty string or null in the database.

select vocabulary.vocabulary_id                                  as id,
       vocabulary.vocabulary_name                                as name,
       vocabulary.vocabulary_version                             as version,
       sum(case standard_concept when 'S' then 1 else 0 end)     as n_standard_concepts,
       sum(case standard_concept when 'C' then 1 else 0 end)     as n_classification_concepts,
       sum(case when standard_concept = '' OR standard_concept IS NULL  then 1 else 0 end) as n_non_standard_concepts
from @vocabDatabaseSchema.vocabulary
left join @vocabDatabaseSchema.concept
    on concept.vocabulary_id = vocabulary.vocabulary_id
group by vocabulary.vocabulary_id, vocabulary.vocabulary_name, vocabulary.vocabulary_version
order by vocabulary.vocabulary_id
;
