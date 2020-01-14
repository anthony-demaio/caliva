/*
 * Question 2
 * 
 * Is a more concise title more likely to be viewed?
 * Measured by the number of letters in the title vs the views.
 * 
 * Answer
 * Yes, the correlation between the length of the title and the number of views is negative, meaning that a reduction in the length of the title is associated with an increase in the number of views. For every character length the title is reduced, one can expect 0.0017 more views.
*/
with views_by_length as
(
SELECT
	id,
	SUM(cast(length(title) as NUMERIC)) title_length,
	sum(view_count) total_views
FROM
	`seismic-sweep-264823`.stackoverflow_caliva.posts_questions
where creation_date >= '2019-08-01'
group by
id
order by id
LIMIT 50000
)
select
CORR(total_views, title_length) pearson_correlation_coefficient,
POW(CORR(total_views, title_length),2) R_squared,
from
views_by_length;