/*
 * Question 7
How many days, on average, pass between a single user posting an answer to any question?
 *  
 * Answer
 * 36 days.
 */

with days_between as (
select
	id,
	owner_user_id,
	creation_date,
	lag(creation_date,
	1) over(partition by owner_user_id
order by
	creation_date ) prior_answer_date
from
	`seismic-sweep-264823`.stackoverflow_caliva.posts_answers
)
select 
avg(date_diff(cast( creation_date as date), cast(prior_answer_date as date), DAY )) days_between
from 
days_between