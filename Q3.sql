/*
What are the ten “hardest” badges to earn on average?
Measured by the time between a user account being created and the most recently received badge, where that badge is not one of the first 5 badges that the user earned and the account is over 1 year old with more than 10 answers.
*/

SELECT badge_name AS First_Gold_Badge, 
       COUNT(1) AS Num_Users,
       ROUND(AVG(tenure_in_days)) AS Avg_Num_Days
FROM
(
  SELECT 
    badges.user_id AS user_id,
    badges.name AS badge_name,
    TIMESTAMP_DIFF(badges.date, users.creation_date, DAY) AS tenure_in_days,
    ROW_NUMBER() OVER (PARTITION BY badges.user_id
                       ORDER BY badges.date) AS row_number
  FROM 
    `bigquery-public-data.stackoverflow.badges` badges
  JOIN
    `bigquery-public-data.stackoverflow.users` users
  ON badges.user_id = users.id
  WHERE badges.class = 1
) 
WHERE tenure_in_days>365  and row_number >5
GROUP BY First_Gold_Badge
ORDER BY Num_Users ASC
LIMIT 10