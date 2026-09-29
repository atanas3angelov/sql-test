-- Postgre since DATE_TRUNC dialect
WITH monthly_purchases AS (
  SELECT DATE_TRUNC('MONTH', created_at) AS month, SUM(value) AS total_purchases
  FROM sf_transactions
  GROUP BY DATE_TRUNC('MONTH', created_at)
),
monthly_perc_changes AS (
  SELECT
    LEFT(CAST(month AS text), 7) AS year_month,
    100.0 * (total_purchases - LAG(total_purchases) OVER(ORDER BY month)) / NULLIF(LAG(total_purchases) OVER(ORDER BY month), 0) AS perc_change
    FROM monthly_purchases
)
SELECT * FROM monthly_perc_changes;
