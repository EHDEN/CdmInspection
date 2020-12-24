-- query benchmark check

SELECT COUNT(*)
FROM @vocabDatabaseSchema.CONCEPT C
        JOIN @vocabDatabaseSchema.CONCEPT_RELATIONSHIP CR
                ON C.CONCEPT_ID = CR.CONCEPT_ID_1
                AND CR.invalid_reason IS NULL
                AND cr.relationship_id = 'Maps to'
        JOIN @vocabDatabaseSchema.CONCEPT C1
                ON CR.CONCEPT_ID_2 = C1.CONCEPT_ID
                AND C1.INVALID_REASON IS NULL
