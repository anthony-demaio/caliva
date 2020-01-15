/*
 * Question 1
 * Is a more verbose description more likely to be answered?
 * 
 * Answer
 * No—a more verbose description is not more likely to be answered. Based on the correlation of description length to total answers overall, for every additional character typed into a description, the question would receive 0.0731 fewer answers.
 *What is the correlation (r^2) of the number of words (or letters) used in a description versus the number of answers
*it gets, divided into quantiles? 
*Across the set of data queried, the pearson correlation coefficient (R) is -0.0731; whereas the R^2 (coefficient of determination) is 0.0053, indicating the length of description does a poor job of explaining the variability (only half a percent) in the number of answers per questions.  

The breakdown of several statistics:
  —min_description_length_of_quantile
  —avg_description_length_of_quantile
  —max_description_length_of_quantile
  —pearson_correlation_coefficient
  —R_squared
  —answers_per_quantile
  —percent_of_total_answers

Across the data broken into six quantiles is as follows:

quantile	min_description_length_of_quantile	avg_description_length_of_quantile	max_description_length_of_quantile	pearson_correlation_coefficient	R_squared	answers_per_quantile
q1_up_to_percentile10	17	233	328	-0.0591	0.0035	3,218,337
q2_percentile10_up_to_percentile25	329	439	545	-0.0102	0.0001	4,497,778
q3_percentile25_up_to_median	546	737	952	-0.0171	0.0003	7,205,836
q4_median_up_to_percentile75	953	1,273	1,700	-0.0263	0.0007	6,736,176
q5_percentile75_up_to_percentile90	1,701	2,212	2,990	-0.0246	0.0006	3,722,126
q6_percentile90_up_to_max	2,991	5,684	58,431	-0.0244	0.0006	2,284,756

Descriptions of a length falling into the third quantile, from 546 characters to 952 character (description lengths falling between the 25th percentile and the median (or 50th percentile)), received the greatest percentage of all answers. Broadly, the sweet spot for description length is between the second and fourth quantiles—just long enough, but not too long a description. Those three, of six, quantiles account for 67% of all answers.
 * 
 */
with answers_by_length as
(
SELECT
	id,
	SUM(cast(length(body) as NUMERIC)) description_length,
	sum(answer_count) total_answers
FROM
	`seismic-sweep-264823`.stackoverflow_caliva.posts_questions
--where creation_date >= '2019-08-01'
group by
id
--order by id
--LIMIT 50000
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
/*
 * The query below returns the R and R^2 values across all data, used to determine the correlation between length of description and answer count per question.
 */
 --
/*
select
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared,
from
answers_by_length;
*/
--
/*
 * The query below calculates statistics for each of six quantiles the data set is broken into.
 */
,
quantile_stats as (
select
'q1_up_to_percentile10' as quantile,
min(description_length) as min_description_length_of_quantile,
avg(description_length) as avg_description_length_of_quantile,
max(description_length) as max_description_length_of_quantile,
sum(total_answers) answers_per_quantile,
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared
from
answers_by_length, stats
where 
description_length >= min and description_length <= percentile10
union all
select
'q2_percentile10_up_to_percentile25' as quantile,
min(description_length) as min_description_length_of_quantile,
avg(description_length) as avg_description_length_of_quantile,
max(description_length) as max_description_length_of_quantile,
sum(total_answers) answers_per_quantile,
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared
from
answers_by_length, stats
where 
description_length > percentile10 and description_length <= percentile25
union all 
select
'q3_percentile25_up_to_median' as quantile,
min(description_length) as min_description_length_of_quantile,
avg(description_length) as avg_description_length_of_quantile,
max(description_length) as max_description_length_of_quantile,
sum(total_answers) answers_per_quantile,
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared
from
answers_by_length, stats
where 
description_length > percentile25 and description_length <= median
union all 
select
'q4_median_up_to_percentile75' as quantile,
min(description_length) as min_description_length_of_quantile,
avg(description_length) as avg_description_length_of_quantile,
max(description_length) as max_description_length_of_quantile,
sum(total_answers) answers_per_quantile,
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared
from
answers_by_length, stats
where 
description_length > median and description_length <= percentile75
union all 
select
'q5_percentile75_up_to_percentile90' as quantile,
min(description_length) as min_description_length_of_quantile,
avg(description_length) as avg_description_length_of_quantile,
max(description_length) as max_description_length_of_quantile,
sum(total_answers) answers_per_quantile,
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared
from
answers_by_length, stats
where 
description_length > percentile75 and description_length <= percentile90
union all 
select
'q6_percentile90_up_to_max' as quantile,
min(description_length) as min_description_length_of_quantile,
avg(description_length) as avg_description_length_of_quantile,
max(description_length) as max_description_length_of_quantile,
sum(total_answers) answers_per_quantile,
CORR(total_answers, description_length) pearson_correlation_coefficient,
POW(CORR(total_answers, description_length),2) R_squared
from
answers_by_length, stats
where 
description_length > percentile90 and description_length <= max
)
select
quantile,
min_description_length_of_quantile,
avg_description_length_of_quantile,
max_description_length_of_quantile,
pearson_correlation_coefficient, R_squared, answers_per_quantile,
answers_per_quantile * 1.0 / (select sum(total_answers) from answers_by_length) as percent_of_total_answers
from
quantile_stats
order by quantile;