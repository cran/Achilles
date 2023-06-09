-- 220	Number of visit occurrence records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	YEAR(vo.visit_start_date) * 100 + MONTH(vo.visit_start_date) AS stratum_1,
	COUNT_BIG(vo.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.visit_occurrence vo
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	vo.person_id = op.person_id
AND 
	vo.visit_start_date >= op.observation_period_start_date
AND 
	vo.visit_start_date <= op.observation_period_end_date
GROUP BY 
	YEAR(vo.visit_start_date) * 100 + MONTH(vo.visit_start_date)
)
SELECT
	220 AS analysis_id,
	CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_220
FROM 
	rawData;
