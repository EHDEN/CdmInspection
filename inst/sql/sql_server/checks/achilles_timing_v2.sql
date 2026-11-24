-- Retrieve timings from the Achilles performance table.

SELECT
    CA.analysis_id AS id,
    CA.analysis_name AS name,
    AP.elapsed_seconds AS duration
FROM @resultsDatabaseSchema.achilles_performance AP
JOIN @resultsDatabaseSchema.achilles_analysis CA
    ON CA.analysis_id = AP.analysis_id
ORDER BY CA.analysis_id;
