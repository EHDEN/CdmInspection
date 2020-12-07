-- overview of vocabulary table

select vocabulary.vocabulary_id                                  as id,
       vocabulary.vocabulary_name                                as name,
       vocabulary.vocabulary_version                             as version,
       sum(case standard_concept when 'S' then 1 else 0 end)     as num_standard,
       sum(case standard_concept when 'C' then 1 else 0 end)     as num_classification,
       sum(case standard_concept when ''  then 1 else 0 end)     as num_non_standard
from @vocabDatabaseSchema.vocabulary
left join @vocabDatabaseSchema.concept
    on concept.vocabulary_id = vocabulary.vocabulary_id
group by vocabulary.vocabulary_id, vocabulary.vocabulary_name, vocabulary.vocabulary_version
order by vocabulary.vocabulary_id
;