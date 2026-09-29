-- Postgre since DATE_TRUNC dialect
WITH monthly_purchases AS (
  SELECT DATE_TRUNC('MONTH', created_at) AS month_start, SUM(value) AS total_purchases
  FROM sf_transactions
  GROUP BY month_start
),
monthly_perc_changes AS (
  SELECT
    LEFT(CAST(month_start AS text), 7) AS year_month,
    ROUND(100.0 * (total_purchases - LAG(total_purchases) OVER(ORDER BY month_start)) / NULLIF(LAG(total_purchases) OVER(ORDER BY month_start), 0), 2) AS perc_change
    FROM monthly_purchases
)
SELECT * FROM monthly_perc_changes;
