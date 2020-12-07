-- source_to_concept_map

select source_vocabulary_id, target_vocabulary_id, count_big(*) as count from @vocabDatabaseSchema.source_to_concept_map
group by source_vocabulary_id, target_vocabulary_id
order by source_vocabulary_id, target_vocabulary_id
