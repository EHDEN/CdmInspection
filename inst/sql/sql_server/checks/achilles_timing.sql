-- get the timings of all the queries of the catalogue_export
SELECT CA.analysis_id as id,
       CA.analysis_name as name,
       CR.stratum_1 as duration
FROM @resultsDatabaseSchema.achilles_results CR
JOIN @resultsDatabaseSchema.achilles_analysis CA
ON CA.analysis_id = (CR.analysis_id-2000000)
