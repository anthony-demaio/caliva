/*
 * Question 5
 * Among the 10,000 most viewed questions, what on average is the number of days between the original question being created and being edited? Treat null edit dates as 0.
 * 
 * Answer
 * For the 10,000 most viewed questions, the average days between creation and edit are 1,779.37.
 */
with most_views as
(
SELECT
	id,
	creation_date,
	last_edit_date,
	case when last_edit_date is null then 0 else date_diff(CAST(last_edit_date as DATE), cast(creation_date as DATE), DAY) end as days_between_creation_and_edit,
	sum(view_count) total_views
FROM
	`seismic-sweep-264823`.stackoverflow_caliva.posts_questions
group by 
id,
creation_date,
last_edit_date
order by total_views desc
limit 10000
)
select 
avg(days_between_creation_and_edit) avg_days_between_edits 
from most_views
;