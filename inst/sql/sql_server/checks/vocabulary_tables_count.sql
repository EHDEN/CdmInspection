-- count on vocabulary tables check

select 'concept' as tablename, count(*) as count from @cdmDatabaseSchema.concept
UNION
select 'concept_ancestor' as tablename, count(*) as count from @cdmDatabaseSchema.concept_ancestor
UNION
select 'concept_class' as tablename, count(*) as count from @cdmDatabaseSchema.concept_class
UNION
select 'concept_relationship' as tablename, count(*) as count from @cdmDatabaseSchema.concept_relationship
UNION
select 'concept_synonym' as tablename, count(*) as count from @cdmDatabaseSchema.concept_synonym
UNION
select 'domain' as tablename, count(*) as count from @cdmDatabaseSchema.domain
UNION
select 'drug_strength' as tablename, count(*) as count from @cdmDatabaseSchema.drug_strength
UNION
select 'vocabulary' as tablename, count(*) as count from @cdmDatabaseSchema.vocabulary
