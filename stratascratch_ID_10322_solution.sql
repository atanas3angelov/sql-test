-- Postgre since using "-" for date arithmetics
-- ignore same day purchases
WITH unique_user_date_purchases AS (
  SELECT DISTINCT user_id,
  CAST(created_at AS DATE) AS purchase_date
  FROM amazon_transactions
),
-- rank purchases made by each user so that 1st and 2nd purchase can be identified
ranked_user_purchases AS (
  SELECT *, ROW_NUMBER() OVER ( PARTITION BY user_id ORDER BY purchase_date) AS rn
  FROM unique_user_date_purchases
),
-- filter purchases made by each user so that only 1st and 2nd purchase remains
first_second_purchases AS (
  SELECT *
  FROM ranked_user_purchases
  WHERE rn BETWEEN 1 AND 2
),
-- calculate days passed since 1st purchase (NULL for 1st one) since LAG() can't be used in WHERE clause
days_passed_since_last_purchase AS (
  SELECT user_id, purchase_date - LAG(purchase_date) OVER(PARTITION BY user_id ORDER BY purchase_date) AS days_passed_since_last_purchase
  FROM first_second_purchases
)
-- select only users who made a 2nd purchase in 1 to 7 days since 1st one (NULLs are filtered out as well)
SELECT user_id
FROM days_passed_since_last_purchase
WHERE days_passed_since_last_purchase BETWEEN 1 AND 7;