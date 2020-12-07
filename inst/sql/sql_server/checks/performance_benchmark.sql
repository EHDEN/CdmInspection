-- query benchmark check

SELECT COUNT(*)
FROM @cdmDatabaseSchema.CONCEPT C
        JOIN @cdmDatabaseSchema.CONCEPT_RELATIONSHIP CR
                ON C.CONCEPT_ID = CR.CONCEPT_ID_1
                AND CR.invalid_reason IS NULL
                AND cr.relationship_id = 'Maps to'
        JOIN @cdmDatabaseSchema.CONCEPT C1
                ON CR.CONCEPT_ID_2 = C1.CONCEPT_ID
                AND C1.INVALID_REASON IS NULL
