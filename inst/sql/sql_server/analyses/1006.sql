-- 1006	Distribution of age by condition_concept_id

--HINT DISTRIBUTE_ON_KEY(subject_id)
SELECT 
	ce.condition_concept_id AS subject_id,
	p.gender_concept_id,
	ce.condition_start_year - p.year_of_birth AS count_value
INTO 
	#rawData_1006
FROM 
	@cdmDatabaseSchema.person p
JOIN (
	SELECT 
		ce.person_id,
		ce.condition_concept_id,
		MIN(YEAR(ce.condition_era_start_date)) AS condition_start_year
	FROM 
		@cdmDatabaseSchema.condition_era ce
	JOIN 
		@cdmDatabaseSchema.observation_period op 
	ON 
		ce.person_id = op.person_id
	AND 
		ce.condition_era_start_date >= op.observation_period_start_date
	AND 
		ce.condition_era_start_date <= op.observation_period_end_date			
	GROUP BY 
		ce.person_id,
		ce.condition_concept_id
	) ce 
ON 
	p.person_id = ce.person_id
;

--HINT DISTRIBUTE_ON_KEY(stratum1_id)
with overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select subject_id as stratum1_id,
    gender_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_1006
	group by subject_id, gender_concept_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  select subject_id as stratum1_id, gender_concept_id as stratum2_id, count_value, count_big(*) as total, row_number() over (partition by subject_id, gender_concept_id order by count_value) as rn
  FROM #rawData_1006
  group by subject_id, gender_concept_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 1006 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults_1006
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select analysis_id, stratum1_id as stratum_1, stratum2_id as stratum_2, 
cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_1006
from #tempResults_1006
;

truncate table #rawData_1006;
drop table #rawData_1006;

truncate table #tempResults_1006;
drop table #tempResults_1006;
