select c1.concept_id as concept_id, 
  c1.concept_name as concept_name, 
	ar1.count_value as count_value
from (
  select cast(stratum_1 as bigint) stratum_1, count_value
  from @results_database_schema.achilles_results
  where analysis_id = 4
  GROUP BY analysis_id, stratum_1, count_value
) ar1
inner join @vocab_database_schema.concept c1 on ar1.stratum_1 = c1.concept_id
