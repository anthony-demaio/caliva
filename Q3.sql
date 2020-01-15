/*
*  Question 3
What are the ten “hardest” badges to earn on average?
Measured by the time between a user account being created and the most recently received badge, where that badge is not one of the first 5 badges that the user earned and the account is over 1 year old with more than 10 answers.
*/
select
badge_name,
avg(days_between_account_creation_and_Latest_badge) day_to_achieve
from (
SELECT
  badges.user_id AS user_id,
  users.display_name,
  badges.name AS badge_name,
  TIMESTAMP_DIFF(badges.date, users.creation_date, DAY) AS days_between_badges,
  TIMESTAMP_DIFF(MAX(badges.date) OVER(PARTITION BY badges.user_id), users.creation_date, DAY) AS days_between_account_creation_and_Latest_badge,
  ROW_NUMBER() OVER (PARTITION BY badges.user_id ORDER BY badges.date) AS row_number
FROM
  `bigquery-public-data.stackoverflow.badges` badges
JOIN
  `bigquery-public-data.stackoverflow.users` users
ON
  badges.user_id = users.id
WHERE
  TIMESTAMP_DIFF(CURRENT_TIMESTAMP, users.creation_date, DAY) > 365
  AND users.id IN (
  SELECT
    user_id
  FROM (
    SELECT
      answers.owner_user_id as user_id,
      COUNT(answers.id) answer_cnt
    FROM
      `seismic-sweep-264823`.stackoverflow_caliva.posts_answers answers
    GROUP BY
      answers.owner_user_id)
  WHERE
    answer_cnt>10)  
)
where row_number > 5
group by badge_name
order by day_to_achieve desc
limit 10