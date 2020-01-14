/*
 * Question 6
 * What are the titles of the 1000 most viewed questions and how many times have each of those questions been answered?
 *  
 * Answer
 * Run query to see answer set.
 * 
 */

SELECT
	title,
	sum(view_count) total_views,
	sum(answer_count) total_answers,
FROM
`seismic-sweep-264823`.stackoverflow_caliva.posts_questions
group by 
title
order by total_views desc
limit 1000