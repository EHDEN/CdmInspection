-- count on vocabulary tables check

select 'concept' as tablename, count(*) as count from @vocabDatabaseSchema.concept
UNION
select 'concept_ancestor' as tablename, count(*) as count from @vocabDatabaseSchema.concept_ancestor
UNION
select 'concept_class' as tablename, count(*) as count from @vocabDatabaseSchema.concept_class
UNION
select 'concept_relationship' as tablename, count(*) as count from @vocabDatabaseSchema.concept_relationship
UNION
select 'concept_synonym' as tablename, count(*) as count from @vocabDatabaseSchema.concept_synonym
UNION
select 'domain' as tablename, count(*) as count from @vocabDatabaseSchema.domain
UNION
select 'drug_strength' as tablename, count(*) as count from @vocabDatabaseSchema.drug_strength
UNION
select 'vocabulary' as tablename, count(*) as count from @vocabDatabaseSchema.vocabulary
