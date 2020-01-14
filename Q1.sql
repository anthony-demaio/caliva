/*
 * Question 1
 * Is a more verbose description more likely to be answered?
 * 
 * Answer
 * Generally no. Based on the correlation of description length to total answers, it seems that for every additional character typed into a description, the question would receive 0.0287 fewer answers.
 *What is the correlation (r^2) of the number of words (or letters) used in a description versus the number of answers
*it gets, divided into quantiles?
*Across the set of data queried, as defined by the WHERE predicate below, the pearson correlation coefficient (R) is -0.0287; whereas the R^2 is 0.001, indicating the length of description does a poor job of explaining the variability in the number of answers per questions.  The breakdown of both R and R^2 across the data broken into six quantiles is as follows: 
*quantile	pearson_correlation_coefficient	R_squared
q1_up_to_percentile10	0.068	0.0047
q2_up_to_percentile25	0.026	0.0007
q3_up_to_percentile50	0.023	0.0005
q4_up_to_percentile75	-0.018	0.0003
q5_up_to_percentile90	-0.020	0.0004
q6_up_to_max	        -0.027	0.0007

The pattern which clearly emerges is a decrease in number of answers as the length of the description becomes longer than the median length, to an increasingly sever degree as the descriptions approach the maximum length.
 * 
 */with answers_by_length as
(
SELECT
	id,
	SUM(cast(length(body) as NUMERIC)) description_length,
	countif(accepted_answer_id is not null) accepted_answer_count,
	countif(accepted_answer_id is  null) No_accepted_answer_count,
	sum(answer_count) total_answers
FROM
	`seismic-sweep-264823`.stackoverflow_caliva.posts_questions
where creation_date >= '2019-08-01'
group by
id
order by id
LIMIT 50000
)
,
stats as (
select
	distinct *
from
	(
	select
		AVG(description_length) over() average,
		STDDEV_POP(description_length) over() standard_deviation,
		PERCENTILE_CONT(description_length, 0) over() AS min,
		PERCENTILE_CONT(description_length, 0.1) OVER() AS percentile10,
		PERCENTILE_CONT(description_length, 0.25) OVER() AS percentile25,
		PERCENTILE_CONT(description_length, 0.5) OVER() AS median,
		PERCENTILE_CONT(description_length, 0.75) OVER() AS percentile75,
		PERCENTILE_CONT(description_length, 0.9) OVER() AS percentile90,
		PERCENTILE_CONT(description_length, 1) over() AS max
	from
		answers_by_length ) 
	)
--select * from stats;
/*
 * The query below returns the R and R^2 values, used to determine the correlation between length of description and answer count per question
 * 
select
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared,
from
answers_by_length;
*/
	
/*
 * The query below calculates the R and R^2 values for each of six quantiles the data set is broken into.
 */
select
'q1_up_to_percentile10' as quantile,
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared,
from
answers_by_length, stats
where 
description_length >= min and description_length <= percentile10
union all
select
'q2_up_to_percentile25' as quantile,
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared,
from
answers_by_length, stats
where 
description_length > percentile10 and description_length <= percentile25
union all 
select
'q3_up_to_percentile50' as quantile,
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared,
from
answers_by_length, stats
where 
description_length > percentile25 and description_length <= median
union all 
select
'q4_up_to_percentile75' as quantile,
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared,
from
answers_by_length, stats
where 
description_length > median and description_length <= percentile75
union all 
select
'q5_up_to_percentile90' as quantile,
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared,
from
answers_by_length, stats
where 
description_length > percentile75 and description_length <= percentile90
union all 
select
'q6_up_to_max' as quantile,
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared,
from
answers_by_length, stats
where 
description_length > percentile90 and description_length <= max
order by quantile;


-----
SELECT
sum(if((description_length >= min and description_length <= percentile10),total_answers,0)) q1_up_to_percentile10,
sum(if((description_length > percentile10 and description_length <= percentile25),total_answers,0)) q2_up_to_percentile25,
sum(if((description_length > percentile25 and description_length <= median),total_answers,0)) q3_up_to_percentile50,
sum(if((description_length > median and description_length <= percentile75),total_answers,0)) q4_up_to_percentile75,
sum(if((description_length > percentile75 and description_length <= percentile90),total_answers,0)) q5_up_to_percentile90,
sum(if((description_length > percentile90 and description_length <= max),total_answers,0)) q6_up_to_max
from 
answers_by_length,
stats
;

SELECT
	COUNT(id)
FROM
	`seismic-sweep-264823`.stackoverflow_caliva.posts_questions;