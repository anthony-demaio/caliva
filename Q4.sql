  /*
 * Question 4
 * Among all posts with more than 1 answer, what are the top 1000 words used in the title?
 */
WITH
  words_in_title_array AS (
  SELECT
    id,
    SPLIT(title," ") AS word
  FROM
    `seismic-sweep-264823`.stackoverflow_caliva.posts_questions
  WHERE
    answer_count > 1 )
,
  individual_words AS (
  SELECT
    id,
    word
  FROM
    words_in_title_array
  CROSS JOIN
    UNNEST(words_in_title_array.word) AS word )
SELECT
  word,
  COUNT(*) cnt
FROM
  individual_words
GROUP BY
  word
ORDER BY
  cnt DESC
LIMIT
  1000;