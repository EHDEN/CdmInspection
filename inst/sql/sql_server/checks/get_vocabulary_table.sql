-- Extraction of cdm_source table

select vocabulary_id as Id,
       vocabulary_name as Name,
       vocabulary_version as Version
from @vocabDatabaseSchema.vocabulary
