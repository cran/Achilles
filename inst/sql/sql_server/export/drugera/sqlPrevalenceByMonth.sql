select c1.concept_id as concept_id,
	num.stratum_2 as x_calendar_month,
	round(1000*(1.0*num.count_value/denom.count_value),5) as y_prevalence_1000pp
from 
	(select CAST(stratum_1 as bigint) stratum_1, CAST(stratum_2 as bigint) stratum_2, count_value from @results_database_schema.achilles_results where analysis_id = 902 GROUP BY analysis_id, stratum_1, stratum_2, count_value) num
	inner join
	(select CAST(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 117 GROUP BY analysis_id, stratum_1, count_value) denom
	on num.stratum_2 = denom.stratum_1  
	inner join @vocab_database_schema.concept c1 on num.stratum_1 = c1.concept_id
