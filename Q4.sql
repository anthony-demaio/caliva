/**
 * Question 4
 * Among all posts with more than 1 answer, what are the top 1000 words used in the title?
 * 
 */


with words_in_title as
(
SELECT
	id,
	split(title," ") as word
FROM
`seismic-sweep-264823`.stackoverflow_caliva.posts_questions
where creation_date >= '2019-08-01' and answer_count > 1
order by id
LIMIT 50000
)
select 
id, word
from words_in_title 
cross join UNNEST(words_in_title.word) as word;

select 
words,
count(*)
from words_in_title
group by words