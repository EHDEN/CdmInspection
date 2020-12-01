-- source_to_concept_map

select source_vocabulary_id, target_vocabulary_id, count(*) as count from @cdmDatabaseSchema.source_to_concept_map group by source_vocabulary_id, target_vocabulary_id
